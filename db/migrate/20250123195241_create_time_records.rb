class CreateTimeRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :time_records do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date
      t.datetime :clock_in
      t.datetime :clock_out
      t.text :notes

      t.timestamps
    end
  end
end
