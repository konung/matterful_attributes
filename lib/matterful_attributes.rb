require "matterful_attributes/version"

module MatterfulAttributes
  extend ActiveSupport::Concern
    # These only make sense as instance methods
      def matterful_attributes(options={})
        options = options.dup
        default     = options[:default].nil?        ? true : options[:default]
        foreign_key = options[:foreign_key].nil?    ? true : options[:foreign_key]
        sti         = options[:sti].nil?            ? true : options[:sti]
        polymorphic = options[:polymorphic].nil?    ? true : options[:polymorphic]
        # extra keys supplied as array of strings to ignore in comparison
        attributes_to_ignore = options[:extra].nil? ? []   : options[:extra]

        # Let's check for and add typical attributes that sti & polymorphic models have, override
        # this by sti: false, polymorphic: false, foreign_key: false
        # by default when looking to compare two objects
        # Customer.find(1).shipping_address.same_as? Address.new(city: 'Chicago')
        # we really only want to see if any of the 'matterfule information changed', like address_line_1 or city.
        # TODO: I guess I could do some smart checking on the model to see what kind of attributes it has.
        # For now we'll just check for all that we want to remove
        if default
          attributes_to_ignore += ['id', 'created_at', 'updated_at']
        end
        # By default we want foreign keys like caegory_id as they provide useful information about current record.
        # Let's say you import a bunch of addresses
        # and they ony matterful change was from shipping to billing category.
        unless foreign_key
          # This will skip polymorphic style foreign keys and only deal with belongs_to style keys
          attributes_to_ignore += attributes.keys.keep_if{|k| k.match(/_id\z/) && !k.match(/able_id\z/) }
        end
        if sti
          attributes_to_ignore += ['type']
        end
        # If you are looking at a model that is polymorphic than most like you want to update something
        # like city for an Address , not addressable_id or addresable_type
        # That is more likely type of information to be updated on external import.
        if polymorphic
          attributes_to_ignore += attributes.keys.keep_if{|k| k.match(/able_id\z/) }
          attributes_to_ignore += attributes.keys.keep_if{|k| k.match(/able_type\z/) }
        end
        attributes.except(*attributes_to_ignore)
      end

      def same_as?(source,options={})
        matterful_attributes(options) == source.matterful_attributes(options)
      end

      def matterful_diff(source,options={})
        matterful_attributes(options).diff(source.matterful_attributes(options))
      end

      # Update self if source object has new data but DO NOT save. Let's say you want to do
      # futer processing on the new data. Validation, upcasing, concatination
      def matterful_update(source,options={})
        options = options.dup
        # Set ignore_nils to false only if you, want to update existing information with nil information from the new object
        # For example, often your table has historical data, while source, may only have current. You may want to keep historical data
        # for reference, or if some process relies on it. It's generally not a good idea to delete good data, unless you have to.
        ignore_nils = options[:ignore_nils].nil?  ? true : options[:ignore_nils]
        # Pay attention to this! Reversing comparison to get expected results
        if !(target_attributes = source.matterful_diff(self, options={})).empty?
          target_attributes.each_pair do |k,v|
            if ignore_nils && v.nil?
              self[k] = v
            end
          end
        end
        self
      end

      def matterful_update!(source,options={})
        # This will update self and save self if valid. Will return true or false.
        self.matterful_update(source,options={})
        save
      end
end

# include the extension
ActiveRecord::Base.send(:include, MatterfulAttributes)

