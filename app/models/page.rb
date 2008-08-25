class Page < ActiveRecord::Base
  named_scope :with_name, lambda{|name| {:conditions => {:name => name}}}
  
  def self.named(name)
    with_name(name).first
  end
end
