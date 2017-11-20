require 'open-uri'
require 'json'

class WordsController < ApplicationController


  def game
    # BELOW option with consonants and vowels
    # @word_grid = []
    # # 9 times add a random capital letter to @word-grid
    # 9.times do
    #   @word_grid << ('A'..'Z').to_a.sample
    # end
    # @start_time = Time.now
    # return @word_grid
    vowels = ["A", "E", "I", "O", "U", "I", "Y"].sample(4)
    cons = Array.new(5){("A".."Z").to_a.sample} - vowels
    grid = vowels << cons
    @start_time = Time.now
    @word_grid = grid.flatten
  end

  def score
    @user_word = params[:user_word]
    start_time = Time.parse(params[:start_time])
    @duration =(Time.now - start_time).round(0)
    @grid = params[:grid].scan(/\w/)
    user_word_a = @user_word.upcase.split("")
    if word_validity(user_word_a, @grid) == false
      @result = { time: @duration, score: 0, message: "not in the grid" }
    elsif in_dictionary?(@user_word) == false
      @result = { time: @duration, score: 0, message: "not an english word" }
    else
      @result = { time: @duration, score: length_score(user_word_a) + time_score(@duration), message: "Well done!" }
    end
    # raise
    return @result

  end

  def in_dictionary?(user_word)
    url = "https://wagon-dictionary.herokuapp.com/#{user_word}"
    word_serialized = open(url).read
    JSON.parse(word_serialized)["found"]
  end

  def time_score(duration)
    time_score = 3 if (0...10).cover?(duration)
    time_score = 2 if (10...15).cover?(duration)
    time_score = 1 if (15...20).cover?(duration)
    time_score = 0 if duration >= 20
    time_score
  end

  def length_score(user_word_a)
    correspondence = { 1 => 0, 2 => 0, 3 => 1, 4 => 2, 5 => 3, 6 => 4, 7 => 5, 8 => 6, 9 => 7 }
    correspondence[user_word_a.length.to_i]
  end


  def word_validity(user_word_a, grid)
    validity = true
    user_word_a.each { |letter| validity = false if user_word_a.count(letter) > grid.count(letter) }
    return validity
  end

end
