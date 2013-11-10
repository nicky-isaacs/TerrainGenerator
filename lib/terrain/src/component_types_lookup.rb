class ComponentTypesLookup


	class << self

		def lookup(types)
			
		end

		private

		def lookup_table
			{
				'mult' => [ %w(x y z w b), %w(x, y, z, w) ], # creates array of ['x', 'y', 'z', 'w', 'b']				
				'div' => [%w(), %w()],
				'value' => [ [], ['v'] ],
				'exp' => [ %w(x y z w e), %w(x y z w)]
			}
		end

	end

end
