#!/bin/bash

# 全局变量：保存所有已添加的文件
SELECTED_FILES=()
ADDED_FILES=()

# 定义全局随机文件数量范围
RANDOM_MIN_FILES=6
RANDOM_MAX_FILES=10

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
  # 检查是否传入日期参数
  if [ -z "$1" ]; then
    echo "Usage: auto_commit <date-in-YYYY-MM-DD-format>"
    return 1
  fi

  INPUT_DATE=$1

  # 检查输入日期的格式是否正确
  if ! date -jf "%Y-%m-%d" "$INPUT_DATE" "+%Y-%m-%d" >/dev/null 2>&1; then
    echo "Invalid date format. Please use YYYY-MM-DD."
    return 1
  fi

  # 获取当前工作目录
  CURRENT_DIR=$(pwd)

  # 获取文件列表
  # 获取所有改动的文件（包括未跟踪的文件）
  IFS=$'\n'
  FILES_TO_COMMIT=($(git status --porcelain | awk '{print substr($0, 4)}' | sed 's/^"//; s/"$//' | while read -r path; do
    # 如果是文件，直接输出
    if [ -f "$path" ]; then
      echo "$path"
    # 如果是目录，递归列出所有文件并输出
    elif [ -d "$path" ]; then
      find "$path" -type f
    else
    # 如果是已删除文件或其他类型，直接输出原始路径
    echo "$path"
  fi
  done))
  unset IFS


  # 检查文件数量
  FILE_COUNT=${#FILES_TO_COMMIT[@]}
  if [ "$FILE_COUNT" -lt "$RANDOM_MIN_FILES" ]; then
    echo "Not enough files to add. Found $FILE_COUNT files. At least $RANDOM_MIN_FILES files are required."

    # 如果文件数量不足，额外执行一次 `git add -A` 和 `git commit`
    export GIT_COMMITTER_DATE="$INPUT_DATE 18:00:00"
    export GIT_AUTHOR_DATE="$INPUT_DATE 18:00:00"

    # 执行 最后一次Git 提交
    git add -A
    git commit --date "$INPUT_DATE 18:00:00" -m "files done"

    return 1
  fi

  # 随机选择 5～8 个文件
  SELECTED_COUNT=0
  RANDOM_FILE_COUNT=$((RANDOM % (RANDOM_MAX_FILES - RANDOM_MIN_FILES + 1) + RANDOM_MIN_FILES))

  while [ "$SELECTED_COUNT" -lt "$RANDOM_FILE_COUNT" ]; do
    # 随机选择一个文件
    RANDOM_FILE="${FILES_TO_COMMIT[$RANDOM % ${#FILES_TO_COMMIT[@]}]}"

    # if [ ! -f "$RANDOM_FILE" ] && [ ! -d "$RANDOM_FILE" ]; then 
    #     continue
    # fi
    # 如果文件尚未被添加，则加入选定文件列表
    if ! is_already_added "$RANDOM_FILE"; then
      SELECTED_FILES+=("$RANDOM_FILE")
      ADDED_FILES+=("$RANDOM_FILE") # 更新全局变量
      git add -- "$RANDOM_FILE" # 处理带空格的路径
      SELECTED_COUNT=$((SELECTED_COUNT + 1))

    fi
  done
  # 设置随机提交时间
  BASE_TIME="${INPUT_DATE} 13:30:00"
  BASE_EPOCH=$(date -jf "%Y-%m-%d %H:%M:%S" "$BASE_TIME" "+%s")
  RANDOM_MINUTES=$((RANDOM % 330))
  RANDOM_EPOCH=$((BASE_EPOCH + RANDOM_MINUTES * 60))
  RANDOM_TIME=$(date -r "$RANDOM_EPOCH" "+%Y-%m-%d %H:%M:%S")

  # 自动生成描述信息
  DESCRIPTIONS=(
  "Update project files" "Refactor code" "Fix minor bugs" "Enhance performance" "Update documentation" "Adjust configurations"
  "Add new feature" "Improve UI design" "Fix security vulnerability" "Optimize code" "Fix regression issue" "Refactor user authentication"
  "Add unit tests" "Fix crash bug" "Update dependencies" "Clean up code" "Refactor database queries" "Improve API performance"
  "Fix memory leak" "Fix UI layout issue" "Implement logging" "Improve error handling" "Update README" "Refactor models"
  "Update style guidelines" "Enhance accessibility" "Fix broken links" "Refactor network layer" "Fix issue with search functionality" "Improve code coverage"
  "Refactor error handling" "Enhance logging" "Add localization support" "Fix UI alignment issue" "Improve performance on large datasets" "Update analytics tracking"
  "Refactor file structure" "Improve authentication flow" "Fix race condition" "Optimize startup time" "Add caching mechanism" "Refactor data validation"
  "Update testing framework" "Improve form validation" "Fix typo in documentation" "Refactor HTTP client" "Add user profile feature" "Optimize image rendering"
  "Fix edge case in user input handling" "Refactor the database schema" "Add custom error pages" "Update third-party libraries" "Fix broken API endpoint" "Refactor search algorithm"
  "Add pagination to API" "Update privacy policy" "Fix bug in session handling" "Refactor event logging" "Improve session timeout handling" "Fix memory management issue"
  "Refactor product filtering" "Fix issue with session persistence" "Update user onboarding process" "Improve network error handling" "Fix bug with multi-language support" "Refactor login flow"
  "Update build configuration" "Fix issue with image loading" "Refactor content management system" "Fix bug in push notifications" "Improve data synchronization" "Update deployment scripts"
  "Refactor data models" "Fix bug in cart system" "Enhance user permissions" "Improve accessibility for screen readers" "Fix incorrect error messages" "Refactor user interface"
  "Add search functionality to the admin panel" "Update API documentation" "Fix bug with form submission" "Enhance analytics integration" "Fix bug in payment gateway" "Refactor code comments"
  "Improve notification system" "Update translation files" "Refactor user activity tracking" "Fix bug with user profile update" "Improve code quality" "Fix bug with password reset"
  "Update libraries to latest versions" "Improve support for dark mode" "Refactor login component" "Fix issue with loading states" "Add multi-language support" "Fix bug in checkout process"
  "Refactor session management" "Fix bug in order processing" "Improve error messages" "Refactor data fetching logic" "Update system configuration" "Add new analytics events"
  "Fix issue with data consistency" "Improve performance of search functionality" "Update admin dashboard" "Fix issue with email notifications" "Refactor data syncing" "Fix bug in payment processing"
  "Improve database performance" "Update user interface components" "Fix bug with email verification" "Improve build time" "Fix issue with API rate limiting" "Refactor API response format"
  "Fix bug with notification preferences" "Refactor user preferences handling" "Update error logging system" "Fix issue with product details page" "Refactor authentication system" "Add new user roles"
  "Fix issue with user permissions" "Improve data export functionality" "Refactor user management" "Add real-time updates to dashboard" "Update payment integration" "Fix issue with coupon system"
  "Refactor API client" "Add new filtering options to search" "Improve documentation for developers" "Fix bug with currency formatting" "Refactor payment processing" "Update user interface design"
  "Fix bug with invoice generation" "Enhance search functionality" "Refactor API endpoints" "Improve search result ranking" "Fix issue with multi-step form" "Refactor user feedback system"
  "Fix bug with product recommendations" "Update database indexes" "Refactor code for readability" "Fix issue with product reviews" "Improve user profile page" "Fix bug with inventory system"
  "Refactor data transformation logic" "Add dark mode support" "Fix issue with multi-language support" "Refactor caching strategy" "Improve build pipeline" "Fix issue with sorting products"
  "Fix issue with user notifications" "Refactor session timeout handling" "Improve security features" "Fix issue with image cropping" "Refactor error handling system" "Update package dependencies"
  "Fix bug with promo code system" "Improve error reporting" "Refactor user account management" "Fix bug in order history" "Add search feature to admin panel" "Update server configuration"
  "Fix issue with product categories" "Improve mobile responsiveness" "Fix issue with tax calculations" "Refactor code for performance" "Improve multi-device support" "Fix bug with discount calculations"
  "Refactor data input validation" "Fix issue with user avatar upload" "Improve accessibility for keyboard navigation" "Fix bug with discount codes" "Update third-party services" "Refactor data storage"
  "Fix bug with shipping address form" "Update security settings" "Improve loading speed" "Fix issue with order tracking" "Refactor mobile app integration" "Fix bug in user profile edit"
  "Refactor API versioning" "Fix issue with coupon code" "Improve support for multiple payment methods" "Refactor UI components" "Add better error handling to forms" "Fix issue with shipping calculations"
  "Improve customer support integration" "Fix bug with user feedback" "Refactor user dashboard" "Fix bug in product search" "Improve authentication flow" "Fix issue with multi-step checkout"
  "Update app permissions" "Fix bug with cart system" "Improve accessibility for vision impaired" "Refactor API pagination" "Fix bug with product inventory" "Update code documentation"
  "Add support for new payment gateway" "Improve user experience on mobile devices" "Fix issue with order processing" "Refactor order management system" "Fix issue with user sign up" "Improve application performance"
  "Fix issue with promotions" "Refactor user notifications system" "Fix bug with account settings" "Add user activity tracking" "Update payment processing system" "Fix issue with data export"
  "Refactor code for testability" "Improve data integrity checks" "Fix issue with promotions display" "Add better error messages for users" "Fix bug with delivery options" "Improve code structure"
  "Refactor order history feature" "Add support for real-time chat" "Fix issue with address form" "Refactor coupon system" "Fix bug with invoice details" "Update payment gateway"
  "Improve user account security" "Fix issue with tax rates" "Refactor authentication process" "Update dashboard layout" "Fix issue with image upload" "Add better documentation"
  "Fix issue with product availability" "Update user preferences" "Refactor product management system" "Fix bug with payment methods" "Improve search performance" "Refactor checkout process"
)
  RANDOM_DESCRIPTION=${DESCRIPTIONS[$RANDOM % ${#DESCRIPTIONS[@]}]}

  # 设置 Git 提交的时间
  export GIT_COMMITTER_DATE="$RANDOM_TIME"
  export GIT_AUTHOR_DATE="$RANDOM_TIME"

  # 执行 Git 提交
  git commit --date "$RANDOM_TIME" -m "$RANDOM_DESCRIPTION"

  # 输出提交信息
  # 定义绿色和重置颜色变量
  GREEN='\033[0;32m'
  RESET='\033[0m'

  # 输出日志时使用绿色
  echo "${GREEN}Committed with date: $RANDOM_TIME${RESET}"
  echo "${GREEN}Commit message: $RANDOM_DESCRIPTION${RESET}"

  echo "Files added:"
  printf "\"%s\"\n" "${SELECTED_FILES[@]}" # 输出文件列表时加双引号
}

# 检查日期是否为周末（周六=6，周日=7）
is_weekend() {
  local date=$1
  DAY_OF_WEEK=$(date -jf "%Y-%m-%d" "$date" "+%u")
  [ "$DAY_OF_WEEK" -ge 6 ]
}

# 主逻辑：根据输入日期和天数往回倒退并执行 auto_commit 函数
start_date=$1
days_count=$2

# 检查日期格式
if ! date -jf "%Y-%m-%d" "$start_date" "+%Y-%m-%d" >/dev/null 2>&1; then
  echo "Invalid date format. Please use YYYY-MM-DD."
  exit 1
fi

# 计算目标日期
current_date="$start_date"
target_date=$(date -v-"$days_count"d -jf "%Y-%m-%d" "$current_date" "+%Y-%m-%d")
# 将日期转换为 Unix 时间戳进行比较
current_timestamp=$(date -j -f "%Y-%m-%d %H:%M:%S" "$current_date 00:00:00" "+%s")
target_timestamp=$(date -j -f "%Y-%m-%d %H:%M:%S" "$target_date 00:00:00" "+%s")

# 往回倒退直到目标日期
while [ "$current_timestamp" -gt "$target_timestamp" ]; do
  # 如果当前日期是周末，跳过
  if is_weekend "$current_date"; then
    current_date=$(date -v-1d -jf "%Y-%m-%d" "$current_date" "+%Y-%m-%d")
    current_timestamp=$(date -j -f "%Y-%m-%d %H:%M:%S" "$current_date 00:00:00" "+%s")
    continue
  fi
  # 调用 auto_commit 函数
  echo "Executing auto_commit for date: $current_date"
  auto_commit "$current_date"

  # 倒退一天
  current_date=$(date -v-1d -jf "%Y-%m-%d" "$current_date" "+%Y-%m-%d")
  current_timestamp=$(date -j -f "%Y-%m-%d %H:%M:%S" "$current_date 00:00:00" "+%s")
done

echo "Finished all commits."
