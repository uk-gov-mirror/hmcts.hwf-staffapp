class CreateDwpChecks < ActiveRecord::Migration
  def change
    create_table :dwp_checks do |t|
      t.string :last_name
      t.date :dob
      t.string :ni_number
      t.date :date_to_check
      t.string :checked_by
      t.string :laa_code
      t.string :unique_number
      t.timestamps null: false
    end
  end
end
