require 'pp'
# hash1 = {
#   :c=>{:foo=>"a c command", :description=>"c description"},
#   :a=>{:foo=>"z a command", :description=>"c description"}, 
#   :b=>{:foo=>" buh command", :description=>"c description"}
# }

hash1 = [
  {:foo=>"a c command", :description=>"c description"},
  {:foo=>"z a command", :description=>"c description"}, 
  {:foo=>" buh command", :description=>"c description"}
]

puts hash1.shift[:foo]
