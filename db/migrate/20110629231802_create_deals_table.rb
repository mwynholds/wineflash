class CreateDealsTable < ActiveRecord::Migration
  def up
    create_table :deals do |t|
      t.column :flash_email_id, :int
      t.column :wine, :string
      t.column :varietal, :string
      t.column :vintage, :string
      t.column :price, :double
      t.column :country, :string
      t.column :size, :int

      t.timestamps
    end
  end

  def down
    drop_table :deals
  end
end
