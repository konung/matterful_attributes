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
