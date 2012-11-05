require 'rubygems'
require 'sinatra'
require './students'

get "/" do
	@students = Student.all
	erb :index
end

get "/:id" do |id|
	if (id.to_i > 0)
		@student = Student.find(id.to_i)
	end

	if (@student.nil?)
		#redirect somewhere
		@student = "no student"
		erb :error_page
	else
		erb :student
	end

end

