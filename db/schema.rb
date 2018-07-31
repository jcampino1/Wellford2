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

ActiveRecord::Schema.define(version: 20180730173243) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "pumps", force: :cascade do |t|
    t.string "bomba"
    t.float "rpm"
    t.float "rodete_max"
    t.float "rodete_min"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "valid_tests", default: [], array: true
    t.string "curva_rodete_max", default: [], array: true
    t.string "curva_rodete_min", default: [], array: true
    t.string "x_maximos", default: [], array: true
    t.string "efficiency_info", default: [], array: true
    t.integer "succion"
    t.integer "descarga"
    t.integer "motor_hp"
    t.string "frame"
    t.string "base"
    t.string "machon_omega"
    t.string "machon_dentado"
    t.string "anillo_delantero"
    t.string "anillo_trasero"
    t.string "delantero_motor"
    t.string "trasero_motor"
    t.string "delantero_bomba"
    t.string "trasero_bomba"
    t.integer "caudal_minimo"
    t.integer "ancho_b1"
    t.integer "largo_l1"
    t.integer "hs"
    t.integer "hd"
    t.integer "peso_motobomba"
    t.integer "acople_machon"
    t.integer "acople_motor"
    t.string "efficiency_info_diams", default: [], array: true
    t.integer "a"
  end

  create_table "tests", force: :cascade do |t|
    t.float "diametro_rodete"
    t.integer "pump_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "curva_h", default: [], array: true
    t.string "curva_e", default: [], array: true
    t.string "curva_p", default: [], array: true
    t.string "current_h", default: [], array: true
    t.string "current_e", default: [], array: true
    t.string "current_p", default: [], array: true
    t.string "coefficients_h", default: [], array: true
    t.string "coefficients_e", default: [], array: true
    t.string "coefficients_p", default: [], array: true
    t.float "xmaximo"
  end

end
