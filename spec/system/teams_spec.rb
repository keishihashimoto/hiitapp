require 'rails_helper'

RSpec.describe "Teams", type: :system do
  describe "チーム登録の結合テスト" do
    before do
      @team = FactoryBot.build(:team)
      @user = FactoryBot.create(:user)
    end

    context "登録できる時" do
      it "必要な情報を入力すれば登録ができ、サインアップページに遷移する" do
        # ルートパスに遷移する
        visit root_path
        # チーム登録ボタンが表示されている
        click_link "チームを登録する"
        # クリックするとチーム登録ページに遷移する
        expect(current_path).to eq new_team_path
        # チーム名を入力し登録ボタンを押すとチーム数が一つ増える
        fill_in "team_name", with: @team.name
        expect{
          find('input[name="commit"]').click
        }.to change{ Team.count }.by(1)
        # ユーザー登録ページに遷移する
        expect(current_path).to eq new_user_registration_path
      end
    end
    context "保存ができない時" do
      it "必要な情報が入力されていなければ保存ができない" do
        # ルートパスに遷移する
        visit root_path
        # チーム登録ボタンが表示されている
        click_link "チームを登録する"
        # クリックするとチーム登録ページに遷移する
        expect(current_path).to eq new_team_path
        # チーム名を入力せずに登録ボタンを押してもチーム数が一つ増えない
        expect{
          find('input[name="commit"]').click
        }.to change{ Team.count }.by(0)
        # 元のページに戻る
        expect(page).to have_content("チーム登録画面です")
        # エラーメッセージが表示されている
        expect(page).to have_content("Name can't be blank")
      end
      it "ログイン済みではチーム登録ページに遷移できない" do
        # サインインする
        sign_in_support(@user)
        visit new_team_path
        expect(current_path).to eq root_path
      end
    end
  end

  describe "トップページの結合テスト" do
    before do
      @team = FactoryBot.create(:team)
      @user = FactoryBot.create(:user, team_id: @team.id)
      @menu = FactoryBot.create(:menu, team_id: @team.id)
        
      8.times do |i|
        FactoryBot.create(:hiit, team_id: @team.id)
        8.times do
          MenuHiit.create(menu_id: @menu.id, hiit_id: Hiit.all[i].id)
        end
        
        group = Group.create(name: Faker::Name.name, hiit_id: Hiit.all[i].id, team_id: @team.id)
        UserGroup.create(user_id: @user.id, group_id: group.id)
      end

        # ３つのHIITは0,3,6に実施
        3.times do |i|
          3.times do |w|
            HiitDate.create(hiit_id: Hiit.all[i].id, date: (3 * w))
          end
        end
        # 残りの5つは1, 2, 4, 5に実施
        5.times do |i|
          2.times do |w|
            HiitDate.create(hiit_id: Hiit.all[(i + 3)].id, date: (3 * w + 1))
            HiitDate.create(hiit_id: Hiit.all[(i + 3)].id, date: (3 * w + 2))
          end
        end

    end

    context "ログインしていない時" do
      it "ログインしていない時の表示を確認" do
        # トップページに遷移できる
        visit root_path
        # アプリ名が表示されている
        expect(page).to have_content("HiitApp")
        # 「チームを登録する」ボタンを押すとチーム登録画面に切り替わる
        click_link "チームを登録する"
        expect(current_path).to eq new_team_path
        # ユーザーを登録するボタンを押すとサインアップページに切り替わる
        click_link "ユーザーを登録する"
        expect(current_path).to eq new_user_registration_path
        # ログインボタンを押すとログインページに遷移する
        click_link "ログインする"
        expect(current_path).to eq new_user_session_path
      end
    end
    
    context "ログインしている時" do
      it "権限ユーザーでログインしている時" do
        # チーム名が表示されている
        sign_in_support(@user)
        expect(page).to have_content(@user.team.name)
        #アプリ名が表示されている
        expect(page).to have_content("HiitApp")
        # ユーザー名が表示されている
        expect(page).to have_content(@user.name)
        # ログアウトボタンが表示されている
        expect(page).to have_content("ログアウト")
        # グループ名が4つと・・・が表示されている
        expect(page).to have_content(Group.all[0].name)
        expect(page).to have_content(Group.all[1].name)
        expect(page).to have_content(Group.all[2].name)
        expect(page).to have_content(Group.all[3].name)
        expect(page).to have_no_content(Group.all[4].name)
        expect(page).to have_content("...")
        # "~さんのマイページです"が表示されている
        expect(page).to have_content("#{@user.name}さんのマイページです")
        # 3日前から3日後までの日付が表示されている
        expect(page).to have_content("#{(Date.today - 3).strftime('%m/%d')}")
        expect(page).to have_content("#{(Date.today - 2).strftime('%m/%d')}")
        expect(page).to have_content("#{(Date.today - 1).strftime('%m/%d')}")
        expect(page).to have_content("#{(Date.today).strftime('%m/%d')}")
        expect(page).to have_content("#{(Date.today + 1).strftime('%m/%d')}")
        expect(page).to have_content("#{(Date.today + 2).strftime('%m/%d')}")
        expect(page).to have_content("#{(Date.today + 3).strftime('%m/%d')}")
        # 今日の日付のカードにのみ、「今日の予定を見る」ボタンがある
        expect(all(".daily-menu-container")[3]).to have_selector ".link-to-today", text: "今日の予定を見る"
        expect(all(".daily-menu-container")[0]).to have_no_selector ".link-to-today", text: "今日の予定を見る"
        expect(all(".daily-menu-container")[1]).to have_no_selector ".link-to-today", text: "今日の予定を見る"
        expect(all(".daily-menu-container")[2]).to have_no_selector ".link-to-today", text: "今日の予定を見る"
        expect(all(".daily-menu-container")[4]).to have_no_selector ".link-to-today", text: "今日の予定を見る"
        expect(all(".daily-menu-container")[5]).to have_no_selector ".link-to-today", text: "今日の予定を見る"
        expect(all(".daily-menu-container")[6]).to have_no_selector ".link-to-today", text: "今日の予定を見る"
        # 日曜日、水曜日、土曜日に関してはその日のHIITが３つなので全て表示されている
        # ここに関しては実施日に書き換えが必要
        expect(all(".daily-menu-container")[2]).to have_content(Hiit.all[0].name)
        expect(all(".daily-menu-container")[2]).to have_content(Hiit.all[1].name)
        expect(all(".daily-menu-container")[2]).to have_content(Hiit.all[2].name)
        expect(all(".daily-menu-container")[5]).to have_content(Hiit.all[0].name)
        expect(all(".daily-menu-container")[5]).to have_content(Hiit.all[1].name)
        expect(all(".daily-menu-container")[5]).to have_content(Hiit.all[2].name)
        expect(all(".daily-menu-container")[6]).to have_content(Hiit.all[0].name)
        expect(all(".daily-menu-container")[6]).to have_content(Hiit.all[1].name)
        expect(all(".daily-menu-container")[6]).to have_content(Hiit.all[2].name)
        # 月曜日、火曜日、木曜日、金曜日に関しては、５つのHIITのうち４つ分しか表示されていない
        expect(all(".daily-menu-container")[0]).to have_content(Hiit.all[3].name)
        expect(all(".daily-menu-container")[0]).to have_content(Hiit.all[4].name)
        expect(all(".daily-menu-container")[0]).to have_content(Hiit.all[5].name)
        expect(all(".daily-menu-container")[0]).to have_content(Hiit.all[6].name)
        expect(all(".daily-menu-container")[0]).to have_no_content(Hiit.all[7].name)
        expect(all(".daily-menu-container")[0]).to have_content("...")
        expect(all(".daily-menu-container")[1]).to have_content(Hiit.all[3].name)
        expect(all(".daily-menu-container")[1]).to have_content(Hiit.all[4].name)
        expect(all(".daily-menu-container")[1]).to have_content(Hiit.all[5].name)
        expect(all(".daily-menu-container")[1]).to have_content(Hiit.all[6].name)
        expect(all(".daily-menu-container")[1]).to have_no_content(Hiit.all[7].name)
        expect(all(".daily-menu-container")[1]).to have_content("...")
        expect(all(".daily-menu-container")[3]).to have_content(Hiit.all[3].name)
        expect(all(".daily-menu-container")[3]).to have_content(Hiit.all[4].name)
        expect(all(".daily-menu-container")[3]).to have_content(Hiit.all[5].name)
        expect(all(".daily-menu-container")[3]).to have_content(Hiit.all[6].name)
        expect(all(".daily-menu-container")[3]).to have_no_content(Hiit.all[7].name)
        expect(all(".daily-menu-container")[3]).to have_content("...")
        expect(all(".daily-menu-container")[4]).to have_content(Hiit.all[3].name)
        expect(all(".daily-menu-container")[4]).to have_content(Hiit.all[4].name)
        expect(all(".daily-menu-container")[4]).to have_content(Hiit.all[5].name)
        expect(all(".daily-menu-container")[4]).to have_content(Hiit.all[6].name)
        expect(all(".daily-menu-container")[4]).to have_no_content(Hiit.all[7].name)
        expect(all(".daily-menu-container")[4]).to have_content("...")
        # 未実施のものには❌、実施済みのものには✅がつく
        expect(all(".todays-hiit-container")[0]).to have_content("❌")
        UserHiit.create(hiit_id: Hiit.all[3].id, done_dates: (Date.today - 3), user_id: @user.id)
        visit root_path
        expect(all(".todays-hiit-container")[0]).to have_no_content("❌")
        expect(all(".todays-hiit-container")[0]).to have_content("✅")
        # adminユーザーログイン時には、メニュー作成・hiit作成・グループ作成のボタンがある
        expect(page).to have_link "メニューを作成する"
        expect(page).to have_link "HIITを作成する"
        expect(page).to have_link "グループを作成する"
      end
      it "一般ユーザーでログインしている時" do
        # 権限の有無を書き換え
        @user.admin = false
        # チーム名が表示されている
        sign_in_support(@user)
        expect(page).to have_content(@user.team.name)
        #アプリ名が表示されている
        expect(page).to have_content("HiitApp")
        # ユーザー名が表示されている
        expect(page).to have_content(@user.name)
        # ログアウトボタンが表示されている
        expect(page).to have_content("ログアウト")
        # グループ名が4つと・・・が表示されている
        expect(page).to have_content(Group.all[0].name)
        expect(page).to have_content(Group.all[1].name)
        expect(page).to have_content(Group.all[2].name)
        expect(page).to have_content(Group.all[3].name)
        expect(page).to have_no_content(Group.all[4].name)
        expect(page).to have_content("...")
        # "~さんのマイページです"が表示されている
        expect(page).to have_content("#{@user.name}さんのマイページです")
        # 3日前から3日後までの日付が表示されている
        expect(page).to have_content("#{(Date.today - 3).strftime('%m/%d')}")
        expect(page).to have_content("#{(Date.today - 2).strftime('%m/%d')}")
        expect(page).to have_content("#{(Date.today - 1).strftime('%m/%d')}")
        expect(page).to have_content("#{(Date.today).strftime('%m/%d')}")
        expect(page).to have_content("#{(Date.today + 1).strftime('%m/%d')}")
        expect(page).to have_content("#{(Date.today + 2).strftime('%m/%d')}")
        expect(page).to have_content("#{(Date.today + 3).strftime('%m/%d')}")
        # 今日の日付のカードにのみ、「今日の予定を見る」ボタンがある
        expect(all(".daily-menu-container")[3]).to have_selector ".link-to-today", text: "今日の予定を見る"
        expect(all(".daily-menu-container")[0]).to have_no_selector ".link-to-today", text: "今日の予定を見る"
        expect(all(".daily-menu-container")[1]).to have_no_selector ".link-to-today", text: "今日の予定を見る"
        expect(all(".daily-menu-container")[2]).to have_no_selector ".link-to-today", text: "今日の予定を見る"
        expect(all(".daily-menu-container")[4]).to have_no_selector ".link-to-today", text: "今日の予定を見る"
        expect(all(".daily-menu-container")[5]).to have_no_selector ".link-to-today", text: "今日の予定を見る"
        expect(all(".daily-menu-container")[6]).to have_no_selector ".link-to-today", text: "今日の予定を見る"
        # 日曜日、水曜日、土曜日に関してはその日のHIITが３つなので全て表示されている
        # ここに関しては実施日に書き換えが必要
        expect(all(".daily-menu-container")[2]).to have_content(Hiit.all[0].name)
        expect(all(".daily-menu-container")[2]).to have_content(Hiit.all[1].name)
        expect(all(".daily-menu-container")[2]).to have_content(Hiit.all[2].name)
        expect(all(".daily-menu-container")[5]).to have_content(Hiit.all[0].name)
        expect(all(".daily-menu-container")[5]).to have_content(Hiit.all[1].name)
        expect(all(".daily-menu-container")[5]).to have_content(Hiit.all[2].name)
        expect(all(".daily-menu-container")[6]).to have_content(Hiit.all[0].name)
        expect(all(".daily-menu-container")[6]).to have_content(Hiit.all[1].name)
        expect(all(".daily-menu-container")[6]).to have_content(Hiit.all[2].name)
        # 月曜日、火曜日、木曜日、金曜日に関しては、５つのHIITのうち４つ分しか表示されていない
        expect(all(".daily-menu-container")[0]).to have_content(Hiit.all[3].name)
        expect(all(".daily-menu-container")[0]).to have_content(Hiit.all[4].name)
        expect(all(".daily-menu-container")[0]).to have_content(Hiit.all[5].name)
        expect(all(".daily-menu-container")[0]).to have_content(Hiit.all[6].name)
        expect(all(".daily-menu-container")[0]).to have_no_content(Hiit.all[7].name)
        expect(all(".daily-menu-container")[0]).to have_content("...")
        expect(all(".daily-menu-container")[1]).to have_content(Hiit.all[3].name)
        expect(all(".daily-menu-container")[1]).to have_content(Hiit.all[4].name)
        expect(all(".daily-menu-container")[1]).to have_content(Hiit.all[5].name)
        expect(all(".daily-menu-container")[1]).to have_content(Hiit.all[6].name)
        expect(all(".daily-menu-container")[1]).to have_no_content(Hiit.all[7].name)
        expect(all(".daily-menu-container")[1]).to have_content("...")
        expect(all(".daily-menu-container")[3]).to have_content(Hiit.all[3].name)
        expect(all(".daily-menu-container")[3]).to have_content(Hiit.all[4].name)
        expect(all(".daily-menu-container")[3]).to have_content(Hiit.all[5].name)
        expect(all(".daily-menu-container")[3]).to have_content(Hiit.all[6].name)
        expect(all(".daily-menu-container")[3]).to have_no_content(Hiit.all[7].name)
        expect(all(".daily-menu-container")[3]).to have_content("...")
        expect(all(".daily-menu-container")[4]).to have_content(Hiit.all[3].name)
        expect(all(".daily-menu-container")[4]).to have_content(Hiit.all[4].name)
        expect(all(".daily-menu-container")[4]).to have_content(Hiit.all[5].name)
        expect(all(".daily-menu-container")[4]).to have_content(Hiit.all[6].name)
        expect(all(".daily-menu-container")[4]).to have_no_content(Hiit.all[7].name)
        expect(all(".daily-menu-container")[4]).to have_content("...")
        # 未実施のものには❌、実施済みのものには✅がつく
        expect(all(".todays-hiit-container")[0]).to have_content("❌")
        UserHiit.create(hiit_id: Hiit.all[3].id, done_dates: (Date.today - 3), user_id: @user.id)
        visit root_path
        expect(all(".todays-hiit-container")[0]).to have_no_content("❌")
        expect(all(".todays-hiit-container")[0]).to have_content("✅")
        # adminユーザーログイン時には、メニュー作成・hiit作成・グループ作成のボタンがある
        #expect(page).to have_no_link "メニューを作成する"
        #expect(page).to have_no_link "HIITを作成する"
        #expect(page).to have_no_link "グループを作成する"
      end
    end
  end

  describe "チーム詳細の結合テスト" do
    before do
      @team = FactoryBot.create(:team)
      @user1 = FactoryBot.create(:user, team_id: @team.id)
      @user2 = FactoryBot.create(:user, team_id: @team.id, admin: false)
      @hiit1 = FactoryBot.create(:hiit, team_id: @team.id)
      @hiit2 = FactoryBot.create(:hiit, team_id: @team.id)
      @menu = FactoryBot.create(:menu, team_id: @team.id)
      8.times do
        MenuHiit.create(menu_id: @menu.id, hiit_id: @hiit1.id)
        MenuHiit.create(menu_id: @menu.id, hiit_id: @hiit2.id)
      end
      @group1 = Group.create(name: "group1", team_id: @team.id, hiit_id: @hiit1.id)
      @usergroup1 = UserGroup.create(user_id: @user1.id, group_id: @group1.id)
      @group2 = Group.create(name: "group2", team_id: @team.id, hiit_id: @hiit2.id)
      @usergroup2 = UserGroup.create(user_id: @user2.id, group_id: @group2.id)
    end
    context "権限ユーザー" do
      it "権限ユーザーであれば一般ユーザーの情報以外に各種新規登録、編集ボタン、ユーザーページへのリンクなどがある" do
        # サインインする
        sign_in_support(@user1)
        # チーム詳細ページに遷移する
        visit team_path(@team)
        # チーム名がテーブルに表示されている
        expect(page).to have_selector "th", text: @team.name
        # チーム名を変更する、のリンクが表示されている
        expect(page).to have_link "チーム名を変更する"
        # 新しいグループを作成する、のリンクが表示されている
        expect(page).to have_link "新しいグループを作成する"
        # 選手名が全てリンク形式で表示されている
        expect(page).to have_link @user1.name
        expect(page).to have_link @user2.name
        # 選手名の横にはその選手の所属するグループへのリンクが表示されている
        expect(all(".border-on")[2]).to have_link @group1.name
        expect(all(".border-on")[3]).to have_link @group2.name
        # 新しいHIITを登録するへのリンクが表示されている
        expect(page).to have_link "新しいHIITを登録する"
        # HIIT名の横には、そのHIITを行っているグループ名が表示されている
        expect(all(".hiit-group-td")[0]).to have_link @hiit1.group.name
        expect(all(".hiit-group-td")[1]).to have_link @hiit2.group.name
        # 新しいメニューを登録するへのリンクが表示されている
        expect(page).to have_link "新しいメニューを登録する"
        # チーム作成時に登録されたメニューが表示されている
        expect(all(".each-menu-container")[0]).to have_link @menu.name
        # に画像も設定されている
        expect(all(".each-menu-container")[0]).to have_selector "img"
      end
    end
    context "一般ユーザー" do
      it "一般ユーザーであれば他のユーザーの情報や各種新規登録、編集ボタン、ユーザーページへのリンクなどが利用できない" do
        # サインインする
        sign_in_support(@user2)
        # チーム詳細ページに遷移する
        visit team_path(@team)
        # チーム名がテーブルに表示されている
        expect(page).to have_selector "th", text: @team.name
        # チーム名を変更する、のリンクが表示されていない
        expect(page).to have_no_link "チーム名を変更する"
        # 新しいグループを作成する、のリンクが表示されていない
        expect(page).to have_no_link "新しいグループを作成する"
        # 全ての選手名が表示されているが、リンクは自分自身の分のみが有効化されている
        expect(page).to have_no_link @user1.name
        expect(page).to have_content @user1.name
        expect(page).to have_link @user2.name
        # 選手名の横にはその選手の所属するグループへのリンクが表示されている
        expect(all(".border-on")[2]).to have_link @group1.name
        expect(all(".border-on")[3]).to have_link @group2.name
        # 新しいHIITを登録するへのリンクが表示されていない
        expect(page).to have_no_link "新しいHIITを登録する"
        # HIIT名の横には、そのHIITを行っているグループ名が表示されている
        expect(all(".hiit-group-td")[0]).to have_link @hiit1.group.name
        expect(all(".hiit-group-td")[1]).to have_link @hiit2.group.name
        # 新しいメニューを登録するへのリンクが表示されていない
        expect(page).to have_no_link "新しいメニューを登録する"
        # チーム作成時に登録されたメニューが表示されている
        expect(all(".each-menu-container")[0]).to have_link @menu.name
        # 画像も設定されている
        expect(all(".each-menu-container")[0]).to have_selector "img"
      end
    end
    context "ログインしていない場合" do
      it "ログインしていない状態でチーム詳細ページに遷移するとログインページにリダイレクトされる" do
        visit team_path(@team)
        expect(current_path).to eq new_user_session_path
      end
    end
  end

  describe "チーム編集の結合テスト" do
    before do
      @team = FactoryBot.create(:team)
      @user1 = FactoryBot.create(:user, team_id: @team.id)
      @user2 = FactoryBot.create(:user, team_id: @team.id, admin: false)
    end
    context "権限ユーザー" do
      it "権限ユーザーであればチーム名の編集ができる" do
        # サインインする
        sign_in_support(@user1)
        # チーム編集ページに遷移する
        visit edit_team_path(@team)
        # チーム名編集画面です、の表示がある
        expect(page).to have_content("チーム情報編集画面です")
        # 現在のチーム名がデフォルトで入力されている
        expect(page).to have_field("team[name]", with: @team.name)
        # チーム詳細画面に戻る、のボタンが表示されている
        expect(page).to have_link "チーム詳細画面に戻る"
        # チーム名の編集ができる
        fill_in "team_name", with: "テストチーム"
        # チーム情報を編集するボタンを押してもチームの数は変更されない
        expect{
          click_on "チーム情報を編集する"
        }.to change{ Team.count }.by(0)
        # チーム詳細画面に遷移する
        expect(current_path).to eq team_path(@team)
        # ヘッダーにチーム名が表示されている
        expect(find("header")).to have_content "テストチーム"
        # テーブルにチーム名が表示されている
        expect(all("th")[0]).to have_content "テストチーム"
      end
    end
    context "一般ユーザー" do
      it "一般ユーザーとしてログインしている場合にはチーム編集のページに遷移できない" do
        # ログインする
        sign_in_support(@user2)
        # チーム編集ページに遷移する
        visit edit_team_path(@team)
        # トップページにリダイレクトされる
        expect(current_path).to eq root_path
      end
    end
    context "未ログイン状態" do
      it "ログインしていない状態ではチーム編集ページに遷移できない" do
        #チーム編集ページにせん# チーム編集ページに遷移する
        visit edit_team_path(@team)
        # ログインページにリダイレクトされる
        expect(current_path).to eq new_user_session_path
      end
    end
  end

end
