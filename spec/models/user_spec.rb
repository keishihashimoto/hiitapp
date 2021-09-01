require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = FactoryBot.build(:user)
  end
  describe "ユーザー新規登録の単体テスト" do
    context "保存ができる時" do
      it "正しく情報が入力されれば保存ができる" do
        expect(@user).to be_valid
      end
      it "adminはfalseでも保存ができる" do
        @user.admin = false
        expect(@user).to be_valid
      end
    end
    context "保存ができない時" do
      it "名前が空欄では保存ができない" do
        @user.name = ""
        @user.valid?
        expect(@user.errors.full_messages).to include("Name can't be blank")
      end
      it "emailが空欄では保存ができない" do
        @user.email = ""
        @user.valid?
        expect(@user.errors.full_messages).to include("Email can't be blank")
      end
      it "emailが他のユーザーと重複していると登録ができない" do
        user = FactoryBot.create(:user)
        @user.email = user.email
        @user.valid?
        expect(@user.errors.full_messages).to include("Email has already been taken")
      end
      it "passwordが空欄では保存ができない" do
        @user.password = ""
        @user.valid?
        expect(@user.errors.full_messages).to include("Password can't be blank")
      end
      it "password_confirmationが空欄では保存ができない" do
        @user.password_confirmation = ""
        @user.valid?
        expect(@user.errors.full_messages).to include("Password confirmation doesn't match Password")
      end
      it "password_confirmationがpasswordと一致しなければ保存ができない" do
        @user.password = "00000a"
        @user.password_confirmation = "00000b"
        @user.valid?
        expect(@user.errors.full_messages).to include("Password confirmation doesn't match Password")
      end
      it "passwordが5文字以下では登録ができない" do
        @user.password = "0000a"
        @user.password_confirmation = "0000a"
        @user.valid?
        expect(@user.errors.full_messages).to include("Password is too short (minimum is 6 characters)")
      end
      it "passwordが129文字以上では登録ができない" do
        password = Faker::String.random(length: 129)
        @user.password = password
        @user.password_confirmation = password
        @user.valid?
        expect(@user.errors.full_messages).to include("Password is too long (maximum is 128 characters)")
      end
      it "teamが空欄では保存ができない" do
        @user.team = nil
        @user.valid?
        expect(@user.errors.full_messages).to include("Team must exist")
      end
    end
  end

end
