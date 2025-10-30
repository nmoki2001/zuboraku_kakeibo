### ER図
[![Image from Gyazo](https://i.gyazo.com/cc7b7a782d8387c92caf623ebe6fb289.png)](https://gyazo.com/cc7b7a782d8387c92caf623ebe6fb289)

アプリで使用する全テーブル・カラム・リレーションを整理しました。  
MVP段階では、以下の4つのテーブルで構成しています。  
- **CATEGORIES**：支出・収入の分類（例：食費、給与）  
- **ENTRIES**：家計簿の明細（ユーザーが入力する内容）  
- **AI_CLASSIFICATIONS**：AIまたはルールによる項目分類の履歴  
- **ANALYSIS**：AIによる全体分析結果（良い点・改善点）
 
---

### 本サービスの概要（700文字以内）
本サービスは、「最小限の入力で家計を自動整理・分析できる家計簿アプリ」です。  
従来の家計簿アプリは入力項目が多く、継続的に記録するのが難しいという課題がありました。  
本アプリでは「日付」「内容」「金額」のみを入力すれば、AIが自動で支出・収入の項目を分類し、定期的に全体の傾向を分析して「良い点」「改善点」を提示します。  
これにより、ユーザーは煩雑な入力作業から解放され、自然に家計の改善ポイントを把握できます。  
想定ユーザーは「家計簿アプリは難しい」「続けられない」と感じる社会人・学生などのライトユーザーです。  
主な機能は、①支出・収入の入力、②生成AIによる自動分類、③AIによる分析レポート出力の3点です。  
MVP段階では、AI分類と分析を中心とした最低限の流れを実装し、将来的に「月次分析」「グラフ表示」などへ拡張できる構成としています。

---

### MVPで実装する予定の機能
- 「日付」＋「内容」＋「金額」の入力フォーム  
- AIによる支出・収入項目の自動分類  
- AIによる家計分析（良い点・改善点の自動生成）  
- 1日3回までの分析実行制限  
- 分析結果（良い点・改善点）の履歴保存  

---

### テーブル詳細

#### CATEGORIESテーブル
- id : 主キー（bigint）
- name : 項目名（例：食費、給与）（string）
- kind : 支出・収入の区別（enum: expense / income）
- created_at / updated_at : 登録・更新日時（datetime）

---

#### ENTRIESテーブル
- id : 主キー（bigint）
- occurred_on : 日付（date）
- description : 内容（例：ランチ、給料）（string）
- amount : 金額（正の整数）（int）
- direction : 収入または支出（enum: income / expense）
- category_id : CATEGORIES.id（AI確定前はNULL）（bigint, FK）
- created_at / updated_at : 登録・更新日時（datetime）

---

#### AI_CLASSIFICATIONSテーブル
- id : 主キー（bigint）
- entry_id : 対象となる明細（bigint, FK）
- method : 分類方法（ルール or AI）（enum: rule / ai）
- predicted_category_id : 推定されたカテゴリID（bigint, FK）
- created_at : 推定日時（datetime）

---

#### ANALYSISテーブル
- id : 主キー（bigint）
- good_points : AIが生成した「良い点」（text）
- improvements : AIが生成した「改善点」（text）
- created_at : 分析実行日時（1日3回制限のカウントにも使用）（datetime）

---

### ER図の注意点チェック
- [x] プルリクエストに最新のER図のスクリーンショットを画像が表示される形で掲載できているか？  
- [x] テーブル名は複数形になっているか？  
- [x] カラムの型は記載されているか？  
- [x] 外部キーは適切に設けられているか？  
- [x] リレーションは適切に描かれているか？多対多の関係は存在しないか？  
- [x] STIは使用していないか？  
- [x] Postsテーブルにpost_nameのように"テーブル名+カラム名"を付けていないか？  
