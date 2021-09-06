require 'rails_helper'

RSpec.describe UserHiit, type: :model do
  before do
    @user = FactoryBot.create(:user)
    @hiit = FactoryBot.create(:hiit)
    @user_hiit = FactoryBot.build(:user_hiit, hiit_id: @hiit.id, user_id: @user.id)
  end

  describe "モデルの単体テスト" do
    context "保存ができるとき" do
      it "必要な情報が揃っていれば保存ができる" do
        expect(@user_hiit).to be_valid
      end
    end
    context "保存ができない時" do
      it "日付が空欄だと保存ができない" do
        @user_hiit.done_dates = ""
        @user_hiit.valid?
        expect(@user_hiit.errors.full_messages).to include("Done dates can't be blank")
      end
      it "ユーザーに紐づいていなければ保存ができない" do
        @user_hiit.user_id = nil
        @user_hiit.valid?
        expect(@user_hiit.errors.full_messages).to include("User must exist")
      end
      it "Hitが紐づいていなければ保存ができない" do
        @user_hiit.hiit_id = nil
        @user_hiit.valid?
        expect(@user_hiit.errors.full_messages).to include("Hiit must exist")
      end
    end
  end
end
