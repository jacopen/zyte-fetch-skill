# zyte-fetch-skill

[Zyte API](https://www.zyte.com/) を利用してWebページを取得する [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 用カスタムスキルです。

Claude Code の標準の `web_fetch` ではJavaScriptで動的にレンダリングされるサイトの内容を取得できない場合があります。このスキルは Zyte API のブラウザレンダリング機能を通じてページを取得するため、SPA や JS 依存のサイトでも正しくコンテンツを取得できます。

## 特徴

- **ブラウザレンダリング** — JavaScript を実行した状態の HTML を取得
- **アンチボット対策のバイパス** — Zyte のプロキシローテーションとフィンガープリント処理
- **スクリーンショット取得** — レンダリング済みページの PNG スクリーンショット
- **HTTP モード** — 静的ページ向けの高速な生 HTTP レスポンス取得

## 前提条件

- [Zyte API](https://www.zyte.com/) のアカウントと API キー
- `curl` と `jq` がインストールされていること
- `base64` コマンド（macOS / Linux 標準搭載）

## インストール

### 1. リポジトリのクローン

スキルの配置先は任意ですが、ここでは `~/.claude/skills/` 以下を例にします。

```bash
git clone https://github.com/jacopen/zyte-fetch-skill.git ~/.claude/skills/zyte-fetch-skill
```

### 2. Zyte API キーの設定

```bash
mkdir -p ~/.config/zyte
echo "YOUR_ZYTE_API_KEY" > ~/.config/zyte/api_key
chmod 600 ~/.config/zyte/api_key
```

環境変数 `ZYTE_API_KEY_FILE` でキーファイルのパスを変更することもできます。

```bash
export ZYTE_API_KEY_FILE=/path/to/your/api_key
```

### 3. Claude Code にスキルを登録

プロジェクトの `.claude/settings.json` またはユーザー設定 `~/.claude/settings.json` に以下を追加します。

```json
{
  "skills": [
    "~/.claude/skills/zyte-fetch-skill/SKILL.md"
  ]
}
```

## 使い方

### Claude Code 上での利用

スキルを登録すると、Claude Code が Web ページの取得時に自動的にこのスキルを選択肢として認識します。以下のようなケースで有効です。

- `web_fetch` で空や不完全なコンテンツが返ってきた場合
- JavaScript レンダリングが必要なサイトの取得
- アンチボット保護があるサイトへのアクセス
- ページのスクリーンショットが必要な場合

### スクリプト単体での利用

`scripts/zyte_fetch.sh` は単体でも利用できます。

#### ブラウザレンダリング（デフォルト）

JS を実行した状態の HTML を取得します。

```bash
scripts/zyte_fetch.sh "https://example.com"
```

#### HTTP モード

JS 不要の静的ページを高速に取得します。

```bash
scripts/zyte_fetch.sh "https://example.com" --http
```

#### スクリーンショット

レンダリング済みページの HTML とスクリーンショット（PNG）を保存します。

```bash
scripts/zyte_fetch.sh "https://example.com" --screenshot --output page.html
# page.html と page.png が出力されます
```

#### Raw JSON レスポンス

Zyte API のレスポンスをそのまま JSON で出力します。

```bash
scripts/zyte_fetch.sh "https://example.com" --raw-json
```

### オプション一覧

| オプション | 説明 |
|---|---|
| `--http` | ブラウザレンダリングの代わりに HTTP モードを使用（高速・JS なし） |
| `--screenshot` | スクリーンショットを PNG で保存 |
| `--output FILE` | 結果を stdout ではなくファイルに出力 |
| `--raw-json` | Zyte API の生 JSON レスポンスを出力 |

## web_fetch との使い分け

| 状況 | 推奨ツール |
|---|---|
| 静的な HTML ページ | `web_fetch`（無料・高速） |
| JS レンダリングが必要なサイト | `zyte_fetch`（ブラウザモード） |
| `web_fetch` で空/不完全な結果 | `zyte_fetch`（ブラウザモード） |
| アンチボット保護があるサイト | `zyte_fetch` |
| スクリーンショットが必要 | `zyte_fetch --screenshot` |

## ライセンス

[MIT License](LICENSE)
