module TerrainLib
  class ComponentTypesLookup
    class << self

      def lookup(types)

      end

      def types
        lookup_table.keys
      end

      def lookup_table
        {
            'result' => [['v'], ['z']],
            'value' => [[], ['v']],
            'mult' => [%w(x y z w b), %w(x y z w)],
            'div' => [%w(x y z w b), %w(x y z w)],
            'add' => [%w(x y z w a b c d), %w(x y z w)],
            'sub' => [%w(x y z w a b c d), %w(x y z w)],
            'exp' => [%w(x y z w e), %w(x y z w)],
            'sqrt' => [%w(x y z w), %w(x y z w)],
            'log' => [%w(x y z w b), %w(x y z w)],
            'random' => [%w(lo hi sd), %w(x y z w)],
            'perlin' => [%w(x y z sd), ['v']],
            'simplex' => [%w(x y z sd), %w(v)],
            'mag' => [%w(x y z w), ['m']],
            'norm' => [%w(x y z w), %w(x y z w)],
            'resize' => [%w(x y z w m), %w(x y z w)]
        }
      end

    end
  end
end
