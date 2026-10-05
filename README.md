
## 学習ログ
### 2026-10-02 GitHub 環境構築
- 403 エラー：古い認証情報が残っていたため削除して解決
- 空フォルダが push されない：Git の仕様。README を配置して解決
- トークン認証失敗：入力値を文字数で検証してから credential に登録して解決

### Terraform × Docker
- nginx コンテナを Terraform で構築（init → plan → apply → destroy）
- 既存コンテナとのポート競合を docker ps で事前に確認し、空きポートを使用
- ポート番号の変更だけで「must be replaced（作り直し）」になることを plan で確認
  → 本番では plan による事前確認が重要だと理解


### GitHub Actions × Terraform
- push 時に terraform fmt -check / validate を自動実行するワークフローを作成
- fmt -check で終了ステータス 3（書式不備）を検出 → -diff で差分確認 → terraform fmt で整形
- push 時に "without workflow scope" で拒否 → トークンに Workflows 権限を追加して解決
- Actions が成功（緑）になることを確認

### Trivy による脆弱性スキャン

#### 1. Trivy 自体の安全性を確認（脆弱性情報の収集）
- 2026年3月に Trivy の GitHub Actions がサプライチェーン攻撃を受けていたことを確認
- 公式アドバイザリ GHSA-69fq-xp46-6x23 で安全なバージョンを確認
  - Trivy 本体：v0.69.2 / v0.69.3
  - trivy-action：v0.35.0 / setup-trivy：v0.2.6
- 対応：Trivy 公式イメージを 0.69.3 に固定して使用

#### 2. nginx イメージのスキャン（検出）
- nginx:latest（Debian 13.7）：HIGH 79件 / CRITICAL 1件（合計80件）
- --rm で毎回 DB を再ダウンロードして遅かったため、Docker ボリュームでキャッシュして高速化

#### 3. CRITICAL の調査（影響調査）
- CVE-2026-6653（libxml2）
- 内容：細工された XML 入力によるサービス停止（DoS）
- Trivy の判定：CRITICAL / Status：affected / 修正版：なし
- Debian セキュリティトラッカーで確認
- 学び：ツールの判定と公式ドキュメントの判断が異なることがあるため、両方を確認する

#### 4. 改善：ベースイメージの見直し（パッチ運用と再展開）
- nginx:alpine をスキャン：HIGH 2件 / CRITICAL 0件（80件 → 2件、約97%削減）
- 理由：Alpine は必要最小限のパッケージ構成のため
- Terraform で nginx:latest → nginx:alpine に変更
  - plan でイメージとコンテナの両方が作り直しになることを確認（参照による連鎖）
  - apply → curl で動作確認 → destroy で片付け
- 注意点：互換性の違いがあるため、切り替え前に動作確認が必要

#### 5. 気づき
- terraform plan の出力は色の制御文字を含むため、grep する場合は -no-color を付ける
