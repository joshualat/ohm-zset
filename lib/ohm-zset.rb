require 'ohm'
require 'time'

module Ohm
  class Model
    def self.zset (name, model, *score_field)

      define_method name do 
        model = Utils.const(self.class, model)

        Ohm::ZSet.new(key[name], model.key, model, score_field)
      end
        
    end
  end

  module ZScores
    module ZScore
      Integer = lambda{ |x| Integer(x) }
      Float = lambda{ |x| Float(x) }
      Boolean = lambda{ |x| Ohm::ZScores.boolean(x) }   
      DateTime = lambda{ |x| Ohm::ZScores.datetime(x) }
      String = lambda{ |x| Ohm::ZScores.string(x) }
      StringInsensitive = lambda{ |x| Ohm::ZScores.string_insensitive(x) }
      StringInsensitiveHigh = lambda{ |x| Ohm::ZScores.string_insensitive_high(x) }
    end

    def self.boolean(val)
      case val
        when "true", "1", true then 1
        when "false", "0", false, nil then 0
        else 1
      end
    end

    def self.datetime(val)
      ::DateTime.parse(val.to_s).to_time.to_i
    end

    # scoring accurate until 9th character
    def self.string(val)
      total_score = 0
      val.each_char.with_index do |c, i|
        total_score += (c.ord-31) * ((126-32) ** (10 - i))
        break if i == 9        
      end
      total_score.to_f
    end

    # scoring accurate until 9th character
    def self.string_insensitive(val)
      total_score = 0
      val.each_char.with_index do |c, i|
        char_ord = c.ord-31
        if ('a'..'z').include? c
          char_ord -= 32
        end
        total_score += (char_ord) * ((126-32) ** (10 - i))
        break if i == 9        
      end
      total_score.to_f
    end

    # scoring accurate until 9th character
    def self.string_insensitive_high(val)
      total_score = 0
      val.each_char.with_index do |c, i|
        char_ord = c.ord-31
        if ('a'..'z').include? c
          char_ord -= 31.5
        end
        total_score += (char_ord) * ((126-32) ** (10 - i))
        break if i == 9        
      end
      total_score.to_f
    end
  end

  class ZSet < Struct.new(:key, :namespace, :model, :score_field)

    include PipelinedFetch
    include Enumerable

    def size
      db.zcard(key)
    end

    def count(a = "-inf", b = "+inf")
      return size if a == "-inf" and b == "+inf"
      db.zcount(key, a, b)
    end

    def ids (a = 0, b = -1)
      execute { |key| db.zrange(key, a, b) }
    end

    def range (a = 0, b = -1)
      fetch( ids(a, b) )
    end

    def revrange (a = 0, b = -1)
      fetch( execute { |key| db.zrevrange(key, a, b) } )
    end

    # Fetch data from Redis
    def to_a
      fetch(ids)
    end

    def sort(options = {})
      if options.has_key?(:get)
        options[:get] = namespace["*->%s" % options[:get]]
        return execute { |key| db.sort(key, options) }
      end

      fetch(execute { |key| db.sort(key, options) })
    end

    def include? (model)
      !rank( model ).nil?
    end

    def get (i)
      range(i, i)[0]
    end

    def each
      to_a.each { |element| yield element }
    end

    def empty?
      size == 0
    end

    def add (model)
      score_value = model
      lambda_function = score_field.each do |field|
        break field if field.is_a? Proc
        score_value = model.send(field)
        break lambda{ |x| x.to_i } if field == score_field.last
      end
      db.zadd(key, lambda_function.call(score_value), model.id)
    end

    def add_list (*models)
      models.each do |model|
        add(model)
      end
    end

    def update (model)
      add (model)
    end

    def delete (model)
      db.zrem(key, model.id)
      model
    end

    def remrangebyrank (a, b)
      db.zremrangebyrank(key, a, b)
    end

    def remrangebyscore (a, b)
      db.zremrangebyscore(key, a, b)
    end

    def intersect (set, w1=1.0, w2=1.0)
      new_key = "ZSet:#{key}&&#{set.key}"
      new_set = Ohm::ZSet.new(new_key, model.key, model, score_field)
      db.zinterstore(new_set.key, [key, set.key], :weights => [w1, w2])      
      new_set
    end

    def intersect_multiple (sets, weights = [])
      sets = sets.map(&:key)
      sets.push(key)
      weights = [1.0] * sets.length if weights = []
      new_key = "ZSet:" + sets.join("&&")
      new_set = Ohm::ZSet.new(new_key, model.key, model, score_field)
      db.zinterstore(new_set.key, sets, :weights => weights)
      new_set
    end

    def union (set, w1=1.0, w2=1.0)
      new_key = "ZSet:#{key}||#{set.key}"
      new_set = Ohm::ZSet.new(new_key, model.key, model, score_field)
      db.zunionstore(new_set.key, [key, set.key], :weights => [w1, w2])
      new_set
    end

    def union_multiple (sets, weights = [])
      sets = sets.map(&:key)
      sets.push(key)
      weights = [1.0] * sets.length if weights = []
      new_key = "ZSet:" + sets.join("&&")
      new_set = Ohm::ZSet.new(new_key, model.key, model, score_field)
      db.zunionstore(new_set.key, sets, :weights => weights)
      new_set
    end

    def rank (model)
      db.zrank(key, model.id)
    end

    def revrank (model)
      db.zrevrank(key, model.id)
    end

    def score (model)
      db.zscore(key, model.id).to_i
    end

    def rangebyscore (a = "-inf", b = "+inf", limit = {})
      limit[:offset] ||= 0
      limit[:count] ||= -1
      fetch(execute { |key| db.zrangebyscore(key, a, b, :limit=>[limit[:offset], limit[:count]]) })
    end

    def revrangebyscore (a = "+inf", b = "-inf", limit = {})
      limit[:offset] ||= 0
      limit[:count] ||= -1
      fetch(execute { |key| db.zrevrangebyscore(key, a, b, :limit=>[limit[:offset], limit[:count]]) })
    end

    def starts_with (query, limit = {})
      start_query = ZScores.string(query)
      end_query = "(" + ZScores.string(query.succ).to_s
      rangebyscore(start_query, end_query, limit)
    end

    def first
      range(0, 1)[0]
    end

    def last
      revrange(0, 1)[0]
    end

    def destroy!
      db.del(key)
    end

    def clear
      remrangebyrank(0, -1)
    end

    private
    def db
      model.db
    end

    def execute
      yield key
    end
  end
end
