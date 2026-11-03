# 贡献指南（ai-sidehustle-zh）

## 加一条副业

在 `data/projects.json` 末尾补一条，**必须严格按证据分级格式**：

```json
{
  "id": "ai-xxx",
  "category": "AI 内容生成",
  "title": "一句话说清这事",
  "cost": "钱=0 时间=少 毅力=否 收益=小 口径=可逆",
  "cost_detail": "具体要花多少钱、多少时间",
  "plain": "大白话讲明白这事是什么",
  "income": "具体数字或公开数据，查不到写「没有公开数据」",
  "why": "这条路背后的机制",
  "evidence": "A",            // A=有官方原文 / B=有统计报告 / C=只有个案经验
  "source": "机构 (年份). 文件名. <链接>",
  "note": "什么情况下不适用 / 风险",
  "tools": ["工具1", "工具2"],
  "status": "ok"
}
```

## 红线

- **C 级必须写清「这是经验判断，没有权威数据」**，不许写成 A 级的口气；
- 不许编数字，没有公开数据就写「没有公开数据」；
- 不收违规路子（刷量、侵权搬运、虚假宣传）。

## 提交前

```powershell
pwsh scripts/check_links.ps1        # 校验字段齐全
pwsh scripts/render.ps1             # 重新生成 docs/index.html
```
