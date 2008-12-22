def with(object, &block)
	yield object if object
end


module Xcode
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
			%x{osascript -e 'tell application "Xcode" to open POSIX file "#{self.path}"'}
		end


		def build
			%x{osascript -e 'tell application "Xcode" to tell project "#{self.name}" to build'}
		end

		def run
			%x{osascript -e 'tell application "Xcode"' -e 'activate' -e 'tell project "#{self.name}" to launch' -e 'end tell' &}
		end

		def clean
			%x{osascript -e 'tell application "Xcode" to tell project "#{self.name}" to clean' &}
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
		# TODO: add it in alphabetical order?
		# TODO: give the file reference utf8 encoding?
		def <<(paths)
			paths = [paths] unless paths.is_a? Array
			commands = []
			paths.each do |path|
				name = File.basename(path)
				commands << %Q{-e 'set file_path to "#{path}" as POSIX file as alias'}
				commands << %Q{-e 'make new file reference at end of group "#{self.name}" with properties {full path:file_path, name:name of (info for file_path)}'}
				unless File.extname(name) == ".h"
					commands << %Q{-e 'set compile_id to (id of compile sources phase of active target)'}
					commands << %Q{-e 'add file reference (name of (info for file_path)) to (build phase id compile_id) of active target'}
				end
			end
			%x{osascript -e 'tell application "Xcode"' -e 'tell project "#{self.project.name}"' #{commands.join(" ")} -e 'end tell' -e 'end tell'}
			# paths.collect { |path| File.basename path }.join(", ")
		end
	end
end