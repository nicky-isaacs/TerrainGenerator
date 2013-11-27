module TerrainLib
  class ComponentTypesLookup
    class << self

      def lookup(types)

      end

      private

      def lookup_table
        {
            'mult' => [ %w(x y z w b), %w(x y z w) ],
            'div' => [%w(x y z w b), %w(x y z w)],
            'add' => [%w(x y z w a b c d), %w(x y z w)],
            'sub' => [%w(x y z w a b c d), %w(x y z w)],
            'value' => [[], ['v']],
            'exp' => [%w(x y z w e), %w(x y z w)],
            'sqrt' => [%w(x y z w), %w(x y z w)],
            'log' => [%w(x y z w b), %w(x y z w)],
            'random' => [%w(lo hi sd), %w(v sd)],
            'perlin' => [%w(x y z w sd), %w(v sd)],
            'simplex' => [%w(x y z w sd), %w(v sd)],
            'mag' => [%w(x y z w), ['m']],
            'norm' => [%w(x y z w), %w(x y z w)],
            'resize' => [%w(x y z w m), %w(x y z w)]
        }
      end

    end
  end
end
