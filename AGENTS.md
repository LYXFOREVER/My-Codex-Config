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

## Conda And Python Environments

Python experiments, training jobs, evaluation scripts, and long-running research commands often require a conda environment.

Before running these commands:

- Infer the conda environment from project context when possible, such as prior commands, scripts, docs, `.env`, or visible terminal history.
- If the environment cannot be inferred confidently, ask the user which conda environment to use before running the command.
- Include `conda run -n <env>` or conda activation in background launch commands when needed.
- Do not install, uninstall, upgrade, or otherwise mutate conda/pip packages unless the user explicitly allows it.
- If a missing dependency blocks execution, report the dependency and ask before changing the environment.
