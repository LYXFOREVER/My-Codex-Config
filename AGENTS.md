# Codex Preferences

## Long-Running Commands

Any command expected to take more than one minute must be run in the background with stdout and stderr redirected to log files.

After starting a long task, report:

- PID or job id
- stdout log path
- stderr log path
- exact command or equivalent launch command
- how to view logs
- how to stop the process

Monitor long tasks by periodically reading/tailing logs and checking expected output files. Do not block the Codex conversation waiting for the process to finish.

For Windows/PowerShell, use `Start-Process` with `-RedirectStandardOutput`, `-RedirectStandardError`, `-WindowStyle Hidden`, and `-PassThru` when `tmux`/`nohup` are unavailable.

For Linux/macOS, use `tmux` when appropriate, otherwise `nohup ... > stdout.log 2> stderr.log &`.

When monitoring experiments, report infrastructure problems such as code errors, network/API/auth failures, malformed JSONL, missing output files, or stalled progress. Do not treat model prediction mistakes as infrastructure errors.
