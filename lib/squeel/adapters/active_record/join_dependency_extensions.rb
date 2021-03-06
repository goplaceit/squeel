require 'polyamorous'

module Squeel
  module Adapters
    module ActiveRecord
      module JoinDependencyExtensions

        def self.included(base)
          base.class_eval do
            alias_method_chain :build, :squeel
          end
        end

        def build_with_squeel(associations, parent = nil, join_type = Arel::InnerJoin)
          case associations
          when Nodes::Stub
            associations = associations.symbol
          when Nodes::Join
            associations = associations._join
          end

          if Nodes::KeyPath === associations
            parent ||= _join_parts.last
            associations.path.each do |key|
              parent = build(key, parent, join_type)
            end
            parent
          else
            if ::ActiveRecord::VERSION::STRING >= '4.1.0'
              build_without_squeel(associations, parent)
            else
              build_without_squeel(associations, parent, join_type)
            end
          end
        end

      end

      if defined?(::ActiveRecord::Associations::JoinDependency)
        JoinAssociation = ::ActiveRecord::Associations::JoinDependency::JoinAssociation
        JoinDependency = ::ActiveRecord::Associations::JoinDependency
      elsif defined?(::ActiveRecord::Associations::ClassMethods::JoinDependency)
        JoinAssociation = ::ActiveRecord::Associations::ClassMethods::JoinDependency::JoinAssociation
        JoinDependency = ::ActiveRecord::Associations::ClassMethods::JoinDependency
      end

      JoinDependency.send :include, Adapters::ActiveRecord::JoinDependencyExtensions

    end
  end
end
