# ohm-zset

Ohm Sorted Set (ZSET) support for Redis.

## Basic Usage

```ruby
class Big < Ohm::Model
  set :smalls, :Small
  zset :zsmalls, :Small, :size
end

class Small < Ohm::Model
  attribute :name 
  attribute :size
end

b = Big.create
s1 = Small.create(name:'S1', size:5)
s2 = Small.create(name:'S2', size:4)
s3 = Small.create(name:'S3', size:3)
s4 = Small.create(name:'S4', size:2)
s5 = Small.create(name:'S5', size:1)

b.zsmalls.add_list(s1, s2, s3, s4, s5)

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

You can update the score of an element by using *update*.

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

It also has *destroy!* to delete the key of the sorted set.

## Set Intersection and Union
Set intersection between sorted sets and sets are allowed.

```ruby
b.smalls.add(s1)
b.smalls.add(s2)
b.smalls.add(s4)

# Intersect ["S5", "S4", "S3", "S2", "S1"] with ["S4", "S2", "S1"]
b.zsmalls.intersect(b.smalls).to_a.map(&:name)
# => ["S4", "S2", "S1"]
```

**Ohm-ZSET** allows union and intersection of multiple sets and sorted sets with weights.
Result of intersection and union is another ZSET.
