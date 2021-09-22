require 'rails_helper'

RSpec.describe "UserHiits", type: :system do
  before do
    @team = FactoryBot.create(:team)
    @user1 = FactoryBot.create(:user, team_id: @team.id)
    @user2 = FactoryBot.create(:user, team_id: @team.id, admin: false)
    @user3 = FactoryBot.create(:user, team_id: @team.id, admin: false)
    @menu1 = FactoryBot.create(:menu, team_id: @team.id)

    # hiit1はグループ登録ずみ
    @hiit1 = FactoryBot.create(:hiit, team_id: @team.id)
    8.times do
      MenuHiit.create(menu_id: @menu1.id, hiit_id: @hiit1.id)
    end

    # hiit2はグループ登録なし
    @hiit2 = FactoryBot.create(:hiit, team_id: @team.id)
    8.times do
      MenuHiit.create(menu_id: @menu1.id, hiit_id: @hiit2.id)
    end

    HiitDate.create(hiit_id: @hiit1.id, date: Date.today.wday)

    @group1 = Group.create(name: Faker::Name.name, team_id: @team.id, hiit_id: @hiit1.id)
    UserGroup.create(group_id: @group1.id, user_id: @user1.id)
    UserGroup.create(group_id: @group1.id, user_id: @user2.id)
    UserGroup.create(group_id: @group1.id, user_id: @user3.id)
  end

  describe "hiit実施登録機能の結合テスト" do
    context "自分のページに関して" do
      it "権限ユーザーであればトップページから当日の詳細予定のページに遷移し、実施記録の更新ができる" do
        # サインインする
        sign_in_support(@user1)
        # 最初の時点では実施有無が❌になっている
        expect(page).to have_content "❌"
        expect(page).to have_no_content "✅"
        # 今日の予定を見るをクリックする
        click_link "今日の予定を見る"
        # 当日の詳細予定ページに遷移する
        expect(current_path).to eq user_user_hiits_path(@user1)
        # 本日の予定が表示されている
        expect(page).to have_content @group1.hiit.name
        # 実施予定hiitのactive_time/rest_time/menu1~8が表示されている
        expect(page).to have_content @group1.hiit.active_time
        expect(page).to have_content @group1.hiit.rest_time
        @group1.hiit.menu_hiits.each do |menu_hiit|
          expect(page).to have_content menu_hiit.menu.name
        end
        # 最初は未実施になっている
        expect(page).to have_content "未実施"
        # 実施記録更新ボタンを押すと実施済みに変化する
        click_link "実施記録を更新する"
        expect(page).to have_no_content "未実施"
        expect(page).to have_content "実施済み!!"
        # もう一度更新ボタンを押すと未実施に戻る
        click_link "実施記録を更新する"
        expect(page).to have_no_content "実施済み!!"
        # もう一度実施済みに変えてからトップページに戻ると❌が✅に変化している
        click_link "実施記録を更新する"
        visit root_path
        expect(page).to have_no_content "❌"
        expect(page).to have_content "✅"
      end
      it "権限ユーザーであればユーザー詳細ページから当日の詳細予定のページに遷移し、実施記録の更新ができる" do
        # サインインする
        sign_in_support(@user1)
        # 最初の時点では実施有無が❌になっている
        expect(page).to have_content "❌"
        expect(page).to have_no_content "✅"
        # ユーザー詳細ページに遷移する
        visit user_path(@user1)
        # 本日の詳しい予定を見るをクリックする
        click_link "本日の詳しい予定を見る"
        # 当日の詳細予定ページに遷移する
        expect(current_path).to eq user_user_hiits_path(@user1)
        # 本日の予定が表示されている
        expect(page).to have_content @group1.hiit.name
        # 実施予定hiitのactive_time/rest_time/menu1~8が表示されている
        expect(page).to have_content @group1.hiit.active_time
        expect(page).to have_content @group1.hiit.rest_time
        @group1.hiit.menu_hiits.each do |menu_hiit|
          expect(page).to have_content menu_hiit.menu.name
        end
        # 最初は未実施になっている
        expect(page).to have_content "未実施"
        # 実施記録更新ボタンを押すと実施済みに変化する
        click_link "実施記録を更新する"
        expect(page).to have_no_content "未実施"
        expect(page).to have_content "実施済み!!"
        # もう一度更新ボタンを押すと未実施に戻る
        click_link "実施記録を更新する"
        expect(page).to have_no_content "実施済み!!"
        # もう一度実施済みに変えてからトップページに戻ると❌が✅に変化している
        click_link "実施記録を更新する"
        visit root_path
        expect(page).to have_no_content "❌"
        expect(page).to have_content "✅"
      end
      it "一般ユーザーであればトップページから当日の詳細予定のページに遷移し、実施記録の更新ができる" do
        # サインインする
        sign_in_support(@user2)
        # 最初の時点では実施有無が❌になっている
        expect(page).to have_content "❌"
        expect(page).to have_no_content "✅"
        # 今日の予定を見るをクリックする
        click_link "今日の予定を見る"
        # 当日の詳細予定ページに遷移する
        expect(current_path).to eq user_user_hiits_path(@user2)
        # 本日の予定が表示されている
        expect(page).to have_content @group1.hiit.name
        # 実施予定hiitのactive_time/rest_time/menu1~8が表示されている
        expect(page).to have_content @group1.hiit.active_time
        expect(page).to have_content @group1.hiit.rest_time
        @group1.hiit.menu_hiits.each do |menu_hiit|
          expect(page).to have_content menu_hiit.menu.name
        end
        # 最初は未実施になっている
        expect(page).to have_content "未実施"
        # 実施記録更新ボタンを押すと実施済みに変化する
        click_link "実施記録を更新する"
        expect(page).to have_no_content "未実施"
        expect(page).to have_content "実施済み!!"
        # もう一度更新ボタンを押すと未実施に戻る
        click_link "実施記録を更新する"
        expect(page).to have_no_content "実施済み!!"
        # もう一度実施済みに変えてからトップページに戻ると❌が✅に変化している
        click_link "実施記録を更新する"
        visit root_path
        expect(page).to have_no_content "❌"
        expect(page).to have_content "✅"
      end
      it "一般ユーザーであればユーザー詳細ページから当日の詳細予定のページに遷移し、実施記録の更新ができる" do
        # サインインする
        sign_in_support(@user2)
        # 最初の時点では実施有無が❌になっている
        expect(page).to have_content "❌"
        expect(page).to have_no_content "✅"
        # ユーザー詳細ページに遷移する
        visit user_path(@user2)
        # 本日の詳しい予定を見るをクリックする
        click_link "本日の詳しい予定を見る"
        # 当日の詳細予定ページに遷移する
        expect(current_path).to eq user_user_hiits_path(@user2)
        # 本日の予定が表示されている
        expect(page).to have_content @group1.hiit.name
        # 実施予定hiitのactive_time/rest_time/menu1~8が表示されている
        expect(page).to have_content @group1.hiit.active_time
        expect(page).to have_content @group1.hiit.rest_time
        @group1.hiit.menu_hiits.each do |menu_hiit|
          expect(page).to have_content menu_hiit.menu.name
        end
        # 最初は未実施になっている
        expect(page).to have_content "未実施"
        # 実施記録更新ボタンを押すと実施済みに変化する
        click_link "実施記録を更新する"
        expect(page).to have_no_content "未実施"
        expect(page).to have_content "実施済み!!"
        # もう一度更新ボタンを押すと未実施に戻る
        click_link "実施記録を更新する"
        expect(page).to have_no_content "実施済み!!"
        # もう一度実施済みに変えてからトップページに戻ると❌が✅に変化している
        click_link "実施記録を更新する"
        visit root_path
        expect(page).to have_no_content "❌"
        expect(page).to have_content "✅"
      end
    end
    context "他のユーザーに関して" do
      it "他のユーザーの当日予定詳細ページには、権限者しか遷移できない" do
        # 一般ユーザーとしてサインインする
        sign_in_support(@user2)
        # 他のユーザーの当日予定のページに遷移する
        visit user_user_hiits_path(@user3)
        # トップページにリダイレクトされる
        expect(current_path).to eq root_path
      end
      it "他のユーザーの実施記録の更新は、権限ユーザーでも行えない" do
        # 権限ユーザーとしてサインインする
        sign_in_support(@user1)
        # ユーザー詳細ページに遷移する
        visit user_path(@user2)
        # ~さんの詳細ページですと表示されている
        expect(page).to have_content "#{@user2.name}さんの詳細ページです"
        # 本日の詳しい予定を見るをクリックする
        click_link "本日の詳しい予定を見る"
        # 当日の予定詳細ページに遷移する
        expect(current_path).to eq user_user_hiits_path(@user2)
        # 実施記録更新ボタンが表示されていない
        expect(page).to have_no_content "実施記録を更新する"
      end
      it "ログインしていない場合には、当日予定詳細ページに遷移できない" do
        # 当日詳細ページに遷移する
        visit user_user_hiits_path(@user2)
        # ログインページにリダイレクトされる
        expect(current_path).to eq new_user_session_path
      end
    end
  end
end
