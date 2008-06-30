class RankFuGenerator < Rails::Generator::NamedBase  
  
  attr_accessor :migration_name
    
  def manifest         
    @migration_name = "AddRolesTo#{class_name}"                
    record do |m|          
      m.migration_template 'roles_migration.rb',"db/migrate", :migration_file_name => "create_roles" if table_name == "roles"                                                                                                                           
      m.migration_template 'model_migration.rb',"db/migrate", :migration_file_name => @migration_name.underscore unless table_name == "roles"  
    end
  end 
  
end