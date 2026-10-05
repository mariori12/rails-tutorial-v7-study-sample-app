# 第6章の演習メモ

Rails 8の資料を、このプロジェクトのRails 7.0.4.3で実施する。

## 6.1 Userモデル

- **6.1.1**: マイグレーションは変更手順、`db/schema.rb`は適用後の構造を表す。
  `users`には`id`、`name`、`email`、`created_at`、`updated_at`ができる。
  Rails 7に合わせて`ActiveRecord::Migration[7.0]`を使用した。
  空のテーブルで`db:rollback`による削除と`db:migrate`による再作成を確認した。
- **6.1.2**: `User.new.is_a?(ApplicationRecord)`は`true`。
  `ApplicationRecord < ActiveRecord::Base`も`true`になる。
- **6.1.3**: 保存したユーザーの`name`と`email`は`String`。
  `created_at`と`updated_at`は`ActiveSupport::TimeWithZone`になる。
- **6.1.4**: `User.find_by(name: user.name)`と`User.find_by_name(user.name)`で検索できる。
  `User.all`は`User::ActiveRecord_Relation`であり、`length`で件数を取得できる。
- **6.1.5**: `user.name = 'Updated User'`の後に`user.save!`で保存できる。
  `user.update!(email: 'updated@example.com')`でメールを変更できる。
  `user.update!(created_at: 1.year.ago)`で作成日時も変更できる。
  未保存の変更は`reload`で破棄される。

作成・検索・更新・削除はトランザクション内で確認し、演習データはロールバックした。
6.2以降は検証が加わるため、上記の操作にも有効な属性が必要になる。

## 6.2 ユーザーを検証する

- **6.2.1**: この節の段階では、名前と有効なメールを指定した`User.new`は有効になる。
  `User.new.valid?`は存在性の検証を加えると`false`になる。
- **6.2.2**: 未入力の名前には`can't be blank`、未入力のメールには
  `can't be blank`と`is invalid`が入る。`u.valid?`の後に
  `u.errors.messages`で全体を、`u.errors[:email]`でメールのエラーを取得できる。
- **6.2.3**: 名前51文字、メール256文字は無効。
  `is too long (maximum is 50 characters)`と
  `is too long (maximum is 255 characters)`を確認した。境界の50文字・255文字は有効。
- **6.2.4**: 外部の正規表現ツールに代えて、Rubyの正規表現をモデルテストで確認した。
  大文字を含む有効なアドレスも`i`オプションで受け入れる。
  ドメインの連続ドット`foo@bar..com`を無効な例に追加した。
  元の正規表現ではテストが失敗し、リスト6.23の正規表現では成功することを確認した。
- **6.2.5**: `before_save { email.downcase! }`で小文字化する。
  `!`付きメソッドは文字列自体を書き換えるため、`self.email =`の代入を省略できる。
  保存後に`reload`して小文字化を検証し、コールバックを外すとテストが失敗することも確認した。
  重複メールはモデルの検証に加え、DBの一意インデックスでも拒否する。
  自動生成された重複fixtureは削除した。

資料後半の`uniqueness: true`だけでは、このRails 7・SQLite環境では大文字の重複に対する
`valid?`が成功してしまう。そのため`uniqueness: { case_sensitive: false }`を維持し、
大小文字を変えた重複のテストを残した。小文字化後のDB制約に到達する前に検証で拒否できる。

## 6.3 セキュアなパスワードを追加する

- **6.3.1**: `password_digest`カラムと`bcrypt`を追加し、`has_secure_password`を使用する。
  DBには平文パスワードではなくダイジェストを保存する。
- **6.3.2**: 名前とメールが有効でも、パスワードがなければ無効になる。
  `user.errors[:password]`には存在性や最小長のエラーが入る。
- **6.3.3**: 演習に従い最小長を本文の6文字から8文字へ変更した。
  7文字は`is too short (minimum is 8 characters)`で拒否し、8文字は受け入れる。
  空白だけのパスワードも拒否する。最小長を6に戻すと境界値テストが失敗することを確認した。
  テストの有効なパスワードも8文字へ変更した。
- **6.3.4**: `User.find(user.id)`で取得し直したユーザーでも、正しいパスワードの
  `authenticate`はユーザー自身を返し、誤ったパスワードでは`false`を返す。
  取得し直すと仮想属性`password`は`nil`なので、名前を変更して`save`すると
  この章のパスワード存在性・最小長の検証に失敗する。
  演習の`update_attribute(:name, 'Updated User')`なら検証を省略して更新できる。
  これは演習用の確認であり、一般の入力を検証せず保存する実装は追加していない。

Rails 7.0.4.3の`has_secure_password`は最大長を文字数で確認する。
bcryptの上限72バイトを超える日本語25文字を標準処理が受け入れることをテストで確認したため、
バイト数を検証する処理を追加した。ASCIIの72文字・日本語24文字は有効、
ASCIIの73文字・日本語25文字は無効となる。確認用ユーザーの操作はロールバックした。
