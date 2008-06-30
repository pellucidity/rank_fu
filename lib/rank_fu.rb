module RankFu
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods     
    def knows_rank_fu     
      Role.find(:first) rescue return    #HACK!
         
      instance_eval do   
        include InstanceMethods
      end     
                                                                                                          
      Role.find(:all).map(&:key).each do |role|
        class_eval do
          define_method "find_#{role.pluralize}" do; Role.find(:all) end
        end          
        instance_eval do
          define_method "#{role}?" do;          self.has_role?(role) end 
          define_method "#{role}_exactly?" do;  self.has_role_without_set?(role) end 
          define_method "make_#{role}" do;     self.has_role(role) end          
          define_method "remove_#{role}" do;   self.does_not_have_role(role) end
        end          
      end  
      
      if Role.find_by_key(:disabled)
        instance_eval do    
          define_method 'disable_user' do;  has_role(:disabled) end 
          define_method 'enable_user' do;   does_not_have_role(:disabled) end 
          define_method 'enabled?' do;      !has_role?(:disabled) end
        end
      end
      
    end     
  end  
  
  module InstanceMethods
    def has_role?(role)                                               
      role = ensure_role(role)
      if role.set? 
        has_role_with_set?(role)
      else
        has_role_without_set?(role) 
      end
    end   

    def has_role(role)
      role = ensure_role(role)       
      role.set_mates.each{|set_mate| self.does_not_have_role set_mate} if role.set?  
      self.update_attribute(:role, (self.role || 0 ) | role.value);self
    end    

    def ensure_role(role_key_or_name)
     role_key_or_name.class == Role ? role_key_or_name : Role.find_by_key_or_name(role_key_or_name) end

    def does_not_have_role(role) 
      self.update_attribute(:role, self.role ^ (self.role & ensure_role(role).value)); self end 

    def roles
      Role.find(:all).select{|role| (self.role & role.value) > 0}.map(&:key) rescue [] end 

    def modifiers 
      Role.find(:all, :conditions => {:is_modifier => true}).select{|role| (self.role & role.value) > 0}.sort end

    def major_roles
      major_roles = Role.find(:all, :conditions => ["is_modifier is not true"]).select{|role| (self.role & role.value) > 0}.sort
      major_roles = major_roles - Role.default_roles if (major_roles - Role.default_roles).any? 
      major_roles
    end 

    def rank
     (modifiers.map{|role|role.name}.join(" ") + " " + major_roles.map{|role|role.name}.join(" / ")).strip; end   

    def has_role_without_set?(role)  
      self_role = (self.role ? self.role : Role.type(:member))      
      self_role & ensure_role(role).value > 0 
    end  

    def has_role_with_set?(role)     
      self_role = (self.role ? self.role : Role.type(:member))
      role = ensure_role(role)          
      self_role & role.set_mates.map{|r|r.value if r.value >= role.value}.compact.sum > 0            
    end
  end 
  
end 



# if method.to_s.match(/^(.*)\?$/) && Role.role_exists?($1)          
#   self.has_role?($1.to_sym)  
# elsif method.to_s.match(/^(.*)_exactly\?$/) && Role.role_exists?($1)          
#   self.has_role_without_set?($1.to_sym)                 
# elsif method.to_s.match(/^make_(.*)$/) && Role.role_exists?($1)          
#   self.has_role($1.to_sym)  
# elsif method.to_s.match(/^remove_(.*)$/) && Role.role_exists?($1)          
#   self.does_not_have_role($1.to_sym)                  
# else
#   method_missing_without_roles(method,*args)
# end             

# def disable_user                 
#   has_role(:disabled) end
# 
# def enable_user                                                
#   does_not_have_role(:disabled)  end 
# alias :make_enabled :enable_user
# 
# def disabled?
#   has_role?(:disabled) end
#   
# def enabled?                           
#   !has_role?(:disabled) end  

