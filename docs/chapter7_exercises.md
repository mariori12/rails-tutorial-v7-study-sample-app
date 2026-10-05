# 第7章の演習メモ

Rails 8の資料をRails 7.0.4.3に読み替えて実装する。

## 7.1 ユーザーを表示する

- **7.1.1**: `/about`のparamsは`controller: static_pages`、`action: about`となる。
  `puts user.attributes.to_yaml`で属性をYAML表示でき、コンソールの`y user.attributes`も
  同じ属性を表示する。デバッグ表示は開発環境だけで有効にした。
  登録時のパスワードを表示しないよう、`params`を`request.filtered_parameters`に読み替えた。
- **7.1.2**: `@user.created_at`、`@user.updated_at`、`Time.now`をERBで表示できる。
  保存済みの日時は再表示しても変わらず、`Time.now`は描画時刻になる。
  一時テンプレートで確認し、完成したプロフィールには演習用日時を残していない。
- **7.1.3**: show内では`@user`が検索したユーザー、`params[:id]`は文字列になる。
  デバッガーでは`puts params.to_unsafe_h.to_yaml`で確認できる。
  7.1時点のnewでは`@user`は`nil`。7.2で`User.new`を代入する。
  今回は同じリクエストの状態をrunnerで確認し、停止用の`debugger`は残していない。
- **7.1.4**: `gravatar_for(user, size: 80)`をキーワード引数で実装した。
  `size: 50`も利用できる。オプションハッシュ版は位置引数としてハッシュを受け取り、
  キーワード引数版は`size`を明示的に受け取る。
  URLのメール小文字化・MD5・サイズ指定はテスト済み。
  任意のGravatarアカウント作成・画像登録は実施していない。

## 7.2 ユーザー登録フォーム

- **7.2.1**: フォームビルダーの変数`f`をすべて`foobar`に変更しても同じ入力欄が生成される。
  テストで確認後、読みやすい`f`へ戻した。名前・メール・パスワード・確認欄を実装した。
- **7.2.2**: `form`の`action`が送信先、`method`がHTTPメソッドを指定する。
  新規ユーザーのフォームは`POST /users`へ送信する。
  `input`の`name="user[email]"`などによって、Railsが`params[:user]`内に値をまとめる。
  `label`の`for`と入力欄の`id`が対応し、パスワード欄は`type="password"`になる。
