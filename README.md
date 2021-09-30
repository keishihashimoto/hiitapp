## アプリ名
HiitApp
## アプリケーション概要
HiitAppのHIITとはトレーニング方法の一種であり、トレーニングと休憩を数十秒ごとに交互に繰り返すやり方のことを言います。  
例）腕立て伏せ20秒→休憩10秒→スクワット20秒→腕立て伏せ20秒→休憩10秒→スクワット20秒  
このアプリは、スポーツチームがチームでHIITに取り組むこと上で、指導者の方の管理をサポートする目的で作成しました。　　
もちろん、個人でもご利用いただけます。

#### このアプリでは、以下のことが可能です。
・さまざまな種目を組み合わせてHIITのメニューを作成できます。  
・HIITに実施予定日を設定することで、スケジュール管理が可能です。  
・アプリのタイマー機能を用いて時間を図ることが可能です。  
・実施したHIITはアプリ内で記録することが可能です。  

## アプリURL
https://hiitapp.herokuapp.com/

## テスト用アカウント
email: test@test, password: 0000000a

## 制作意図
このアプリの目的は、スポーツチームでHIITに取り組む上で、管理を効率化することです。

アプリケーション概要の項目で触れたHIITというトレーニング手法は、近年普及しつつあり専用のアプリもいくつかリリースされています。　　
しかし、私が個人的に利用したところ、いくつかの問題点がありました。　　
・複数のメニューを登録できない  
 HIITは複数のメニューを用意し日替わりでローテーションすることも多い（例えば1日目は腕立て伏せと腹筋で2日目はスクワットと背筋、など）ですが、既存のアプリでは複数の種目を登録できないことがほとんどです。<br>
 このため、前回とことなるメニューを行う場合には、一回一回メニューを登録し直さなくてはなりませんでした。<br>
・HIITの実施有無の記録に関する機能が不十分<br>
 上記の例に関連してですが、HIITを実施したかどうかを記録する機能に関しても不十分でした。<br>
 既存のアプリでは、その日にHIITを行ったかどうかは記録できても、どのような種目を行ったかを記録できません。<br>
 そのため、前回何をやったかを覚えておかないとその日にどのメニューを行えばよいかがよいかがよいかが分からなくなってしまうという問題がありました。<br>
・チーム単位での管理に対応していない<br>
 既存のHIIT関連のアプリのほとんどは個人用です。<br>
 そのため、誰がどんなメニューに取り組んでいるか、各個人がきちんとメニューをこなせているかどうかをチーム単位で管理することができませんでした。<br>
 しかし、本アプリでは権限ユーザーならチーム内の全選手の情報を確認することが可能です。<br>
 チームの指導者の方が選手のトレーニング状況を一括管理することが簡単になります。
 
 ## DEMO
 
 ### HIITの作成
 [![Image from Gyazo](https://i.gyazo.com/72b525ffc43cc4d1ab6035f6c794a99f.gif)](https://gyazo.com/72b525ffc43cc4d1ab6035f6c794a99f)
 ### グループの作成
 [![Image from Gyazo](https://i.gyazo.com/074214c51d138f521b37bbd5746bfd96.gif)](https://gyazo.com/074214c51d138f521b37bbd5746bfd96)
 ### HIIT実施状況の確認
 [![Image from Gyazo](https://i.gyazo.com/880d4bf4e7786e963ca23519674dfbf6.gif)](https://gyazo.com/880d4bf4e7786e963ca23519674dfbf6)
 ### タイマー機能
 [![Image from Gyazo](https://i.gyazo.com/f297107d08a955b613ed831061633daa.gif)](https://gyazo.com/f297107d08a955b613ed831061633daa)
 ### HIIT実施記録の更新
[![Image from Gyazo](https://i.gyazo.com/b3c8fb5a31e63fa5ee44a97571f3a812.gif)](https://gyazo.com/b3c8fb5a31e63fa5ee44a97571f3a812)
## テーブル設計

### teams テーブル

| Column | Type   | Options                   |
| ------ | ------ | ------------------------- |
| name   | string | null: false, unique: true |

#### Associations

- has_many :users
- has_many :menus
- has_many :hiits
- has_many :groups

### users テーブル

| Column             | Type       | Options                        |
| ------------------ | ---------- | ------------------------------ |
| name               | string     | null: false                    |
| email              | string     | null: false, unique: true      |
| encrypted_password | string     | null: false                    |
| admin              | boolean    | null: false                    |
| team               | references | null: false, foreign_key: true |

#### Associations

- belongs_to :team
- has_many :user_groups
- has_many :groups, through: :user_groups
- has_many :user-hiits

### menus テーブル

| Column             | Type       | Options                        |
| ------------------ | ---------- | ------------------------------ |
| name               | string     | null: false                    |
| text               | text       |
| team               | references | null: false, foreign_key: true |

#### Associations

- belongs_to :team
- has_many :menu_hiits
- has_many :hiits, through: :menu_hiits

### hiits テーブル

| Column             | Type       | Options                        |
| ------------------ | ---------- | ------------------------------ |
| name               | string     | null: false                    |
| active_time        | string     | null: false                    |
| rest_time          | string     | null: false                    |
| date               | integer    | null: false                    |
| menus          | references | null: false, foreign_key: true | 
| team               | references | null: false, foreign_key: true |

#### Associations

- belongs_to :team
- has_many :groups
- has_many :user_hiits
- has_many :menu_hiits
- has_many :menus, through: :menu_hiits
- has_many :hiit_dates

### groups テーブル

| Column             | Type       | Options                        |
| ------------------ | ---------- | ------------------------------ |
| name               | string     | null: false                    |
| hiit               | references | null: false, foreign_key: true |
| team               | references | null: false, foreign_key: true |

#### Associations

- belongs_to :team
- has_many :user_groups
- has_many :users, through: :user_groups
- belongs_to :hiits

### user_groupsテーブル

| Column             | Type       | Options                        |
| ------------------ | ---------- | ------------------------------ |
| user               | references | null: false, foreign_key: true |
| group              | references | null: false, foreign_key: true |

#### Associations

- belongs_to :user
- belongs_to :groups

### user_hiitsテーブル

| Column             | Type       | Options                        |
| ------------------ | ---------- | ------------------------------ |
| done_dates         | datetime   | null: false                    |
| hiit               | references | null: false, foreign_key: true |
| user               | references | null: false, foreign_key: true |

#### Associations

- belongs_to :user
- belongs_to :hiit

### menu_hiitsテーブル

| Column             | Type       | Options                        |
| ------------------ | ---------- | ------------------------------ |
| menu               | references | null: false, foreign_key: true |
| user               | references | null: false, foreign_key: true |

#### Associations

- belongs_to :menu
- belongs_to :hiit

### hiit_datesテーブル

| Column             | Type       | Options                        |
| ------------------ | ---------- | ------------------------------ |
| hiit               | references | null: false, foreign_key: true |
| date               | integer    | null: false                    |

#### Associations

- belongs_to :menu
- belongs_to :hiit
