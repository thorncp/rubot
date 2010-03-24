require "fileutils"
require "extensions/string"

def init(name)
  if Dir.exist? name
    puts "directory '#{name}' already exists"
    return
  end
  
  template_dir = File.join(File.dirname(__FILE__), "template")
  
  FileUtils.cp_r(template_dir, name)
  
  dir_structure = %w{resources commands listeners runners}
  
  # for some reason gem doesn't include empty folders during the install.
  # this is to make sure these directories exist
  dir_structure.each do |dir|
    FileUtils.mkdir File.join(name, dir) unless File.exist? File.join(name, dir)
  end
end

def generate_command(name)
  generate("commands", name)
end

def generate_listener(name)
  generate("listeners", name)
end

def generate_runner(name)
  generate("runners", name)
end

def generate(template, name)
  filename = File.join(template, "#{name.underscore}.rb")
  puts "file '#{filename}' already exists" and return if File.exist?(filename)
  
  template_file = File.join(File.dirname(__FILE__), "generators", "#{template}.template")
  source = IO.read(template_file).gsub(/--NAME--/, name.camelize)
  File.open(filename, "w") {|file| file.write(source)}
end
