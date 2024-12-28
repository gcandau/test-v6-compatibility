# Redmineup

This gem is used at RedmineUP as a general place for shared functionality and
assets. It contains **Chart.js** and **select2** JS libraries, various mixins
for ActiveRecord models and other things you might find useful.

Among mixins there are:

* up_acts_as_draftable
* up_acts_as_taggable
* up_acts_as_viewable
* up_acts_as_votable


## Installation

Add it to your plugin's Gemfile:
```ruby
gem 'redmineup'
```

Then invoke the following command in your plugin's or Redmine directory:
```
$ bundle install
```

And now you can start using it.


## Usage
### Drafts
This module allows saving and restoring drafts for different models. To be
saved as a draft, an instance does not need to pass the validations. Drafts
store not only model attributes, but also associations and virtual attributes.
A draft could be linked to a given user, so every user can manage his/her own
drafts independent of others. A draft might have a parent instance.

First of all, drafts need to be saved somewhere, so let's create a migration:
```ruby
class CreateDrafts < Rails.version > '5' ? ActiveRecord::Migration[5.0] : ActiveRecord::Migration
  def change
    ActiveRecord::Base.create_drafts_table
  end
end
```

Then in the Redmine directory run:
```
$ rake redmine:plugins:migrate
```

Next, add `up_acts_as_draftable` to a model for which you want to save drafts:
```ruby
class Message < ActiveRecord::Base
  up_acts_as_draftable
end
```

And that's it for the preparation, now you're ready to make use of drafts:
```ruby
# You can save message as a draft.
Message.new(subject: 'foo').save_draft

# And later restore message from the draft.
draft = Message.drafts(nil).last
message = draft.restore
puts message.subject
# => foo

# Draft can be overwritten.
message.content = 'bar'
puts message.save_draft
# => true

# You can also save draft linked to a particular user.
Message.new(subject: 'baz').save_draft(user: current_user)

# And restore message from some user's draft.
user_draft = Message.drafts(current_user).last
user_message = user_draft.restore
puts user_message.subject
# => baz

# It's also possible to restore a bunch of messages at once.
messages = Message.drafts(current_user).restore_all
p messages.map(&:subject)
# => ["baz"]

# When a model instance is saved, corresponding draft is removed.
puts Message.drafts(current_user).count
# => 1
user_message.board_id = Board.first.id
user_message.save!
puts Message.drafts(current_user).count
# => 0

# Drafts will be saved only for new (not persisted) or changed instances.
puts Message.new.save_draft
# => true
persisted = Message.last
puts persisted.save_draft
# => false
persisted.subject = 'other subject'
puts persisted.save_draft
# => true
```

### Tags
This module makes it possible to tag objects.

First, create a migration:
```ruby
class CreateTags < Rails.version > '5' ? ActiveRecord::Migration[5.0] : ActiveRecord::Migration
  def change
    ActiveRecord::Base.create_taggable_table
  end
end
```

Then in the Redmine directory run:
```
$ rake redmine:plugins:migrate
```

Next, add `up_acts_as_taggable` to a model for which you want to provide tags:
```ruby
class Contact < ActiveRecord::Base
  up_acts_as_taggable
end
```

TODO: Add examples of usage.

### Viewings
This module allows you to count views for some ActiveRecord model instances.

To count views you'll need to create a migration:
```ruby
class CreateViewings < Rails.version > '5' ? ActiveRecord::Migration[5.0] : ActiveRecord::Migration
  def change
    ActiveRecord::Base.create_viewings_table
  end
end
```

To apply it, run the following in the Redmine directory:
```
$ rake redmine:plugins:migrate
```

Then add `up_acts_as_viewed` to a model for which you want to count views.
```ruby
class Question < ActiveRecord::Base
  up_acts_as_viewed
end
```

TODO: Provide some usage examples.

### Votes
With this module you can make your models votable and allow users to vote.

As always, create a migration first:
```ruby
class CreateVotes < Rails.version > '5' ? ActiveRecord::Migration[5.0] : ActiveRecord::Migration
  def change
    ActiveRecord::Base.create_votable_table
  end
end
```

Then apply it by running the following command in the Redmine directory:
```
$ rake redmine:plugins:migrate
```

To make a model votable, add `up_acts_as_votable` to it:
```ruby
class Question < ActiveRecord::Base
  up_acts_as_votable
end
```

TODO: Write about `up_acts_as_voter` and add usage examples.


## Development

If you're planning to extend this gem, you will need to install development
dependencies. To do this, execute the following command in the project's
directory:
```
$ bundle install
```

After that you'll be able to run tests:
```
$ bundle exec rake test
```

SQLite in-memory database will be used by default, which is the fastest way to run tests. To run them using different database adapters, set `DB` environment variable to one of the available values — `mysql`, `postgresql`, `sqlite`. For example, to use PostgreSQL, invoke tests like so:
```
$ bundle exec rake test DB=postgresql
```
