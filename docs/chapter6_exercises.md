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
