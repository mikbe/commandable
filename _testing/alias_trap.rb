require 'pp'
hash1 = {
  :c=>{:foo=>"a c command", :description=>"c description"},
  :a=>{:foo=>"z a command", :description=>"c description"}, 
  :b=>{:foo=>" buh command", :description=>"c description"}
}


hash1.sort.each {|com| puts hash1[[0]]}
