# My-Codex-Config 使用说明

这个仓库用来保存我自己的 Codex 配置，方便在不同电脑之间同步。

目前主要保存两类东西：

- `AGENTS.md`：给 Codex 的全局偏好和工作习惯。
- `skills/`：自定义 skill，例如 `long-task-runner`。

## 这个仓库解决什么问题

我希望 Codex 在不同机器上都记得一些固定规则，例如：

- 长时间运行的命令不要前台卡住聊天窗口。
- 超过 1 分钟的任务要后台运行，并把 stdout/stderr 写入日志。
- 启动后要告诉我 PID、日志路径、查看日志方式、停止进程方式。
- Python 实验大概率需要 conda 环境，运行前要确认环境。
- 不要擅自安装、卸载、升级 conda/pip 包。

只要把这个仓库部署到某台机器的 Codex 配置目录，之后 Codex 就能自动读到这些规则。

## 仓库结构

```text
my-codex-config/
  AGENTS.md
  scripts/
    install.ps1
    install.sh
  skills/
    long-task-runner/
      SKILL.md
      agents/
        openai.yaml
```

## 第一次在新机器上安装

### Windows

先 clone 仓库：

```powershell
git clone git@github.com:LYXFOREVER/My-Codex-Config.git
cd My-Codex-Config
```

然后运行安装脚本：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

脚本会自动把配置复制到：

```text
%USERPROFILE%\.codex\
```

也就是类似：

```text
C:\Users\你的用户名\.codex\
```

### Linux / macOS

先 clone 仓库：

```bash
git clone git@github.com:LYXFOREVER/My-Codex-Config.git
cd My-Codex-Config
```

然后运行安装脚本：

```bash
bash scripts/install.sh
```

脚本会自动把配置复制到：

```text
~/.codex/
```

## 以后如何更新

以后如果 GitHub 仓库里的配置更新了，只需要在本地仓库目录重新运行安装脚本。

Windows：

```powershell
cd My-Codex-Config
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

Linux / macOS：

```bash
cd My-Codex-Config
bash scripts/install.sh
```

安装脚本默认会先执行：

```bash
git pull --ff-only
```

然后再复制配置到 Codex 目录。

## 如果只是本地测试脚本

有时候远端仓库还没配置好，或者只是想测试复制逻辑，可以跳过 `git pull`。

Windows：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1 -SkipPull
```

Linux / macOS：

```bash
bash scripts/install.sh --skip-pull
```

## CODEX_HOME 是什么

安装脚本会优先检查环境变量 `CODEX_HOME`。

如果设置了 `CODEX_HOME`，配置会复制到：

```text
$CODEX_HOME
```

如果没有设置：

- Windows 默认使用 `%USERPROFILE%\.codex`
- Linux/macOS 默认使用 `~/.codex`

一般情况下不用手动设置 `CODEX_HOME`。

## 当前已有的 skill

### long-task-runner

这个 skill 规定：预计超过 1 分钟的任务不要直接前台运行。

Codex 应该：

- 后台启动长任务。
- 把 stdout/stderr 分别写到日志文件。
- 启动后立刻告诉我 PID 和日志路径。
- 告诉我怎么查看日志、怎么停止进程。
- 定期检查日志和输出文件。
- 报告代码、网络、API、权限、JSONL 格式等基础设施错误。
- 不把模型自己预测错当成程序错误。

它还记录了 conda 规则：

- Python 实验前要确认 conda 环境。
- 能从上下文判断环境名就使用该环境。
- 判断不出来就问我。
- 不要擅自安装、卸载、升级环境里的库。

## 修改配置后怎么提交

修改完这个仓库里的配置后：

```bash
git status
git add .
git commit -m "Update Codex config"
git push
```

然后在其他机器上重新运行安装脚本即可。
