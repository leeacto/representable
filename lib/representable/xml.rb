require 'representable'
require 'representable/bindings/xml_bindings'
require 'representable/xml/collection'
require 'nokogiri'

module Representable
  module XML
    def self.included(base)
      base.class_eval do
        include Representable
        extend ClassMethods
        self.representation_wrap = true # let representable compute it.
        register_feature Representable::XML
      end
    end


    module ClassMethods
      def remove_namespaces!
        representable_attrs.options[:remove_namespaces] = true
      end

      def collection_representer_class
        Collection
      end
    end

    def from_xml(doc, *args)
      node = parse_xml(doc, *args)

      from_node(node, *args)
    end

    def from_node(node, options={})
      update_properties_from(node, options, Binding)
    end

    # Returns a Nokogiri::XML object representing this object.
    def to_node(options={})
      options[:doc] ||= Nokogiri::XML::Document.new
      root_tag = options[:wrap] || representation_wrap(options)

      create_representation_with(Nokogiri::XML::Node.new(root_tag.to_s, options[:doc]), options, Binding)
    end

    def to_xml(*args)
      to_node(*args).to_s
    end

  private
    def remove_namespaces?
      # TODO: make local Config easily extendable so you get Config#remove_ns? etc.
      representable_attrs.options[:remove_namespaces]
    end

    def parse_xml(doc, *args)
      node = Nokogiri::XML(doc)

      node.remove_namespaces! if remove_namespaces?
      node.root
    end
  end
end
