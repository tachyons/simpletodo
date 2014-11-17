# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	def javascript(*args)
	  content_for(:head) { javascript_include_tag(*args) }
	end
end
