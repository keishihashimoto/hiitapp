require 'rails_helper'

RSpec.describe "Users", type: :system do

  describe "サインアップの結合テスト" do
    before do
      @team = FactoryBot.create(:team)
      @user = FactoryBot.build(:user, team_id: @team.id)
    end

    context "サインアップできる時" do
      it "ユーザー情報が設定されていればサインアップができる" do
        # サインアップページに遷移する
        visit new_user_registration_path
        # Sign upの文字が表示されている
        expect(page).to have_content("Sign up")
        " 必要情報を入力する"
        fill_in "user_name", with: @user.name
        fill_in "user_email", with: @user.email
        fill_in "user_password", with: @user.password
        fill_in "user_password_confirmation", with: @user.password
        find("select[name='user[team_id]']").find("option[value='#{@team.id}']").select_option
        # SignUpボタンを押すとuserの数が一つ増える
        expect{
          find("input[name='commit']").click
        }.to change{ User.count }.by(1)
        # トップページに遷移する
        expect(current_path).to eq root_path
      end
    end
    context "サインアップできない時" do
      it "ユーザー情報が設定されていなければサインアップができない" do
        # サインアップページに遷移する
        visit new_user_registration_path
        # Sign upの文字が表示されている
        expect(page).to have_content("Sign up")
        # 何も入力せずにそのままSignUpボタンを押してもとuserの数が一つ増えない
        expect{
          find("input[name='commit']").click
        }.to change{ User.count }.by(0)
        # 元のページに戻り、Sign upの文字も表示されている
        expect(page).to have_content("Sign up")
        # エラーメッセージも表示されている
        expect(page).to have_content("Name can't be blank")
        expect(page).to have_content("Email can't be blank")
        expect(page).to have_content("Password can't be blank")
      end
    end
  end

  describe "サインインの結合テスト" do
    before do
      @user = FactoryBot.create(:user)
    end

    context "サインインできる時" do
      it "必要な情報が入力されればサインインができる" do
        sign_in_support(@user)
      end
    end
    context "サインインできない時" do
      it "必要な情報が入力されていなければサインインができない" do
        visit new_user_session_path
        find("input[name='commit']").click
        expect(page).to have_content("Log in")
      end
    end
  end

  describe "users#detailの結合テスト" do
    before do
      @team = FactoryBot.create(:team)
      @user1 = FactoryBot.create(:user, team_id: @team.id)
      @user2 = FactoryBot.create(:user, team_id: @team.id, admin: false)
      @menu = FactoryBot.create(:menu, team_id: @team.id)
        
      8.times do |i|
        FactoryBot.create(:hiit, team_id: @team.id)
        8.times do
          MenuHiit.create(menu_id: @menu.id, hiit_id: Hiit.all[i].id)
        end
        
        group = Group.create(name: Faker::Name.name, hiit_id: Hiit.all[i].id, team_id: @team.id)
        UserGroup.create(user_id: @user1.id, group_id: group.id)
        UserGroup.create(user_id: @user2.id, group_id: group.id)
      end

        # ３つのHIITは0,3,6に実施
        3.times do |i|
          3.times do |w|
            HiitDate.create(hiit_id: Hiit.all[i].id, date: ((Date.today - 3 + 3 * w).wday))
          end
        end
        # 残りの5つは1, 2, 4, 5に実施
        5.times do |i|
          2.times do |w|
            HiitDate.create(hiit_id: Hiit.all[(i + 3)].id, date:  ((Date.today - 2 + 3 * w).wday))
            HiitDate.create(hiit_id: Hiit.all[(i + 3)].id, date: ((Date.today - 1 + 3 * w).wday))
          end
        end

    end
    context "ログイン中（権限ユーザー）" do
      it "権限ユーザーはurl直接入力で自分のdetailページに遷移することができる" do
        # サインインする
        sign_in_support(@user1)
        # 自分自身のdetailページに遷移する
        visit detail_user_path(@user1)
        # ~のトレーニングメニューという表記がある
        expect(page).to have_content("#{@user1.name}のトレーニングメニュー")
        # 3日前から3日後までの日付が表示されている
        expect(all(".date-container")[0]).to have_content("#{(Date.today - 3).strftime('%m/%d')}")
        expect(all(".date-container")[1]).to have_content("#{(Date.today - 2).strftime('%m/%d')}")
        expect(all(".date-container")[2]).to have_content("#{(Date.today - 1).strftime('%m/%d')}")
        expect(all(".date-container")[3]).to have_content("#{(Date.today ).strftime('%m/%d')}")
        expect(all(".date-container")[4]).to have_content("#{(Date.today + 1).strftime('%m/%d')}")
        expect(all(".date-container")[5]).to have_content("#{(Date.today + 2).strftime('%m/%d')}")
        expect(all(".date-container")[6]).to have_content("#{(Date.today + 3).strftime('%m/%d')}")
        # それぞれの日付の横に曜日が表示されている
        expect(all(".date-container")[0]).to have_content("#{Wday.find((Date.today - 3).wday).name.slice(0)}")
        expect(all(".date-container")[1]).to have_content("#{Wday.find((Date.today - 2).wday).name.slice(0)}")
        expect(all(".date-container")[2]).to have_content("#{Wday.find((Date.today - 1).wday).name.slice(0)}")
        expect(all(".date-container")[3]).to have_content("#{Wday.find((Date.today).wday).name.slice(0)}")
        expect(all(".date-container")[4]).to have_content("#{Wday.find((Date.today + 1).wday).name.slice(0)}")
        expect(all(".date-container")[5]).to have_content("#{Wday.find((Date.today + 2).wday).name.slice(0)}")
        expect(all(".date-container")[6]).to have_content("#{Wday.find((Date.today + 3).wday).name.slice(0)}")
        # それぞれの日付に対応したカードには、その日に行うべきhiitが表示されている
        expect(all(".daily-menu-container")[0]).to have_link @team.hiits[0].name
        expect(all(".daily-menu-container")[0]).to have_link @team.hiits[1].name
        expect(all(".daily-menu-container")[0]).to have_link @team.hiits[2].name
        expect(all(".daily-menu-container")[3]).to have_link @team.hiits[0].name
        expect(all(".daily-menu-container")[3]).to have_link @team.hiits[1].name
        expect(all(".daily-menu-container")[3]).to have_link @team.hiits[2].name
        expect(all(".daily-menu-container")[6]).to have_link @team.hiits[0].name
        expect(all(".daily-menu-container")[6]).to have_link @team.hiits[1].name
        expect(all(".daily-menu-container")[6]).to have_link @team.hiits[2].name
        expect(all(".daily-menu-container")[1]).to have_link @team.hiits[3].name
        expect(all(".daily-menu-container")[1]).to have_link @team.hiits[4].name
        expect(all(".daily-menu-container")[1]).to have_link @team.hiits[5].name
        expect(all(".daily-menu-container")[1]).to have_link @team.hiits[6].name
        expect(all(".daily-menu-container")[1]).to have_no_link @team.hiits[7].name
        expect(all(".daily-menu-container")[2]).to have_link @team.hiits[3].name
        expect(all(".daily-menu-container")[2]).to have_link @team.hiits[4].name
        expect(all(".daily-menu-container")[2]).to have_link @team.hiits[5].name
        expect(all(".daily-menu-container")[2]).to have_link @team.hiits[6].name
        expect(all(".daily-menu-container")[2]).to have_no_link @team.hiits[7].name
        expect(all(".daily-menu-container")[4]).to have_link @team.hiits[3].name
        expect(all(".daily-menu-container")[4]).to have_link @team.hiits[4].name
        expect(all(".daily-menu-container")[4]).to have_link @team.hiits[5].name
        expect(all(".daily-menu-container")[4]).to have_link @team.hiits[6].name
        expect(all(".daily-menu-container")[4]).to have_no_link @team.hiits[7].name
        expect(all(".daily-menu-container")[5]).to have_link @team.hiits[3].name
        expect(all(".daily-menu-container")[5]).to have_link @team.hiits[4].name
        expect(all(".daily-menu-container")[5]).to have_link @team.hiits[5].name
        expect(all(".daily-menu-container")[5]).to have_link @team.hiits[6].name
        expect(all(".daily-menu-container")[5]).to have_no_link @team.hiits[7].name
        # 表示されているhiitの数は、hiitが３つ以下であれば全て、4つ以上であれば４つまで
        # 省略されてるhiitがある時には...が表示
        expect(all(".daily-menu-container")[0]).to have_no_content("...")
        expect(all(".daily-menu-container")[1]).to have_content("...")
        expect(all(".daily-menu-container")[2]).to have_content("...")
        expect(all(".daily-menu-container")[3]).to have_no_content("...")
        expect(all(".daily-menu-container")[4]).to have_content("...")
        expect(all(".daily-menu-container")[5]).to have_content("...")
        expect(all(".daily-menu-container")[6]).to have_no_content("...")
        # 今日の日付の部分にのみ"今日の予定を見る"が表示
        expect(all(".daily-menu-container")[0]).to have_no_link("今日の予定を見る")
        expect(all(".daily-menu-container")[1]).to have_no_link("今日の予定を見る")
        expect(all(".daily-menu-container")[2]).to have_no_link("今日の予定を見る")
        expect(all(".daily-menu-container")[3]).to have_link("今日の予定を見る")
        expect(all(".daily-menu-container")[4]).to have_no_link("今日の予定を見る")
        expect(all(".daily-menu-container")[5]).to have_no_link("今日の予定を見る")
        expect(all(".daily-menu-container")[6]).to have_no_link("今日の予定を見る")
        # 実施していないhiitについては❌が表示
        expect(all(".daily-menu-container")[0]).to have_content("❌")
        expect(all(".daily-menu-container")[1]).to have_content("❌")
        expect(all(".daily-menu-container")[2]).to have_content("❌")
        expect(all(".daily-menu-container")[3]).to have_content("❌")
        expect(all(".daily-menu-container")[4]).to have_content("❌")
        expect(all(".daily-menu-container")[5]).to have_content("❌")
        expect(all(".daily-menu-container")[6]).to have_content("❌")
        expect(all(".daily-menu-container")[0]).to have_no_content("✅")
        expect(all(".daily-menu-container")[1]).to have_no_content("✅")
        expect(all(".daily-menu-container")[2]).to have_no_content("✅")
        expect(all(".daily-menu-container")[3]).to have_no_content("✅")
        expect(all(".daily-menu-container")[4]).to have_no_content("✅")
        expect(all(".daily-menu-container")[5]).to have_no_content("✅")
        expect(all(".daily-menu-container")[6]).to have_no_content("✅")
        # 実施済みのhiitに関しては✅が表示
        UserHiit.create(user_id: @user1.id, hiit_id: @team.hiits[0].id, done_dates: Date.today)
        visit detail_user_path(@user1)
        expect(all(".daily-menu-container")[3].all(".todays-hiit-container")[0]).to have_content("✅")
        # 画面下部には"詳細を見る", "削除する", "チームのページに戻る"のリンクが表示
        expect(page).to have_link "#{@user1.name}の詳細を見る"
        expect(page).to have_link "チームのページに戻る"
      end
      it "権限ユーザーはチーム詳細ページから他の選手のdetailページに遷移することができる" do
        # サインインする
        sign_in_support(@user1)
        # チーム詳細ページに遷移する
        visit team_path(@team)
        # ＠user2のユーザー名をクリックする
        click_link @user2.name
        # ユーザー2のdetailページに遷移する
        expect(current_path).to eq detail_user_path(@user2)
        # ~のトレーニングメニューという表記がある
        expect(page).to have_content("#{@user2.name}のトレーニングメニュー")
        # 3日前から3日後までの日付が表示されている
        expect(all(".date-container")[0]).to have_content("#{(Date.today - 3).strftime('%m/%d')}")
        expect(all(".date-container")[1]).to have_content("#{(Date.today - 2).strftime('%m/%d')}")
        expect(all(".date-container")[2]).to have_content("#{(Date.today - 1).strftime('%m/%d')}")
        expect(all(".date-container")[3]).to have_content("#{(Date.today ).strftime('%m/%d')}")
        expect(all(".date-container")[4]).to have_content("#{(Date.today + 1).strftime('%m/%d')}")
        expect(all(".date-container")[5]).to have_content("#{(Date.today + 2).strftime('%m/%d')}")
        expect(all(".date-container")[6]).to have_content("#{(Date.today + 3).strftime('%m/%d')}")
        # それぞれの日付の横に曜日が表示されている
        expect(all(".date-container")[0]).to have_content("#{Wday.find((Date.today - 3).wday).name.slice(0)}")
        expect(all(".date-container")[1]).to have_content("#{Wday.find((Date.today - 2).wday).name.slice(0)}")
        expect(all(".date-container")[2]).to have_content("#{Wday.find((Date.today - 1).wday).name.slice(0)}")
        expect(all(".date-container")[3]).to have_content("#{Wday.find((Date.today).wday).name.slice(0)}")
        expect(all(".date-container")[4]).to have_content("#{Wday.find((Date.today + 1).wday).name.slice(0)}")
        expect(all(".date-container")[5]).to have_content("#{Wday.find((Date.today + 2).wday).name.slice(0)}")
        expect(all(".date-container")[6]).to have_content("#{Wday.find((Date.today + 3).wday).name.slice(0)}")
        # それぞれの日付に対応したカードには、その日に行うべきhiitが表示されている
        expect(all(".daily-menu-container")[0]).to have_link @team.hiits[0].name
        expect(all(".daily-menu-container")[0]).to have_link @team.hiits[1].name
        expect(all(".daily-menu-container")[0]).to have_link @team.hiits[2].name
        expect(all(".daily-menu-container")[3]).to have_link @team.hiits[0].name
        expect(all(".daily-menu-container")[3]).to have_link @team.hiits[1].name
        expect(all(".daily-menu-container")[3]).to have_link @team.hiits[2].name
        expect(all(".daily-menu-container")[6]).to have_link @team.hiits[0].name
        expect(all(".daily-menu-container")[6]).to have_link @team.hiits[1].name
        expect(all(".daily-menu-container")[6]).to have_link @team.hiits[2].name
        expect(all(".daily-menu-container")[1]).to have_link @team.hiits[3].name
        expect(all(".daily-menu-container")[1]).to have_link @team.hiits[4].name
        expect(all(".daily-menu-container")[1]).to have_link @team.hiits[5].name
        expect(all(".daily-menu-container")[1]).to have_link @team.hiits[6].name
        expect(all(".daily-menu-container")[1]).to have_no_link @team.hiits[7].name
        expect(all(".daily-menu-container")[2]).to have_link @team.hiits[3].name
        expect(all(".daily-menu-container")[2]).to have_link @team.hiits[4].name
        expect(all(".daily-menu-container")[2]).to have_link @team.hiits[5].name
        expect(all(".daily-menu-container")[2]).to have_link @team.hiits[6].name
        expect(all(".daily-menu-container")[2]).to have_no_link @team.hiits[7].name
        expect(all(".daily-menu-container")[4]).to have_link @team.hiits[3].name
        expect(all(".daily-menu-container")[4]).to have_link @team.hiits[4].name
        expect(all(".daily-menu-container")[4]).to have_link @team.hiits[5].name
        expect(all(".daily-menu-container")[4]).to have_link @team.hiits[6].name
        expect(all(".daily-menu-container")[4]).to have_no_link @team.hiits[7].name
        expect(all(".daily-menu-container")[5]).to have_link @team.hiits[3].name
        expect(all(".daily-menu-container")[5]).to have_link @team.hiits[4].name
        expect(all(".daily-menu-container")[5]).to have_link @team.hiits[5].name
        expect(all(".daily-menu-container")[5]).to have_link @team.hiits[6].name
        expect(all(".daily-menu-container")[5]).to have_no_link @team.hiits[7].name
        # 表示されているhiitの数は、hiitが３つ以下であれば全て、4つ以上であれば４つまで
        # 省略されてるhiitがある時には...が表示
        expect(all(".daily-menu-container")[0]).to have_no_content("...")
        expect(all(".daily-menu-container")[1]).to have_content("...")
        expect(all(".daily-menu-container")[2]).to have_content("...")
        expect(all(".daily-menu-container")[3]).to have_no_content("...")
        expect(all(".daily-menu-container")[4]).to have_content("...")
        expect(all(".daily-menu-container")[5]).to have_content("...")
        expect(all(".daily-menu-container")[6]).to have_no_content("...")
        # 今日の日付の部分にのみ"今日の予定を見る"が表示
        expect(all(".daily-menu-container")[0]).to have_no_link("今日の予定を見る")
        expect(all(".daily-menu-container")[1]).to have_no_link("今日の予定を見る")
        expect(all(".daily-menu-container")[2]).to have_no_link("今日の予定を見る")
        expect(all(".daily-menu-container")[3]).to have_link("今日の予定を見る")
        expect(all(".daily-menu-container")[4]).to have_no_link("今日の予定を見る")
        expect(all(".daily-menu-container")[5]).to have_no_link("今日の予定を見る")
        expect(all(".daily-menu-container")[6]).to have_no_link("今日の予定を見る")
        # 実施していないhiitについては❌が表示
        expect(all(".daily-menu-container")[0]).to have_content("❌")
        expect(all(".daily-menu-container")[1]).to have_content("❌")
        expect(all(".daily-menu-container")[2]).to have_content("❌")
        expect(all(".daily-menu-container")[3]).to have_content("❌")
        expect(all(".daily-menu-container")[4]).to have_content("❌")
        expect(all(".daily-menu-container")[5]).to have_content("❌")
        expect(all(".daily-menu-container")[6]).to have_content("❌")
        expect(all(".daily-menu-container")[0]).to have_no_content("✅")
        expect(all(".daily-menu-container")[1]).to have_no_content("✅")
        expect(all(".daily-menu-container")[2]).to have_no_content("✅")
        expect(all(".daily-menu-container")[3]).to have_no_content("✅")
        expect(all(".daily-menu-container")[4]).to have_no_content("✅")
        expect(all(".daily-menu-container")[5]).to have_no_content("✅")
        expect(all(".daily-menu-container")[6]).to have_no_content("✅")
        # 実施済みのhiitに関しては✅が表示
        UserHiit.create(user_id: @user2.id, hiit_id: @team.hiits[0].id, done_dates: Date.today)
        visit detail_user_path(@user2)
        expect(all(".daily-menu-container")[3].all(".todays-hiit-container")[0]).to have_content("✅")
        # 画面下部には"詳細を見る", "削除する", "チームのページに戻る"のリンクが表示
        expect(page).to have_link "#{@user2.name}の詳細を見る"
        expect(page).to have_link "チームのページに戻る"        
      end
    end
    context "ログイン中（一般ユーザー）" do
      it "一般ユーザーはurl直接入力で権限ユーザーのdetailページに遷移することができない" do
        # サインインする
        sign_in_support(@user2)
        # 権限ユーザーのdetailページのurlを直接入力する
        visit detail_user_path(@user1)
        # トップページにリダイレクトされる
        expect(current_path).to eq root_path
      end
      it "一般ユーザーはurl直接入力で自分のdetailページに遷移することができない" do
        # サインインする
        sign_in_support(@user2)
        # 権限ユーザーのdetailページのurlを直接入力する
        visit detail_user_path(@user2)
        # トップページにリダイレクトされる
        expect(current_path).to eq root_path
      end
    end
    context "未ログイン状態" do
      it "未ログイン状態ではurl直接入力で権限ユーザーのdetailページに遷移することができない" do
        # 権限ユーザーのdetailページのurlを直接入力する
        visit detail_user_path(@user1)
        # ログインページにリダイレクトされる
        expect(current_path).to eq root_path
      end
      it "未ログイン状態ではurl直接入力で自分のdetailページに遷移することができない" do
        # 権限ユーザーのdetailページのurlを直接入力する
        visit detail_user_path(@user1)
        # ログインページにリダイレクトされる
        expect(current_path).to eq root_path
      end
    end
  end

  describe "users#showの結合テスト" do
    before do
      @team = FactoryBot.create(:team)
      @user1 = FactoryBot.create(:user, team_id: @team.id)
      @user2 = FactoryBot.create(:user, team_id: @team.id, admin: false)
      @menu = FactoryBot.create(:menu, team_id: @team.id)
        
      8.times do |i|
        FactoryBot.create(:hiit, team_id: @team.id)
        8.times do
          MenuHiit.create(menu_id: @menu.id, hiit_id: Hiit.all[i].id)
        end
        
        group = Group.create(name: Faker::Name.name, hiit_id: Hiit.all[i].id, team_id: @team.id)
        UserGroup.create(user_id: @user1.id, group_id: group.id)
        UserGroup.create(user_id: @user2.id, group_id: group.id)
      end

        # ３つのHIITは0,3,6に実施
        3.times do |i|
          3.times do |w|
            HiitDate.create(hiit_id: Hiit.all[i].id, date: ((Date.today - 3 + 3 * w).wday))
          end
        end
        # 残りの5つは1, 2, 4, 5に実施
        5.times do |i|
          2.times do |w|
            HiitDate.create(hiit_id: Hiit.all[(i + 3)].id, date:  ((Date.today - 2 + 3 * w).wday))
            HiitDate.create(hiit_id: Hiit.all[(i + 3)].id, date: ((Date.today - 1 + 3 * w).wday))
          end
        end

    end
    context "ログイン中（権限ユーザー）" do
      it "権限ユーザーであれば、自分の詳細ページに遷移できる" do
        # サインインする
        sign_in_support(@user1)
        # ヘッダーの自分の名前をクリックする
        find("header").click_link @user1.name
        # ユーザー詳細ページに遷移する
        expect(current_path).to eq user_path(@user1)
        # 1行目にユーザー名が表示されている
        expect(all("td")[0]).to have_link @user1.name
        # 2行目にはチーム名が表示されている
        expect(all("td")[1]).to have_link @user1.team.name
        # 3行目にはuser1が所属しているグループ名が表示されている
        8.times do |i|
          expect(all("td")[2]).to have_link @team.groups[i].name
        end
        # 4行目には、今日のhiitが表示されている
        3.times do |i|
          expect(all("td")[3]).to have_link @team.hiits[i].name
        end
        # 本日の詳しい予定を見るその他へのリンクがある
        expect(page).to have_link "本日の詳しい予定を見る"
        expect(page).to have_link "ユーザー情報を編集する"
        expect(page).to have_link "ホーム画面へ戻る"
      end
      it "権限ユーザーであれば一般ユーザーの詳細ページに遷移できる" do
        # サインインする
        sign_in_support(@user1)
        # ユーザーdetailページに遷移する
        visit detail_user_path(@user2)
        # "~の詳細を見る"をクリックする
        click_link "#{@user2.name}の詳細を見る"
        # ユーザー詳細ページに遷移する
        expect(current_path).to eq user_path(@user2)
        # 1行目にユーザー名が表示されている
        expect(all("td")[0]).to have_link @user2.name
        # 2行目にはチーム名が表示されている
        expect(all("td")[1]).to have_link @user2.team.name
        # 3行目にはuser1が所属しているグループ名が表示されている
        8.times do |i|
          expect(all("td")[2]).to have_link @team.groups[i].name
        end
        # 4行目には、今日のhiitが表示されている
        3.times do |i|
          expect(all("td")[3]).to have_link @team.hiits[i].name
        end
        # 本日の詳しい予定を見るその他へのリンクがある
        expect(page).to have_link "本日の詳しい予定を見る"
        expect(page).to have_link "ホーム画面へ戻る"      
        # ユーザー情報編集へのリンクがない
        expect(page).to have_no_link "ユーザー情報を編集する"  
      end
    end
    context "ログイン中（一般ユーザー）" do
      it "一般ユーザーであれば自分の詳細ページに遷移できる" do
        # サインインする
        sign_in_support(@user2)
        # ヘッダーの自分の名前をクリックする
        click_link @user2.name
        # ユーザー詳細ページに遷移する
        expect(current_path).to eq user_path(@user2)
        # 1行目にユーザー名が表示されている
        expect(all("td")[0]).to have_link @user2.name
        # 2行目にはチーム名が表示されている
        expect(all("td")[1]).to have_link @user2.team.name
        # 3行目にはuser1が所属しているグループ名が表示されている
        8.times do |i|
          expect(all("td")[2]).to have_link @team.groups[i].name
        end
        # 4行目には、今日のhiitが表示されている
        3.times do |i|
          expect(all("td")[3]).to have_link @team.hiits[i].name
        end
        # 本日の詳しい予定を見るその他へのリンクがある
        expect(page).to have_link "本日の詳しい予定を見る"
        expect(page).to have_link "ホーム画面へ戻る"      
        expect(page).to have_link "ユーザー情報を編集する" 
      end
      it "一般ユーザーは他のユーザーの詳細ページには遷移できない" do
        # サインインする
        sign_in_support(@user2)
        # ユーザー詳細ページへのurlをて入力する
        visit user_path(@user1)
        # トップページにリダイレクトされる
        expect(current_path).to eq root_path
      end
    end
    context "未ログイン状態" do
      it "ログインしていない場合には他の権限ユーザーの詳細ページに遷移できない" do
        # ユーザー詳細ページへのurlをて入力する
        visit user_path(@user1)
        # ログインページにリダイレクトされる
        expect(current_path).to eq new_user_session_path
      end
      it "ログインしていない場合には他の一般ユーザーの詳細ページに遷移できない" do
        # ユーザー詳細ページへのurlをて入力する
        visit user_path(@user2)
        # ログインページにリダイレクトされる
        expect(current_path).to eq new_user_session_path
      end
    end
  end

  describe "ユーザー削除の結合テスト" do
    before do
      @team = FactoryBot.create(:team)
      @user1 = FactoryBot.create(:user, team_id: @team.id)
      @user2 = FactoryBot.create(:user, team_id: @team.id, admin: false)
      @menu = FactoryBot.create(:menu, team_id: @team.id)

      8.times do |i|
        FactoryBot.create(:hiit, team_id: @team.id)
        8.times do
          MenuHiit.create(menu_id: @menu.id, hiit_id: Hiit.all[i].id)
        end
        
        group = Group.create(name: Faker::Name.name, hiit_id: Hiit.all[i].id, team_id: @team.id)
        UserGroup.create(user_id: @user1.id, group_id: group.id)
        UserGroup.create(user_id: @user2.id, group_id: group.id)
      end

      # ３つのHIITは0,3,6に実施
      3.times do |i|
        3.times do |w|
          HiitDate.create(hiit_id: Hiit.all[i].id, date: ((Date.today - 3 + 3 * w).wday))
        end
      end
      # 残りの5つは1, 2, 4, 5に実施
      5.times do |i|
        2.times do |w|
          HiitDate.create(hiit_id: Hiit.all[(i + 3)].id, date:  ((Date.today - 2 + 3 * w).wday))
          HiitDate.create(hiit_id: Hiit.all[(i + 3)].id, date: ((Date.today - 1 + 3 * w).wday))
        end
      end
    end
    context "ログイン中（権限ユーザー）" do
      it "権限ユーザーであれば、showページから一般ユーザーを削除できる" do
        # サインインする
        sign_in_support(@user1)
        # ユーザー詳細ページに遷移する
        visit user_path(@user2)
        # ユーザー削除ボタンをクリックすると、ユーザーが削除される
        expect{
          click_link "#{@user2.name}を削除する" 
        }.to change{ User.count }.by(-1)
        # チーム詳細ページに遷移する
        expect(current_path).to eq team_path(@team)
      end
      it "権限ユーザーであっても、編集ページから自身を削除することはできない" do
        # サインインする
        sign_in_support(@user1)
        # ユーザー編集ページに遷移する
        visit edit_user_registration_path(@user1)
        # ユーザー削除へのリンクは表示されていない
        expect(page).to have_no_link "delete", href: user_path(@user1)
        expect(page).to have_no_link "delete", href: users_path
      end
      it "権限ユーザーであっても、そのユーザーを削除することでグループが0人になる場合には削除ができない" do
        # サインインする
        sign_in_support(@user1)
        # ユーザー詳細ページに遷移する
        visit user_path(@user2)
        # ユーザー削除ボタンをクリックすると、ユーザーが削除される
        expect{
          click_link "#{@user2.name}を削除する" 
        }.to change{ User.count }.by(-1)
        # チーム詳細ページに遷移する
        expect(current_path).to eq team_path(@team)
        # user1の詳細ページに遷移する
        visit user_path(@user1)
        # ユーザー削除ボタンをクリックしても、ユーザーが削除されない
        expect{
          click_link "#{@user1.name}を削除する" 
        }.to change{ User.count }.by(0)
        # ユーザー詳細ページに戻る
        expect(current_path).to eq user_path(@user1)
        # エラーメッセージが表示されている
        expect(page).to have_content("Since group containing this user exists, this user can't be deleted")
      end
    end
    context "ログイン中（一般ユーザー）" do
      it "一般ユーザーは自身の詳細ページから自分を削除することができない" do
        # サインインする
        sign_in_support(@user2)
        # 自身の詳細ページに遷移する
        visit user_path(@user2)
        # 削除ボタンが表示されてない
        expect(page).to have_no_link "#{@user2.name}を削除する"
      end
      it "一般ユーザーは自身の編集ページから自分を削除することができない" do
        # サインインする
        sign_in_support(@user2)
        # ユーザー編集ページに遷移する
        visit edit_user_registration_path(@user2)
        # ユーザー削除へのリンクは表示されていない
        expect(page).to have_no_link "delete", href: user_path(@user2)
        expect(page).to have_no_link "delete", href: users_path
      end
    end
  end

end
