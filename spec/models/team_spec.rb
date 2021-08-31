require 'rails_helper'

RSpec.describe Team, type: :model do
  before do
    @team = FactoryBot.build(:team)
  end
  describe "チーム登録の単体テスト" do
    context "登録できる時" do
      it "チーム名を入力していれば登録ができる" do
        expect(@team).to be_valid
      end
    end
    context "登録できない時" do
      it "チーム名が空欄だと登録できない" do
        @team.name = ""
        @team.valid?
        expect(@team.errors.full_messages).to include("Name can't be blank")
      end
      it "チーム名が他のチームと重複していると登録ができない" do
        team = FactoryBot.create(:team)
        @team.name = team.name
        @team.valid?
        expect(@team.errors.full_messages).to include("Name has already been taken")
      end
    end
  end

end
