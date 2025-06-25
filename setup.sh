#!/bin/bash
# Multi-Agent Communication 環境構築
# 参考: setup_full_environment.sh

set -e  # エラー時に停止

# 色付きログ関数
log_info() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[1;34m[SUCCESS]\033[0m $1"
}

echo "Multi-Agent Communication"
echo "==========================================="
echo ""

# STEP 1: 既存セッションクリーンアップ
log_info "既存セッションクリーンアップ開始..."

tmux kill-session -t multiagent 2>/dev/null && log_info "multiagentセッション削除完了" || log_info "multiagentセッションは存在しませんでした"
tmux kill-session -t pm 2>/dev/null && log_info "pmセッション削除完了" || log_info "pmセッションは存在しませんでした"

# 完了ファイルクリア
mkdir -p ./tmp
rm -f ./tmp/bp*_done.txt 2>/dev/null && log_info "既存の完了ファイルをクリア" || log_info "完了ファイルは存在しませんでした"

log_success "クリーンアップ完了"
echo ""

# STEP 2: multiagentセッション作成（4ペイン：techlead + bp1,2,3）
log_info "multiagentセッション作成開始 (4ペイン)..."

# 最初のペイン作成
tmux new-session -d -s multiagent -n "agents"

# 2x2グリッド作成（合計4ペイン）
tmux split-window -h -t "multiagent:0"      # 水平分割（左右）
tmux select-pane -t "multiagent:0.0"
tmux split-window -v                        # 左側を垂直分割
tmux select-pane -t "multiagent:0.2"
tmux split-window -v                        # 右側を垂直分割

# ペインタイトル設定
log_info "ペインタイトル設定中..."
PANE_TITLES=("techlead" "bp1" "bp2" "bp3")

for i in {0..3}; do
    tmux select-pane -t "multiagent:0.$i" -T "${PANE_TITLES[$i]}"
    tmux send-keys -t "multiagent:0.$i" "tmux source ~/.tmux/.tmux.conf" C-m
    # 作業ディレクトリ設定
    tmux send-keys -t "multiagent:0.$i" "cd $(pwd)" C-m
    
    # カラープロンプト設定
    if [ $i -eq 0 ]; then
        # techlead: 赤色
        tmux send-keys -t "multiagent:0.$i" "export PS1='(\[\033[1;31m\]${PANE_TITLES[$i]}\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
    else
        # bps: 青色
        tmux send-keys -t "multiagent:0.$i" "export PS1='(\[\033[1;34m\]${PANE_TITLES[$i]}\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
    fi
    
    # ウェルカムメッセージ
    tmux send-keys -t "multiagent:0.$i" "echo '=== ${PANE_TITLES[$i]} エージェント ==='" C-m
done

log_success "multiagentセッション作成完了"
echo ""

# STEP 3: pmセッション作成（1ペイン）
log_info "pmセッション作成開始..."

tmux new-session -d -s pm
tmux send-keys -t pm "tmux source ~/.tmux/.tmux.conf" C-m
tmux send-keys -t pm "cd $(pwd)" C-m
tmux send-keys -t pm "export PS1='(\[\033[1;35m\]PM\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
tmux send-keys -t pm "echo '=== PM セッション ==='" C-m
tmux send-keys -t pm "echo 'プロジェクト統括責任者'" C-m
tmux send-keys -t pm "echo '========================'" C-m

log_success "pmセッション作成完了"
echo ""

# STEP 4: 環境確認・表示
log_info "環境確認中..."

echo ""
echo "セットアップ結果:"
echo "==================="

# tmuxセッション確認
echo "Tmux Sessions:"
tmux list-sessions
echo ""

# ペイン構成表示
echo "ペイン構成:"
echo "  multiagentセッション（4ペイン）:"
echo "    Pane 0: techlead  (TechLead)"
echo "    Pane 1: bp1       (Developer A)"
echo "    Pane 2: bp2       (Developer B)"
echo "    Pane 3: bp3       (Developer C)"
echo ""
echo "  pmセッション（1ペイン）:"
echo "    Pane 0: PM (Project Manager)"

echo ""
log_success "環境セットアップ完了"
echo ""
echo " 次のステップ:"
echo "  1. セッションアタッチ:"
echo "     tmux attach-session -t multiagent  # マルチエージェント アタッチ"
echo "     tmux attach-session -t pm          # Project Manager アタッチ"
echo ""
echo "  2. Claude Code起動:"
echo "     # 手順1: pm認証"
echo "     tmux send-keys -t pm 'claude --dangerously-skip-permissions' C-m"
echo "     # 手順2: 認証後、multiagent一括起動"
echo "     for i in {0..3}; do tmux send-keys -t multiagent:0.\$i 'claude --dangerously-skip-permissions' C-m; done"
echo ""
echo "  3. 指示書確認:"
echo "     PM          : roles/pm.md"
echo "     Techlead    : roles/techlead.md"
echo "     BP1,2,3     : roles/bp.md"
echo "     システム構造 : CLAUDE.md"
echo ""
echo "  4. デモ実行: PMに「あなたはpmです。～を作成したいです。」と入力" 
