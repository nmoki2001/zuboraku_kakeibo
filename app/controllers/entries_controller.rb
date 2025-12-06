class EntriesController < ApplicationController
  before_action :set_entry, only: [:edit, :update, :destroy]

  def new
    @expense_entry = Entry.new(direction: :expense)
    @income_entry  = Entry.new(direction: :income)

    @entries = Entry.for_anon_user(current_anon_user_id)
                    .order(occurred_on: :desc)
  end

  def create
    @entry = Entry.new(entry_params.merge(anon_user_id: current_anon_user_id))

    if @entry.save
      redirect_to new_entry_path, notice: "登録しました"
    else
      @expense_entry = Entry.new(direction: :expense)
      @income_entry  = Entry.new(direction: :income)
      @entries = Entry.for_anon_user(current_anon_user_id)
                      .order(occurred_on: :desc)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @entry.update(entry_params)
      redirect_to analysis_path, notice: "修正しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @entry.destroy!
    redirect_to analysis_path, notice: "削除しました"
  end

  private

  def set_entry
    # ★ そのブラウザ（匿名ユーザー）のデータだけから探す
    @entry = Entry.for_anon_user(current_anon_user_id).find(params[:id])
  end

  def entry_params
    params.require(:entry).permit(:occurred_on, :description, :amount, :direction, :category_id)
  end
end
