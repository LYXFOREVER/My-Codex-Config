---
name: long-task-runner
description: Run and monitor long-running commands safely. Use when a command may take more than one minute, calls external networks/APIs, trains/evaluates models, compiles large projects, runs long tests, starts servers, or otherwise risks making Codex appear stuck.
---

# Long Task Runner

## Core Rule

Do not run long tasks in the foreground. Any command expected to take more than one minute must run in the background with stdout and stderr redirected to log files.

## Workflow

1. Choose a log directory near the task output, usually under `logs/`.
2. For Python experiments or research scripts, confirm the conda environment before launch.
3. Create separate stdout and stderr logs with a stable name, such as:
   - `logs/<task>_stdout.log`
   - `logs/<task>_stderr.log`
4. Start the process in the background.
5. Immediately tell the user:
   - PID or job id
   - stdout log path
   - stderr log path
   - command used
   - conda environment used, if applicable
   - how to view the logs
   - how to stop the process
6. Monitor with periodic tail/read checks instead of blocking.
7. Report only actionable issues:
   - process exited unexpectedly
   - stderr/network/API/auth/code errors
   - output log stops progressing for a suspiciously long time
   - expected result file is missing or not growing
   - malformed JSONL, parse errors, or missing required fields
8. Do not treat model prediction mistakes as infrastructure errors.

## Conda Environments

Many Python experiments require a project-specific conda environment.

- Infer the conda environment from context when possible: prior commands, project docs, scripts, `.env`, terminal history, or user notes.
- If the environment cannot be inferred confidently, ask the user which conda environment to use.
- Do not install, uninstall, or upgrade packages unless the user explicitly permits it.
- If a missing dependency blocks execution, report the dependency and ask before mutating the environment.
- Include `conda run -n <env-name>` or conda activation in the actual background command and in the user-facing launch summary.

## Windows PowerShell Pattern

Use this when `tmux`/`nohup` are unavailable:

```powershell
$out = "logs/task_stdout.log"
$err = "logs/task_stderr.log"
$cmd = "conda run -n <env-name> python script.py --arg value"
$p = Start-Process -FilePath powershell `
  -ArgumentList @("-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", $cmd) `
  -WorkingDirectory "E:\code" `
  -RedirectStandardOutput $out `
  -RedirectStandardError $err `
  -WindowStyle Hidden `
  -PassThru
"PID=$($p.Id)"
```

View logs:

```powershell
Get-Content logs/task_stdout.log -Tail 50 -Wait
Get-Content logs/task_stderr.log -Tail 50 -Wait
```

Stop process:

```powershell
Stop-Process -Id <PID>
```

## Unix Pattern

Prefer `tmux` if available and useful for interactive monitoring. Otherwise use `nohup`:

```bash
mkdir -p logs
nohup bash -lc 'conda run -n <env-name> python script.py --arg value' > logs/task_stdout.log 2> logs/task_stderr.log &
echo $!
```

View logs:

```bash
tail -f logs/task_stdout.log
tail -f logs/task_stderr.log
```

Stop process:

```bash
kill <PID>
```

## Tool Availability Check

Before choosing a background method, check the host:

- Windows/PowerShell: `Get-Command tmux`, `Get-Command nohup`; if absent, use `Start-Process`.
- Linux/macOS: `command -v tmux`, `command -v nohup`; prefer the available tool that matches the task.

## User Updates

For long experiments, periodically summarize:

- current PID status
- latest progress count, such as completed JSONL rows
- latest relevant stdout/stderr lines
- whether errors are infrastructure errors or ordinary task/model failures
