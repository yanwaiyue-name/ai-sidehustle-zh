<#
ai-sidehustle-zh 渲染：从 data/projects.json 生成 docs/index.html（不联网可用）
#>
[CmdletBinding()]
param([string]$DataPath, [string]$OutPath)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
if (-not $DataPath) { $DataPath = Join-Path $root 'data/projects.json' }
if (-not $OutPath)  { $OutPath  = Join-Path $root 'docs/index.html' }

$projects = @(Get-Content -LiteralPath $DataPath -Raw -Encoding UTF8 | ConvertFrom-Json)

function Html-Escape($s) { ($s -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;' -replace '"', '&quot;') }

$rows = New-Object System.Collections.Generic.List[string]
foreach ($p in $projects) {
    $rows.Add(@"
    <tr>
      <td><b>$(Html-Escape [string]$p.title)</b><br><span class="cat">$(Html-Escape [string]$p.category)</span></td>
      <td>$(Html-Escape [string]$p.cost_detail)</td>
      <td>$(Html-Escape [string]$p.income)</td>
      <td><span class="ev ev-$([string]$p.evidence)">$([string]$p.evidence) 级</span></td>
      <td>$(Html-Escape [string]$p.note)</td>
    </tr>
"@)
}

$okCount = @($projects | Where-Object { [string]$_.status -eq 'ok' }).Count
$today = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd')

$html = @"
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>中文 AI 副业实战导航</title>
<style>
  body { font-family: -apple-system, "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif; max-width: 1100px; margin: 2rem auto; padding: 0 1rem; color:#1a1a1a; line-height:1.6; }
  h1 { text-align:center; }
  .sub { text-align:center; color:#666; margin-bottom:1.5rem; }
  .summary { display:flex; gap:1rem; justify-content:center; margin-bottom:2rem; flex-wrap:wrap; }
  .summary div { background:#f5f5f7; border-radius:8px; padding:.6rem 1.2rem; }
  table { width:100%; border-collapse:collapse; font-size:.9rem; }
  th, td { text-align:left; padding:.6rem .7rem; border-bottom:1px solid #eee; vertical-align:top; }
  th { background:#fafafa; }
  .cat { color:#0078d4; font-size:.8em; }
  .ev { font-weight:bold; padding:.1rem .4rem; border-radius:4px; }
  .ev-A { background:#dafbe1; } .ev-B { background:#eef9ff; } .ev-C { background:#fff8c5; }
  a { color:#0078d4; }
  footer { margin-top:3rem; text-align:center; color:#999; font-size:.85rem; }
</style>
</head>
<body>
  <h1>💰 中文 AI 副业实战导航</h1>
  <p class="sub">只列真实可执行的路子 · 每条标成本 / 收益 / 证据等级 / 出处</p>
  <div class="summary">
    <div>条目 <b>$($projects.Count)</b></div>
    <div>存活 <b>$okCount</b></div>
    <div>更新 <b>$today</b></div>
  </div>
  <table>
    <thead><tr><th>项目</th><th>成本</th><th>收益</th><th>证据</th><th>备注 / 风险</th></tr></thead>
    <tbody>
$(($rows -join "`n"))
    </tbody>
  </table>
  <footer>本页由 scripts/render.ps1 从 data/projects.json 生成 · 副业有风险，收入无保证</footer>
</body>
</html>
"@

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $OutPath) | Out-Null
[System.IO.File]::WriteAllText($OutPath, $html, (New-Object System.Text.UTF8Encoding($false)))
Write-Host ("已生成：$OutPath （$($projects.Count) 条）")
