class Movie < ActiveRecord::Base
  attr_accessible :title, :rating, :description, :release_date

  def self.rating_list
	return Movie.select(:rating).map(&:rating).uniq.sort
  end
end
