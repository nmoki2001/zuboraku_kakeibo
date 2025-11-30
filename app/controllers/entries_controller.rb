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

  private

  def entry_params
    params.require(:entry).permit(:occurred_on, :description, :amount, :direction, :category_id)
  end
end
