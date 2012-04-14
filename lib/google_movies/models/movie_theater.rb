module GoogleMovies
  class MovieTheater
  
    attr_accessor :movies, :name, :address
  
    def initialize(name, address, movies = [])
      @movies = movies
      @name = name
      @address = address
    end
  end
end