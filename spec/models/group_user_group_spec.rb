require 'rails_helper'

RSpec.describe GroupUserGroup, type: :model do
  before do
    @team = FactoryBot.create(:team)
    @user1 = FactoryBot.create(:user, team_id: @team.id)
    sleep 0.1
    @user2 = FactoryBot.create(:user, team_id: @team.id)
    @hiit = FactoryBot.create(:hiit, team_id: @team.id)
    sleep 0.1
    @group_user_group = FactoryBot.build(:group_user_group, team_id: @team.id, hiit_id: @hiit.id, user_ids: [@user1.id, @user2.id])
    sleep 0.1
  end
  describe "モデルの単体テスト" do
    context "保存ができる時" do
      it "全ての情報が選択されていれば保存ができる" do
        expect(@group_user_group).to be_valid
      end
      it "ユーザーが1人しか選択されていなくても保存ができる" do
        @group_user_group.user_ids = [@user1.id]
        expect(@group_user_group).to be_valid
      end
    end
    context "保存ができない時" do
      it "グループ名が空欄では保存ができない" do
        @group_user_group.name = ""
        @group_user_group.valid?
        expect(@group_user_group.errors.full_messages).to include("Name can't be blank")
      end
      it "HIITが選択されていない状態では保存ができない" do
        @group_user_group.hiit_id = ""
        @group_user_group.valid?
        expect(@group_user_group.errors.full_messages).to include("Hiit can't be blank")
      end
      it "ユーザーが選択されていない状態では保存ができない" do
        @group_user_group.user_ids = ""
        @group_user_group.valid?
        expect(@group_user_group.errors.full_messages).to include("User ids can't be blank")
      end
      it "チームに紐づいていないでは保存ができない" do
        @group_user_group.team_id = ""
        @group_user_group.valid?
        expect(@group_user_group.errors.full_messages).to include("Team can't be blank")
      end
    end
  end
end
