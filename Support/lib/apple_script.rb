module AppleScript
	class Script
		attr_reader :lines
		def initialize
			@lines = []
			@prefix = ""
		end
		
		def tell(noun, which, &block)
			self << %Q{tell #{noun} "#{which}"}
			self.indent
			yield self
			self.outdent
			self << %Q{end tell}
			self
		end

		def method_missing(method, *args, &block)
			method_name = method.to_s
			if noun = method_name[/^tell_(\w+)$/, 1]
				tell(noun, *args, &block)
			elsif args.empty?
				self << method_name
			elsif args.size == 1 and property = method_name[/^(\w+)=$/, 1]
				self[property] = args.first
			elsif args.size == 1
				self << %Q{#{method_name} #{args.first}}
			else
				super
			end
		end

		def <<(line)
			self.lines << self.prefix + line
		end
		
		
		def []=(key, value)
			self << %Q{set #{key} to #{value}}
		end
		
		def [](key)
			key
		end
		
		
		def to_s
			self.lines.join($/)
		end
		
		def to_command
			%Q{osascript <<END_APPLESCRIPT} + $/ + self.to_s + $/ + %Q{END_APPLESCRIPT}
		end

		def run
			case result = %x{#{self.to_command}}.strip
			when "true"
				true
			when "false"
				false
			else
				result
			end
		end
		
	protected
		
		attr_accessor :prefix
		
		def indent
			self.prefix += "	"
		end
		
		def outdent
			self.prefix.chop!
		end
	end
end