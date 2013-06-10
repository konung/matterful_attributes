matterful_attributes
====================

Ruby / Rails gem that shims ActiveRecord::Base to provide some helpful methods for parsing out attributes that matter to humans, i.e.
``` Address.first.matterful_attributes ```
will return a hash of attributes minus
<b> id, type, polymorphic_id, polymorphic_type, cretated_at, updated_at</b> and can also skip all foreign_keys, like <b>category_id or status_id </b>.

This is really useful when you need to be able to import, compare and update information on a record from an external source like a CSV file or a legacy DB. In that context only attributes specific to the model matter. In the world outside of rails, such as some old legacy DB these Rails specific attributes don't mean much. And I got tired of writing things like
```ruby
Address.first.attributes.except('id','created_at','updated_at').diff(OldStyleAddress.first.attributes)
```
It's much cleaner to right it this way:
```ruby
Address.first.matterful_diff(OldStyleAddress.first)
```
don't  you think?


Production
==========
This was extracted from production code that's tested. However use at your own risk. NO warranties or guarantees provided!


Tests
=====
This gem needs tests! It's tested in the context of my production code, but no gem specific tests. I'll add them later if time allows. Really bad practice, I know, but I'm really short on time.
I suggest you check out this answer on stackoverflow: http://stackoverflow.com/a/13156750/198424

Usage
=====
Using Gemfile:

```ruby
gem 'matterful_attributes', require: 'matterful_attributes'
```

Available methods
```ruby
# List attributes that matter to humans
matterful_attributes( source,
                      optons={ default:true,
                               sti: true,
                               polymorphic: true,
                               foreign_key: true,
                               extra: ['Array', 'of extra', 'attributes', 'to ignore as strings']
                             })

# Do comparison of two similar Records for attributes that matter. Returns a hash of attributes that will be updated with the information that will update it
matterful_diff(source , optons
                      ={ default:true,
                               sti: true,
                               polymorphic: true,
                               foreign_key: true,
                               extra: ['Array', 'of extra', 'attributes', 'to ignore as strings']
                             })

# Diff and update target from source. Returns self. with updated attributes, but doesn't save!!!
matterful_update(sour ce, opto
                      ns={ default:true,
                               sti: true,
                               polymorphic: true,
                               foreign_key: true,
                               extra: ['Array', 'of extra', 'attributes', 'to ignore as strings']
                             })

# Same as matterful_update but also saves self. right away if valid. Returns true / false.
matterful_update!(sou rce, opt
                      ons={ default:true,
                               sti: true,
                               polymorphic: true,
                               foreign_key: true,
                               extra: ['Array', 'of extra', 'attributes', 'to ignore as strings']
                             })

# I decided not to overload standard comparison operators to avoid confusion. hence this. Returns true or false
same_as?(source, opto ns={ def
                      ault:true,
                               sti: true,
                               polymorphic: true,
                               foreign_key: true,
                               extra: ['Array', 'of extra', 'attributes', 'to ignore as strings']
                             })
```

!!! Attention
Foreign_keys such as category_id are by default not ignored pass foreign_key: false to ignore them. See example below.


Now all your models have matterful INSTANCE methods. These methods only make sence to use in an instance of Address.first, no in Address  as class by itself doesn't hod any information that matters to humans: sucha s when you import CSV data you are going to update a very specific record, not some abstract Address.

```ruby
# Assuming you have an Address model like so
class Address < ActiveRecord::Base {
                  :id => :integer,
      :address_line_1 => :string,
      :address_line_2 => :string,
      :address_line_3 => :string,
                :city => :string,
               :state => :string,
                 :zip => :string,
             :country => :string,
                :attn => :string,
         :category_id => :integer,
      :addressable_id => :integer,
    :addressable_type => :string,
          :created_at => :datetime,
          :updated_at => :datetime
}
```

```ruby
# List matterful attributes, without foreign_keys like category_id
Address.first.matterful_attributes(foreign_keys: false)

# Returns hash like so
# {"address_line_1"=>"300 Sample Drive",
# "address_line_2"=>nil,
# "address_line_3"=>nil,
# "city"=>"Buffalo Grove",
# "state"=>"IL",
# "zip"=>"60089",
# "country"=>"USA",
# "attn"=>nil}

# List matterful attributes, without foreign_keys like category_id
Address.first.matterful_diff(Address.last)

# Returns hash like so
# {"address_line_1"=>"300 Sample Drive",
# "address_line_2"=>nil,
# "address_line_3"=>nil,
# "city"=>"Buffalo Grove",
# "state"=>"IL",
# "zip"=>"60089",
# "country"=>"USA",
# "attn"=>nil}

```
