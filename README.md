
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
