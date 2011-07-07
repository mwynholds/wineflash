class CreateFlashEmailsTable < ActiveRecord::Migration
  def up
    create_table :flash_emails do |t|
      t.column :message_id, :string
      t.column :source, :string
      t.column :subject, :string
      t.column :raw, :text
      t.column :raw_sha256, :string
      t.column :status, :string
      
      t.timestamps
    end
  end

  def down
    drop_table :flash_emails
  end
end
