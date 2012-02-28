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
  '-DDEBUG',
  '-std=c99',
  '-fobjc-arc',
  '-I ./',
  '-g'
].join(' ')

LIBS = [
  '-framework Foundation'
].join(' ')

OBJC_SOURCES = FileList['*.m', 'example/*.m']
O_FILES = OBJC_SOURCES.ext('.o')

rule '.o' => ['.m'] do |t|
  sh "#{CC} #{t.source} #{CFLAGS} -c -o #{t.name}"
end

OBJC_SOURCES.each do |src|
  file src.ext('.o') => src
end

PRODUCTS.each do |product, source|
  object_files = O_FILES - (PRODUCTS.values - [source]).map{|f|f.ext('.o')}
  desc "Build executable for '#{product}'"
  file product => object_files do |t|
    sh "#{LD} #{LIBS} #{object_files} -o bin/#{t.name}"
  end
end
  
CLEAN.include("**/*.o")
CLOBBER.include(PRODUCTS.keys)
  
desc 'build them all!'
task :all => PRODUCTS.keys
  
task :default => 'all'