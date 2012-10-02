require_relative "../helper"

class Big < Ohm::Model
  include Ohm::ZScores
  
  collection :smalls, :Small
  zset :zlittles, :Little, :score, ZScore::Float
  zset :zsmalls, :Small, :value
  zset :zlittles2, :Little, :score
  zset :zlittles3, :Little, :score
  zset :zbools, :Bool, :is_valid, ZScore::Boolean
  set :slittles, :Little
  zset :zdts, :DT, :last_login, ZScore::DateTime
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
  #attribute :date_updated
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

def add_to_zset(model, zset_name, items, item_class)
  z = model.send(zset_name)

  items.each do |i|
    z.send(:add, item_class.create(i))
  end
end

def setup_big_1
  b = Big.create

  l1 = Little.create(name: 'L1', score: 1)
  l2 = Little.create(name: 'L2', score: 2)
  l3 = Little.create(name: 'L3', score: 3)
  l4 = Little.create(name: 'L4', score: 4)

  Big.zlittles.clear
  Big.zlittles.add(l1)
  Big.zlittles.add(l2)
  Big.zlittles.add(l3)
  Big.zlittles.add(l4)

  b.slittles.add(l1)
  b.slittles.add(l2)
  b.slittles.add(Little.create(name: 'E3', score: 24))
  b.slittles.add(l4)

  Big.zlittles2.clear
  Big.zlittles2.add(l2)
  Big.zlittles2.add(l3)
  Big.zlittles2.add(l4)

  Big.zlittles3.clear
  Big.zlittles3.add(l1)
  Big.zlittles3.add(l4)
  Big.zlittles3.add(Little.create(name: 'E1', score: 21))
  Big.zlittles3.add(Little.create(name: 'E2', score: 22))

  Big.zsmalls.clear
  Big.zsmalls.add(Small.create(name: 'S1', value: 8))
  Big.zsmalls.add(Small.create(name: 'S2', value: 7))
  Big.zsmalls.add(Small.create(name: 'S3', value: 6))
  Big.zsmalls.add(Small.create(name: 'S4', value: 5))

  b
end

def setup_1
  b = Big.create

  l1 = Little.create(name: 'L1', score: 1)
  l2 = Little.create(name: 'L2', score: 2)
  l3 = Little.create(name: 'L3', score: 3)
  l4 = Little.create(name: 'L4', score: 4)

  b.slittles.add(l1)
  b.slittles.add(l2)
  b.slittles.add(Little.create(name: 'E3',score: 24))
  b.slittles.add(l4)

  b.zlittles.add(l1)
  b.zlittles.add(l2)
  b.zlittles.add(l3)
  b.zlittles.add(l4)

  b.zlittles2.add(l2)
  b.zlittles2.add(l3)
  b.zlittles2.add(l4)

  b.zlittles3.add(l1)
  b.zlittles3.add(l4)
  b.zlittles3.add(Little.create(name: 'E1', score: 21))
  b.zlittles3.add(Little.create(name: 'E2', score: 22))

  b.zsmalls.add(Small.create(name: 'S1', value: 8))
  b.zsmalls.add(Small.create(name: 'S2', value: 7))
  b.zsmalls.add(Small.create(name: 'S3', value: 6))
  b.zsmalls.add(Small.create(name: 'S4', value: 5))


  b.zlittles.add(l1)
  b.zlittles.add(l2)
  b.zlittles.add(l3)
  b.zlittles.add(l4)

  b
end

def setup_2
  b = Big.create

  l1 = Little.create(name: 'L1', score: 1)
  l2 = Little.create(name: 'L2', score: 2)
  l3 = Little.create(name: 'L3', score: 3)
  l4 = Little.create(name: 'L4', score: 4)

  b.zlittles.add(l1)
  b.zlittles.add(l2)
  b.zlittles.add(l3)
  b.zlittles.add(l4)

  [b, l1, l2, l3, l4]
