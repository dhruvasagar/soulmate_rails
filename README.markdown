# Soulmate Rails

Soulmate Rails is a rails plugin that helps to solve the common problem
building auto-completion back-end in rails intuitively. It extends the
soulmate gem <a href="http://github.com/seatgeek/soulmate">Soulmate</a> to
make it easily pluggable into a rails project.

## Getting Started

### Installation :

```sh
$ gem install soulmate_rails
```
OR add this to your `Gemfile` :

```ruby
gem 'soulmate_rails'
```

### Usage :

  Following is an example of how one can use Soulmate Rails for enabling backend
  autocompletion using redis.

```ruby
class User < ActiveRecord::Base
  autocomplete :first_name, :score => :calculate_score
  autocomplete :last_name, :score => :id

  def calculate_score
    # Some magic calculation returning a number.
  end
end

1.9.3p385 :001 > User.create(:first_name => 'First1', :last_name => 'Last1')
1.9.3p385 :002 > User.create(:first_name => 'First2', :last_name => 'Last2')
1.9.3p385 :003 > User.create(:first_name => 'First3', :last_name => 'Last3')
1.9.3p385 :004 > User.search_by_first_name('firs')
  => [#<User:0x000000014bb1e8 @new_record=false,
  @attributes={"first_name"=>"First3", "last_name"=>"Last3" "id"=>3},
  @changed_attributes={}>, #<User:0x000000014bb1e9 @new_record=false,
  @attributes={"first_name"=>"First2", "last_name"=>"Last2" "id"=>2},
  @changed_attributes={}>, #<User:0x000000014bb1ea @new_record=false,
  @attributes={"first_name"=>"First1", "last_name"=>"Last1" "id"=>1},
  @changed_attributes={}>]
1.9.3p385 :005 > User.search_by_last_name('last1')
  => [#<User:0x000000014bb1e8 @new_record=false,
  @attributes={"first_name"=>"First3", "last_name"=>"Last3" "id"=>3},
  @changed_attributes={}>]
```

The `autocomplete` method takes 2 arguments :

* attribute name to use for autocompletion.
* options that determine how autocompletion works for indexing.

### Methods added by autocomplete :
* Class Methods
  * `search_by(attribute, term, options={})` - Generic method to search by
    an attribute for which an autocomplete was defined.
  * `search_by_#{attribute}(term, options={})` - Specific methods for each
    attribute autocomplete was defined for.
* Instance Methods
  * `update_index_for(attribute, options={})`
  * `update_index_for_#{attribute}` - used in an `after_save` callback to
    update index for searching.
  * `remove_index_for(attribute)`
  * `remove_index_for_#{attribute}` - used in a `before_destroy` callback to
    remove index for searching. Hence you should use `destroy` as opposed to
    `delete` to ensure the callbacks are invoked appropriately by rails and
    soulmate updates the index.

### Options you can provide to `autocomplete` :
* `:score` : This is required. Soulmate uses it for sorting the results (in
  reverse order, i.e. higher score first). This can be the name of a function
  or can also be the name of another attribute with integer values.
* `:aliases` : This is optional. Soulmate uses this as aliases for the term
  field and uses it for searching as well. This can be an array of values or
  a method name which returns an array of values.

### Configuration :
Within your rails application inside config/application.rb you can optionally
provide redis configuration. Example :

```ruby
config.soulmate_rails.redis = 'redis://127.0.0.1:6380/0'
# or you can assign an existing instance of Redis, Redis::Namespace, etc.
# config.soulmate_rails.redis = $redis
```

Alternatively, you can also add configuration in an initializer. Example :

```ruby
Soulmate.redis = 'redis://127.0.0.1:6380/0'
# or you can assign an existing instance of Redis, Redis::Namespace, etc.
# Soulmate.redis = $redis
```

## Contributing
### Reporting an Issue :
* Use <a href="http://github.com/dhruvasagar/soulmate_rails/issues">Github
   Issue Tracker</a> to report issues.

### Contributing to code :
* Fork it.
* Commit your changes ( git commit ).
* Push to github ( git push ).
* Open a Pull Request.

## License
Soulmate Rails is released under the MIT License

<!-- vim: set tw=80 colorcolumn=80 -->
