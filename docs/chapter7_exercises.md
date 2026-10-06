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

## 7.3 ユーザー登録失敗

- **7.3.2**: `/signup?admin=1`の`params[:admin]`は文字列`"1"`になる。
  paramsに存在することとモデルへの代入許可は別である。
  Rails 8の`params.expect`はRails 7の`params.require(:user).permit(...)`へ読み替えた。
  `id`、`created_at`、`admin`などをフォームに追加しても代入されないことをテストした。
- **7.3.3**: 名前を空、メールを`user@invalid`、パスワードと確認を空にすると5件のエラーになる。
  パスワードの存在性検証が二重に働くため、空欄のエラーが重複する。
  未送信は`GET /signup`、送信後は`POST /users`である。
  `render 'new'`はビューを再描画するだけでリダイレクトしないためURLは`/users`のままになる。
- **7.3.4**: ユーザー数が増えないこと、422応答、タイトル、エラー件数、エラー表示のCSSを検証した。
  名前・メールの再表示とパスワードを再表示しないことも確認する。

各コミットを動作可能にするため、保存成功時の基本リダイレクトは7.3で実装した。
TurboでPOST後にGETへ移動できるよう303応答を使用し、成功メッセージは7.4で追加する。

## 7.4 ユーザー登録成功

- **7.4.1**: 登録後に`User.find_by!(email: ...)`で保存を確認した。
  `redirect_to @user`と`redirect_to user_url(@user)`の両方で同じ統合テストが成功する。
- **7.4.2**: シンボル`:success`を文字列展開すると`success`となる。
  flashのキーを`alert-success`などのBootstrapクラス名に展開して表示する。
- **7.4.3**: 登録、DB保存、プロフィール表示を統合テストで確認した。
  既存の開発DBを消す`db:migrate:reset`は行わず、テストのトランザクションを利用した。
  GravatarのURLと画像タグは検証したが、外部アカウントへの画像登録は行っていない。
- **7.4.4**: flashが空でないこと、成功メッセージの表示、次のリクエストで消えることを検証した。
  演習に従い`content_tag`でflashのHTMLを生成した。
  リダイレクトを外すと応答のテストが失敗し、`@user.save`を`false`にすると
  `User.count`が1増えないため`assert_difference`が失敗することを確認して元に戻した。

## 7.5 プロのデプロイ

- **7.5.1**: 本番環境で`config.force_ssl = true`を設定した。
  RailsのSSLミドルウェアがHTTPをHTTPSへリダイレクトし、HTTPSを通すことをローカルで検証した。
- **7.5.2**: 資料どおりPumaのworker数を`WEB_CONCURRENCY`で指定し、既定値を4にした。
  `preload_app!`を有効にし、Procfileの起動を`puma -C config/puma.rb`に変更した。
  環境変数でworker数を変更できることも検証した。
- **7.5.3**: productionのPostgreSQL用`pg`と`DATABASE_URL`は既に設定済みのため維持した。
  ダミーの接続URLを使い、DBへ接続せず本番設定の起動とアダプター選択を確認した。
- **7.5.4**: RenderのBuild Commandは`./bin/render-build.sh`、Start Commandは
  `bundle exec puma -C config/puma.rb`を指定する。
  本番の`DATABASE_URL`と`RAILS_MASTER_KEY`または適切な秘密鍵の設定が必要になる。
  worker数は利用するサービスのメモリに合わせて`WEB_CONCURRENCY`で調整する。

これまでと同様、ローカル実装・テスト・コミットまでを実施した。
mainへのマージ、push、Render設定変更・デプロイは行っていない。
7.5の演習にある公開URLのHTTPS確認、本番での登録・Gravatar表示確認は未実施である。

## 7.6 最後に

この節はまとめであり、新しいアプリケーション機能の追加はない。
登録フォームから送信し、失敗時はエラー付きで再表示、成功時は保存したユーザーの
プロフィールへ移動して一度だけ成功メッセージを表示する流れが完成した。
ログインとログアウトは第8章以降のため、まだ実装していない。

最終検証は31テスト・100アサーションで失敗・エラーなし。
プロフィールとフォームのCSSコンパイル、Puma設定、本番設定の起動、
SSLミドルウェアのリダイレクトもローカルで確認した。
