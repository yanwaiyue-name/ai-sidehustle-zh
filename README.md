<div align="center">

# 💰 中文 AI 副业实战导航

**用 AI 赚外快，但只列「真实可执行」的项目——每条标成本、收益、证据等级、出处**

> 市面上「AI 副业合集」九成是标题党。这份清单只收：你今天就能照着做的、成本算得清的路子，并且**明确标出哪些数字其实没有权威数据**。

**📖 在线读**：https://yanwaiyue-name.github.io/ai-sidehustle-zh/

[English](README.en.md) ｜ **中文**

![License](https://img.shields.io/badge/license-MIT-green)
![Status](https://img.shields.io/badge/状态-维护中-blue)
[![validate-pr](https://github.com/yanwaiyue-name/ai-sidehustle-zh/actions/workflows/validate-pr.yml/badge.svg)](https://github.com/yanwaiyue-name/ai-sidehustle-zh/actions/workflows/validate-pr.yml)

</div>

---

## 目录

- [这本书和别的有什么不一样](#这本书和别的有什么不一样)
- [证据现状（先读这个）](#-证据现状先读这个)
- [入口](#-入口)
- [分类速览](#-分类速览)
- [自动体检怎么跑](#-自动体检怎么跑)
- [数据字段说明](#-数据字段说明)

---

## 这本书和别的有什么不一样

网上教 AI 副业的，一类喊「月入十万」，一类卖课。两类都没告诉你**具体账怎么算、失败率多少、要投多少时间**。

每一条都按同一个格式写（沿用《学生版·高性价比人生指南》的写法）：

| 字段 | 回答什么 |
| --- | --- |
| 成本 | 要花多少钱、多少时间、要不要长期自律 |
| 说人话 | 这件事到底是什么，不用术语 |
| 收益 | 具体数字或公开数据，查不到就写「没有公开数据」 |
| 为什么 | 这条路背后的机制 |
| 证据等级 | A（有官方/平台原文）/ B（有统计/报告）/ C（只有个案经验） |
| 来源 | 机构、文件名、链接 |
| 来源链接 | 可点击的官方规则页 / 数据来源 |
| 备注 | 什么情况下这条不适用 |

**证据 C 级必须写清「这是经验判断，没有权威数据」**，不许写成 A 级的口气。

---

## ⚠️ 证据现状（先读这个）

**目前 20 条全部是 C 级证据。** 收益数字来自平台公开挂单价与个案经验，
**没有权威统计，不保证收入**。首版 README 里「官方出处背书」的说法不准确，已改正。

这份清单的正确用法是：当作「有哪些路子、账大概怎么算」的地图，
而不是收益承诺。要升级到 A/B 级，需要补平台官方分成规则原文或第三方统计报告——
欢迎提 PR 补证据。

---

## 🚪 入口

| 你是 | 点这里 |
| --- | --- |
| 想直接看清单 | [docs/index.html](docs/index.html)（网页，支持搜索/分类/证据筛选） |
| 想看单条详情 | [docs/projects/](docs/projects/) 下每项目一个 Markdown |
| 想拿结构化数据 | [data/projects.json](data/projects.json) |

---

## ⚡ 分类速览

| 方向 | 条目 | 难度 | 启动成本 |
| --- | --- | --- | --- |
| AI 内容生成（视频/图文） | 6 | 低 | 0 |
| AI 工具/自动化接单 | 5 | 中 | 少 |
| 数字产品（模板/课程/电子书） | 4 | 低 | 0 |
| 数据与爬虫服务 | 3 | 中高 | 少 |
| AI 咨询/陪跑 | 2 | 中 | 0 |

---

## 🩺 自动体检怎么跑

```powershell
pwsh scripts/check_links.ps1                      # 只校验数据（字段/枚举/去重），不联网
pwsh scripts/check_links.ps1 -ProbeLinks          # 额外逐条探测来源链接是否存活
pwsh scripts/render.ps1                           # 重新生成网页 + 20 个详情页
```

每周六由 GitHub Actions 跑一轮：数据校验 → 来源链接探测 → 重新渲染 → 部署 Pages。
改动 `data/` 的 PR 会触发 `validate-pr.yml`，格式不合格直接挡下。

---

## 🧾 数据字段说明

| 字段 | 谁写 | 含义 |
| --- | --- | --- |
| `id` / `category` / `title` / `plain` / `why` / `note` / `tools` | 手写 | 标识、分类、标题、白话、机制、风险、工具 |
| `cost` / `cost_detail` | 手写 | 五维成本标签 + 具体说明 |
| `income` / `evidence` / `source` / `source_url` | 手写 | 收益口径、A/B/C 级、出处文字、出处链接 |
| `status` | 手写 | 条目是否仍有效 |
| `link_status` / `link_checked` | 脚本回写 | 来源链接可达性、体检日期 |

---

## ⚠️ 免责

副业有风险，收入无保证。这份清单只是「账怎么算」，不是「你一定能赚」。请勿用于虚假宣传、刷量、侵权搬运等违规用途。
