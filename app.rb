require 'rubygems'
require 'sinatra'
require './students'

get "/" do
	@students = Student.all
	erb :index
end

get "/:user" do |user|
	@student = Student.find_by_slug(user)

	if (@student.nil?)
		#redirect somewhere
		@student = "no student"
		erb :error_page
	else
		erb :student
	end

end

