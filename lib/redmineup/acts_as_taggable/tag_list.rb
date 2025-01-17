module Redmineup
  module ActsAsTaggable #:nodoc:
    class TagList < Array #:nodoc:
      cattr_accessor :delimiter
      self.delimiter = ','

      def initialize(*args)
        add(*args)
      end

      # Add tags to the tag_list. Duplicate or blank tags will be ignored.
      #
      #   tag_list.add("Fun", "Happy")
      #
      # Use the <tt>:parse</tt> option to add an unparsed tag string.
      #
      #   tag_list.add("Fun, Happy", :parse => true)
      def add(*names)
        extract_and_apply_options!(names)
        concat(names)
        clean!
        self
      end

      # Remove specific tags from the tag_list.
      #
      #   tag_list.remove("Sad", "Lonely")
      #
      # Like #add, the <tt>:parse</tt> option can be used to remove multiple tags in a string.
      #
      #   tag_list.remove("Sad, Lonely", :parse => true)
      def remove(*names)
        extract_and_apply_options!(names)
        delete_if { |name| names.include?(name) }
        self
      end

      # Toggle the presence of the given tags.
      # If a tag is already in the list it is removed, otherwise it is added.
      def toggle(*names)
        extract_and_apply_options!(names)

        names.each do |name|
          include?(name) ? delete(name) : push(name)
        end

        clean!
        self
      end

      # Transform the tag_list into a tag string suitable for edting in a form.
      # The tags are joined with <tt>TagList.delimiter</tt> and quoted if necessary.
      #
      #   tag_list = TagList.new("Round", "Square,Cube")
      #   tag_list.to_s # 'Round, "Square,Cube"'
      def to_s
        clean!

        map do |name|
          name.include?(delimiter) ? "\"#{name}\"" : name
        end.join(delimiter[-1] == (' ') ? delimiter : "#{delimiter} ")
      end

     private
      # Remove whitespace, duplicates, and blanks.
      def clean!
        reject!(&:blank?)
        map!(&:strip)
        uniq!
      end

      def extract_and_apply_options!(args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        options.assert_valid_keys :parse

        args.map! { |a| self.class.from(a) } if options[:parse]

        args.flatten!
      end

      class << self
        # Returns a new TagList using the given tag string.
        #
        #   tag_list = TagList.from("One , Two,  Three")
        #   tag_list # ["One", "Two", "Three"]
        def from(source)
          tag_list = new

          case source
          when Array
            tag_list.add(source)
          else
            string = source.to_s.dup

            # Parse the quoted tags
            [
              /\s*#{delimiter}\s*(['"])(.*?)\1\s*/,
              /^\s*(['"])(.*?)\1\s*#{delimiter}?/
            ].each do |re|
              string.gsub!(re) { tag_list << $2; "" }
            end

            tag_list.add(string.split(delimiter))
          end

          tag_list
        end
      end
    end
  end
end
