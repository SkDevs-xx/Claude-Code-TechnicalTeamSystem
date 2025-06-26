#!/bin/bash
# 改良版：Agent間メッセージ送信スクリプト

# エージェント→tmuxターゲット マッピング
get_agent_target() {
    case "$1" in
        "tech") echo "tech" ;;
        "bp1") echo "multiagent:0.0" ;;
        "bp2") echo "multiagent:0.1" ;;
        "bp3") echo "multiagent:0.2" ;;
        "bp4") echo "multiagent:0.3" ;;
        *) echo "" ;;
    esac
}

# 送信元を環境変数から取得（またはコマンドライン引数）
get_sender_role() {
    # 環境変数 AGENT_ROLE が設定されていればそれを使用
    if [[ -n "$AGENT_ROLE" ]]; then
        echo "$AGENT_ROLE"
    else
        # tmuxペイン情報から推測
        local pane_info=$(tmux display-message -p '#S:#I.#P')
        case "$pane_info" in
            "tech:0.0") echo "tech" ;;
            "multiagent:0.0") echo "bp1" ;;
            "multiagent:0.1") echo "bp2" ;;
            "multiagent:0.2") echo "bp3" ;;
            "multiagent:0.3") echo "bp4" ;;
            *) echo "unknown" ;;
        esac
    fi
}

# コンテキストプレフィックスを生成
generate_prefix() {
    local sender="$1"
    local receiver="$2"
    
    case "$sender-$receiver" in
        "tech")       echo "[MISSION FROM TECH]" ;;
        "tech-bp"*)   echo "[TASK FROM TECHLEAD]" ;;
        "bp"*"-tech") echo "[REPORT FROM ${sender^^}]" ;;
        *) echo "[MESSAGE FROM $sender TO $receiver]" ;;
    esac
}

# メッセージ送信（改良版）
send_message() {
    local target="$1"
    local message="$2"
    local sender="$3"
    local receiver="$4"
    
    # プレフィックスを生成
    local prefix=$(generate_prefix "$sender" "$receiver")
    
    echo "送信中: $sender → $receiver ($target)"
    echo "プレフィックス: $prefix"
    
    # Claude Codeのプロンプトを一度クリア
    tmux send-keys -t "$target" C-c
    sleep 0.3
    
    # プレフィックス付きメッセージ送信
    tmux send-keys -t "$target" "$prefix: $message"
    sleep 0.1
    
    # エンター押下
    tmux send-keys -t "$target" C-m
    sleep 0.5
}

# 使用方法の表示（改良版）
show_usage() {
    cat << EOF
改良版Agent間メッセージ送信

使用方法:
  $0 [受信エージェント] [メッセージ] [送信元エージェント（オプション）]
  $0 --list

環境変数:
  AGENT_ROLE - 送信元エージェントを指定（tech, bp1, bp2, bp3, bp4）

使用例:
  # 送信元を明示的に指定
  $0 tech '{"mission_id": "TEST"}' tech
  
  # 環境変数で送信元を設定
  export AGENT_ROLE=tech
  $0 tech '{"mission_id": "TEST"}'
  
  # 自動検出（tmuxペイン情報から）
  $0 bp1 '{"task_id": "DB_SETUP"}'
EOF
}

# メイン処理（改良版）
main() {
    if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]]; then
        show_usage
        exit 0
    fi
    
    if [[ "$1" == "--list" ]]; then
        echo "📋 利用可能なエージェント:"
        echo "=========================="
        echo "  tech    → tech           (プロジェクト統括責任者)"
        echo "  bp1     → multiagent:0.0 (実行担当者A)"
        echo "  bp2     → multiagent:0.1 (実行担当者B)"
        echo "  bp3     → multiagent:0.2 (実行担当者C)"
        echo "  bp4     → multiagent:0.3 (実行担当者D)"
        exit 0
    fi
    
    local receiver="$1"
    local message="$2"
    local sender="${3:-$(get_sender_role)}"  # 第3引数がなければ自動検出
    
    # ターゲット取得
    local target=$(get_agent_target "$receiver")
    
    if [[ -z "$target" ]]; then
        echo "❌ エラー: 不明なエージェント '$receiver'"
        exit 1
    fi
    
    # メッセージ送信
    send_message "$target" "$message" "$sender" "$receiver"
    
    # ログ記録（送信元情報も含む）
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    mkdir -p logs
    echo "[$timestamp] $sender → $receiver: \"$message\"" >> logs/send_log.txt
    
    echo "✅ 送信完了: $sender → $receiver"
    
    return 0
}

main "$@"