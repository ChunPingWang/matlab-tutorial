#!/usr/bin/env bash
# 跑遍 tutorial 所有 scripts，重新產生 images/
#
# 用法：
#   ./tools/run_all.sh                          # 全跑
#   ./tools/run_all.sh 03-physics-simulation    # 只跑單章
#   ./tools/run_all.sh 03-physics-simulation/scripts/02_spring_mass_damper.m  # 跑單檔
set -euo pipefail

MATLAB_BIN="${MATLAB_BIN:-/Applications/MATLAB_R2025a.app/bin/matlab}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -x "$MATLAB_BIN" ]]; then
    echo "MATLAB 找不到：$MATLAB_BIN"
    echo "可用 MATLAB_BIN=/path/to/matlab ./tools/run_all.sh 覆寫"
    exit 1
fi

# 蒐集要跑的腳本清單
declare -a scripts
if [[ $# -eq 0 ]]; then
    while IFS= read -r f; do scripts+=("$f"); done < <(find 0*/scripts -name '*.m' | sort)
elif [[ "$1" == *.m ]]; then
    scripts=("$1")
else
    chapter="$1"
    while IFS= read -r f; do scripts+=("$f"); done < <(find "$chapter/scripts" -name '*.m' | sort)
fi

# 過濾 function 檔（首行以 function 開頭），只執行 script
declare -a filtered
for s in "${scripts[@]}"; do
    first=$(head -1 "$s" | sed 's/^[[:space:]]*//')
    if [[ "$first" == function* ]]; then
        continue
    fi
    filtered+=("$s")
done

echo "要跑 ${#filtered[@]} 個腳本（已略過 function 檔）"
for s in "${filtered[@]}"; do
    echo "==> $s"
    # 用 eval(fileread()) 而非 run()：run 在 R2025a 對部分 UTF-8 內容會誤判
    "$MATLAB_BIN" -batch "addpath(genpath('tools')); cd('$(dirname "$s")'); eval(fileread('$(basename "$s")'))"
done
echo "完成"
