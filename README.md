# mitab (MITab file parser)

A ruby parser for MITab file format.

#How to install ?

```sh
	gem install mitab
```

#How to use ?

```ruby
	require 'mitab'
	
	text = open(filename) { |f| f.read }
	m = Mitab::MitabParser.new(text)
	
	m.print
	puts m.mitab
	puts m.nodes
	puts m.scores
	puts m.links
```
