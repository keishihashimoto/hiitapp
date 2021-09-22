require 'rails_helper'

RSpec.describe "Menus", type: :system do
  before do
    @team = FactoryBot.create(:team)
    @user1 = FactoryBot.create(:user, team_id: @team.id)
    @user2 = FactoryBot.create(:user, team_id: @team.id, admin: false)
    @menu1 = FactoryBot.build(:menu, team_id: @team.id)
    @menu2 = FactoryBot.build(:menu, team_id: @team.id)
  end

  describe "メニュー作成の結合テスト" do
    context "権限ユーザーの場合" do
      it "権限ユーザーであれば、チーム詳細画面からメニュー作成ができる" do
        # サインインする
        sign_in_support(@user1)
        # チーム詳細画面に移動する
        visit team_path(@team)
        # 新しいメニューを登録するをクリック
        click_link "新しいメニューを登録する"
        # メニュー作成画面に移動する
        expect(current_path).to eq new_menu_path
        # メニューの内容を入力する
        fill_in "menu_name", with: @menu1.name
        fill_in "menu_text", with: @menu1.text
        image_path1 = Rails.root.join("app/assets/images/meeting.png")
        attach_file("menu_icon", image_path1)
        # メニューを登録するボタンを押すとメニューが登録される
        expect{
          find("input[name='commit']").click
        }.to change{ Menu.count }.by(1)
        # チームのページにリダイレクトされる
        expect(current_path).to eq team_path(@team)
        # 先程登録したメニューが表示されている
        expect(page).to have_link @menu1.name
      end
      it "権限ユーザーであれば、トップページからメニュー作成ができる" do
        # サインインする
        sign_in_support(@user1)
        # 新しいメニューを登録するをクリック
        click_link "メニューを作成する"
        # メニュー作成画面に移動する
        expect(current_path).to eq new_menu_path
        # メニューの内容を入力する
        fill_in "menu_name", with: @menu1.name
        fill_in "menu_text", with: @menu1.text
        image_path1 = Rails.root.join("app/assets/images/meeting.png")
        attach_file("menu_icon", image_path1)
        # メニューを登録するボタンを押すとメニューが登録される
        expect{
          find("input[name='commit']").click
        }.to change{ Menu.count }.by(1)
        # チームのページにリダイレクトされる
        expect(current_path).to eq team_path(@team)
        # 先程登録したメニューが表示されている
        expect(page).to have_link @menu1.name
      end
      it "メニュー作成に失敗すると元のページに戻り、エラーメッセージが表示される" do
        # サインインする
        sign_in_support(@user1)
        # メニュー作成ページに遷移する
        visit new_menu_path
        # 説明文だけを入力する
        fill_in "menu_text", with: "ダミーテキスト"
        # メニュー名を何も登録せずに、"メニューを登録する"をクリックしてもメニューの数は増えない
        expect{
          find("input[name='commit']").click
        }.to change{ Menu.count }.by(0)
        # エラーメッセージが表示される
        expect(page).to have_content "Name can't be blank"
        # 説明文に入力した内容はそのままになっている
        expect(page).to have_content "ダミーテキスト"
      end
    end
    context "一般ユーザーの場合" do
      it "一般ユーザーはメニュー作成画面のURLを入力してもトップページにリダイレクトされる" do
        # サインインする
        sign_in_support(@user2)
        # メニュー作成ページのurlをて入力する
        visit new_menu_path
        # トップページにリダイレクトされる
        expect(current_path).to eq root_path
      end
    end
    context "ログインしていないの場合" do
      it "ログインせずにメニュー作成画面のURLを入力してもトップページにリダイレクトされる" do
        # メニュー作成ページのurlをて入力する
        visit new_menu_path
        # トップページにリダイレクトされる
        expect(current_path).to eq root_path
      end
    end
  end

  describe "メニュー詳細の結合テスト" do
    before do
      @team = FactoryBot.create(:team)
      @user1 = FactoryBot.create(:user, team_id: @team.id)
      @user2 = FactoryBot.create(:user, team_id: @team.id, admin: false)
      @menu1 = FactoryBot.create(:menu, team_id: @team.id)
      @menu2 = FactoryBot.create(:menu, team_id: @team.id, text: "")

      # @menu1はtextあり、登録しているhiitあり
      # @menu2はtextなし、登録しているhiitなし

      @hiit = FactoryBot.create(:hiit, team_id: @team.id)
      8.times do
        MenuHiit.create(menu_id: @menu1.id, hiit_id: @hiit.id)
      end

      HiitDate.create(hiit_id: @hiit.id, date: 0)
      
    end
    context "権限ユーザー" do
      it "権限ユーザーであればチーム詳細ページからメニュー詳細に遷移できる。テキストやhiit登録がある場合はそれについても表示される" do
        # サインインする
        sign_in_support(@user1)
        # チーム詳細ページに遷移する
        visit team_path(@team)
        # メニュー名をクリックする
        click_link @menu1.name
        # メニュー詳細ページに遷移する
        expect(current_path).to eq menu_path(@menu1)
        # メニュー名が表示されている
        expect(page).to have_content @menu1.name
        # メニューアイコンが表示されている
        expect(page).to have_selector "img"
        # メニューのコメントが表示されている
        expect(page).to have_content @menu1.text
        # メニューが含まれるHIITが表示されている
        expect(page).to have_link @hiit.name
        # メニュー編集・削除・作成・トップページ・チームページへのリンクが表示されている
        expect(page).to have_link "メニューを編集する"
        expect(page).to have_link "メニューを削除する"
        expect(page).to have_link "メニューを作成する"
        expect(page).to have_link "自分のページに戻る"
        expect(page).to have_link "チームのページに戻る"
      end
      it "権限ユーザーであればチーム詳細ページからメニュー詳細に遷移できる。テキストやhiit登録がない場合はその旨が表示される" do
        # サインインする
        sign_in_support(@user1)
        # チーム詳細ページに遷移する
        visit team_path(@team)
        # メニュー名をクリックする
        click_link @menu2.name
        # メニュー詳細ページに遷移する
        expect(current_path).to eq menu_path(@menu2)
        # メニュー名が表示されている
        expect(page).to have_content @menu2.name
        # メニューアイコンが表示されている
        expect(page).to have_selector "img"
        # "説明文は特にありません"と表示されている
        expect(page).to have_content "説明文は特にありません"
        # "このメニューが含まれているHIITはありません"と表示されている
        expect(page).to have_content "このメニューが含まれているHIITはありません"
        # メニュー編集・削除・作成・トップページ・チームページへのリンクが表示されている
        expect(page).to have_link "メニューを編集する"
        expect(page).to have_link "メニューを削除する"
        expect(page).to have_link "メニューを作成する"
        expect(page).to have_link "自分のページに戻る"
        expect(page).to have_link "チームのページに戻る"
      end
    end
    context "一般ユーザー" do
      it "一般ユーザーであればチーム詳細ページからメニュー詳細に遷移できる" do
        # サインインする
        sign_in_support(@user2)
        # チーム詳細ページに遷移する
        visit team_path(@team)
        # メニュー名をクリックする
        click_link @menu1.name
        # メニュー詳細ページに遷移する
        expect(current_path).to eq menu_path(@menu1)
        # メニュー名が表示されている
        expect(page).to have_content @menu1.name
        # メニューアイコンが表示されている
        expect(page).to have_selector "img"
        # メニューのコメントが表示されている
        expect(page).to have_content @menu1.text
        # メニューが含まれるHIITが表示されている
        expect(page).to have_link @hiit.name
        # トップページ・チームページへのリンクが表示されている
        expect(page).to have_link "自分のページに戻る"
        expect(page).to have_link "チームのページに戻る"
        # メニュー編集・削除・作成へのリンクは表示されていない
        expect(page).to have_no_link "メニューを編集する"
        expect(page).to have_no_link "メニューを削除する"
        expect(page).to have_no_link "メニューを作成する"
      end
    end
    context "ログインしていない時" do
      it "ログインしていない場合はメニュー詳細に遷移できない" do
        visit menu_path(@menu1)
      end
    end
  end

  describe "メニュー編集の結合テスト" do
    before do
      @team = FactoryBot.create(:team)
      @user1 = FactoryBot.create(:user, team_id: @team.id)
      @user2 = FactoryBot.create(:user, team_id: @team.id, admin: false)
      @menu1 = FactoryBot.create(:menu, team_id: @team.id)
      @menu2 = FactoryBot.create(:menu, team_id: @team.id, text: "")

      # @menu1はtextあり、登録しているhiitあり
      # @menu2はtextなし、登録しているhiitなし

      @hiit = FactoryBot.create(:hiit, team_id: @team.id)
      8.times do
        MenuHiit.create(menu_id: @menu1.id, hiit_id: @hiit.id)
      end

      HiitDate.create(hiit_id: @hiit.id, date: 0)
      
    end

    context "権限ユーザーの場合" do
      it "権限ユーザーであればメニューを編集できる" do
        # サインインする
        sign_in_support(@user1)
        # メニュー詳細ページに遷移する
        visit menu_path(@menu1)
        # メニューを編集するをクリックする
        click_link "メニューを編集する"
        # メニュー編集ページに遷移する
        expect(current_path).to eq edit_menu_path(@menu1)
        # メニュー名が表示されている
        expect(page).to have_field("menu[name]", with: @menu1.name)
        # メニューアイコンが表示されている
        expect(page).to have_selector "img"
        # メニューの説明文が表示されている
        expect(page).to have_content @menu1.text
        # メニュー削除・メニューページ・メニュー作成へのリンクが表示されている
        expect(page).to have_link "メニューを削除する"
        expect(page).to have_link "新しいメニューを作成する"
        expect(page).to have_link "メニューのページに戻る"
        # メニュー名と説明文を変更する
        fill_in "menu_name", with: "テスト"
        fill_in "menu_text", with: "テスト文章"
        # メニューを編集するボタンを押してもMenu.countは変化しない
        expect{
          find("input[name='commit']").click
        }.to change{ Menu.count }.by(0)
        # メニュー詳細ページに遷移する
        expect(current_path).to eq menu_path(@menu1)
        # メニュー名とテキストが変更されている
        expect(page).to have_content "テスト"
        expect(page).to have_content "テスト文章"
      end
    end
    context "一般ユーザーの場合" do
      it "一般ユーザーであればメニューを編集ない" do
        # サインインする
        sign_in_support(@user2)
        # メニュー編集ページに遷移する
        visit edit_menu_path(@menu1)
        # トップページに遷移する
        expect(current_path).to eq root_path
      end
    end
    context "ログインしていないの場合" do
      it "ログインしていなければメニューを編集できない" do
        # メニュー編集ページに遷移する
        visit edit_menu_path(@menu1)
        # トップページに遷移する
        expect(current_path).to eq root_path
      end
    end
  end

  describe "メニュー削除の結合テスト" do
    before do
      @team = FactoryBot.create(:team)
      @user1 = FactoryBot.create(:user, team_id: @team.id)
      @menu1 = FactoryBot.create(:menu, team_id: @team.id)
      @menu2 = FactoryBot.create(:menu, team_id: @team.id, text: "")

      # @menu1はtextあり、登録しているhiitあり
      # @menu2はtextなし、登録しているhiitなし

      @hiit = FactoryBot.create(:hiit, team_id: @team.id)
      8.times do
        MenuHiit.create(menu_id: @menu1.id, hiit_id: @hiit.id)
      end

      HiitDate.create(hiit_id: @hiit.id, date: 0)
      
    end
    it "どのhiitにも登録されていないメニューであれば削除ができる" do
      # サインインする
      sign_in_support(@user1)
      # メニュー詳細ページに遷移する
      visit menu_path(@menu2)
      # メニューを削除するボタンを押すとメニューが削除される
      expect{
        click_link "メニューを削除する"
      }.to change{ Menu.count }.by(-1)
      # チーム詳細ページにリダイレクトされる
      expect(current_path).to eq team_path(@team)
      # 削除したメニューの名前が表示されていない
      expect(page).to have_no_link @menu2.name
    end
    it "hiitにも登録されているメニューであれば削除ができない" do
      # サインインする
      sign_in_support(@user1)
      # メニュー編集ページに遷移する
      visit edit_menu_path(@menu1)
      # メニューを削除するボタンを押してもとメニューが削除されない
      expect{
        click_link "メニューを削除する"
      }.to change{ Menu.count }.by(0)
      # エラーメッセージが表示される
      expect(page).to have_content "Since hiit using this menu exists, this menu can't be deleted."
      # チーム詳細ページに戻ると削除したメニューの名前が表示されている
      visit team_path(@team)
      expect(page).to have_link @menu1.name
    end
  end

end
