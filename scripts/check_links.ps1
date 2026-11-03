<#
ai-sidehustle-zh 链接体检：校验 data/projects.json 引用的工具官网是否存活
（本项目无外部链接数据源，故只做 JSON 格式与字段校验；如需校验 tools 官网可扩展）
#>
[CmdletBinding()]
param([string]$DataPath)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
if (-not $DataPath) { $DataPath = Join-Path $root 'data/projects.json' }

$projects = @(Get-Content -LiteralPath $DataPath -Raw -Encoding UTF8 | ConvertFrom-Json)
$reqFields = @('id', 'category', 'title', 'cost', 'cost_detail', 'plain', 'income', 'why', 'evidence', 'source', 'note', 'tools', 'status')
$bad = 0
foreach ($p in $projects) {
    foreach ($f in $reqFields) {
        if (-not ($p.PSObject.Properties.Name -contains $f)) {
            Write-Host ("缺字段：$($p.id) -> $f")
            $bad++
        }
    }
}
if ($bad -gt 0) { throw "有 $bad 处字段缺失" }
Write-Host ("格式校验通过：$($projects.Count) 条，字段齐全")
if ($env:GITHUB_STEP_SUMMARY) {
    Add-Content -LiteralPath $env:GITHUB_STEP_SUMMARY -Value ("### AI 副业导航 校验（$((Get-Date).ToUniversalTime().ToString('yyyy-MM-dd'))）`n`n通过 **$($projects.Count)** 条，字段齐全") -Encoding utf8
}
