# frozen_string_literal: true

require 'kaitai/struct/visualizer/ksy_compiler'

module Kaitai::Struct::Visualizer
  describe KSYCompiler do
    before(:context) { @old_pwd = Dir.pwd; Dir.chdir('spec/formats_err') }
    after(:context) { Dir.chdir(@old_pwd) }

    out = StringIO.new
    c = KSYCompiler.new({}, out)

    context '#resolve_yaml_path' do
      it 'resolves YAML paths generated by ksc in mappings' do
        node = c.resolve_yaml_path('attr_bad_if2.ksy', %w[types foo_type instances foo if])
        expect(node.start_line).to eq 17
        expect(node.start_column).to eq 12
      end

      it 'resolves YAML paths generated by ksc in sequences' do
        node = c.resolve_yaml_path('attr_bad_key.ksy', %w[seq 1 blah])
        expect(node.start_line).to eq 11
        expect(node.start_column).to eq 10
      end
    end

    context '#report_err' do
      it 'formats attr_bad_if2' do
        err_str = '[{"file": "attr_bad_if2.ksy",
          "message": "invalid type: expected boolean, got CalcIntType",
          "path": ["types", "foo_type", "instances", "foo", "if"]}]'
        err = JSON.parse(err_str)
        c.report_err(err)
        expect(out.string).to eq(
          "Error:\n\n" \
          "attr_bad_if2.ksy:18:12:/types/foo_type/instances/foo/if: invalid type: expected boolean, got CalcIntType\n"
        )
      end
    end
  end
end
