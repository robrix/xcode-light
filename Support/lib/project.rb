def with(object, &block)
	yield object if object
end



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
	
	
	def build
		%x{osascript -e 'tell application "Xcode" to tell project "#{self.name}" to build'}
	end
	
	def run
		%x{osascript -e 'tell application "Xcode" to tell project "#{self.name}" to launch'}
	end
	
	
	private
	def self.name_for_path(path)
		File.basename(path, ".xcodeproj")
	end
end