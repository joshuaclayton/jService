


#Arguments are seasons to grab. [1,30] grabs seasons 1 through 30
desc "hi"
task :get_clues, [:arg1,:arg2]  => :environment  do |t, args|
  require 'nokogiri'
  require 'open-uri'
  require 'chronic'
  require "game_retriever"
  require "peach"


  arg1int = args.arg1.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  arg2int = args.arg2.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  if(arg1int && arg2int)
    #get game list
    gameIds = Array.new
    puts "retrieving seasons"
    for i in args.arg1.to_i..args.arg2.to_i
      seasonsUrl = 'http://j-archive.com/showseason.php?season='+i.to_s
      seasonList = Nokogiri::HTML(open(seasonsUrl))
      linkList = seasonList.css('table td a')
      linkList.each do |ll|
        href = ll.attr('href');
        href = href.split('id=')
        hrefId = href[1]
        gameIds.push(hrefId)
      end
    end

    puts "retrieving games"
    gameIds.peach(3) do |gid|
      GameRetriever.new(gid).run
    end
  end #if
end
