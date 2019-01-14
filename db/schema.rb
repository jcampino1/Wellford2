# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190114131522) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "intersections", force: :cascade do |t|
    t.integer "pump_id"
    t.integer "motor_id"
    t.string "base"
    t.integer "ancho_b1"
    t.integer "largo_l1"
    t.integer "hs"
    t.integer "hd"
    t.integer "a"
    t.integer "peso"
  end

  create_table "motors", force: :cascade do |t|
    t.float "rpm"
    t.float "kw"
    t.integer "hp"
    t.string "frame"
    t.string "machon_omega"
    t.string "machon_dentado"
    t.string "rod_delantero"
    t.string "rod_trasero"
  end

  create_table "pumps", force: :cascade do |t|
    t.string "bomba"
    t.float "rpm"
    t.string "valid_tests", default: [], array: true
    t.string "curva_rodete_max", default: [], array: true
    t.string "curva_rodete_min", default: [], array: true
    t.string "x_maximos", default: [], array: true
    t.string "efficiency_info_diams", default: [], array: true
    t.string "points_max", default: [], array: true
    t.string "points_min", default: [], array: true
    t.string "posibles_hp", default: [], array: true
    t.string "posibles_kw", default: [], array: true
    t.string "posibles_motores", default: [], array: true
    t.integer "succion"
    t.integer "descarga"
    t.float "rodete_max"
    t.float "rodete_min"
    t.string "anillo_delantero"
    t.string "anillo_trasero"
    t.string "bomba_delantero"
    t.string "bomba_trasero"
    t.integer "caudal_minimo_2900"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "caudal_minimo_1450"
    t.string "efficiency_info", default: [], array: true
    t.float "caudal_minimo_eficiencia"
  end

  create_table "requests", force: :cascade do |t|
    t.integer "user_id"
    t.string "state", default: "Pendiente"
  end

  create_table "tests", force: :cascade do |t|
    t.string "nombre"
    t.float "numero_pedido"
    t.float "diametro_rodete"
    t.integer "pump_id"
    t.string "curva_h", default: [], array: true
    t.string "curva_e", default: [], array: true
    t.string "current_h", default: [], array: true
    t.string "current_e", default: [], array: true
    t.string "coefficients_h", default: [], array: true
    t.string "coefficients_e", default: [], array: true
    t.string "xmaximos", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.boolean "aceptado", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
