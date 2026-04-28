# チーム開発用 Git / GitHub ルール

## 目的

このページは、チーム開発で Git / GitHub を使うときの基本ルールをそろえ、コード共有をスムーズに行うためのガイドです。

---

## 1. 使うもの

* Git
* GitHub
* VS Code または任意のエディタ

---

## 2. リポジトリ構成

基本ブランチは次のようにします。

* `main` : 発表用・安定版
* `develop` : 開発の中心
* `feature/機能名` : 各自の作業ブランチ

### ブランチ例

* `feature/inventory-ui`
* `feature/recipe-list`
* `feature/training-record`
* `feature/db-setup`

---

## 3. 基本ルール

### 3-1. main に直接 push しない

* `main` は完成版用にする
* 直接変更しない
* 必ず `develop` または `feature` ブランチ経由で反映する

### 3-2. 作業前に最新を取る

作業前は必ず最新の状態を取得する。

```bash
git checkout develop
git pull origin develop
```

その後、自分の作業ブランチを作る。

```bash
git checkout -b feature/機能名
```

### 3-3. 作業は自分のブランチで行う

例：在庫画面担当なら

```bash
git checkout -b feature/inventory-ui
```

### 3-4. こまめに commit する

1つの作業ごとに commit する。

例：

* 画面だけ作った
* ボタンを追加した
* DB接続を追加した

---

## 4. commit メッセージルール

できるだけ簡潔に、日本語でも英語でもよいが統一する。

### 例

* `在庫一覧画面を追加`
* `食材登録フォームを作成`
* `レシピ一覧のUIを修正`
* `DB接続処理を追加`

英語でそろえる場合：

* `add inventory screen`
* `create recipe list UI`
* `fix training record form`

---

## 5. push までの流れ

```bash
git add .
git commit -m "在庫一覧画面を追加"
git push origin feature/inventory-ui
```

---

## 6. マージの流れ

### 基本の流れ

1. `develop` から自分のブランチを作る
2. 作業する
3. push する
4. Pull Request を作る
5. 確認後に `develop` へマージする
6. 動作確認後、最終的に `main` に反映する

---

## 7. Pull Request の書き方

### タイトル例

* 在庫一覧画面を追加
* レシピ詳細画面を作成
* 筋トレ記録機能を追加

### 本文テンプレート

```md
## 変更内容
- 在庫一覧画面の作成
- 食材カードUIの追加

## 確認してほしい点
- レイアウト崩れがないか
- ボタン遷移が問題ないか
```

---

## 8. 作業開始時の手順

```bash
git checkout develop
git pull origin develop
git checkout -b feature/機能名
```

---

## 9. 作業終了時の手順

```bash
git add .
git commit -m "変更内容"
git push origin feature/機能名
```

GitHub 上で Pull Request を作成する。

---

## 10. コンフリクトを減らすコツ

* 同じファイルを複数人で同時に触りすぎない
* 担当範囲を分ける
* 作業前に必ず `pull` する
* 大きすぎる変更を一気に出さない
* UI、ロジック、データをできるだけ分ける

---

## 11. 禁止事項

* `main` に直接 push
* 何を変更したか分からない commit
* 古いコードのまま push
* 他人の作業を勝手に上書き

---

## 12. チームで決めておくと良いこと

* ブランチ名の付け方
* commit メッセージの書き方
* Pull Request は誰が確認するか
* 1日1回の進捗確認

---

## 13. よく使うコマンド一覧

### 状態確認

```bash
git status
```

### ブランチ確認

```bash
git branch
```

### 最新取得

```bash
git pull origin develop
```

### ブランチ作成

```bash
git checkout -b feature/機能名
```

### 追加

```bash
git add .
```

### commit

```bash
git commit -m "変更内容"
```

### push

```bash
git push origin feature/機能名
```

---

## 14. 初回セットアップ

### リポジトリを clone

```bash
git clone リポジトリURL
```

### フォルダへ移動

```bash
cd リポジトリ名
```

### develop ブランチへ移動

```bash
git checkout develop
```

---

## 15. PM向け確認ポイント

* 全員が clone できているか
* develop ブランチがあるか
* feature ブランチ運用になっているか
* main へ直接 push していないか
* Pull Request を通しているか

---

## 16. おすすめ運用

今回のチーム開発では次の運用がおすすめです。

* 発表直前までは `develop` で統合
* 発表に使う安定版だけ `main` に反映
* 各メンバーは `feature/担当名` または `feature/機能名` で作業

例：

* `feature/yamada-inventory`
* `feature/suzuki-recipe`
* `feature/training-ui`

---

## 17. 一言まとめ

* 直接 main を触らない
* 自分のブランチで作業する
* 作業前に pull する
* こまめに commit する
* Pull Request で統合する
