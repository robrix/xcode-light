#!/usr/bin/env ruby


require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/detach.rb"
require "#{ENV['TM_SUPPORT_PATH']}/lib/ui.rb"
require "#{ENV['TM_SUPPORT_PATH']}/lib/textmate.rb"
$: << "#{ENV['TM_BUNDLE_SUPPORT']}/lib" if ENV.has_key?('TM_BUNDLE_SUPPORT')
require "xcode"

with Xcode::Project.select_project do |project|
	TextMate.detach do
		result = with(TextMate.selected_files || [ENV["TM_FILEPATH"]]) do |files|
			if files
				files_by_parent_folder = {}
				files.collect do |file|
					relative = file.sub(/^#{ENV["TM_PROJECT_DIRECTORY"]}\//, '')
					group = relative[/(.+?)\//, 1]
					files_by_parent_folder[group] = [] unless files_by_parent_folder[group]
					files_by_parent_folder[group] << file
				end
				
				files_by_parent_folder.inject("") do |memo, (group, grouped_files)|
					memo << ((project.groups[group] || project.groups["Classes"]) << grouped_files)
				end
			else
				"No files were selected, so nothing was added to the project."
			end
		end
		
		TextMate::UI.tool_tip(result)
	end
end