end

def setup_3
  b = Big.create

  b1 = Bool.create(name: 'B1', is_valid: "false")
  b2 = Bool.create(name: 'B2', is_valid: "true")
  b3 = Bool.create(name: 'B3', is_valid: "false")
  b4 = Bool.create(name: 'B4', is_valid: "true")

  b.zbools.add(b1)
  b.zbools.add(b2)
  b.zbools.add(b3)
  b.zbools.add(b4)

  b
end

def setup_4
  b = Big.create

  d1 = DT.create(name: 'D1', last_login: "2012-07-29 06:24:20 +0800")
  d2 = DT.create(name: 'D2', last_login: "2012-07-29 05:24:20 +0800")
  d3 = DT.create(name: 'D3', last_login: "2012-07-29 04:24:20 +0800")
  d4 = DT.create(name: 'D4', last_login: "2012-08-29")
  b.zdts.add_list(d1, d2, d3, d4)
  b
end

def setup_5
  b = Big.create

  items = [
    {name: 'Apple', is_valid: 'false'},
    {name: 'Coconut', is_valid: 'true'},
    {name: 'Dragonfruit', is_valid: 'false'},
    {name: 'Banana', is_valid: 'true'},
    {name: 'apples', is_valid: 'true'},
    {name: 'coconuts', is_valid: 'true'},
    {name: 'durians', is_valid: 'false'},
    {name: 'bananas', is_valid: 'true'},
    {name: 'apple', is_valid: 'true'},
    {name: 'coconut', is_valid: 'true'},
    {name: 'banana', is_valid: 'false'},
    {name: 'durian', is_valid: 'true'},
  ]

  add_to_zset(b, 'zbools2', items, Bool)

  b
end

def setup_6
  b = Big.create

  items = [
    {name: 'apple', is_valid: 'false'},
    {name: 'Coconut', is_valid: 'true'},
    {name: 'duria', is_valid: 'false'},
    {name: 'Banana', is_valid: 'true'},
    {name: 'Apples', is_valid: 'true'},
    {name: 'coconuts', is_valid: 'true'},
    {name: 'durians', is_valid: 'false'},
    {name: 'bananas', is_valid: 'true'},
    {name: 'Apple', is_valid: 'true'},
    {name: 'coconut', is_valid: 'true'},
    {name: 'banana', is_valid: 'false'},
    {name: 'Durian', is_valid: 'true'},
  ]

  add_to_zset(b, 'zbools3', items, Bool)

  b
end

def setup_7
  b = Big.create

  items = [
    {name: 'apple', is_valid: 'false'},
    {name: 'Coconut', is_valid: 'true'},
    {name: 'duria', is_valid: 'false'},
    {name: 'Banana', is_valid: 'true'},
    {name: 'Apples', is_valid: 'true'},
    {name: 'coconuts', is_valid: 'true'},
    {name: 'durians', is_valid: 'false'},
    {name: 'bananas', is_valid: 'true'},
    {name: 'Apple', is_valid: 'true'},
    {name: 'coconut', is_valid: 'true'},
    {name: 'banana', is_valid: 'false'},
    {name: 'Durian', is_valid: 'true'},
  ]

  add_to_zset(b, 'zbools4', items, Bool)

  b
end

# Tests for the class methods
# TODO: figure out how to DRY up the class and instance method tests. Probably move the method body to a common method and test that common method instead
describe Ohm do
  it "can add objects and get the size for the class" do
    setup_big_1

    assert_equal 4, Big.zlittles.size
  end
end

