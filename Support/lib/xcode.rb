require "apple_script"

def with(object, &block)
	yield object if object
end

class Symbol
	def to_proc
		proc { |object, *args| object.send self, *args }
	end
end


module Xcode
	# TODO: provide access to a list of targets
	class Project
		def self.select_project
			if ENV['TM_XCODE_PROJECT']
				if File.exists? ENV['TM_XCODE_PROJECT']
					Project.new ENV['TM_XCODE_PROJECT']
				else
					puts "TM_XCODE_PROJECT didn’t point at a project."
					nil
				end
			else
				if project = Project.find(ENV['TM_PROJECT_DIRECTORY'])
					project
				else
					puts "Couldn’t find a project in #{ENV['TM_PROJECT_DIRECTORY']}. Try setting TM_XCODE_PROJECT."
				end
			end
		end

		def self.find(within = ".")
			if path = Dir["#{within}/*.xcodeproj"].first
				Project.new(path)
			end
		end

		attr_reader :name, :path

		def initialize(path)
			@path = path
			@name = Project.name_for_path(@path)
		end


		def open
			AppleScript::Script.new.tell_application "Xcode" do |xcode|
				xcode.open %Q{POSIX file "#{self.path}"}
			end.run
		end


		def build
			AppleScript::Script.new.tell_application "Xcode" do |xcode|
				xcode.tell_project self.name, &:build
			end.run
		end

		def run
			AppleScript::Script.new.tell_application "Xcode" do |xcode|
				xcode.activate
				xcode.tell_project self.name, &:launch
			end.run
		end

		def clean
			AppleScript::Script.new.tell_application "Xcode" do |xcode|
				xcode.tell_project self.name, &:clean
			end.run
		end


		def groups
			GroupProxy.new(self)
		end


		private
		def self.name_for_path(path)
			File.basename(path, ".xcodeproj")
		end
	end


	class GroupProxy
		attr_reader :project

		def initialize(project)
			@project = project
		end


		def [](name)
			Group.new(project, name)
		end
	end

	class Group
		attr_reader :name, :project

		def initialize(project, name)
			@project = project
			@name = name
		end


		# add the files to this group in the project
		def <<(*paths)
			paths.flatten!
			AppleScript::Script.new.tell_application "Xcode" do |xcode|
				xcode.tell_project self.project.name do |project|
					paths.each do |path|
						project.file_path = %Q{"#{path}" as POSIX file as alias}
						project << %Q{make new file reference at end of group "#{self.name}" with properties {full path:file_path, name:name of (info for file_path)}}
						unless File.extname(path) == ".h"
							project.compile_id = %Q{id of compile sources phase of active target}
							project << %Q{add file reference (name of (info for file_path)) to (build phase id compile_id) of active target}
						end
					end
				end
			end.run
		end
	end
end