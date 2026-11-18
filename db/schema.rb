# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_18_060012) do
  create_table "action_mailbox_inbound_emails", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.string "message_id", null: false
    t.string "message_checksum", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id", "message_checksum"], name: "index_action_mailbox_inbound_emails_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "canned_replies", force: :cascade do |t|
    t.string "title", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customers", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "name", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_customers_on_email_address", unique: true
  end

  create_table "inboxes", force: :cascade do |t|
    t.string "name", null: false
    t.string "email_address", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_inboxes_on_email_address", unique: true
  end

  create_table "messages", force: :cascade do |t|
    t.integer "ticket_id", null: false
    t.integer "user_id"
    t.text "body", null: false
    t.string "email_message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "internal", default: false, null: false
    t.index ["email_message_id"], name: "index_messages_on_email_message_id", unique: true
    t.index ["ticket_id"], name: "index_messages_on_ticket_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.integer "customer_id", null: false
    t.integer "assignee_id"
    t.string "subject", null: false
    t.string "status", default: "open", null: false
    t.string "portal_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "pending_since"
    t.integer "inbox_id", null: false
    t.index ["assignee_id"], name: "index_tickets_on_assignee_id"
    t.index ["customer_id"], name: "index_tickets_on_customer_id"
    t.index ["inbox_id"], name: "index_tickets_on_inbox_id"
    t.index ["pending_since"], name: "index_tickets_on_pending_since"
    t.index ["portal_token"], name: "index_tickets_on_portal_token", unique: true
    t.index ["status"], name: "index_tickets_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.string "name", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deactivated_at"
    t.boolean "admin", default: false, null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "messages", "tickets"
  add_foreign_key "messages", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "tickets", "customers"
  add_foreign_key "tickets", "inboxes"
  add_foreign_key "tickets", "users", column: "assignee_id"

  # Virtual tables defined in this database.
  # Note that virtual tables may not work with other database engines. Be careful if changing database.
  create_virtual_table "ticket_search", "fts5", ["subject", "body", "customer", "tokenize='unicode61 remove_diacritics 2'"]
end