# Tests for the instance methods
describe Ohm do
  it "can add objects and get the size" do
    b = setup_1

    assert_equal 4, b.zlittles.size
  end

  it "can add objects with scores and automatically sorts them by score" do
    b = setup_1

    assert_equal ["L1", "L2", "L3", "L4"], b.zlittles.to_a.map(&:name)
  end

  it "can return a range of sorted elements" do
    b = setup_1

    assert_equal ["L2", "L3"], b.zlittles.range(1, 2).map(&:name)
    assert_equal ["L1", "L2", "L3"], b.zlittles.range(0, 2).map(&:name)
  end

  it "can return a range of sorted elements in reverse" do
    b = setup_1

    assert_equal ["L3", "L2"], b.zlittles.revrange(1, 2).map(&:name)
    assert_equal ["L4", "L3", "L2"], b.zlittles.revrange(0, 2).map(&:name)
  end

  it "can iterate over the elements of a specified range of the set" do
    b = setup_1

    expected_items = ["L2", "L3", "L4"]

    b.zlittles.range(1, 3).each_with_index do |e, i|
      assert_equal expected_items[i], e.name
    end
  end

  it "can iterate over the elements of a specified range of the reverse sorted set" do
    b = setup_1
    expected_items = ["L3", "L2", "L1"]

    b.zlittles.revrange(1, 3).each_with_index do |e, i|
      assert_equal expected_items[i], e.name
    end
  end

  it "can get an element with a specified index" do
    b = setup_1

    assert_equal "L3", b.zlittles.get(2).name
    assert_nil b.zlittles.get(5)
  end

  it "can delete an element" do
    b = setup_1

    x = b.zlittles.get(2)
    deleted_element = b.zlittles.delete(x)

    assert_equal x, deleted_element
    assert_equal 3, b.zlittles.size
  end

  it "knows if it includes a specified element" do
    b, l1, l2, l3, l4 = setup_2

    assert b.zlittles.include?(l1)

    b.zlittles.delete(l2)

    refute b.zlittles.include?(l2)
    assert b.zlittles.include?(l3)
    assert b.zlittles.include?(l4)
    assert b.zlittles.include?(l1)

    b.zlittles.add(l2)

    assert b.zlittles.include?(l2)
  end

  it "can delete a range of elements by rank" do
    b = setup_1
    assert_equal ["L1", "L2", "L3", "L4"], b.zlittles.to_a.map(&:name)

    b.zlittles.remrangebyrank(0, 1)
    assert_equal ["L3", "L4"], b.zlittles.to_a.map(&:name)

    b.zlittles.remrangebyrank(0, 0)
    assert_equal ["L4"], b.zlittles.to_a.map(&:name)
  end

  it "can delete a range of elements by score" do
    b = setup_1
    assert_equal ["L1", "L2", "L3", "L4"], b.zlittles.to_a.map(&:name)

    b.zlittles.remrangebyscore(2, 3)
    assert_equal ["L1", "L4"], b.zlittles.to_a.map(&:name)
  end

  it "can allow intersection of 2 zsets" do
    b = setup_1

    zlittles = b.zlittles
    zlittles2 = b.zlittles2
    zintersection = b.zlittles.intersect(zlittles2)
    zlittles3 = b.zlittles3
    zintersection2 = b.zlittles.intersect(zlittles3)
    zintersection3 = zintersection.intersect(zintersection2)
    zintersection4 = zintersection.intersect(zintersection)

    assert_equal ["L1", "L4"], zintersection2.to_a.map(&:name)
    assert_equal ["L2", "L3", "L4"], zintersection.to_a.map(&:name)
    assert_equal ["L4"], zintersection3.to_a.map(&:name)
    assert_equal zintersection.to_a.map(&:name), zintersection4.to_a.map(&:name)
  end

  it "can allow intersection of a zset and a set" do
    b = setup_1

    zlittles = b.zlittles
    zlittles2 = b.zlittles2
    slittles = b.slittles

    zintersection = b.zlittles.intersect(slittles)
    zintersection2 = b.zlittles2.intersect(slittles)

    assert_equal ["L1","L2","L4"], zintersection.to_a.map(&:name)
    assert_equal ["L2","L4"], zintersection2.to_a.map(&:name)
  end

  it "can allow intersection of multiple zsets and sets" do
    b = setup_1

    zlittles = b.zlittles
    zlittles2 = b.zlittles2
    zlittles3 = b.zlittles3
    slittles = b.slittles

    zintersection = b.zlittles.intersect_multiple([zlittles2, zlittles3])

    assert_equal ["L4"], zintersection.to_a.map(&:name)
  end

  it "can allow intersection of multiple zsets and sets to a new named set" do
    b = setup_1

    zlittles = b.zlittles
    zlittles2 = b.zlittles2
    zlittles3 = b.zlittles3
    slittles = b.slittles
    zintersection = Ohm::ZSet.intersect_multiple("zintersection", [zlittles, zlittles2, zlittles3])

    assert_equal ["L4"], zintersection.to_a.map(&:name)
    assert_equal "zintersection", zintersection.key
  end

  it "can allow union of 2 zsets" do
    b = setup_1

    zlittles = b.zlittles
    zlittles2 = b.zlittles2
    zunion = b.zlittles.union(zlittles2)

    assert_equal ["L1","L2","L3","L4"], zunion.to_a.map(&:name)
  end

  it "can allow union of a zset and a set" do
    b = setup_1

    zlittles = b.zlittles
    zlittles2 = b.zlittles2
    slittles = b.slittles

    zunion = b.zlittles.union(slittles)
    zunion2 = b.zlittles2.union(slittles)

    assert_equal ["E3","L1","L2","L3","L4"], zunion.to_a.map(&:name)
  end

  it "can allow union of multiple zsets and sets" do
    b = setup_1

    zlittles = b.zlittles
    zlittles2 = b.zlittles2
    zlittles3 = b.zlittles3
    slittles = b.slittles

    zunion = b.zlittles.union_multiple([slittles, zlittles2, zlittles3])

    assert_equal ["E3","L1","L2","L3","L4","E1","E2"], zunion.to_a.map(&:name)
  end

  it "can allow union of multiple zsets and sets to a newly named set" do
    b = setup_1

    zlittles = b.zlittles
    zlittles2 = b.zlittles2
    zlittles3 = b.zlittles3
    slittles = b.slittles

    zunion = Ohm::ZSet.union_multiple("zunion", [zlittles, slittles, zlittles2, zlittles3])

    assert_equal ["E3","L1","L2","L3","L4","E1","E2"], zunion.to_a.map(&:name)
    assert_equal "zunion", zunion.key
  end

  it "can get the rank of an element" do
    b, l1, l2, l3, l4 = setup_2

    assert_equal 0, b.zlittles.rank(l1)
    assert_equal 1, b.zlittles.rank(l2)
    assert_equal 2, b.zlittles.rank(l3)
    assert_equal 3, b.zlittles.rank(l4)
  end

  it "can get the rank of specified element from the reverse sorted list" do
    b, l1, l2, l3, l4 = setup_2

    assert_equal 3, b.zlittles.revrank(l1)
    assert_equal 2, b.zlittles.revrank(l2)
    assert_equal 1, b.zlittles.revrank(l3)
    assert_equal 0, b.zlittles.revrank(l4)
  end

  it "can get the score of an element" do
    b, l1, l2, l3, l4 = setup_2

    assert_equal 1, b.zlittles.score(l1)
    assert_equal 2, b.zlittles.score(l2)
    assert_equal 3, b.zlittles.score(l3)
    assert_equal 4, b.zlittles.score(l4)
  end

  it "can get a range of elements by score" do
    b, = setup_2

    assert_equal ["L1", "L2", "L3", "L4"], b.zlittles.rangebyscore(0, 4).to_a.map(&:name)
    assert_equal ["L1", "L2"], b.zlittles.rangebyscore(1, 2).to_a.map(&:name)
    assert_equal ["L3", "L4"], b.zlittles.rangebyscore(3, 4).to_a.map(&:name)
    assert_equal ["L1", "L2", "L3"], b.zlittles.rangebyscore(1, 3).to_a.map(&:name)
    assert_equal ["L1", "L2"], b.zlittles.rangebyscore(0, 4, offset: 0, count: 2).to_a.map(&:name)
    assert_equal ["L3", "L4"], b.zlittles.rangebyscore(0, 4, offset: 2, count: 2).to_a.map(&:name)
    assert_equal ["L2", "L3", "L4"], b.zlittles.rangebyscore(0, 4, offset: 1, count: 3).to_a.map(&:name)
    assert_equal ["L3"], b.zlittles.rangebyscore(1, 3, offset: 2, count: 4).to_a.map(&:name)
    assert_equal ["L1", "L2", "L3", "L4"], b.zlittles.rangebyscore(0, "+inf").to_a.map(&:name)
    assert_equal ["L4"], b.zlittles.rangebyscore(2, "+inf", offset: 2).to_a.map(&:name)
    assert_equal ["L1", "L2"], b.zlittles.rangebyscore("-inf", 2).to_a.map(&:name)
    assert_equal ["L4"], b.zlittles.rangebyscore(2, "+inf", offset: 2, count: 2).to_a.map(&:name)
  end

  it "can get a range of elements by score in reverse" do
    b, = setup_2

    assert_equal ["L4", "L3", "L2", "L1"], b.zlittles.revrangebyscore(4, 0).to_a.map(&:name)
    assert_equal ["L2", "L1"], b.zlittles.revrangebyscore(2, 1).to_a.map(&:name)
    assert_equal ["L4", "L3"], b.zlittles.revrangebyscore(4, 3).to_a.map(&:name)
    assert_equal ["L3", "L2", "L1"], b.zlittles.revrangebyscore(3, 1).to_a.map(&:name)
    assert_equal ["L4", "L3"], b.zlittles.revrangebyscore(4, 0, offset: 0, count: 2).to_a.map(&:name)
    assert_equal ["L2", "L1"], b.zlittles.revrangebyscore(4, 0, offset: 2, count: 2).to_a.map(&:name)
    assert_equal ["L3", "L2", "L1"], b.zlittles.revrangebyscore(4, 0, offset: 1, count: 3).to_a.map(&:name)
    assert_equal ["L1"], b.zlittles.revrangebyscore(3, 1, offset: 2, count: 4).to_a.map(&:name)
    assert_equal ["L4", "L3", "L2", "L1"], b.zlittles.revrangebyscore("+inf", 0).to_a.map(&:name)
    assert_equal ["L2"], b.zlittles.revrangebyscore("+inf", 2, offset: 2).to_a.map(&:name)
    assert_equal ["L2", "L1"], b.zlittles.revrangebyscore(2, "-inf").to_a.map(&:name)
    assert_equal ["L2"], b.zlittles.revrangebyscore("+inf", 2, offset: 2, count: 2).to_a.map(&:name)
  end

  it "can get the number of elements between 2 given scores" do
    b, = setup_2

    assert_equal 2, b.zlittles.count(1, 2)
    assert_equal 2, b.zlittles.count(3, 4)
    assert_equal 4, b.zlittles.count(1, 4)
    assert_equal 3, b.zlittles.count(2, "+inf")
    assert_equal 4, b.zlittles.count
    assert_equal 4, b.zlittles.count("-inf", "+inf")
    assert_equal 2, b.zlittles.count("-inf", 2)
  end

  it "can update the sorted set properly upon updating the score of an element" do
    b, l1, l2, l3, l4 = setup_2
    assert_equal ["L1", "L2", "L3", "L4"], b.zlittles.to_a.map(&:name)

    l1.score = 5
    l1.save
    b.zlittles.update(l1)
    assert_equal ["L2", "L3", "L4", "L1"], b.zlittles.to_a.map(&:name)

    l3.score = -3
    l3.save
    b.zlittles.update(l3)
    assert_equal ["L3", "L2", "L4", "L1"], b.zlittles.to_a.map(&:name)

  end

  it "can sort elements by date" do
    b = setup_4

    assert_equal ["D3", "D2", "D1", "D4"], b.zdts.to_a.map(&:name)
  end

  it "can sort elements by name" do
    b = setup_5

    assert_equal ["Apple", "Banana", "Coconut", "Dragonfruit",
                  "apple", "apples", "banana", "bananas",
                  "coconut", "coconuts", "durian", "durians"],
                  b.zbools2.to_a.map(&:name)
  end

  it "can sort elements by name (insensitive)" do
    b = setup_6

    assert_equal ["apple", "Apple", "Apples",
                  "Banana", "banana", "bananas",
                  "Coconut", "coconut", "coconuts",
                  "duria", "Durian", "durians"],
                  b.zbools3.to_a.map(&:name)
  end

  it "can sort elements by name (insensitive high)" do
    b = setup_7

    assert_equal ["Apple", "Apples", "apple",
                  "Banana", "banana", "bananas",
                  "Coconut", "coconut", "coconuts",
                  "Durian", "duria", "durians"],
                  b.zbools4.to_a.map(&:name)
  end

  it "can find elements that starts with specified string" do
    b = setup_5

    assert_equal ["durian", "durians"], b.zbools2.starts_with("du").map(&:name)
    assert_equal ["durians"], b.zbools2.starts_with("d",offset:1,limit:1).map(&:name)
    assert_equal ["bananas"], b.zbools2.starts_with("bananas").map(&:name)
  end

  it "can return the first and last elements" do
    b = setup_1

    assert_equal "L1", b.zlittles.first.name
    assert_equal "L4", b.zlittles.last.name
  end

  it "can be deleted / destroyed" do
    b = setup_1

    b.zlittles.destroy!

    assert_equal [], b.zlittles.to_a.map(&:name)
  end

  it "can delete all elements at once" do
    b = setup_1

    b.zlittles.clear

    assert_equal [], b.zlittles.to_a.map(&:name)
  end

  it "can clone itself to another instance" do
    b, l1, l2, l3, l4 = setup_2

    clone = b.zlittles.duplicate

    assert_equal ["L1", "L2", "L3", "L4"], clone.to_a.map(&:name)
    assert_equal 1, clone.score(l1)
    assert_equal 2, clone.score(l2)
    assert_equal 3, clone.score(l3)
    assert_equal 4, clone.score(l4)
  end

  it "can convert a procedure block to string and back" do
    x = lambda { |x| x + 1 }
    y = Ohm::Utils.proc_to_string x

    assert_equal "proc { |x| (x + 1) }", y

    z = Ohm::Utils.string_to_proc y

    assert_equal 3, z.call(2)
  end

  it "can convert a score_field list to string and back" do
    score_field = [:n1, :n2, :n3, lambda { |x| x + 1 }]
    score_field_string = Ohm::Utils.score_field_to_string score_field

    assert_equal "n1:n2:n3:proc { |x| (x + 1) }", score_field_string

    score_field_list = Ohm::Utils.string_to_score_field score_field_string

    assert_equal :n1, score_field_list[0]
    assert_equal :n2, score_field_list[1]
    assert_equal :n3, score_field_list[2]

    assert_equal 3, score_field_list[3].call(2)
  end

  it "can save and load sets by name" do
    b = setup_1

    sorted_set = b.zlittles
    sorted_set.save_set
    sorted_set_2 = Ohm::ZSet.load_set(sorted_set.key)

    assert_equal sorted_set_2.to_a.map(&:name), sorted_set.to_a.map(&:name)

    sorted_set_2.add(Little.create(name:'X1',score:29))

    assert_equal sorted_set_2.to_a.map(&:name), sorted_set.to_a.map(&:name)
  end
end
