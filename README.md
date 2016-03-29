# mitab (MITab file parser)

A ruby parser for MITab file format.

#How to install ?

```sh
	gem install mitab
```

#How to use ?

```ruby
	text = open(filename) { |f| f.read }
	m = Mitab::MitabParser.new(text)
	m.print
	m.mitab
	m.nodes
	m.scores
	m.links
```
