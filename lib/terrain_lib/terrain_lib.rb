src_path = File.join( File.dirname(__FILE__), 'src')

Dir.entries(src_path).each do |f|
	f = File.join(src_path, f)
	require f if f.include? '.rb'
end
