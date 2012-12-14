<img src="http://i.imgur.com/qiNrL.jpg" alt="Cooler" align="right">

# Cooler

_The Good-Hearted Leader_

> Cooler Howard Smith has an outgoing and mellow personality and always keeps
> his head up even in the most daring situations. He is smart, laid-back,
> friendly, witty, and usually optimistic even when things get serious.

A mini ORM, agnostic to key value store databases.

If you're in a hurry, and need to define some models that should be persisted,
in any Key-Value Store Database, this is the right gem.

## Installation

Add `gem 'cooler'` to your Gemfile.

## Define Adapter's set, get and delete

In an initializer, you'll need to specify how to set, get and delete a key.
Let's say that you use Redis, then you want to do something similar to:

```ruby
redis = Redis.new

Cooler::Adapater.set = ->(key, value) { redis.set(key, value.to_json) }
Cooler::Adapater.get = ->(key) do
  result = Bloodhound.redis.get(key) and JSON.parse(result)
end
Cooler::Adapater.delete = ->(key) { redis.del(key) }
```

That's it.

## Define your models

Defining a model is as easy as 1, 2, 3.

```ruby
# A model should inherit from Struct, attributes defined there are PERSISTED
# in the database.
class User < Struct.new(:login, :age, :encrypted_password, :created_at)
  # You must include Cooler::Model
  include Cooler::Model

  # Any attribute accessor, or instance variables, are NOT STORED in the
  # database, however you can  initialize an object with these attributes.
  attr_accessor :password

  # You can set defaults for any of the attributes.
  default :age, 18
  default :encrypted_password,
    ->(user) { Digest::MD5.hexdigest(user.password) }
  default :created_at, -> { Time.now.utc }

  # To define the key for a Model, you need to pass a block, and return an
  # String that will be the key to store the object.
  key { |user| "user_#{user.login}" }
end

# You can create a new instance, passing its atributes:
user = User.new(login: 'cooler', age: 20, password: 'im_cooler')
user.save

# You can also get any stored object, passing a Hash as argument, or
# specifying the exact key.
user = User.get(login: 'cooler') # or User.get('user_cooler')
user.age = 10
user.save
```

## License

MIT
