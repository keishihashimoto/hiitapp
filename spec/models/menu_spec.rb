require 'rails_helper'

RSpec.describe Menu, type: :model do
  before do
    @menu = FactoryBot.build(:menu)
  end
  describe "menu登録の単体テスト" do
    context "登録できる時" do
      it "必要な情報を全て入力すれば登録ができる" do
        expect(@menu).to be_valid
      end
      it "iconを設定しなくても登録ができる" do
        @menu.icon = nil
        expect(@menu).to be_valid
      end
      it "textを設定しなくても登録ができる" do
        @menu.text = ""
        expect(@menu).to be_valid
      end
    end
    context "登録ができない時" do
      it "nameが空欄だと登録ができない" do
        @menu.name = ""
        @menu.valid?
        expect(@menu.errors.full_messages).to include("Name can't be blank")
      end
      it "nameが使用済みだと登録ができない" do
        menu = FactoryBot.create(:menu)
        @menu.name = menu.name
        @menu.valid?
        expect(@menu.errors.full_messages).to include("Name has already been taken")
      end
      it "teamに紐づいていないと登録ができない" do
        @menu.team = nil
        @menu.valid?
        expect(@menu.errors.full_messages).to include("Team must exist")
      end
    end
  end

end
