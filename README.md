# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## teams テーブル

| Column | Type   | Options                   |
| ------ | ------ | ------------------------- |
| name   | string | null: false, unique: true |

### Associations

- has_many :users
- has_many :menus
- has_many :hiits
- has_many :groups

## users テーブル

| Column             | Type       | Options                        |
| ------------------ | ---------- | ------------------------------ |
| name               | string     | null: false                    |
| email              | string     | null: false, unique: true      |
| encrypted_password | string     | null: false                    |
| admin              | boolean    | null: false                    |
| team               | references | null: false, foreign_key: true |

### Associations

- belongs_to :team
- has_many :user_groups
- has_many :groups, through: :user_groups
- has_many :user-hiits

## menus テーブル

| Column             | Type       | Options                        |
| ------------------ | ---------- | ------------------------------ |
| name               | string     | null: false                    |
| text               | text       |
| team               | references | null: false, foreign_key: true |

### Associations

- belongs_to :team

## hiits テーブル

| Column             | Type       | Options                        |
| ------------------ | ---------- | ------------------------------ |
| name               | string     | null: false                    |
| active_time        | text       | null: false                    |
| rest_time          | text       | null: false                    |
| date               | datetime   | null: false                    |
| team               | references | null: false, foreign_key: true |

### Associations

- belongs_to :team
- has_many :groups
- has_many :user_hiits

## groups テーブル

| Column             | Type       | Options                        |
| ------------------ | ---------- | ------------------------------ |
| name               | string     | null: false                    |
| hiit               | references | null: false, foreign_key: true |
| team               | references | null: false, foreign_key: true |

### Associations

- belongs_to :team
- has_many :user_groups
- has_many :users, through: :user_groups
- belongs_to :hiits

## user_groupsテーブル

| Column             | Type       | Options                        |
| ------------------ | ---------- | ------------------------------ |
| user               | references | null: false, foreign_key: true |
| group              | references | null: false, foreign_key: true |

### Associations

- belongs_to :user
- belongs_to :groups

## user_hiitsテーブル

| Column             | Type       | Options                        |
| ------------------ | ---------- | ------------------------------ |
| done_dates         | datetime   | null: false                    |
| hiit               | references | null: false, foreign_key: true |
| user               | references | null: false, foreign_key: true |

### Associations

- belongs_to :user
- belongs_to :hiit