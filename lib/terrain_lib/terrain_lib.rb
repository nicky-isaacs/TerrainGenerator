src_dir =  File.expand_path File.join(File.dirname(__FILE__), 'src')

Dir.entries(src_dir).each do |f|
  path = File.join(src_dir, f)
  require path if path.match /\.rb$/
end