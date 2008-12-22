#!/usr/bin/env ruby

require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/detach.rb"
require "#{ENV['TM_SUPPORT_PATH']}/lib/ui.rb"
require "#{ENV['TM_SUPPORT_PATH']}/lib/textmate.rb"
$: << "#{ENV['TM_BUNDLE_SUPPORT']}/lib" if ENV.has_key?('TM_BUNDLE_SUPPORT')
require "project"

with Project.select_project do |project|
	TextMate.detach do
		TextMate::UI.tool_tip project.groups["Classes"] << TextMate.selected_files
	end
end