class EntriesController < ApplicationController
  before_action :set_entry, only: [:edit, :update, :destroy]

  def new
    @expense_entry = Entry.new(direction: :expense)
    @income_entry  = Entry.new(direction: :income)

    @entries = Entry.for_anon_user(current_anon_user_id)
                    .order(occurred_on: :desc)
  end

  def create
    # ★ ここで必ず anon_user_id をセットする
    @entry = Entry.new(entry_params.merge(anon_user_id: current_anon_user_id))

    if @entry.save
      redirect_to new_entry_path, notice: "登録しました"
    else
      # バリデーションエラー時に、同じ画面に戻す
      @expense_entry = Entry.new(direction: :expense)
      @income_entry  = Entry.new(direction: :income)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # @entry は before_action :set_entry で取得済み
  end

  def update
    if @entry.update(entry_params)
      # 戻りたい画面に合わせて変更してください（今は入力画面に戻す）
      redirect_to new_entry_path, notice: "修正しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @entry.destroy!
    # ここも戻り先はお好みで
    redirect_to new_entry_path, notice: "削除しました"
  end

  private

  # ★ 常に「自分のブラウザのデータ」だけを取る
  def set_entry
    @entry = Entry.for_anon_user(current_anon_user_id).find(params[:id])
  end

  def entry_params
    params.require(:entry).permit(:occurred_on, :description, :amount, :direction, :category_id)
  end
end
