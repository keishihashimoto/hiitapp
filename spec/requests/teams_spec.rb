require 'rails_helper'

RSpec.describe "Teams", type: :request do
  describe "teamコントローラの単体テスト" do
    context "ルートパスへの遷移" do
      it "ログインせずにルートパスに遷移した場合" do
        get root_path
        expect(response.status).to eq 200
        expect(response.body).to include("HiitApp")
        expect(response.body).to include("チームを登録する")
        expect(response.body).to include("ユーザーを登録する")
        expect(response.body).to include("ログインする")
      end
    end
  end
end
