module Mitab
  class MitabParser
   
    def initialize
      puts "lib invoked"
    end

    def self.map_pub(pubStr)
      arr = pubStr.split(':')
      {name:arr[0], value:arr[1]}
    end

    def self.map_field(fieldStr)
      textInParenthesis = /\((.*?)\)/
      textInQuotes = /\"(.*?)\"/
      if(fieldStr.match(textInQuotes).nil? || fieldStr.match(textInParenthesis).nil?)
        arr = fieldStr.split(':')
        return {name:arr[0], score:arr[1]}
      end
      {name:fieldStr.match(textInQuotes)[1], value:fieldStr.match(textInParenthesis)[1]}
    end

    def self.add_score(score, tScores)
      if( !score[:score].to_f.nan?)
        if(tScores.key?(score[:name]))
          if(tScores[score[:name]][:min].to_f > score[:score].to_f) 
            tScores[score[:name]][:min] = score[:score].to_f
          end
          if(tScores[score[:name]][:max].to_f < score[:score].to_f) 
            tScores[score[:name]][:max] = score[:score].to_f
          end
        else
            tScores[score[:name]] = {name:score[:name], min:score[:score], max:score[:score]}
        end
      end
    end

    def self.map_score(scoreStr,tScores)
      arr = scoreStr.split(':')
      score = {name:arr[0], score:arr[1]}
      self.add_score(score, tScores)
      score
    end

    def self.map_taxonomy(taxStr)
      textInTax = /\:(.*?)\(/
      if(taxStr != '-')
          return (taxStr.match(textInTax).nil?) ? taxStr.split(':')[1] : taxStr.match(textInTax)[1]
      end
    end

    def self.get_node(idStr, altIdsStr, aliasStr, taxStr)
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

    def self.parse(line, tScores)
      if (!line.is_a? String) 
        puts "MITab cannot parse line"
        return {}
      end
      fields = line.split("\t")
      if(fields.length < 15)
        puts "MITab cannot parse line"
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
        scores: fields[14].split('|').map{|x| map_score(x, tScores)}
      }



      # nodes[nodeA[:id]] = nodeA
      # nodes[nodeB[:id]] = nodeB

      return interaction, nodeA, nodeB, tScores
    end
    
    def print
      puts @mitab
    end
  end
end
