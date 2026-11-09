<#
Installs the WorkCtx wiki and skills into a code repo, for both Codex and Claude Code.
Everything it writes stays local: ignore rules go to .git/info/exclude, never to the tracked .gitignore.

  ./install.ps1 -RepoPath E:\repos\MyApp -Project MyApp -TicketPattern '\bABC-\d+\b' `
                -TicketExample ABC-123 -JiraBaseUrl https://myco.atlassian.net/browse

Run again with -Update to refresh skills, templates and the hook from this repo (feature pages and tickets are never touched).
#>
param(
    [Parameter(Mandatory)] [string] $RepoPath,
    [Parameter(Mandatory)] [string] $Project,
    [string] $TicketPattern = '',
    [string] $TicketExample = 'ABC-123',
    [string] $JiraBaseUrl = '',
    [string] $MasterRef = 'origin/master',
    [switch] $Update
)
$ErrorActionPreference = 'Stop'
$template = Join-Path $PSScriptRoot 'template'
$repo = (Resolve-Path $RepoPath).Path
$wiki = Join-Path $repo 'wiki'
$skills = 'start', 'plan', 'learn', 'review'

function Fill([string] $path) {
    $text = [IO.File]::ReadAllText($path)
    $text = $text.Replace('{{PROJECT}}', $Project).Replace('{{TICKET_PATTERN}}', $TicketPattern).
        Replace('{{TICKET_EXAMPLE}}', $TicketExample).Replace('{{JIRA_BASE_URL}}', $JiraBaseUrl).Replace('{{MASTER_REF}}', $MasterRef)
    [IO.File]::WriteAllText($path, $text)
}

function IsTracked([string] $relative) {
    git -C $repo ls-files --error-unmatch $relative 2>$null | Out-Null
    return $LASTEXITCODE -eq 0
}

# 1. Wiki skeleton (new install) or refresh of the shared parts (-Update).
if (-not (Test-Path $wiki)) {
    Copy-Item (Join-Path $template 'wiki') $wiki -Recurse
    Get-ChildItem $wiki -Recurse -File -Include *.md, *.py, *.base | ForEach-Object { Fill $_.FullName }
    Write-Host "Created $wiki"
} elseif ($Update) {
    foreach ($part in 'skills', 'templates', 'hooks') {
        New-Item -ItemType Directory -Force (Join-Path $wiki $part) | Out-Null
        Copy-Item (Join-Path $template "wiki/$part/*") (Join-Path $wiki $part) -Recurse -Force
        Get-ChildItem (Join-Path $wiki $part) -Recurse -File | ForEach-Object { Fill $_.FullName }
    }
    # Obsidian settings and views are added once and then left to the user.
    foreach ($optional in '.obsidian', 'features.base', 'tickets.base') {
        if (-not (Test-Path (Join-Path $wiki $optional))) { Copy-Item (Join-Path $template "wiki/$optional") $wiki -Recurse }
    }
    Write-Host 'Refreshed skills, templates and hook'
} else {
    Write-Host 'wiki/ exists, kept as is (use -Update to refresh skills, templates and hook)'
}

# 2. AGENTS.md for Codex, CLAUDE.md importing it for Claude Code. Tracked files are never edited.
$agents = Join-Path $repo 'AGENTS.md'
if (-not (Test-Path $agents)) {
    Copy-Item (Join-Path $template 'AGENTS.md') $agents
    Fill $agents
    Write-Host 'Created AGENTS.md'
} elseif (-not (Select-String -Path $agents -Pattern 'wiki/README.md' -Quiet)) {
    Write-Warning 'AGENTS.md exists without wiki rules; merge template/AGENTS.md into it by hand'
}
$claude = Join-Path $repo 'CLAUDE.md'
$import = 'Local wiki and skill rules: @AGENTS.md'
if (IsTracked 'CLAUDE.md') {
    # Never edit a tracked file; CLAUDE.local.md is the per-checkout file Claude Code also loads.
    $local = Join-Path $repo 'CLAUDE.local.md'
    if (-not ((Test-Path $local) -and (Select-String -Path $local -Pattern '@AGENTS.md' -SimpleMatch -Quiet))) {
        Add-Content $local $import
        Write-Host 'CLAUDE.md is tracked; added the import to CLAUDE.local.md'
    }
} elseif (-not (Test-Path $claude)) {
    Set-Content $claude $import
} elseif (-not (Select-String -Path $claude -Pattern '@AGENTS.md' -SimpleMatch -Quiet)) {
    Set-Content $claude ($import + "`n`n" + [IO.File]::ReadAllText($claude)) -NoNewline
}

# 3. Skill junctions: one source in wiki/skills, read by both agents.
foreach ($dir in '.claude/skills', '.agents/skills') {
    $target = Join-Path $repo $dir
    New-Item -ItemType Directory -Force $target | Out-Null
    foreach ($skill in $skills) {
        $link = Join-Path $target $skill
        $item = Get-Item $link -ErrorAction SilentlyContinue
        if ($item -and -not $item.LinkType) { Write-Warning "$link is a real folder; move it away and rerun"; continue }
        if ($item) { $item.Delete() }
        New-Item -ItemType Junction -Path $link -Target (Join-Path $wiki "skills/$skill") | Out-Null
    }
}

# 4. Local ignore rules.
$exclude = Join-Path $repo '.git/info/exclude'
$current = if (Test-Path $exclude) { Get-Content $exclude } else { @() }
$rules = '/wiki/', '/AGENTS.md', '/CLAUDE.md', '/CLAUDE.local.md', '/.agents/', '/.claude/skills/', '/.claude/settings.local.json'
$missing = $rules | Where-Object { $_ -notin $current }
if ($missing) { Add-Content $exclude (@('# WorkCtx (local only)') + $missing) }

# 5. Claude Code hook, only when a ticket pattern is known.
if ($TicketPattern) {
    $settingsPath = Join-Path $repo '.claude/settings.local.json'
    $settings = if (Test-Path $settingsPath) { Get-Content $settingsPath -Raw | ConvertFrom-Json -AsHashtable } else { @{} }
    $command = 'python "$CLAUDE_PROJECT_DIR/wiki/hooks/wiki_trigger.py"'
    if (-not ($settings | ConvertTo-Json -Depth 20).Contains('wiki_trigger.py')) {
        if (-not $settings.hooks) { $settings.hooks = @{} }
        if (-not $settings.hooks.UserPromptSubmit) { $settings.hooks.UserPromptSubmit = @() }
        $settings.hooks.UserPromptSubmit += @{ hooks = @(@{ type = 'command'; command = $command; timeout = 10 }) }
        $settings | ConvertTo-Json -Depth 20 | Set-Content $settingsPath
        Write-Host 'Registered wiki_trigger hook in .claude/settings.local.json'
    }
}

# 6. Standalone skills (work in any repo, such as doc): linked once at user level for both agents.
foreach ($dir in (Join-Path $HOME '.claude/skills'), (Join-Path $HOME '.agents/skills')) {
    New-Item -ItemType Directory -Force $dir | Out-Null
    foreach ($skill in Get-ChildItem (Join-Path $PSScriptRoot 'skills') -Directory) {
        $link = Join-Path $dir $skill.Name
        $item = Get-Item $link -ErrorAction SilentlyContinue
        if ($item -and -not $item.LinkType) { Write-Warning "$link is a real folder; move it away and rerun"; continue }
        if ($item) { $item.Delete() }
        New-Item -ItemType Junction -Path $link -Target $skill.FullName | Out-Null
    }
}

Write-Host 'Done. Open wiki/ as an Obsidian vault for the graph view (optional).'
