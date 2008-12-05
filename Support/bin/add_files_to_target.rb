#!/usr/bin/env ruby

require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/detach.rb"
$: << "#{ENV['TM_BUNDLE_SUPPORT']}/lib" if ENV.has_key?('TM_BUNDLE_SUPPORT')
require "project"

=begin
tell application "Xcode"
    tell project "SampleApp"
        make new file reference at end of group "Classes" with properties {full path:"/Volumes/Local/bar.m", name:"bar.m"}
    end tell
end tell
=end
