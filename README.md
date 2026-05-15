# URL to Obsidian

面向 [Obsidian](https://obsidian.md/) 的 **Claude / Cursor Agent Skill**：把任意网页交给真实浏览器抓取，再由 AI 整理成结构化 Markdown 笔记，写入你的 Vault。

## 适合做什么

- 保存文章、文档页：一键生成带 front matter 的摘要笔记。
- 视频页：尽量抓取标题、描述、标签与可见文字稿。
- 搜索引擎结果页（如小红书搜索）：可抽取结果链接、按互动数据排序后打开若干条详情，再合并总结。
- **批量**：多个 URL 可依次处理，每条生成独立 `.md` 文件。

## 工作原理（简要）

```
用户给出网址 → Kimi WebBridge 健康检查 → 浏览器打开页面 → 抓取内容 → AI 总结 → 写入 Obsidian → 关闭会话
```

抓取通过本机运行的 **Kimi WebBridge**（控制真实浏览器，复用登录态）。Skill 内说明了 `navigate`、`snapshot`、`evaluate` 等调用方式及固定会话名 `url-summarize`。

## 依赖

| 依赖 | 说明 |
|------|------|
| **Kimi WebBridge** | 本机 `http://127.0.0.1:10086`，扩展已连接。首次执行前按 `SKILL.md` 做 `kimi-webbridge status` 检查。 |
| **Claude Code / Cursor** | 将本目录作为 Agent Skill 使用（见安装）。 |
| **Obsidian** | 任意 Vault；笔记输出目录需在 `SKILL.md` 中配置。 |

## 安装

1. 安装并启动 [Kimi WebBridge](https://github.com/MoonshotAI/kimi-webbridge)（或你环境对应的 WebBridge），确保 `status` 为 `running` 且扩展已连接。
2. 把整个 `url-to-obsidian` 文件夹放到 Agent 的 skills 目录，例如：
   - Cursor：`.cursor/skills/` 或项目内 `.claude/skills/`
   - Claude Code：按官方文档配置 skills 路径
3. 打开 `SKILL.md`，按你的系统修改 **Obsidian Vault 路径**与**笔记子目录**（默认文档中为 `D:\ObsidianVault\网址总结\`，请改成你的实际路径）。

## 输出笔记格式

每条笔记包含 YAML front matter（`date`、`source`、`type: url-summary`）、标题、200–500 字左右总结、3–7 条要点，以及原文链接。默认文件名：`YYYY-MM-DD-标题.md`（标题会做文件名安全处理）。

## 仓库内文件

| 文件 | 作用 |
|------|------|
| `SKILL.md` | Skill 定义与完整操作流程（健康检查、各页面类型策略、批量、注意事项）。 |
| `scripts/screenshot.sh` | 截图辅助脚本：把 WebBridge 返回的 base64 落到磁盘，只回传路径，避免大段 base64 撑爆上下文。 |

在 Windows 上若使用 `screenshot.sh`，需通过 Git Bash、WSL 或等价环境执行 bash。

## 使用方式

在支持该 Skill 的对话里**直接发送 URL**（可附带「总结并保存到 Obsidian」等说明；仅发链接也会按 Skill 描述触发）。Agent 会按 `SKILL.md` 执行抓取、总结与落盘。

## 注意事项（摘自 Skill）

- 需要截图时优先用 `scripts/screenshot.sh`，不要直接把截图 API 的大段 base64 读进对话。
- `evaluate` 里的 JS 注意 JSON 转义；多次 evaluate 可用 IIFE 避免变量重复声明。
- 页面极长时优先正文区域，忽略导航/侧栏噪声。

## 许可证

本仓库未默认附带许可证文件；如需开源请自行在仓库根目录添加 `LICENSE`。
