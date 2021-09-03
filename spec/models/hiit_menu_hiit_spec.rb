require 'rails_helper'

RSpec.describe HiitMenuHiit, type: :model do
  before do
    @team = FactoryBot.create(:team)
    @menu = FactoryBot.create(:menu, team_id: @team.id)
    menu_ids = []
    8.times do
      menu_ids << @menu.id
      sleep 0.1
    end
    @hiit_menu_hiit = FactoryBot.build(:hiit_menu_hiit, team_id: @team.id, menu_ids: menu_ids)
  end

  describe "モデルの単体テスト" do
    context "保存ができる時" do
      it "必要な情報が全て選択されていれば保存ができる" do
        expect(@hiit_menu_hiit).to be_valid
      end
      it "active_timeがx秒という形でも保存ができる" do
        @hiit_menu_hiit.active_time = "5秒"
        expect(@hiit_menu_hiit).to be_valid
      end
      it "active_timeがx分という形でも保存ができる" do
        @hiit_menu_hiit.active_time = "5分"
        expect(@hiit_menu_hiit).to be_valid
      end
      it "active_timeがxx分という形でも保存ができる" do
        @hiit_menu_hiit.active_time = "20分"
        expect(@hiit_menu_hiit).to be_valid
      end
      it "rest_timeがx秒という形でも保存ができる" do
        @hiit_menu_hiit.rest_time = "5秒"
        expect(@hiit_menu_hiit).to be_valid
      end
      it "rest_timeがx分という形でも保存ができる" do
        @hiit_menu_hiit.rest_time = "5分"
        expect(@hiit_menu_hiit).to be_valid
      end
      it "rest_timeがxx分という形でも保存ができる" do
        @hiit_menu_hiit.rest_time = "20分"
        expect(@hiit_menu_hiit).to be_valid
      end
      it "曜日を一つしか選択しなくても保存ができる" do
        @hiit_menu_hiit.date = [0]
        expect(@hiit_menu_hiit).to be_valid
      end
      it "曜日を2つしか選択しなくても保存ができる" do
        @hiit_menu_hiit.date = [1, 2]
        expect(@hiit_menu_hiit).to be_valid
      end
      it "曜日を3つしか選択しなくても保存ができる" do
        @hiit_menu_hiit.date = [3, 4, 5]
        expect(@hiit_menu_hiit).to be_valid
      end
      it "曜日を4つしか選択しなくても保存ができる" do
        @hiit_menu_hiit.date = [0, 2, 4, 6]
        expect(@hiit_menu_hiit).to be_valid
      end
      it "曜日を5つしか選択しなくても保存ができる" do
        @hiit_menu_hiit.date = [1, 2, 4, 5, 6]
        expect(@hiit_menu_hiit).to be_valid
      end
      it "曜日を6つしか選択しなくても保存ができる" do
        @hiit_menu_hiit.date = [1, 2, 3, 4, 5, 6]
        expect(@hiit_menu_hiit).to be_valid
      end
      it "選択する種目が何であっても保存ができる" do
        menu = FactoryBot.create(:menu, team_id: @team.id)
        menu_ids = []
        4.times do 
          menu_ids << menu.id
          menu_ids << @menu.id
        end
        @hiit_menu_hiit.menu_ids = menu_ids
        expect(@hiit_menu_hiit).to be_valid
      end
    end
    context "保存ができない時" do
      it "名前が空白では保存ができない" do
        @hiit_menu_hiit.name = ""
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Name can't be blank")
      end
      it "active_timeが空白では保存ができない" do
        @hiit_menu_hiit.active_time = ""
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Active time can't be blank")
      end
      it "active_timeが「'3桁以上の数字'分」の形式では保存ができない" do
        @hiit_menu_hiit.active_time = "100分"
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Active time is invalid")
      end
      it "active_timeが「'3桁以上の数字'秒」の形式では保存ができない" do
        @hiit_menu_hiit.active_time = "100秒"
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Active time is invalid")
      end
      it "active_timeが「'全角数字'秒」の形式では保存ができない" do
        @hiit_menu_hiit.active_time = "１００秒"
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Active time is invalid")
      end
      it "active_timeが「'全角数字'分」の形式では保存ができない" do
        @hiit_menu_hiit.active_time = "１００分"
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Active time is invalid")
      end
      it "active_timeが「'全角数字'分」の形式では保存ができない(アルファベット)" do
        @hiit_menu_hiit.active_time = "abc分"
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Active time is invalid")
      end
      it "active_timeが「'全角数字'秒」の形式では保存ができない(アルファベット)" do
        @hiit_menu_hiit.active_time = "abc秒"
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Active time is invalid")
      end
      it "active_timeが「'全角数字'分」の形式では保存ができない(全角文字)" do
        @hiit_menu_hiit.active_time = "十分"
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Active time is invalid")
      end
      it "active_timeが「'全角数字'秒」の形式では保存ができない(全角文字)" do
        @hiit_menu_hiit.active_time = "十秒"
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Active time is invalid")
      end
      it "active_timeが数字のみの形式では保存ができない" do
        @hiit_menu_hiit.active_time = "10"
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Active time is invalid")
      end
      it "active_timeが~秒、~分以外の形式では保存ができない" do
        @hiit_menu_hiit.active_time = "10時間"
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Active time is invalid")
      end
      it "rest_timeが空白では保存ができない" do
        @hiit_menu_hiit.rest_time = ""
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Rest time can't be blank")
      end
      it "rest_timeが「'3桁以上の数字'分」の形式では保存ができない" do
        @hiit_menu_hiit.rest_time = "100分"
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Rest time is invalid")
      end
      it "rest_timeが「'3桁以上の数字'秒」の形式では保存ができない" do
        @hiit_menu_hiit.rest_time = "100秒"
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Rest time is invalid")
      end
      it "rest_timeが「'全角数字'秒」の形式では保存ができない" do
        @hiit_menu_hiit.rest_time = "１００秒"
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Rest time is invalid")
      end
      it "rest_timeが「'全角数字'分」の形式では保存ができない" do
        @hiit_menu_hiit.rest_time = "１００分"
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Rest time is invalid")
      end
      it "rest_timeが「'全角数字'分」の形式では保存ができない(アルファベット)" do
        @hiit_menu_hiit.rest_time = "abc分"
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Rest time is invalid")
      end
      it "rest_timeが「'全角数字'秒」の形式では保存ができない(アルファベット)" do
        @hiit_menu_hiit.rest_time = "abc秒"
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Rest time is invalid")
      end
      it "rest_timeが「'全角数字'分」の形式では保存ができない(全角文字)" do
        @hiit_menu_hiit.rest_time = "十分"
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Rest time is invalid")
      end
      it "rest_timeが「'全角数字'秒」の形式では保存ができない(全角文字)" do
        @hiit_menu_hiit.rest_time = "十秒"
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Rest time is invalid")
      end
      it "rest_timeが数字のみの形式では保存ができない" do
        @hiit_menu_hiit.rest_time = "10"
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Rest time is invalid")
      end
      it "rest_timeが~秒、~分以外の形式では保存ができない" do
        @hiit_menu_hiit.rest_time = "10時間"
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Rest time is invalid")
      end
      it "種目が選択されていない場合には保存ができない" do
        @hiit_menu_hiit.menu_ids = []
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Menu ids must be choosen at eight-times")
      end
      it "menu_idsの中に''が含まれていると保存ができない" do
        @hiit_menu_hiit.menu_ids[7] = ""
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Menu ids must be choosen at eight-times")
      end
      it "menu_idsの中に'---'が含まれていると保存ができない" do
        @hiit_menu_hiit.menu_ids[7] = "0"
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Menu ids must be choosen at eight-times")
      end
      it "種目が９つ以上選択されると保存ができない" do
        @hiit_menu_hiit.menu_ids << @menu.id
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Menu ids must be choosen at eight-times")
      end
      it "曜日が選択されていない場合には保存ができない" do
        @hiit_menu_hiit.date = []
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Date can't be blank")
      end
      it "曜日として0未満の数字が選択されると保存ができない" do
        @hiit_menu_hiit.date = [-1]
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Date is invalid")
      end
      it "曜日として7以上の数字が選択されると保存ができない" do
        @hiit_menu_hiit.date = [7]
        @hiit_menu_hiit.valid?
        expect(@hiit_menu_hiit.errors.full_messages).to include("Date is invalid")
      end
    end
  end
end
