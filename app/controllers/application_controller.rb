class ApplicationController < ActionController::Base
  # モダンブラウザ制限（元の設定を保持）
  allow_browser versions: :modern

  # 全ページで匿名ユーザーIDをセット
  before_action :set_anonymous_user

  private

  # 匿名ユーザーIDを cookie に保存（なければ生成）
  def set_anonymous_user
    # signed: 改ざん防止（Railsが署名付与）
    # permanent: 有効期限 20 年レベル
    cookies.permanent.signed[:anon_user_id] ||= SecureRandom.uuid
  end

  # どこからでも利用できるヘルパー
  def current_anon_user_id
    cookies.signed[:anon_user_id]
  end
end
