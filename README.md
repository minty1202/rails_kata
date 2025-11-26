# Rails Kata - Sorbet 型安全パターン集

## セットアップ

```bash
make init
```

このコマンドで以下が自動実行されます：

1. Docker イメージのビルド
2. Gem のインストール
3. データベースの作成・マイグレーション
4. Sorbet/Tapioca の初期化（RBI ファイル生成）
5. コンテナの起動

## よく使うコマンド

```bash
# 型チェック
make typecheck  # または make tc

# 型チェック（自動修正付き）
make typecheck-auto

# RBI ファイルの再生成
make tapioca-gems  # Gem用
make tapioca-dsl   # DSL用
make tapioca-all   # 全て

# コンテナ操作
make up            # コンテナ起動
make down          # コンテナ停止
make bash          # コンテナに入る
make logs          # ログ表示

# Rails コマンド
make console       # Rails コンソール
```

## パターン別の解説

### 1. NotesController - 標準 Rails パターン

**ファイル:** `app/controllers/notes_controller.rb`

```ruby
@note = Note.new(**note_params)
```

**特徴:**
- Rails の慣用的な書き方
- `**` でキーワード引数 splat を使用
- シンプルで書きやすい

**Sorbet との相性:**

- エラーが出る可能性がある
- `ActionController::Parameters` の型が曖昧
- Sorbet は splat の型推論が苦手

---

### 2. SafeCaseNotesController - 型安全な直接呼び出し

**ファイル:** `app/controllers/safe_case_notes_controller.rb`

```ruby
@note = Note.safe_new(
  title: note_params[:title],
  content: note_params[:content]
)
```

**特徴:**

- 明示的にキーワード引数を渡す
- カスタムメソッド `safe_new` で型定義
- パラメータを直接取り出して使用

**Sorbet との相性:**

- 型チェックが通る
- 型が明確で推論しやすい
- splat を使わないため安全

---

### 3. RepositoryPatternNotesController - リポジトリパターン

**ファイル:**

- `app/controllers/repository_pattern_notes_controller.rb`
- `app/repositories/application_repository.rb`
- `app/repositories/note_repository.rb`
- `app/params/note_params_object.rb`

```ruby
@note = repo.notes.create(
  title: note_params.title,
  content: note_params.content
)
```

**特徴:**

- データアクセス層を分離（Repository）
- API client 風の設計（`repo.notes.create`）
- パラメータオブジェクトで型安全に

**構造:**

```
Controller
  ↓
ApplicationRepository (リポジトリの統合管理)
  ↓
NoteRepository (Note のデータアクセス)
  ↓
Model
```

**Sorbet との相性:**

- 型定義が明確
- テストしやすい（モック化が容易）
- データアクセスロジックが一箇所に集約

---

### 4. ServiceNotesController - Service + Form パターン（レイヤード）

**ファイル:**

- `app/controllers/service_notes_controller.rb`
- `app/params/note_params_object.rb`
- `app/forms/note_form.rb`
- `app/services/create_note_service.rb`

```ruby
params_obj = NoteParamsObject.from_params(params)  # パラメータ抽出
form = NoteForm.from_params_object(params_obj)      # バリデーション
@note = CreateNoteService.call(form)                # ビジネスロジック
```

**特徴:**

- 責務を3層に分離
- Form で ActiveModel::Validations を使用
- Service Object でビジネスロジックをカプセル化

**構造:**

```
Controller
  ↓
NoteParamsObject (型安全なパラメータ抽出)
  ↓
NoteForm (バリデーション + 正規化) ← ActiveModel::Validations + T::Struct
  ↓
CreateNoteService (ビジネスロジック)
  ↓
Model
```

**Sorbet との相性:**
- 各層が型安全
- T::Struct と ActiveModel の組み合わせ
- 責務が明確で保守しやすい

---

## ディレクトリ構造

```
app/
├── controllers/
│   ├── notes_controller.rb                      # 1. 標準Rails
│   ├── safe_case_notes_controller.rb            # 2. 型安全な直接呼び出し
│   ├── repository_pattern_notes_controller.rb   # 3. リポジトリパターン
│   └── service_notes_controller.rb              # 4. Service + Form
├── models/
│   └── note.rb
├── params/
│   └── note_params_object.rb                    # パラメータオブジェクト
├── forms/
│   └── note_form.rb                             # Form Object
├── services/
│   └── create_note_service.rb                   # Service Object
└── repositories/
    ├── application_repository.rb                # リポジトリ統合管理
    └── note_repository.rb                       # Note リポジトリ
```

## 個人的な見解

Repository Pattern が一番バランスが取れていると思います。
Safe ケースは最も Rails らしく、シンプルですが、規模が大きくなるにつれて Model への依存が強くなりがちです。
Model への記述量も増えるため肥大化しやすいと感じます。
Service + Form パターンは責務が明確で保守性が高いですが、Service + Form パターンは本来複雑なビジネスロジックを扱う場合に有効であり、
単純な CRUD 操作には過剰設計になる可能性があります。
上記を踏まえると、リポジトリパターンは適度な抽象化と保守性を提供しつつ、過剰設計を避けるバランスの取れたアプローチと言えます。
複雑なビジネスロジックになる場合は、リポジトリパターンを踏襲しつつ、Service + Form パターンを組み合わせるのも良いでしょう。
Rails Way から若干外れますが、Sorbet の使用を前提とする以上何かしらの型安全なアクセサが必要になります。
そのため、個人的にはリポジトリパターンを基軸に据えるのが最も実用的と考えています。

