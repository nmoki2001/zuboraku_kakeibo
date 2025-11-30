class EntriesController < ApplicationController
  def new
    @expense_entry = Entry.new(direction: :expense)
    @income_entry  = Entry.new(direction: :income)
  end

  def create
    @entry = Entry.new(entry_params)

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
    @entry = Entry.find(params[:id])
  end

  def update
    @entry = Entry.find(params[:id])

    if @entry.update(entry_params)
      # 戻りたい画面に合わせて変更してください（今は入力画面に戻す）
      redirect_to new_entry_path, notice: "修正しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @entry = Entry.find(params[:id])
    @entry.destroy!
    # ここも戻り先はお好みで
    redirect_to new_entry_path, notice: "削除しました"
  end

  private

  def entry_params
    params.require(:entry).permit(:occurred_on, :description, :amount, :direction, :category_id)
  end
end
