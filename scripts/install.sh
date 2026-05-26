#!/usr/bin/env bash
set -euo pipefail

skip_pull=0
if [[ "${1:-}" == "--skip-pull" ]]; then
  skip_pull=1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
cd "${repo_root}"

if [[ "${skip_pull}" -eq 0 ]]; then
  git pull --ff-only
fi

codex_home="${CODEX_HOME:-${HOME}/.codex}"
skills_dest="${codex_home}/skills"

mkdir -p "${skills_dest}"
cp "${repo_root}/AGENTS.md" "${codex_home}/AGENTS.md"

for skill_dir in "${repo_root}"/skills/*; do
  if [[ -d "${skill_dir}" ]]; then
    skill_name="$(basename "${skill_dir}")"
    rm -rf "${skills_dest}/${skill_name}"
    cp -R "${skill_dir}" "${skills_dest}/${skill_name}"
  fi
done

echo "Installed Codex config to: ${codex_home}"
echo "Installed skills to: ${skills_dest}"
