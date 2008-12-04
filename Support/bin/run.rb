#!/usr/bin/env ruby

$: << "#{ENV['TM_BUNDLE_SUPPORT']}/lib" if ENV.has_key?('TM_BUNDLE_SUPPORT')
require "project"

with Project.select_project do |project|
	project.run
	puts "Running #{project.name}"
end