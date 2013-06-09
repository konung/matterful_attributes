require "matterful_attributes/version"

module MatterfulAttributes
  module ActiveRecord
    class Base

      def matterful_attributes(options={})
        options = options.dup
        default     = options[:default].nil?        ? true : options[:default]
        foreign_key = options[:foreign_key].nil?    ? true : options[:foreign_key]
        sti         = options[:sti].nil?            ? true : options[:sti]
        polymorphic = options[:polymorphic].nil?    ? true : options[:polymorphic]
        # extra keys supplied as array of strings to ignore in comparison
        attributes_to_ignore = options[:extra].nil? ? []   : options[:extra]

        # Let's check for and add typical attributes that sti & polymorphic models have, override this by sti: false, polymorphic: false, :foreign_key: false
        # by default when looking to compare two objects Customer.find(1).shipping_address.same_as? Address.new(city: 'Chicago')
        # we really only want to see if any of the 'matterfule information changed', like address_line_1 or city.
        # TODO: I guess I could do some smart checking on the model to see what kind of attributes it has. For now we'll just check for all that we want to remove
        if default
          attributes_to_ignore += ['id', 'created_at', 'updated_at']
        end
        if foreign_key
          attributes_to_ignore += attributes.keys.keep_if{|k| k.match(/_id\z/) && !k.match(/able_id\z/) }  # This will skipp polymorphic style foreign keys
        end
        if sti
          attributes_to_ignore += ['type']
        end
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

      def matterful_update(source,options={})
        # Update self if source object has new data but DO NOT save. Let's say you want to do futer processing on the new data. Validation, upcasing, concatination
        if !(target_attributes = source.matterful_diff(self, options={})).empty?  # Pay attention to this! Reversing comparison to get expected results
          target_attributes.each_pair do |k,v|
            self[k] = v
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
  end
end
