class RoleAdderGenerator < Rails::Generator::NamedBase  
  
  attr_accessor :migration_name
    
  def manifest 
    @migration_name = "AddRolesTo#{class_name}"   
    
    record do |m|               
      m.migration_template 'lib/roles_migration.rb',"db/migrate", :migration_file_name => "create_roles"
      m.migration_template 'lib/model_migration.rb',"db/migrate", :migration_file_name => @migration_name.underscore   
    end
  end 
  
end