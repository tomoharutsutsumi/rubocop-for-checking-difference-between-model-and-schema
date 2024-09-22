require 'active_support/core_ext/string'

module RuboCop
  module Cop
    module CustomCops
      class CompareConstraintsBetweenSchemaAndModel < Cop
        MSG = "Even though schema doesn't have 'null false', corresponding association doesn't also have 'optional true'".freeze

        def investigate(processed_source)
          model_file = processed_source.file_path
          return unless model_file.include?('app/models')

          has_null_false_for = check_column_has_null_false(model_file:)

          processed_source.ast.each_node(:send) do |node|
            next unless node.method_name == :belongs_to

            related_model_name = node.arguments.first.value.to_s
            if !has_null_false_for[related_model_name] && !has_optional_true?(node:)
              add_offense(node, location: :expression, message: MSG)
            end
          end
        end

        private

        def check_column_has_null_false(model_file:)
          model_name = model_file.split('/').last.sub('.rb', '')
          schema_path = File.join(Dir.pwd, 'db', 'schema.rb')
          schema = File.read(schema_path)
          has_null_false = {}
          extracted_table = schema.scan(/create_table "#{model_name}s".*?end/m).first
          if extracted_table.present?
            lines = extracted_table.split("\n")
            lines.each do |line|
              foreign_key = line.match(/t.bigint \"(\w+)_id\"/)
              if foreign_key.present?
                has_null_false[foreign_key[1]] = line.include?('null: false')
              end
            end
          end

          has_null_false
        end

        def has_optional_true?(node:)
          node.arguments.any? do |arg|
            arg.hash_type? && arg.pairs.any? do |option|
              option.key.value == :optional && option.value.true_type?
            end
          end
        end
      end
    end
  end
end
