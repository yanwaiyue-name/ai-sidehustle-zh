<#
ai-sidehustle-zh 链接与数据体检

原来这个脚本名不副实（只查字段、数据里也没 URL）。现在它会：
  1. 校验 JSON 可解析、必填字段齐全、枚举合法、id 不重复；
  2. 逐条探测 source_url（官方规则页 / 数据来源）是否存活，结果写回 link_status；
  3. 校验 evidence 等级与 income / source 的写法是否自洽。

用法：
  ./scripts/check_links.ps1                          # 只做数据校验，不联网
  ./scripts/check_links.ps1 -ProbeLinks             # 额外探测链接（CI 用）
  ./scripts/check_links.ps1 -ProbeLinks -Token $env:GH_TOKEN
#>
[CmdletBinding()]
param(
    [string]$DataPath,
    [switch]$ProbeLinks,
    [int]$TimeoutSec = 12,
    [string]$Token
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
if (-not $DataPath) { $DataPath = Join-Path $root 'data/projects.json' }
$today = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd')

$errors   = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

try { $projects = @(Get-Content -LiteralPath $DataPath -Raw -Encoding UTF8 | ConvertFrom-Json) }
catch { Write-Host ("JSON 解析失败：" + $_.Exception.Message); exit 1 }

$reqFields = @('id', 'category', 'title', 'cost', 'cost_detail', 'plain', 'income', 'why', 'evidence', 'source', 'note', 'tools', 'status', 'source_url')
$seenIds = @{}
for ($i = 0; $i -lt $projects.Count; $i++) {
    $p = $projects[$i]
    $tag = "#$($i + 1) $([string]$p.id)"

    foreach ($f in $reqFields) {
        if (-not ($p.PSObject.Properties.Name -contains $f) -or [string]::IsNullOrWhiteSpace([string]$p.$f)) {
            $errors.Add("$tag 缺必填字段：$f")
        }
    }

    $ev = [string]$p.evidence
    if ($ev -notin @('A', 'B', 'C')) { $errors.Add("$tag evidence 非法（应为 A/B/C）：$ev") }

    # C 级必须自认「没有权威数据」，不许写成 A 级口气
    if ($ev -eq 'C') {
        $income = [string]$p.income
        if ($income -and $income -notmatch '没有|无权威|无公开数据|经验|个案') {
            $warnings.Add("$tag 是 C 级，但 income 未声明「无权威/公开数据」，请补上口径")
        }
    }

    $u = [string]$p.source_url
    if ($u -and $u -notmatch '^https?://') { $errors.Add("$tag source_url 格式不合法：$u") }

    $id = [string]$p.id
    if ($id) {
        if ($seenIds.ContainsKey($id)) { $errors.Add("$tag id 重复，与 #$($seenIds[$id]) 相同") }
        else { $seenIds[$id] = $i + 1 }
    }
}

# ---------- 链接探测（可选） ----------
$okLinks = 0; $deadLinks = 0
if ($ProbeLinks) {
    $headers = @{ 'User-Agent' = 'ai-sidehustle-zh-check' }
    if ($Token) { $headers['Authorization'] = 'Bearer ' + $Token }
    foreach ($p in $projects) {
        $u = [string]$p.source_url
        if (-not $u) { continue }
        $code = 0
        try {
            $resp = Invoke-WebRequest -Uri $u -Method Head -Headers $headers -TimeoutSec $TimeoutSec -MaximumRedirection 5 -ErrorAction Stop
            $code = [int]$resp.StatusCode
        }
        catch {
            if ($_.Exception.Response) { $code = [int]$_.Exception.Response.StatusCode }
            # HEAD 不支持时退回 GET
            if ($code -in @(0, 403, 405, 501)) {
                try {
                    $r2 = Invoke-WebRequest -Uri $u -Method Get -Headers $headers -TimeoutSec $TimeoutSec -MaximumRedirection 5 -ErrorAction Stop
                    $code = [int]$r2.StatusCode
                } catch { if ($_.Exception.Response) { $code = [int]$_.Exception.Response.StatusCode } }
            }
        }
        # 有任意 HTTP 响应就算入口活着（403 常见于反爬，不是死链）
        $st = if ($code -gt 0) { 'ok' } else { 'unknown' }
        if ($p.PSObject.Properties.Name -contains 'link_status') { $p.link_status = $st }
        else { $p | Add-Member -NotePropertyName 'link_status' -NotePropertyValue $st -Force }
        if ($p.PSObject.Properties.Name -contains 'link_checked') { $p.link_checked = $today }
        else { $p | Add-Member -NotePropertyName 'link_checked' -NotePropertyValue $today -Force }
        if ($st -eq 'ok') { $okLinks++ } else { $deadLinks++ }
        Write-Host ("{0,-26} -> {1} (HTTP {2})" -f $p.id, $st, $code)
    }
}

Write-Host ("校验完成：{0} 条，错误 {1}，警告 {2}" -f $projects.Count, $errors.Count, $warnings.Count)
if ($ProbeLinks) { Write-Host ("链接探测：可达 {0}，未响应 {1}" -f $okLinks, $deadLinks) }
foreach ($w in $warnings) { Write-Host "  [warn] $w" }
foreach ($e in $errors)   { Write-Host "  [ERROR] $e" }

# 探测结果无论是否有错误都写回（link_status 是体检产出）
if ($ProbeLinks) {
    [System.IO.File]::WriteAllText($DataPath, (ConvertTo-Json -InputObject $projects -Depth 8), (New-Object System.Text.UTF8Encoding($false)))
}

if ($env:GITHUB_STEP_SUMMARY) {
    $md = @("### AI 副业导航 校验（$today）", "", "条目 **$($projects.Count)** / 错误 **$($errors.Count)** / 警告 **$($warnings.Count)**")
    if ($ProbeLinks) { $md += ''; $md += "来源链接可达 **$okLinks** / 未响应 **$deadLinks**" }
    if ($errors.Count -gt 0) { $md += ''; $md += '```'; $md += $errors; $md += '```' }
    Add-Content -LiteralPath $env:GITHUB_STEP_SUMMARY -Value ($md -join "`n") -Encoding utf8
}

if ($errors.Count -gt 0) { exit 1 }
Write-Host '校验通过 ✅'
