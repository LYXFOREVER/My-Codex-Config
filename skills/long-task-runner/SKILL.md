---
name: long-task-runner
description: Run and monitor long-running commands safely. Use when a command may take more than one minute, calls external networks/APIs, trains/evaluates models, compiles large projects, runs long tests, starts servers, or otherwise risks making Codex appear stuck.
---

# Long Task Runner

## Core Rule

Do not run long tasks in the foreground. Any command expected to take more than one minute must run in the background with stdout and stderr redirected to log files.

## Workflow

1. Choose a log directory near the task output, usually under `logs/`.
2. Create separate stdout and stderr logs with a stable name, such as:
   - `logs/<task>_stdout.log`
   - `logs/<task>_stderr.log`
3. Start the process in the background.
4. Immediately tell the user:
   - PID or job id
   - stdout log path
   - stderr log path
   - command used
   - how to view the logs
   - how to stop the process
5. Monitor with periodic tail/read checks instead of blocking.
6. Report only actionable issues:
   - process exited unexpectedly
   - stderr/network/API/auth/code errors
   - output log stops progressing for a suspiciously long time
   - expected result file is missing or not growing
   - malformed JSONL, parse errors, or missing required fields
7. Do not treat model prediction mistakes as infrastructure errors.

## Windows PowerShell Pattern

Use this when `tmux`/`nohup` are unavailable:

```powershell
$out = "logs/task_stdout.log"
$err = "logs/task_stderr.log"
$p = Start-Process -FilePath python `
  -ArgumentList @("script.py", "--arg", "value") `
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
nohup python script.py --arg value > logs/task_stdout.log 2> logs/task_stderr.log &
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
