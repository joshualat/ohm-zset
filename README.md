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
s1 = Small.create(name: 'S1', size: 5)
s2 = Small.create(name: 'S2', size: 4)
s3 = Small.create(name: 'S3', size: 3)
s4 = Small.create(name: 'S4', size: 2)
s5 = Small.create(name: 'S5', size: 1)

b.zsmalls.add_list(s1, s2, s3, s4, s5)

b.zsmalls.size
# => 5

b.zsmalls.to_a.map(&:name)
# => ['S5', 'S4', 'S3', 'S2', 'S1']

b.zsmalls.to_a.map(&:size)
# => ['1', '2', '3', '4', '5']
```

## Interacting with the elements of the set
**Ohm-ZSET** includes *get*, *rank*, *revrank*, *score*, *range*, *revrange*, *rangebyscore*, *revrangebyscore*

```ruby

b.zsmalls.get(0).name
# => 'S5'

b.zsmalls.range(0, 3).to_a.map(&:name)
# => ['S5', 'S4', 'S3', 'S2']

b.zsmalls.revrange(0, 3).each do |small|
  puts "#{small.name} - #{small.size}"
end
# => S1 - 5
# => S2 - 4
# => S3 - 3
# => S4 - 2

s6 = Small.create(name:'S6', size:3.5)
b.zsmalls.add(s6)
b.zsmalls.to_a.map(&:name)
# => ['S5', 'S4', 'S3', 'S6', 'S2', 'S1']
```

You can also add an element with a custom score.

```ruby
class Big < Ohm::Model
  include Ohm::ZScores
  
  zset :zcustom, :Bool, nil, ZScore::DateTime
end

class Bool < Ohm::Model
  attribute :name
  attribute :is_valid
end

b = Big.create
b1 = Bool.create(name: 'B1', is_valid: "false")
b2 = Bool.create(name: 'B2', is_valid: "true")
b3 = Bool.create(name: 'B3', is_valid: "false")
b4 = Bool.create(name: 'B4', is_valid: "true")

b.zcustom.add(b1, "2012-07-29 06:24:20 +0800")
b.zcustom.add(b2, "2012-07-25 06:24:20 +0800")
b.zcustom.add(b3, "2012-07-30 06:24:20 +0800")
b.zcustom.add(b4, "2012-07-27 06:24:20 +0800")

b.zcustom.to_a.map(&:name)
# => ['B2', 'B4', 'B1', 'B3']
```

You can update the score of an element by using *update*. There is also a *count* function that returns the number of elements with scores inside a specified range.

## Deleting Elements
**Ohm-ZSET** includes *delete* for deleting a single element, *clear* for deleting all elements, and *remrangebyrank* and *remrangebyscore* for deleting selected elements.

```ruby
b.zsmalls.delete(s6)
b.zsmalls.to_a.map(&:name)
# => ['S5', 'S4', 'S3', 'S2', 'S1']

b.zsmalls.include? s6
# => false

b.zsmalls.clear
b.zsmalls.to_a.map(&:name)
# => []
```

It also has *destroy!* to delete the key of the sorted set.

## Set Intersection and Union
Set intersection between sorted sets and sets are allowed. You can use *intersect*, *intersect_multiple*, *union*, and *union_multiple* between sets and sorted sets.

```ruby
b.smalls.add(s1)
b.smalls.add(s2)
b.smalls.add(s4)

# Intersect ['S5', 'S4', 'S3', 'S2', 'S1'] with ['S4', 'S2', 'S1']
b.zsmalls.intersect(b.smalls).to_a.map(&:name)
# => ['S4', 'S2', 'S1']
```

The sorted set allows union and intersection of multiple sets and sorted sets with weights.
Result of intersection and union is another ZSET.

It also allows intersection and union to a new set with the specified name.

```ruby
zunion = Ohm::ZSet.union_multiple('zunion', [zlittles, slittles, zlittles2, zlittles3])

zunion.key
# => 'zunion'
```

## Scoring Functions
**Ohm-ZSET** also supports custom scoring functions. The default scoring function is ZScore::Integer.
There are also available built-in scoring functions in the module.

```ruby
class Bigger < Ohm::Model
  include Ohm::ZScores

  zset :zlittles, :Little, :score

  # Custom scoring function
  zset :zsmalls, :Small, :value, lambda{ |x| Integer(x) + 1 }

  # Built-in scoring functions
  zset :zlittles, :Little, :score, ZScore::Float
  zset :zbools, :Bool, :is_valid, ZScore::Boolean
  zset :zdts, :DT, :last_login, ZScore::DateTime

  # Built-in string sorting functions
  zset :zbools2, :Bool, :name, ZScore::String
  zset :zbools3, :Bool, :name, ZScore::StringInsensitive
  zset :zbools4, :Bool, :name, ZScore::StringInsensitiveHigh
end

class Bool < Ohm::Model
  attribute :name
  attribute :is_valid
end

class DT < Ohm::Model
  attribute :name
  attribute :last_login
end

class Small < Ohm::Model
  attribute :name 
  attribute :value
end

class Little < Ohm::Model
  attribute :name
  attribute :score
end

```

Redis allows only numerical scores so DateTime and strings objects are first converted to numbers and then stored as scores.

**Note**: The string scoring algorithm is limited only to the first 9 characters because of the floating point accuracy limit.
You can use the *starts_with* function when dealing with string sorted sets. It returns all the elements of the set with a score field value that starts with the specified string.

## Saving and Loading ZSet instances by name / key

```ruby

sorted_set = b.zlittles
sorted_set.save_set

sorted_set_2 = Ohm::ZSet.load_set(sorted_set.key)
sorted_set_2.add(Little.create(name: 'X1',score: 29))

# sorted_set and sorted_set_2 are pointing to same ZSet instance
```

## Updating gem
```

gem build ohm-zset.gemspec
gem push ohm-zset-0.X.gem
```

## Copyright
Copyright (c) 2012 [Joshua Arvin Lat](http://www.joshualat.com). See LICENSE for more details.
