require 'rails_helper'

RSpec.describe "Groups", type: :system do
  before do
    @team = FactoryBot.create(:team)
    @user1 = FactoryBot.create(:user, team_id: @team.id)
    @user2 = FactoryBot.create(:user, team_id: @team.id, admin: false)
    @menu1 = FactoryBot.create(:menu, team_id: @team.id)

    # hiit1はグループ登録ずみ
    @hiit1 = FactoryBot.create(:hiit, team_id: @team.id)
    8.times do
      MenuHiit.create(menu_id: @menu1.id, hiit_id: @hiit1.id)
    end

    # hiit2はグループ登録を行う方
    @hiit2 = FactoryBot.create(:hiit, team_id: @team.id)
    8.times do
      MenuHiit.create(menu_id: @menu1.id, hiit_id: @hiit2.id)
    end

    # hiit3はグループ登録を行わない方
    @hiit3 = FactoryBot.create(:hiit, team_id: @team.id)
    8.times do
      MenuHiit.create(menu_id: @menu1.id, hiit_id: @hiit3.id)
    end

    HiitDate.create(hiit_id: @hiit1.id, date: 0)

    @group1 = Group.create(name: Faker::Name.name, team_id: @team.id, hiit_id: @hiit1.id)
    UserGroup.create(group_id: @group1.id, user_id: @user1.id)
  end

  describe "グループ登録の結合テスト" do
    context "権限ユーザー" do
      it "権限ユーザーであればグループ作成を行うことができる" do
        # サインインする
        sign_in_support(@user1)
        # グループを作成するのリンクをクリックする
        click_link "グループを作成する"
        # グループ作成ページに遷移する
        expect(current_path).to eq new_group_path
        # まだグループ作成に利用されていないhiitのみが一覧で表示される
        expect(page).to have_content @hiit2.name
        expect(page).to have_content @hiit3.name
        # すでにグループ登録済みのhiitは表示されない
        expect(page).to have_no_content @hiit1.name
        # グループ登録されていないhiitについては実施日、active_time, rest_time, メニュー内容も表示されている
        expect(page).to have_content @hiit2.active_time
        expect(page).to have_content @hiit2.rest_time
        7.times do |i|
          if HiitDate.exists?(hiit_id: @hiit2.id, date: i)
            expect(page).to have_content Wday.find(i).name
          else
            expect(page).to have_no_content Wday.find(i).name
          end
        end
        MenuHiit.where(hiit_id: @hiit2.id).each do |menu_hiit|
          expect(page).to have_link menu_hiit.menu.name
        end
        # グループメンバーの選択肢として、チームメンバーが全て表示されている
        expect(page).to have_selector "label", text: @user1.name

        # グループ名を入力する
        group_name = Faker::Name.name
        fill_in "group_user_group[name]", with: group_name
        # hiitとメンバーを選択する
        # ラベルの関係で一旦後回し
        choose @hiit2.name
        check @user1.name
        check @user2.name
        # グループ登録ボタンをクリックするとグループが登録される
        expect{
          find("input[name='commit']").click
        }.to change{ Group.count }.by(1)
        # チーム詳細ページに遷移する
        expect(current_path).to eq team_path(@team)
        # 先程作成したグループ名が表示されている
        expect(page).to have_link group_name
      end
      it "hiit詳細ページから、そのhiitを引用してのグループ作成を行うことができる" do
        # サインインする
        sign_in_support(@user1)
        # hiit詳細ページに遷移する
        visit hiit_path(@hiit2)
        # "このHIITでグループを作成する"をクリックする
        click_link "このHIITでグループを作成する"
        # "グループの引用作成ページに遷移する"
        expect(current_path).to eq new_restricted_hiit_groups_path(@hiit2)
        # まだグループ作成に利用されていないhiitのみが一覧で表示される
        expect(page).to have_content @hiit3.name
        # すでにグループ登録済みのhiitは表示されない
        expect(page).to have_no_content @hiit1.name
        # グループ登録されていないhiitについては実施日、active_time, rest_time, メニュー内容も表示されている
        expect(page).to have_content @hiit2.active_time
        expect(page).to have_content @hiit2.rest_time
        expect(page).to have_content @hiit3.active_time
        expect(page).to have_content @hiit3.rest_time
        7.times do |i|
          if HiitDate.exists?(hiit_id: @hiit2.id, date: i)
            expect(page).to have_content Wday.find(i).name
          else
            expect(page).to have_no_content Wday.find(i).name
          end
        end
        7.times do |i|
          if HiitDate.exists?(hiit_id: @hiit3.id, date: i)
            expect(page).to have_content Wday.find(i).name
          else
            expect(page).to have_no_content Wday.find(i).name
          end
        end
        MenuHiit.where(hiit_id: @hiit2.id).each do |menu_hiit|
          expect(page).to have_link menu_hiit.menu.name
        end
        MenuHiit.where(hiit_id: @hiit3.id).each do |menu_hiit|
          expect(page).to have_link menu_hiit.menu.name
        end
        # グループメンバーの選択肢として、チームメンバーが全て表示されている
        expect(page).to have_selector "label", text: @user1.name
        expect(page).to have_selector "label", text: @user2.name
        # グループ名を入力する
        group_name = Faker::Name.name
        fill_in "group_user_group[name]", with: group_name
        # メンバーを選択する
        check @user1.name
        check @user2.name
        # グループ登録ボタンをクリックするとグループが登録される
        expect{
          find("input[name='commit']").click
        }.to change{ Group.count }.by(1)
        # チーム詳細ページに遷移する
        expect(current_path).to eq team_path(@team)
        # 先程作成したグループ名が表示されている
        expect(page).to have_link group_name
      end
      it "グループ作成に失敗した場合にはエラーメッセージが表示される（通常作成）" do
        # サインインする
        sign_in_support(@user1)
        # グループを作成するのリンクをクリックする
        click_link "グループを作成する"
        # グループ作成ページに遷移する
        expect(current_path).to eq new_group_path
        # 何も入力せずにグループ作成ボタンをクリックしても、グループが作成されない
        expect{
          find("input[name='commit']").click
        }.to change{ Group.count }.by(0)
        # エラーメッセージが表示される
        expect(page).to have_content "Name can't be blank"
        expect(page).to have_content "Hiit can't be blank"
        expect(page).to have_content "User ids can't be blank"
      end
      it "グループ作成に失敗した場合にはエラーメッセージが表示される（引用作成）" do
        # サインインする
        sign_in_support(@user1)
        # グループの引用作成ページに遷移する
        visit new_restricted_hiit_groups_path(@hiit2)
        # 何も入力せずにグループ作成ボタンをクリックしても、グループが作成されない
        expect{
          find("input[name='commit']").click
        }.to change{ Group.count }.by(0)
        # エラーメッセージが表示される
        expect(page).to have_content "Name can't be blank"
        expect(page).to have_content "User ids can't be blank"
      end
      it "すでにグループ登録済みのhiitに対して引用作成ページに遷移してもエラーメッセージが表示され、hiitの通常作成ページに遷移する" do
        # サインインする
        sign_in_support(@user1)
        # グループの引用作成ページに遷移する
        visit new_restricted_hiit_groups_path(@hiit1)
        # エラーメッセージが表示されている
        expect(page).to have_content "This HIIT is already used."
        # 引用しようとしたhiit名は表示されていない
        expect(page).to have_no_content @hiit1.name
      end
    end
    context "一般ユーザー" do
      it "一般ユーザーではグループの通常作成のページに遷移できない" do
        # サインインする
        sign_in_support(@user2)
        # グループの引用作成ページに遷移する
        visit new_group_path
        # トップページに遷移する
        expect(current_path).to eq root_path
      end
      it "一般ユーザーではグループの引用作成のページに遷移できない" do
        # サインインする
        sign_in_support(@user2)
        # グループの引用作成ページに遷移する
        visit new_restricted_hiit_groups_path(@hiit2)
        # トップページに遷移する
        expect(current_path).to eq root_path
      end
    end
    context "ログインしていない時" do
      it "ログインしていない時にはグループ作成のページに遷移できない" do
        # グループの引用作成ページに遷移する
        visit new_group_path
        # トップページに遷移する
        expect(current_path).to eq new_user_session_path
      end
      it "ログインしていない時にはグループの引用作成のページに遷移できない" do
        # グループの引用作成ページに遷移する
        visit new_restricted_hiit_groups_path(@hiit2)
        # トップページに遷移する
        expect(current_path).to eq new_user_session_path
      end
    end
  end

  describe "グループ詳細の結合テスト" do
    context "権限ユーザーとしてログインしている時" do
      it "権限ユーザーであればグループ詳細ページに遷移できる。グループの編集・削除へのリンクも表示されている" do
        # サインインする
        sign_in_support(@user1)
        # チーム詳細ページに遷移する
        visit team_path(@team)
        # グループ名をクリックする
        visit group_path(@group1)
        # グループ詳細ページに遷移する
        expect(current_path).to eq group_path(@group1)
        # グループ名, グループのhiit名、hiitのactive_time, rest_time, 種目, 実施日, メンバーが表示されている
        expect(page).to have_link @group1.name
        expect(page).to have_content @group1.hiit.name
        expect(page).to have_content @group1.hiit.active_time
        expect(page).to have_content @group1.hiit.rest_time
        @group1.hiit.menu_hiits.each do |menu_hiit|
          expect(page).to have_link menu_hiit.menu.name
        end
        @group1.user_groups.each do |group_user|
          expect(page).to have_link group_user.user.name
        end
        @group1.hiit.hiit_dates.each do |hiit_date|
          expect(page).to have_content Wday.find(hiit_date.date).name
        end
        # 各種リンクが表示されている
        expect(page).to have_link "グループの情報を編集する"
        expect(page).to have_link "グループを削除する"
        expect(page).to have_link "チームのページに戻る"
        expect(page).to have_link "自分のページに戻る"
      end
    end
    context "一般ユーザーとしてログインしている時" do
      it "権限ユーザーであればグループ詳細ページに遷移できる。グループの編集・削除へのリンクは表示されていない" do
        # サインインする
        sign_in_support(@user2)
        # チーム詳細ページに遷移する
        visit team_path(@team)
        # グループ名をクリックする
        visit group_path(@group1)
        # グループ詳細ページに遷移する
        expect(current_path).to eq group_path(@group1)
        # グループ名, グループのhiit名、hiitのactive_time, rest_time, 種目, 実施日, メンバーが表示されている
        expect(page).to have_link @group1.name
        expect(page).to have_content @group1.hiit.name
        expect(page).to have_content @group1.hiit.active_time
        expect(page).to have_content @group1.hiit.rest_time
        @group1.hiit.menu_hiits.each do |menu_hiit|
          expect(page).to have_link menu_hiit.menu.name
        end
        @group1.user_groups.each do |group_user|
          expect(page).to have_content group_user.user.name
        end
        @group1.hiit.hiit_dates.each do |hiit_date|
          expect(page).to have_content Wday.find(hiit_date.date).name
        end
        # 権限者のみのリンクは表示されていない
        expect(page).to have_no_link "グループの情報を編集する"
        expect(page).to have_no_link "グループを削除する"
        # 各種リンクが表示されている
        expect(page).to have_link "チームのページに戻る"
        expect(page).to have_link "自分のページに戻る"
      end
    end
    context "ログインしていない時" do
      it "ログインしていない時にはグループ詳細ページに遷移できない" do
        # グループ詳細ページに遷移する
        visit group_path(@group1)
        # ログインページに遷移する
        expect(current_path).to eq new_user_session_path
      end
    end
  end

  describe "グループ編集の結合テスト" do
    context "権限ユーザーの場合" do
      it "権限ユーザーであればグループの編集が可能" do
        # サインインする
        sign_in_support(@user1)
        # グループ詳細ページに遷移する
        visit group_path(@group1)
        # グループの情報を編集するをクリックする
        click_link "グループの情報を編集する"
        # グループの編集ページですと表示されている
        expect(page).to have_content "グループ編集のページです"
        # グループ名が初期値として表示されている
        expect(page).to have_field("group_user_group[name]", with: @group1.name)
        # 選択可能なhiit名/active_time/rest_time/実施日/menuが全て表示されている
        @team.hiits.each do |hiit|
          if hiit.group == nil
            expect(page).to have_content hiit.name
            expect(page).to have_content hiit.active_time
            expect(page).to have_content hiit.rest_time
            Wday.all.each do |wday|
              if HiitDate.exists?(date: wday, hiit_id: hiit.id)
                expect(page).to have_content wday.name
              end
            end
            MenuHiit.where(hiit_id: hiit.id).each do |menu_hiit|
              expect(page).to have_link menu_hiit.menu.name
            end
          end
        end
        # そのグループに含まれているhiitは表示され、最初からチェックが入っている
        expect(page).to have_checked_field(@hiit1.name)
        expect(page).to have_content @hiit1.active_time
        expect(page).to have_content @hiit1.rest_time
        Wday.all.each do |wday|
          if HiitDate.exists?(date: wday, hiit_id: @group.hiit.id)
            expect(page).to have_content wday.name
          else
            expect(page).to have_no_content wday.name
          end
        end
        MenuHiit.where(hiit_id: @group.hiit.id).each do |menu_hiit|
          expect(page).to have_link menu_hiit.menu.name
        end
        # チーム詳細・グループ詳細へのリンクが表示されている
        expect(page).to have_link "チームのページに戻る"
        expect(page).to have_link "グループのページに戻る"
        # グループ名、取り組むhiit, メンバーを編集する
        fill_in "group_user_group[name]", with: "編集テスト"
        choose @hiit2.name
        check @user2.name
        # グループを編集するボタンを押してもグループの数は変更されない
        expect{
          find("input[name='commit']").click
        }.to change{ Group.count }.by(0)
        # グループ詳細ページに遷移する
        expect(current_path).to eq group_path(@group1)
        # チーム名、hiit名、選手名が変更されている
        expect(page).to have_link "編集テスト"
        expect(page).to have_content @hiit2.name
        expect(page).to have_link @user1.name
        expect(page).to have_link @user2.name
      end
      it "グループ編集に失敗した場合にはエラーメッセージが表示される" do
        # サインインする
        sign_in_support(@user1)
        # グループ詳細ページに遷移する
        visit group_path(@group1)
        # グループの情報を編集するをクリックする
        click_link "グループの情報を編集する"
        # グループの編集ページですと表示されている
        expect(page).to have_content "グループ編集のページです"
        # グループ情報の編集
        # 名前を空欄にする
        fill_in "group_user_group[name]", with: ""
        # 他のhiitを選択する
        choose @hiit2.name
        # メンバーを追加する
        check @user2.name
        # グループ編集ボタンを押してもグループの数は変わらない
        expect{
          find("input[name='commit']").click
        }.to change{ Group.count }.by(0)
        # エラーメッセージが表示される
        expect(page).to have_content "Name can't be blank"
        # 編集した内容がそのまま表示されている
        expect(page).to have_field("group_user_group[name]", with: "")
        expect(page).to have_checked_field(@user1.name)
        expect(page).to have_checked_field(@user2.name)
      end
    end
    context "一般ユーザーの場合" do
      it "一般ユーザーの場合にはグループ情報の編集ページに遷移ができない" do
        # サインインする
        sign_in_support(@user2)
        # グループ編集ページに遷移する
        visit edit_group_path(@group1)
        # トップページにリダイレクトされる
        expect(current_path).to eq root_path
      end
    end
    context "ログインしていない場合の場合" do
      it "ログインしていない場合にはグループ情報の編集ページに遷移ができない" do
        # グループ編集ページに遷移する
        visit edit_group_path(@group1)
        # ログインページにリダイレクトされる
        expect(current_path).to eq new_user_session_path
      end
    end
  end

  describe "グループ削除の結合テスト" do
    context "権限ユーザーの場合" do
      it "権限ユーザーであれば、グループの削除が可能" do
        # サインインする
        sign_in_support(@user1)
        # グループ詳細ページに遷移する
        visit group_path(@group1)
        # グループを削除するボタンをクリックするとグループが削除される
        expect{
          click_link "グループを削除する"
        }.to change{ Group.count }.by(-1)
        # チーム詳細ページに遷移する
        expect(current_path).to eq team_path(@team)
        # 削除したグループが表示されなくなっている
        expect(page).to have_no_link @group1.name
        # 削除したgroupに関連するuser_groupも削除される
        expect(UserGroup.where(group_id: @group1.id).length).to eq 0
      end
    end
  end

end
