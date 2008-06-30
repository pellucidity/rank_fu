class <%= migration_name %> < ActiveRecord::Migration 
  def self.up
    change_table "<%= table_name %>" do |t|     
      t.integer :role  
    end 
  end

  def self.down         
    change_table "<%= table_name %>" do |t|     
      t.remove :role  
    end
  end
end
