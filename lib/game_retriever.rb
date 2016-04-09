require "open-uri"
require "chronic"
require "nokogiri"

class GameRetriever
  def initialize(game_id)
    @gid = game_id
  end

  def run
    puts "* retrieving game: #{gid}"
    gameurl = 'http://www.j-archive.com/showgame.php?game_id='+gid.to_s
    game = Nokogiri::HTML(open(gameurl))

    ## OK, were going to do this twice, once for each round
    questions = game.css("#jeopardy_round .clue")

    #Define vars
    var_question = ''
    var_answer = ''
    var_value = ''
    var_category = ''
    var_airdate = nil


    #get an array of the category names, we'll need these later
    categories = game.css('#jeopardy_round .category_name')
    categoryArr = Array.new
    categories.each do |c|
      categoryName = c.text().downcase
      categoryArr.push(Category.find_or_create_by_title(categoryName))
    end

    #get the airdate
    ad = game.css('#game_title h1').text().split(" - ")
    if(!ad[1].nil?)
      var_airdate = Chronic.parse(ad[1])
      puts "Working on: " + ad[1]
    end

    questions.each do |q|

      qdiv = q.css('div').first

      if(!qdiv.nil?)
        qdivMouseover = qdiv.attr('onmouseover')
        #=========== Set Answer =============
        answermatch = /ponse">(.*)<\/e/.match(qdivMouseover)
        var_answer = answermatch.captures[0].to_s

        #puts var_answer
        var_question = q.css('.clue_text').text()
        index = q.xpath('count(preceding-sibling::*)').to_i
        var_category = categoryArr[index]
        var_value = q.css('.clue_value').text[/[0-9\.]+/]

        newClue = Clue.where(
          :question => var_question,
          :answer => var_answer,
          :category => var_category,
          :value => var_value,
          :airdate => var_airdate,
          :game_id => gid
        ).first_or_create
      end
    end
  end

  private

  attr_reader :gid
end
