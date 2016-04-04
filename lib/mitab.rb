require 'open-uri'
module Mitab
  class MitabParser
    attr_reader :nodes, :links, :scores, :mitab
   
    def initialize(text)
      @nodes = {}
      @links= []
      @scores = {}
      @mitab
      

      lines = text.split("\n")

      interactions = lines.map{ |l| parse(l)}
      nodeval = @nodes.values

      @links = interactions

      @mitab = {
        links: interactions,
        nodes: nodeval,
        ids: nodeval.map { |h| h[:id] },
        taxa: nodeval.reduce([]){ |union, x| union | x[:taxonomy]}.compact,
        scores: @scores.values
      }
    end

    def map_pub(pubStr)
      arr = pubStr.split(':')
      {name:arr[0], value:arr[1]}
    end

    def map_field(fieldStr)
      textInParenthesis = /\((.*?)\)/
      textInQuotes = /\"(.*?)\"/
      if(fieldStr.match(textInQuotes).nil? || fieldStr.match(textInParenthesis).nil?)
        arr = fieldStr.split(':')
        return {name:arr[0], score:arr[1]}
      end
      {name:fieldStr.match(textInQuotes)[1], value:fieldStr.match(textInParenthesis)[1]}
    end

    def add_score(score)
      if( !score[:score].to_f.nan?)
        if(@scores.key?(score[:name]))
          if(@scores[score[:name]][:min].to_f > score[:score].to_f) 
            @scores[score[:name]][:min] = score[:score].to_f
          end
          if(@scores[score[:name]][:max].to_f < score[:score].to_f) 
            @scores[score[:name]][:max] = score[:score].to_f
          end
        else
            @scores[score[:name]] = {name:score[:name], min:score[:score], max:score[:score]}
        end
      end
    end

    def map_score(scoreStr)
      arr = scoreStr.split(':')
      score = {name:arr[0], score:arr[1]}
      add_score(score)
      score
    end

    def map_taxonomy(taxStr)
      textInTax = /\:(.*?)\(/
      if(taxStr != '-')
          return (taxStr.match(textInTax).nil?) ? taxStr.split(':')[1] : taxStr.match(textInTax)[1]
      end
    end

    def get_node(idStr, altIdsStr, aliasStr, taxStr)
      geneName = /\((gene name)\)/
      geneNameSynonym = /\((gene name synonym)\)/
      textInTax = /\:(.*?)\(/
      gNameAliases = aliasStr.split("|")

      gNameStr = gNameAliases.select{ |gNameAlias| gNameAlias.match(geneName)}

      gNameStr = (gNameStr.nil?) ? gNameAliases.select{ |gNameAlias| gNameAlias.match(geneNameSynonym)} : gNameStr
      ids = idStr.split("|") + altIdsStr.split("|") + aliasStr.split("|")
      ids = ids.map{|x| map_pub(x)}
      id = ids.select{|id| id[:name] == "uniprotkb"}
      node = {
        id: ids[0][:value],
        ids: ids,
        uniprot: (id.nil?) ? '' : id,
        geneName: (gNameStr.nil?) ? '' : gNameStr.map{|gStr| gStr.match(textInTax)[1]},
        altIds: altIdsStr.split('|').map{|x| map_pub(x)},
        taxonomy: taxStr.split('|').uniq{|x| map_taxonomy(x)},
      }

    end

    def parse(line)
      if (!line.is_a? String) 
        puts 'MITab cannot parse line '
        return {}
      end
      fields = line.split("\t")
      if(fields.length < 15)
        puts "MITab cannot parse line "
        return {}
      end

      nodeA = get_node(fields[0], fields[2], fields[4], fields[9])
      nodeB = get_node(fields[1], fields[3], fields[5], fields[10])

      interaction = {
        source: nodeA[:id],
        target: nodeB[:id],
        detMethods: fields[6].split('|').map{|x| map_field(x)},
        firstAuthor: fields[7].split('|'),
        publications: fields[8].split('|').map{|x| map_field(x)},
        intTypes: fields[11].split('|').map{|x| map_field(x)},
        sourceDbs: fields[12].split('|').map{|x| map_field(x)},
        intIds: fields[13].split('|').map{|x| map_pub(x)},
        scores: fields[14].split('|').map{|x| map_score(x)},
      }



      @nodes[nodeA[:id]] = nodeA
      @nodes[nodeB[:id]] = nodeB

      interaction
    end
    
    def print
      puts @mitab
    end
  end
end
