# frozen_string_literal: true

module LinkedRails
  module Model
    module Iri
      extend ActiveSupport::Concern

      # @return [RDF::URI].
      def canonical_iri(opts = {})
        return iri_with_root(root_relative_canonical_iri(opts)) if opts.present?

        @canonical_iri ||= iri_with_root(root_relative_canonical_iri(opts))
      end

      def canonical_iri_opts
        iri_opts
      end

      # @return [RDF::URI].
      def iri(opts = {})
        return iri_with_root(root_relative_iri(opts)) if opts.present?

        @iri ||= iri_with_root(root_relative_iri)
      end

      # @return [Hash]
      def iri_opts
        @iri_opts ||= {
          fragment: route_fragment,
          id: to_param
        }
      end

      def reload(_opts = {})
        @iri = nil
        super
      end

      # @return [RDF::URI]
      def root_relative_canonical_iri(opts = {})
        RDF::URI(expand_canonical_iri_template(canonical_iri_opts.merge(opts)))
      end

      # @return [RDF::URI]
      def root_relative_iri(opts = {})
        RDF::URI(expand_iri_template(iri_opts.merge(opts)))
      end

      # @return [String, Symbol]
      def route_fragment; end

      private

      # @return [String]
      def expand_canonical_iri_template(args = {})
        canonical_iri_template.expand(args)
      end

      # @return [String]
      def expand_iri_template(args = {})
        iri_template.expand(args)
      end

      # @return [RDF::URI]
      def iri_with_root(root_relative_iri)
        iri = root_relative_iri.dup
        iri.scheme = LinkedRails.scheme
        iri.host = LinkedRails.host
        iri
      end

      # @return [URITemplate]
      def iri_template
        self.class.iri_template
      end

      # @return [URITemplate]
      def canonical_iri_template
        self.class.canonical_iri_template || iri_template
      end

      # @return [URITemplate]
      def iri_template_expand_path(template_base, path)
        tokens = template_base.tokens

        ind = tokens.find_index do |t|
          t.is_a?(URITemplate::RFC6570::Expression::FormQuery) || t.is_a?(URITemplate::RFC6570::Expression::Fragment)
        end

        prefix = ind ? tokens[0...ind] : tokens
        suffix = ind ? tokens[ind..-1] : []
        URITemplate.new([prefix, path, suffix].flatten.join)
      end

      # @return [URITemplate]
      def iri_template_with_fragment(template_base, fragment)
        URITemplate.new("#{template_base.to_s.sub(/{#[\w]+}/, '').split('#').first}##{fragment}")
      end

      module ClassMethods
        def iri
          @iri ||= iri_namespace[name.demodulize]
        end

        def iri_namespace
          superclass.try(:iri_namespace) ||
            (parents.include?(LinkedRails) ? LinkedRails::NS::ONTOLA : LinkedRails.app_ns)
        end

        def iri_template
          @iri_template ||= URITemplate.new("/#{route_key}{/id}{#fragment}")
        end

        def canonical_iri_template; end

        delegate :route_key, to: :model_name
      end
    end
  end
end
