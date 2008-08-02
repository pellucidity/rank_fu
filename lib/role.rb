class Role < ActiveRecord::Base
  validates_presence_of :key, :value

  def self.types(this_key=nil)
    return self.type(this_key) if this_key
    return_hash = {}
    self.find(:all, :order => "value desc").map {|x| return_hash[x.key.to_sym] = x.value }
    return_hash
  end
  
  def self.type(this_key)
    s = self.find_by_key_or_name(this_key); s ? s.value : nil end      
    
  def set_mates
    Role.roles_in_set(self.set) end 

  def self.find_by_key_or_name(key_or_name)
    if key_or_name.class == Symbol or key_or_name =~ /^[_a-z]*$/
      self.find_by_key(key_or_name.to_s)
    else        
      self.find_by_name(key_or_name)
    end  
  end
  class << self
  alias_method :[], :type
  end

  def self.roles_in_set(set)
    Role.find_all_by_set(set) end              

  def self.role_exists?(key_or_name)
    find_by_key_or_name(key_or_name) != nil  end  

  def self.default_roles
    find_all_by_is_default(true) end  
  
  def self.user_count_for(this_key)
    Role.find_by_key(this_key).user_count end
  
  def self.controllers(this_key)
    Role.find_by_key(this_key).controllers end
  
  def self.controller_count(this_key)
    Role.find_by_key(this_key).controller_count end
  
  def controllers
    ControllerPermission.find(:all, :conditions => ["minimum_permitted_role_value >= ?", self.value]) end
  
  def controller_count
    ControllerPermission.count(:all, :conditions => ["minimum_permitted_role_value >= ?", self.value]) end
  
  def user_count
    User.count(:all, :conditions => ["role & ?", self.value]) end         

  def <=> (other)
    self.value >= other.value ? self : other  end
    
  [:>=, :<= , :<, :>, :==].each do |operator|
    delegate operator, :to => :value
  end
end