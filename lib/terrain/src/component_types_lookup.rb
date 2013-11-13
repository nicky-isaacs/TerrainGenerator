class ComponentTypesLookup


	class << self

		def lookup(types)
			
		end

		private

		def lookup_table
			{
				'mult' => [ %w(x y z w b), %w(x y z w) ],
				'div' => [%w(x y z w b), %w(x y z w)],
				'add' => [%w(x y z w a b c d), %w(x y z w)]
				'sub' => [%w(x y z w a b c d), %w(x y z w)]
				'value' => [ [], ['v'] ],
				'exp' => [ %w(x y z w e), %w(x y z w)],
			}
		end

	end

end
