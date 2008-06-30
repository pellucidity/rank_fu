class CreateRoles < ActiveRecord::Migration
  def self.up  
    create_table "roles", :force => true do |t|
      t.string   "key",                       :null => false
      t.string   "name"
      t.integer  "value",       :limit => 11, :null => false    
      t.integer  "set",         :limit => 11    
      t.boolean  "is_modifier"                 
      t.boolean  "is_default" 
      t.timestamps
    end    
    
    add_index :roles, :key, :unique => true
  end

  def self.down  
    drop_table "roles"
  end             
  
end