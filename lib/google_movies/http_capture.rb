# encoding: utf-8 
$:.unshift File.expand_path('../models', __FILE__)
require 'nokogiri'
require "net/http"
require "uri"
require 'movie'
require 'movie_theater'

module HttpCapture
  
  def movies_theaters(page_url)
    @http_address = URI.parse(URI.encode(page_url.strip))
    get_information(@http_address)
  end
  
  def get_information(url)
    @movies_theater = []
    @doc = page_doc(@http_address)
    @doc.search('div[@class="theater"]').each do |theater|
      movies = []
      movies = get_movies(theater)
      @movies_theater << create_movie_theater_with(theater, movies)
    end
    @movies_theater
  end
  
  private 
  
  def page_doc(uri)
    Nokogiri::HTML(Net::HTTP.get_response(uri).body)
  end

	def create_movie_theater_with(theater, movies)
		id = theater.search('div[@class="desc"]').first.attr("id").gsub("theater_", "")
		name = theater.search('h2[@class="name"]').first.content
		info = theater.search('div[@class="info"]').first.content
		GoogleMovies::MovieTheater.new(name, info, id, movies)
	end
	
	def create_movie_with(movie)
		name = movie.search('div[@class="name"]').first.search('a').first.content
		id = movie.search('div[@class="name"]').first.search('a').first.attr("href").split("&mid=")[1]
		info = movie.search('span[@class="info"]').first.content
		GoogleMovies::Movie.new(name, id, info)
	end
  
  def get_movies(theater)
    movies = []
    theater.search('div[@class="movie"]').each do |movie_document|
      movies << create_movie_with(movie_document)
    end
    movies
  end  
  
  class Client
    include HttpCapture
    
    attr_accessor :movies_theater
    
    def initialize(page_url)
      @movies_theater = movies_theaters(page_url)
    end
    
  end
end

