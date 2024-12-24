#!/bin/bash

# 全局变量：保存所有已添加的文件
SELECTED_FILES=()
ADDED_FILES=()

# 定义全局随机文件数量范围
RANDOM_MIN_FILES=3
RANDOM_MAX_FILES=6

# 检查文件是否已添加的函数
is_already_added() {
  local file=$1
  for added_file in "${ADDED_FILES[@]}"; do
    if [ "$added_file" == "$file" ]; then
      return 0 # 已添加
    fi
  done
  return 1 # 未添加
}

# auto_commit 函数
auto_commit() {
  if [ -z "$1" ]; then
    echo "Usage: auto_commit <date-in-YYYY-MM-DD-format>"
    return 1
  fi

  INPUT_DATE=$1

  if ! date -jf "%Y-%m-%d" "$INPUT_DATE" "+%Y-%m-%d" >/dev/null 2>&1; then
    echo "Invalid date format. Please use YYYY-MM-DD."
    return 1
  fi

  IFS=$'\n'
  FILES_TO_COMMIT=($(git status --porcelain | awk '{print substr($0, 4)}' | sed 's/^"//; s/"$//' | while read -r path; do
    if [ -f "$path" ]; then
      echo "$path"
    elif [ -d "$path" ]; then
      find "$path" -type f
    else
      echo "$path"
    fi
  done))
  unset IFS

  FILE_COUNT=${#FILES_TO_COMMIT[@]}
  if [ "$FILE_COUNT" -lt "$RANDOM_MIN_FILES" ]; then
    echo "Not enough files to add. Found $FILE_COUNT files. At least $RANDOM_MIN_FILES files are required."
    export GIT_COMMITTER_DATE="$INPUT_DATE 18:00:00"
    export GIT_AUTHOR_DATE="$INPUT_DATE 18:00:00"
    git add -A
    git commit --date "$INPUT_DATE 18:00:00" -m "files done"
    return 1
  fi

  SELECTED_COUNT=0
  RANDOM_FILE_COUNT=$((RANDOM % (RANDOM_MAX_FILES - RANDOM_MIN_FILES + 1) + RANDOM_MIN_FILES))
  while [ "$SELECTED_COUNT" -lt "$RANDOM_FILE_COUNT" ]; do
    RANDOM_FILE="${FILES_TO_COMMIT[$RANDOM % ${#FILES_TO_COMMIT[@]}]}"
    if ! is_already_added "$RANDOM_FILE"; then
      SELECTED_FILES+=("$RANDOM_FILE")
      ADDED_FILES+=("$RANDOM_FILE")
      git add -- "$RANDOM_FILE"
      SELECTED_COUNT=$((SELECTED_COUNT + 1))
    fi
  done

  BASE_TIME="${INPUT_DATE} 13:30:00"
  BASE_EPOCH=$(date -jf "%Y-%m-%d %H:%M:%S" "$BASE_TIME" "+%s")
  RANDOM_MINUTES=$((RANDOM % 330))
  RANDOM_EPOCH=$((BASE_EPOCH + RANDOM_MINUTES * 60))
  RANDOM_TIME=$(date -r "$RANDOM_EPOCH" "+%Y-%m-%d %H:%M:%S")

  DESCRIPTIONS=("Update project files" "Refactor code" "Fix minor bugs" "Enhance performance" "Update documentation")
  RANDOM_DESCRIPTION=${DESCRIPTIONS[$RANDOM % ${#DESCRIPTIONS[@]}]}

  export GIT_COMMITTER_DATE="$RANDOM_TIME"
  export GIT_AUTHOR_DATE="$RANDOM_TIME"
  git commit --date "$RANDOM_TIME" -m "$RANDOM_DESCRIPTION"
  echo -e "\033[0;32mCommitted with date: $RANDOM_TIME\033[0m"
  echo -e "\033[0;32mCommit message: $RANDOM_DESCRIPTION\033[0m"
  printf "\"%s\"\n" "${SELECTED_FILES[@]}"
}

# 主逻辑：根据输入日期和天数往后递增并执行 auto_commit 函数
start_date=$1
days_count=$2

if ! date -jf "%Y-%m-%d" "$start_date" "+%Y-%m-%d" >/dev/null 2>&1; then
  echo "Invalid date format. Please use YYYY-MM-DD."
  exit 1
fi

current_date="$start_date"
end_date=$(date -v+"$days_count"d -jf "%Y-%m-%d" "$current_date" "+%Y-%m-%d")
current_timestamp=$(date -j -f "%Y-%m-%d %H:%M:%S" "$current_date 00:00:00" "+%s")
end_timestamp=$(date -j -f "%Y-%m-%d %H:%M:%S" "$end_date 00:00:00" "+%s")

while [ "$current_timestamp" -le "$end_timestamp" ]; do
  if is_weekend "$current_date"; then
    current_date=$(date -v+1d -jf "%Y-%m-%d" "$current_date" "+%Y-%m-%d")
    current_timestamp=$(date -j -f "%Y-%m-%d %H:%M:%S" "$current_date 00:00:00" "+%s")
    continue
  fi
  echo "Executing auto_commit for date: $current_date"
  auto_commit "$current_date"
  current_date=$(date -v+1d -jf "%Y-%m-%d" "$current_date" "+%Y-%m-%d")
  current_timestamp=$(date -j -f "%Y-%m-%d %H:%M:%S" "$current_date 00:00:00" "+%s")
done

echo "Finished all commits."
