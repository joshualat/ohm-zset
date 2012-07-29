# ohm-zset

Ohm Sorted Set (ZSET) support for Redis.

## Basic Usage

```ruby
class Big < Ohm::Model
  collection :smalls, :Small
  zset :zsmalls, :Small, :size
end

class Small < Ohm::Model
  attribute :name 
  attribute :size
end

b = Big.create
b.zsmalls.add(Small.create(name:'S1', size:5))
b.zsmalls.add(Small.create(name:'S2', size:4))
b.zsmalls.add(Small.create(name:'S3', size:3))
b.zsmalls.add(Small.create(name:'S4', size:2))
b.zsmalls.add(Small.create(name:'S5', size:1))

b.zsmalls.size
# => 5

b.zsmalls.to_a.map(&:name)
# => ["S5", "S4", "S3", "S2", "S1"]

b.zsmalls.to_a.map(&:size)
# => ["1", "2", "3", "4", "5"]
```

## Interacting with the elements of the set
**Ohm-ZSET** includes *get*, *rank*, *revrank*, *score*, *range*, *revrange*, *rangebyscore*, *revrangebyscore*

```ruby

b.zsmalls.get(0).name
# => "S5"

b.zsmalls.range(0, 3).to_a.map(&:name)
# => ["S5", "S4", "S3", "S2"]

b.zsmalls.revrange(0, 3).each do |small|
  puts "#{small.name} - #{small.size}"
end
# => S1 - 5
# => S2 - 4
# => S3 - 3
# => S4 - 2

s6 = Small.create(name:"S6", size:3.5)
b.zsmalls.add(s6)
b.zsmalls.to_a.map(&:name)
# => ["S5", "S4", "S3", "S6", "S2", "S1"]
```

## Deleting Elements
**Ohm-ZSET** includes *delete* for deleting a single element, *clear* for deleting all elements, and *remrangebyrank* and *remrangebyscore* for deleting selected elements.

```ruby
b.zsmalls.delete(s6)
b.zsmalls.to_a.map(&:name)
# => ["S5", "S4", "S3", "S2", "S1"]

b.zsmalls.include? s6
# => false

b.zsmalls.clear
b.zsmalls.to_a.map(&:name)
# => []
```
