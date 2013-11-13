class Component < ActiveRecord::Base

	attr_accessable :lock, :input, :output

	def initialize(params={})
		if params[:output]
			@output = params[:output]
		else
			@output = nil
		end

		@input = params[:input]
	end


end
