Gem::Specification.new do |s|
  s.name        = 'mitab'
  s.version     = File.read("VERSION")
  s.date        = '2016-05-04'
  s.summary     = "MITab parser"
  s.executables = ["mitab"]
  s.description = "A ruby parser for MITab file format."
  s.authors     = ["Prasun Anand"]
  s.email       = 'prasunanand.bitsp@gmail.com'
  s.files = Dir['lib/**/*.rb'] + Dir['bin/*'] 
  s.homepage    = 'https://github.com/prasunanand/mitab'
  s.license     = 'MIT'
end