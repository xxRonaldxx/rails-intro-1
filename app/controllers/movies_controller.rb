class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
	
    # in the case incoming URI is lacking the right params[] need to fill them from session[]
    if session[:sort] != params[:sort] || session[:ratings] != params[:ratings] 
      params[:sort] ||= session[:sort]
      session[:sort] = params[:sort]
      params[:ratings] ||= session[:ratings]
      session[:ratings] = params[:ratings]
      flash.keep
      redirect_to movies_path(params)
    end

	# create an array of all ratings using a class method defined in movie.rb
    @all_ratings = Movie.rating_list
    
    # Checkbox code - used in view file: index.html.haml
    #  When ratings params are passed (some boxes are unchecked)      
    if params[:ratings] 
      # create a hash with all keys being false  
      @check = Hash[Movie.rating_list.collect {|r| [r,false]}]
      # then merge with the passed params, changing the checked ones ("1") to true
      #@check = @check.merge!(params[:ratings].each_key {|k|  params[:ratings][k] = true})
      # note: able to shorten the above by changing the views check_box_tag default from 1 to true
      @check = @check.merge!(params[:ratings])
    else
      # check all boxes by default if no params are passed
      @check = Hash[Movie.rating_list.collect {|r| [r,true]}]
    end

    # gets all the movies from the database
    @movies = Movie.scoped

    # restrict the query based on the rating boxes the user has checked
    @movies = @movies.where(:rating => params[:ratings].keys) if params[:ratings]

    # handle the events when the title and release dates need sorted
    if params['sort']
      @movies = @movies.order(params['sort'])
      instance_variable_set("@" + params['sort'], 'hilite')
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
