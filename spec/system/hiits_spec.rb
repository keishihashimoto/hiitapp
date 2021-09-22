require 'rails_helper'

RSpec.describe "Hiits", type: :system do

  describe "hiit新規登録の結合テスト" do
    before do
      @team = FactoryBot.create(:team)
      @user1 = FactoryBot.create(:user, team_id: @team.id)
      @user2 = FactoryBot.create(:user, team_id: @team.id, admin: false)
      @menu1 = FactoryBot.create(:menu, team_id: @team.id)
    end
    context "権限ユーザーの場合" do
      it "権限ユーザーであればhiitの作成ができる" do
        # サインインする
        sign_in_support(@user1)
        # チーム詳細ページに遷移する
        visit team_path(@team)
        # 新しいhiitを登録するをクリックする
        click_link "新しいHIITを登録する"
        # hiit作成ページに遷移する
        expect(current_path).to eq new_hiit_path
        # 作成するhiitの内容を入力する
        fill_in "hiit_menu_hiit[name]", with: "hiitテスト"
        fill_in "hiit_menu_hiit[active_time]", with: "20秒"
        fill_in "hiit_menu_hiit[rest_time]", with: "10秒"
        check "日曜日"
        8.times do |i|
          all("select")[i].find("option[value='#{@menu1.id}']").select_option
        end
        # 登録ボタンをクリックするとhiitが登録される
        expect{
          find("input[name='commit']").click
        }.to change{ Hiit.count }.by(1)
        # チーム詳細ページに遷移する
        expect(current_path).to eq team_path(@team)
        # 先程作成したhiitが表示されている
        expect(page).to have_link "hiitテスト"
      end
      it "権限ユーザーであればhiitの作成ができる。作成に失敗した場合には元のページに戻される" do
        # サインインする
        sign_in_support(@user1)
        # チーム詳細ページに遷移する
        visit team_path(@team)
        # 新しいhiitを登録するをクリックする
        click_link "新しいHIITを登録する"
        # hiit作成ページに遷移する
        expect(current_path).to eq new_hiit_path
        # 何も入力せずに登録ボタンを押してもhiitが作成されない
        expect{
          find("input[name='commit']").click
        }.to change{ Hiit.count }.by(0)
        # hiit作成画面に戻される
        expect(page).to have_content "1種目あたりの時間"
        # エラーメッセージが表示されている
        expect(page).to have_content "Name can't be blank"
        expect(page).to have_content "Date can't be blank"
        expect(page).to have_content "Active time can't be blank"
        expect(page).to have_content "Rest time can't be blank"
        expect(page).to have_content "Active time is invalid"
        expect(page).to have_content "Rest time is invalid"
      end
    end
    context "一般ユーザーの場合" do
      it "一般ユーザーであればhiitの作成ができない" do
        # サインインする
        sign_in_support(@user2)
        # 編集ページに遷移する
        visit new_hiit_path
        # トップページにリダイレクトされる
        expect(current_path).to eq root_path
      end
    end
    context "ログインしていない場合" do
      it "ログインしていない場合はhiitの作成ができない" do
        # 編集ページに遷移する
        visit new_hiit_path
        # トップページにリダイレクトされる
        expect(current_path).to eq root_path
      end
    end
  end
  describe "hiit詳細の結合テスト" do
    before do
      @team = FactoryBot.create(:team)
      @user1 = FactoryBot.create(:user, team_id: @team.id)
      @user2 = FactoryBot.create(:user, team_id: @team.id, admin: false)
      @menu1 = FactoryBot.create(:menu, team_id: @team.id)
  
      @hiit1 = FactoryBot.create(:hiit, team_id: @team.id)
      8.times do
        MenuHiit.create(menu_id: @menu1.id, hiit_id: @hiit1.id)
      end
  
      @hiit2 = FactoryBot.create(:hiit, team_id: @team.id)
      8.times do
        MenuHiit.create(menu_id: @menu1.id, hiit_id: @hiit2.id)
      end
  
      HiitDate.create(hiit_id: @hiit1.id, date: 0)
  
      # hiit1はグループ登録あり、hiit2はグループ登録なし
      @group = Group.create(name: Faker::Name.name, team_id: @team.id, hiit_id: @hiit1.id)
      UserGroup.create(group_id: @group.id, user_id: @user1.id)
    end
    context "権限ユーザーの場合" do
      it "権限ユーザーであればhiit詳細ページが確認できる" do
        # サインインする
        sign_in_support(@user1)
        # チーム詳細ページに遷移する
        visit team_path(@team)
        # hiit名をクリックする
        click_link @hiit1.name
        # hiit詳細ページに遷移する
        expect(current_path).to eq hiit_path(@hiit1)
        # ~の詳細ページです、という文字が表示されている
        expect(page).to have_content "#{@hiit1.name}の詳細ページです"
        # hiitのactive_timeとrest_timeが表示されている
        expect(page).to have_content "1セットあたりの時間：#{@hiit1.active_time} ／ セット間の休憩時間：#{@hiit1.rest_time}"
        # このhiitを行う曜日のみが表示されている
        7.times do |i|
          if HiitDate.exists?(hiit_id: @hiit1.id, date: i)
            expect(page).to have_content Wday.find(i).name
          else
            expect(page).to have_no_content Wday.find(i).name
          end
        end
        # このhiitで行う種目が表示されている
        MenuHiit.where(hiit_id:@hiit1.id).each do |menu_hiit|
          expect(page).to have_link menu_hiit.menu.name
        end
        # このhiitを登録しているグループとその選手名が表示されている
        expect(page).to have_link @hiit1.group.name
        UserGroup.where(group_id: @hiit1.group.id).each do |user_group|
          expect(page).to have_link user_group.user.name
        end
        # グループ登録済みのhiitに関しては、hiit作成ページへのリンクが表示されていない
        expect(page).to have_no_link "このHIITでグループを作成する"
        # hiit作成その他へのリンクが表示されている
        expect(page).to have_link "HIITを編集する"
        expect(page).to have_link "HIITを削除する"
        expect(page).to have_link "HIITを作成する"
        expect(page).to have_link "チームのページに戻る"
        expect(page).to have_link "自分のページに戻る"
      end
      it "権限ユーザーであればhiit詳細ページが確認できる" do
        # サインインする
        sign_in_support(@user1)
        # チーム詳細ページに遷移する
        visit team_path(@team)
        # hiit名をクリックする
        click_link @hiit2.name
        # hiit詳細ページに遷移する
        expect(current_path).to eq hiit_path(@hiit2)
        # ~の詳細ページです、という文字が表示されている
        expect(page).to have_content "#{@hiit2.name}の詳細ページです"
        # hiitのactive_timeとrest_timeが表示されている
        expect(page).to have_content "1セットあたりの時間：#{@hiit2.active_time} ／ セット間の休憩時間：#{@hiit2.rest_time}"
        # このhiitを行う曜日のみが表示されている
        7.times do |i|
          if HiitDate.exists?(hiit_id: @hiit2.id, date: i)
            expect(page).to have_content Wday.find(i).name
          else
            expect(page).to have_no_content Wday.find(i).name
          end
        end
        # このhiitで行う種目が表示されている
        MenuHiit.where(hiit_id:@hiit2.id).each do |menu_hiit|
          expect(page).to have_link menu_hiit.menu.name
        end
        # このhiitを登録しているグループとその選手名が表示されている
        expect(page).to have_content "このHIITに取り組んでいるグループはありません"
        # hiit作成ページへのリンクが表示されている
        expect(page).to have_link "このHIITでグループを作成する"
        # hiit作成その他へのリンクが表示されている
        expect(page).to have_link "HIITを編集する"
        expect(page).to have_link "HIITを削除する"
        expect(page).to have_link "HIITを作成する"
        expect(page).to have_link "チームのページに戻る"
        expect(page).to have_link "自分のページに戻る"
      end
    end
    context "一般ユーザーの場合" do
      it "権限ユーザーであればhiit詳細ページが確認できるが、削除などへのリンクは確認することができない" do
        # サインインする
        sign_in_support(@user2)
        # チーム詳細ページに遷移する
        visit team_path(@team)
        # hiit名をクリックする
        click_link @hiit1.name
        # hiit詳細ページに遷移する
        expect(current_path).to eq hiit_path(@hiit1)
        # ~の詳細ページです、という文字が表示されている
        expect(page).to have_content "#{@hiit1.name}の詳細ページです"
        # hiitのactive_timeとrest_timeが表示されている
        expect(page).to have_content "1セットあたりの時間：#{@hiit1.active_time} ／ セット間の休憩時間：#{@hiit1.rest_time}"
        # このhiitを行う曜日のみが表示されている
        7.times do |i|
          if HiitDate.exists?(hiit_id: @hiit1.id, date: i)
            expect(page).to have_content Wday.find(i).name
          else
            expect(page).to have_no_content Wday.find(i).name
          end
        end
        # このhiitで行う種目が表示されている
        MenuHiit.where(hiit_id:@hiit1.id).each do |menu_hiit|
          expect(page).to have_link menu_hiit.menu.name
        end
        # このhiitを登録しているグループとその選手名が表示されている
        expect(page).to have_link @hiit1.group.name
        UserGroup.where(group_id: @hiit1.group.id).each do |user_group|
          expect(page).to have_content user_group.user.name
        end
        # hiit作成ページへのリンクが表示されていない
        expect(page).to have_no_link "このHIITでグループを作成する"
        # hiit作成その他へのリンクが表示されていない
        expect(page).to have_no_link "HIITを編集する"
        expect(page).to have_no_link "HIITを削除する"
        expect(page).to have_no_link "HIITを作成する"
        # マイページとチーム詳細へのリンクのみが表示されている
        expect(page).to have_link "チームのページに戻る"
        expect(page).to have_link "自分のページに戻る"
      end
    end
    context "ログインしていない場合" do
      it "ログインしていない場合はhiit詳細ページが確認できない" do
        # hiit詳細ページのurlを入力する
        visit hiit_path(@hiit1)
        # ログインページにリダイレクトされる
        expect(current_path).to eq new_user_session_path
      end
    end
  end
  describe "hiit編集の結合テスト" do
    before do
      @team = FactoryBot.create(:team)
      @user1 = FactoryBot.create(:user, team_id: @team.id)
      @user2 = FactoryBot.create(:user, team_id: @team.id, admin: false)
      @menu1 = FactoryBot.create(:menu, team_id: @team.id)
  
      @hiit1 = FactoryBot.create(:hiit, team_id: @team.id)
      8.times do
        MenuHiit.create(menu_id: @menu1.id, hiit_id: @hiit1.id)
      end
  
      @hiit2 = FactoryBot.create(:hiit, team_id: @team.id)
      8.times do
        MenuHiit.create(menu_id: @menu1.id, hiit_id: @hiit2.id)
      end
  
      HiitDate.create(hiit_id: @hiit1.id, date: 0)
  
      # hiit1はグループ登録あり、hiit2はグループ登録なし
      @group = Group.create(name: Faker::Name.name, team_id: @team.id, hiit_id: @hiit1.id)
      UserGroup.create(group_id: @group.id, user_id: @user1.id)
    end
    context "権限ユーザーの場合" do
      it "権限ユーザーであればhiitの編集ができる" do
        # サインインする
        sign_in_support(@user1)
        # hiit詳細ページに遷移する
        visit hiit_path(@hiit1)
        # hiitを編集するボタンを押す
        click_link "HIITを編集する"
        # hiit編集ページに遷移する
        expect(current_path).to eq edit_hiit_path(@hiit1)
        # hiitの名前、active_time, rest_timeに関しては初期値が入力されている
        expect(page).to have_field("hiit_menu_hiit[name]", with: @hiit1.name)
        expect(page).to have_field("hiit_menu_hiit[active_time]", with: @hiit1.active_time)
        expect(page).to have_field("hiit_menu_hiit[rest_time]", with: @hiit1.rest_time)
        # 該当する実施日に全てチェックが入っている
        7.times do |i|
          if HiitDate.exists?(hiit_id: @hiit1.id, date: i)
            expect(page).to have_checked_field(Wday.find(i).name)
          else
            expect(page).to have_unchecked_field(Wday.find(i).name)
          end
        end
        # hiit名、active_time, rest_time, 実施日を変更する
        fill_in "hiit_menu_hiit[name]", with: "編集テスト"
        fill_in "hiit_menu_hiit[active_time]", with: "10秒"
        fill_in "hiit_menu_hiit[rest_time]", with: "10秒"
        7.times do |i|
          check Wday.find(i).name
        end
        # menu1~8を選択する
        8.times do |i|
          all("select")[i].find("option[value='#{@menu1.id}']").select_option
        end
        # 編集ボタンをクリックする
        expect{
          find("input[name='commit']").click
        }.to change{ Hiit.count }.by(0)
        # hiit詳細ページに遷移する
        expect(current_path).to eq hiit_path(@hiit1)

        # ~の詳細ページです、という文字が表示されている
        expect(page).to have_content "編集テスト"
        # hiitのactive_timeとrest_timeが表示されている
        expect(page).to have_content "1セットあたりの時間：10秒 ／ セット間の休憩時間：10秒"
        # このhiitを行う曜日のみが表示されている
        7.times do |i|
            expect(page).to have_content Wday.find(i).name
        end
        # このhiitで行う種目が表示されている
        MenuHiit.where(hiit_id:@hiit1.id).each do |menu_hiit|
          expect(page).to have_link menu_hiit.menu.name
        end
        # このhiitを登録しているグループとその選手名が表示されている
        expect(page).to have_link @hiit1.group.name
        UserGroup.where(group_id: @hiit1.group.id).each do |user_group|
          expect(page).to have_link user_group.user.name
        end

      end
      it "権限ユーザーであればhiitの編集ができる。編集に失敗した場合には元のページに戻され、エラーメッセージが表示される" do
        # サインインする
        sign_in_support(@user1)
        # hiit詳細ページに遷移する
        visit hiit_path(@hiit1)
        # hiitを編集するボタンを押す
        click_link "HIITを編集する"
        # hiit編集ページに遷移する
        expect(current_path).to eq edit_hiit_path(@hiit1)
        # hiitの名前、active_time, rest_timeに関しては初期値が入力されている
        expect(page).to have_field("hiit_menu_hiit[name]", with: @hiit1.name)
        expect(page).to have_field("hiit_menu_hiit[active_time]", with: @hiit1.active_time)
        expect(page).to have_field("hiit_menu_hiit[rest_time]", with: @hiit1.rest_time)
        # 該当する実施日に全てチェックが入っている
        7.times do |i|
          if HiitDate.exists?(hiit_id: @hiit1.id, date: i)
            expect(page).to have_checked_field(Wday.find(i).name)
          else
            expect(page).to have_unchecked_field(Wday.find(i).name)
          end
        end
        # hiit名、active_time, rest_time, 実施日を変更する
        fill_in "hiit_menu_hiit[name]", with: "編集テスト"
        fill_in "hiit_menu_hiit[active_time]", with: "100秒"
        fill_in "hiit_menu_hiit[rest_time]", with: "100秒"
        7.times do |i|
          check Wday.find(i).name
        end
        # menu1~8を選択せずに編集ボタンをクリックする
        expect{
          find("input[name='commit']").click
        }.to change{ Hiit.count }.by(0)
        # エラーメッセージが表示される
        expect(page).to have_content "Menu ids must be choosen at eight-times"
        # 編集途中の内容は表示される
        expect(page).to have_field("hiit_menu_hiit[name]", with: "編集テスト")
        expect(page).to have_field("hiit_menu_hiit[active_time]", with: "100秒")
        expect(page).to have_field("hiit_menu_hiit[rest_time]", with: "100秒")
      end
    end
    context "一般ユーザーの場合" do
      it "権限ユーザーであればhiitの編集ができない" do
        # サインインする
        sign_in_support(@user2)
        # hiit編集ページに遷移する
        visit edit_hiit_path(@hiit1)
        # トップページにリダイレクトされる
        expect(current_path).to eq root_path
      end
    end
    context "ログインしていない場合" do
      it "ログインしていない場合はhiitの編集ができない" do
        # hiit編集ページに遷移する
        visit edit_hiit_path(@hiit1)
        # サインインページにリダイレクトされる
        expect(current_path).to eq root_path
      end
    end
  end
  describe "hiit削除の結合テスト" do
    before do
      @team = FactoryBot.create(:team)
      @user1 = FactoryBot.create(:user, team_id: @team.id)
      @user2 = FactoryBot.create(:user, team_id: @team.id, admin: false)
      @menu1 = FactoryBot.create(:menu, team_id: @team.id)
  
      @hiit1 = FactoryBot.create(:hiit, team_id: @team.id)
      8.times do
        MenuHiit.create(menu_id: @menu1.id, hiit_id: @hiit1.id)
      end
  
      @hiit2 = FactoryBot.create(:hiit, team_id: @team.id)
      8.times do
        MenuHiit.create(menu_id: @menu1.id, hiit_id: @hiit2.id)
      end
  
      HiitDate.create(hiit_id: @hiit1.id, date: 0)
  
      # hiit1はグループ登録あり、hiit2はグループ登録なし
      @group = Group.create(name: Faker::Name.name, team_id: @team.id, hiit_id: @hiit1.id)
      UserGroup.create(group_id: @group.id, user_id: @user1.id) 
    end 
    context "権限ユーザーの場合" do
      it "権限ユーザーであればhiitの削除ができる" do
        # サインインする
        sign_in_support(@user1)
        # hiit詳細ページに遷移する
        visit hiit_path(@hiit2)
        # "hiitを削除する"をクリックするとhiitが削除される
        expect{
          click_link "HIITを削除する"
        }.to change{ Hiit.count }.by(-1)
        # チーム詳細ページにリダイレクトされる
        expect(current_path).to eq team_path(@team)
        # 削除したhiitの名前が表示されていない
        expect(page).to have_no_link @hiit2.name
      end
      it "権限ユーザーであっても、登録済みのgroupがあるhiitは削除できない。元のページに戻され、エラーメッセージが表示される" do
        # サインインする
        sign_in_support(@user1)
        # hiit詳細ページに遷移する
        visit hiit_path(@hiit1)
        # "hiitを削除する"をクリックしてもhiitが削除されない
        expect{
          click_link "HIITを削除する"
        }.to change{ Hiit.count }.by(0)
        # hiit詳細ページに戻る
        expect(page).to have_content "#{@hiit1.name}の詳細ページです"
        # エラーメッセージが表示される
        expect(page).to have_content ("Since group using this hiit exists, this hiit can't be deleted")
      end
    end
  end
end
