<#
ai-sidehustle-zh 渲染：
  1. 从 data/projects.json 生成单文件 docs/index.html（搜索 / 分类 / 证据筛选）
  2. 为每条副业生成 docs/projects/<id>.html 详情页，兑现 README 的入口
#>
[CmdletBinding()]
param([string]$DataPath, [string]$OutPath, [string]$DocsDir)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
if (-not $DataPath) { $DataPath = Join-Path $root 'data/projects.json' }
if (-not $OutPath)  { $OutPath  = Join-Path $root 'docs/index.html' }
if (-not $DocsDir)  { $DocsDir  = Join-Path $root 'docs/projects' }

$projects = @(Get-Content -LiteralPath $DataPath -Raw -Encoding UTF8 | ConvertFrom-Json)

function Html-Escape($s) {
    if ($null -eq $s) { return '' }
    ([string]$s -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;' -replace '"', '&quot;')
}

New-Item -ItemType Directory -Force -Path $DocsDir | Out-Null

# ---------- 单条详情页（HTML） ----------
# GitHub Pages 不会把 .md 当网页渲染，直接点开只会看到源码。
# 所以详情页也生成 HTML，和总览页共用同一套样式。
if (Test-Path -LiteralPath $DocsDir) {
    Get-ChildItem -LiteralPath $DocsDir -File |
        Where-Object { $_.Extension -in '.md', '.html' } |
        Remove-Item -Force
}

foreach ($p in $projects) {
    $id = [string]$p.id
    $ev = [string]$p.evidence
    $srcHtml = if ($p.source_url) {
        '<a href="' + (Html-Escape $p.source_url) + '" target="_blank" rel="noopener">来源 / 官方规则页 ↗</a>'
    } else {
        '（暂无可点链接，见下方出处说明）'
    }
    $notice = if ($ev -eq 'C') {
        '<div class="notice">⚠️ 本条为 C 级：只有个案经验与平台公开挂单价，<b>没有权威统计数据</b>，收益数字不可当作保证。</div>'
    } else { '' }
    $detail = @"
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$(Html-Escape $p.title) · 中文 AI 副业实战导航</title>
<style>
  :root { color-scheme: light dark; }
  body { font-family: -apple-system, "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif; max-width: 860px; margin: 2rem auto; padding: 0 1rem; color:#1a1a1a; line-height:1.7; }
  .back { display:inline-block; margin-bottom:1rem; font-size:.9rem; }
  h1 { font-size:1.55rem; line-height:1.35; margin:.2rem 0 .6rem; }
  .meta { color:#666; font-size:.9rem; }
  .ev { font-weight:bold; padding:.1rem .45rem; border-radius:4px; }
  .ev-A { background:#dafbe1; } .ev-B { background:#eef9ff; } .ev-C { background:#fff8c5; }
  .notice { background:#fff8c5; border-left:4px solid #d4a72c; padding:.7rem 1rem; font-size:.9rem; margin:1.2rem 0; border-radius:4px; }
  dl { margin:1.2rem 0; }
  dt { font-weight:600; margin-top:1rem; }
  dd { margin:.25rem 0 0; }
  code { background:#f5f5f7; padding:.1rem .35rem; border-radius:4px; }
  a { color:#0078d4; text-decoration:none; } a:hover { text-decoration:underline; }
  footer { margin-top:2.5rem; padding-top:1rem; border-top:1px solid #eee; color:#999; font-size:.85rem; }
  @media (prefers-color-scheme: dark) {
    body { background:#0d1117; color:#e6edf3; }
    .meta, footer { color:#8b949e; }
    .notice { background:#3b2f0b; }
    code { background:#161b22; }
    footer { border-color:#30363d; }
  }
</style>
</head>
<body>
<script src="https://yanwaiyue-name.github.io/yuese-nav/nav.js" data-site="ai-sidehustle-zh" data-theme="auto" data-max="860" defer></script>
<main>
  <a class="back" href="../index.html">← 返回清单</a>
  <h1>$(Html-Escape $p.title)</h1>
  <p class="meta">分类：$(Html-Escape $p.category) ｜ 证据等级：<span class="ev ev-$ev">$ev 级</span></p>
  $notice
  <dl>
    <dt>成本标签</dt><dd><code>$(Html-Escape $p.cost)</code></dd>
    <dt>成本</dt><dd>$(Html-Escape $p.cost_detail)</dd>
    <dt>说人话</dt><dd>$(Html-Escape $p.plain)</dd>
    <dt>收益</dt><dd>$(Html-Escape $p.income)</dd>
    <dt>为什么</dt><dd>$(Html-Escape $p.why)</dd>
    <dt>来源</dt><dd>$(Html-Escape $p.source)</dd>
    <dt>来源链接</dt><dd>$srcHtml</dd>
    <dt>常用工具</dt><dd>$(Html-Escape ((@($p.tools)) -join '、'))</dd>
    <dt>备注 / 风险</dt><dd>$(Html-Escape $p.note)</dd>
  </dl>
  <footer>本页由 scripts/render.ps1 从 data/projects.json 生成 · 副业有风险，收入无保证</footer>
</main>
</body>
</html>
"@
    [System.IO.File]::WriteAllText((Join-Path $DocsDir "$id.html"), $detail, (New-Object System.Text.UTF8Encoding($false)))
}

# ---------- 总览页 ----------
$rows = New-Object System.Collections.Generic.List[string]
foreach ($p in $projects) {
    $ev = [string]$p.evidence
    $cat = Html-Escape $p.category
    $srcLink = if ($p.source_url) {
        '<a href="' + (Html-Escape $p.source_url) + '" target="_blank" rel="noopener" title="官方规则页 / 数据来源">来源 ↗</a>'
    } else { '—' }
    $detailLink = '<a href="projects/' + (Html-Escape $p.id) + '.html">详情</a>'
    $hay = Html-Escape ((@($p.title, $p.plain, $p.category, $p.tools) -join ' ').ToLowerInvariant())

    $rows.Add(@"
    <tr data-cat="$cat" data-ev="$ev" data-hay="$hay">
      <td><a href="projects/$(Html-Escape $p.id).html"><b>$(Html-Escape $p.title)</b></a><br><span class="cat">$cat</span><br><span class="meta">$detailLink · $srcLink</span></td>
      <td>$(Html-Escape $p.cost_detail)</td>
      <td>$(Html-Escape $p.income)</td>
      <td><span class="ev ev-$ev">$ev 级</span></td>
      <td>$(Html-Escape $p.note)</td>
    </tr>
"@)
}

$catList = @($projects | ForEach-Object { [string]$_.category } | Sort-Object -Unique)
$catButtons = @('<button class="filter active" data-cat="all">全部</button>') +
              @($catList | ForEach-Object { '<button class="filter" data-cat="' + (Html-Escape $_) + '">' + (Html-Escape $_) + '</button>' })
$evCounts = @{}
foreach ($p in $projects) { $k = [string]$p.evidence; if (-not $evCounts.ContainsKey($k)) { $evCounts[$k] = 0 }; $evCounts[$k]++ }
$today = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd')

$html = @"
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>中文 AI 副业实战导航</title>
<style>
  :root { color-scheme: light dark; }
  body { font-family: -apple-system, "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif; max-width: 1180px; margin: 2rem auto; padding: 0 1rem; color:#1a1a1a; line-height:1.6; }
  h1 { text-align:center; margin-bottom:.3rem; }
  .sub { text-align:center; color:#666; margin:0 0 1.2rem; }
  .notice { background:#fff8c5; border-left:4px solid #d4a72c; padding:.7rem 1rem; font-size:.88rem; margin-bottom:1.2rem; border-radius:4px; }
  .summary { display:flex; gap:.8rem; justify-content:center; margin-bottom:1.2rem; flex-wrap:wrap; }
  .summary div { background:#f5f5f7; border-radius:8px; padding:.5rem 1.1rem; font-size:.9rem; }
  .toolbar { position:sticky; top:0; background:var(--bg,#fff); padding:.8rem 0; border-bottom:1px solid #e5e5e5; z-index:5; }
  #q { width:100%; box-sizing:border-box; padding:.6rem .9rem; font-size:1rem; border:1px solid #d0d0d0; border-radius:8px; }
  .filters { margin-top:.6rem; display:flex; gap:.4rem; flex-wrap:wrap; align-items:center; }
  button.filter { cursor:pointer; border:1px solid #d0d0d0; background:#fafafa; color:#333; border-radius:20px; padding:.25rem .8rem; font-size:.85rem; }
  button.filter.active { background:#0078d4; border-color:#0078d4; color:#fff; }
  table { width:100%; border-collapse:collapse; font-size:.88rem; }
  th, td { text-align:left; padding:.55rem .6rem; border-bottom:1px solid #eee; vertical-align:top; }
  th { background:#fafafa; position:sticky; top:118px; }
  .cat { color:#0078d4; font-size:.85em; } .meta { color:#888; font-size:.8em; }
  .ev { font-weight:bold; padding:.1rem .45rem; border-radius:4px; white-space:nowrap; }
  .ev-A { background:#dafbe1; } .ev-B { background:#eef9ff; } .ev-C { background:#fff8c5; }
  a { color:#0078d4; text-decoration:none; } a:hover { text-decoration:underline; }
  #none { display:none; text-align:center; color:#888; padding:2rem; }
  footer { margin-top:3rem; text-align:center; color:#999; font-size:.85rem; }
  @media (prefers-color-scheme: dark) {
    body { background:#0d1117; color:#e6edf3; }
    .toolbar { --bg:#0d1117; border-color:#30363d; }
    .summary div, th, button.filter { background:#161b22; color:#e6edf3; border-color:#30363d; }
    #q { background:#161b22; color:#e6edf3; border-color:#30363d; }
    td, th { border-color:#30363d; }
    .notice { background:#3b2f0b; }
  }
</style>
</head>
<body>
<script src="https://yanwaiyue-name.github.io/yuese-nav/nav.js" data-site="ai-sidehustle-zh" data-theme="auto" data-max="860" defer></script>
  <h1>💰 中文 AI 副业实战导航</h1>
  <p class="sub">只列真实可执行的路子 · 每条标成本 / 收益 / 证据等级 / 出处</p>
  <div class="notice">
    <b>先把预期说清楚</b>：本清单目前 <b>$(if ($evCounts.ContainsKey('C')) { $evCounts['C'] } else { 0 }) 条全为 C 级证据</b>——
    收益数字来自平台公开挂单价与个案经验，<b>没有权威统计，不保证收入</b>。
    你可以把它当「有哪些路子、账大概怎么算」的地图，别当收益承诺。
  </div>
  <div class="summary">
    <div>条目 <b>$($projects.Count)</b></div>
    <div>A 级 <b>$(if ($evCounts.ContainsKey('A')) { $evCounts['A'] } else { 0 })</b></div>
    <div>B 级 <b>$(if ($evCounts.ContainsKey('B')) { $evCounts['B'] } else { 0 })</b></div>
    <div>C 级 <b>$(if ($evCounts.ContainsKey('C')) { $evCounts['C'] } else { 0 })</b></div>
    <div>更新 <b>$today</b></div>
    <div>显示 <b id="shown">$($projects.Count)</b></div>
  </div>
  <div class="toolbar">
    <input id="q" type="search" placeholder="搜索副业 / 工具，例如：PPT、爬虫、数字人…" autocomplete="off">
    <div class="filters">
      $(($catButtons -join ' '))
      <label style="font-size:.85rem;"><input type="checkbox" id="onlyAB"> 只看 A/B 级证据</label>
    </div>
  </div>
  <table id="t">
    <thead><tr><th>项目</th><th>成本</th><th>收益</th><th>证据</th><th>备注 / 风险</th></tr></thead>
    <tbody>
$(($rows -join "`n"))
    </tbody>
  </table>
  <p id="none">没有匹配的项目，换个关键词试试。</p>
  <footer>本页由 scripts/render.ps1 从 data/projects.json 生成 · 副业有风险，收入无保证</footer>
<script>
(function () {
  var q = document.getElementById('q'),
      rows = Array.prototype.slice.call(document.querySelectorAll('#t tbody tr')),
      shown = document.getElementById('shown'),
      none = document.getElementById('none'),
      onlyAB = document.getElementById('onlyAB'), cat = 'all';
  function apply() {
    var term = q.value.trim().toLowerCase(), n = 0;
    rows.forEach(function (r) {
      var ok = (cat === 'all' || r.dataset.cat === cat) &&
               (!term || r.dataset.hay.indexOf(term) !== -1) &&
               (!onlyAB.checked || r.dataset.ev !== 'C');
      r.style.display = ok ? '' : 'none';
      if (ok) n++;
    });
    shown.textContent = n;
    none.style.display = n ? 'none' : 'block';
  }
  q.addEventListener('input', apply);
  onlyAB.addEventListener('change', apply);
  document.querySelectorAll('button.filter').forEach(function (b) {
    b.addEventListener('click', function () {
      document.querySelectorAll('button.filter').forEach(function (x) { x.classList.remove('active'); });
      b.classList.add('active'); cat = b.dataset.cat; apply();
    });
  });
})();
</script>
</body>
</html>
"@

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $OutPath) | Out-Null
[System.IO.File]::WriteAllText($OutPath, $html, (New-Object System.Text.UTF8Encoding($false)))
Write-Host ("已生成：$OutPath （$($projects.Count) 条）+ $DocsDir 下 $($projects.Count) 个 HTML 详情页")
