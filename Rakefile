require 'rake/clean'

CC = 'clang'
CXX = 'clang++'
LD = CC

PRODUCTS = {
  # exe => src
  :desc => 'example/desc.m',
  :'long-desc' => 'example/long-desc.m',
  :spiffy => 'example/spiffy.m',
  :'chocolat-app' => 'example/chocolat-app.m',
}

CFLAGS = [
  '-g',
  '-DDEBUG',
  '-std=c99',
  '-I ArgumentParser',
  '-I Pods/Headers/CoreParse',
  '-include example/example-Prefix.pch',
].join(' ')

LIBS = [
  '-framework Foundation'
].join(' ')

OBJC_SOURCES = FileList['ArgumentParser/*.m', 'example/*.m']
OBJC_SOURCES_NO_ARC = FileList['Pods/CoreParse/CoreParse/**/*.m']
O_FILES = OBJC_SOURCES.ext('.o') + OBJC_SOURCES_NO_ARC.ext('.o')

rule '.o' => ['.m'] do |t|
  arc_setting = if OBJC_SOURCES.include?(t.source)
  				  '-fobjc-arc'
  				elsif OBJC_SOURCES_NO_ARC.include?(t.source)
  				  '-fobjc-no-arc'
  				else
  				  ''
  				end
  sh "#{CC} #{t.source.gsub(' ','\ ')} #{CFLAGS} #{arc_setting} -c -o#{t.name.gsub(' ', '\ ')}"
end

[*OBJC_SOURCES, *OBJC_SOURCES_NO_ARC].each do |src|
  file src.ext('.o') => src
end

PRODUCTS.each do |product, source|
  object_files = O_FILES - (PRODUCTS.values - [source]).map{|f|f.ext('.o')}
  desc "Build executable for '#{product}'"
  file product => object_files do |t|
    sh "#{LD} #{LIBS} #{object_files.map{|object_file|object_file.gsub(' ', '\ ')}} -o bin/#{t.name.gsub(' ', '\ ')}"
  end
end
  
CLEAN.include("**/*.o")
CLOBBER.include(PRODUCTS.keys)
  
desc 'build them all!'
task :all => PRODUCTS.keys
  
task :default => 'all'
