class InputSourcesController < ApplicationController
  before_filter :load_input_source, :except => [:new, :create, :find]
  before_filter :load_republished_feed, :only => [:new, :create]

  access_control do
    allow all, :to => [:show, :find]
    allow :owner, :of => :republished_feed, :to => [:new, :create]
    allow :owner, :of => :input_source, :to => [:edit, :update, :destroy]
    allow :superadmin, :input_source_admin
  end

  def new
    @input_source = InputSource.new(:republished_feed_id => @republished_feed.id)
  end

  def create
    @input_source = InputSource.new(:republished_feed_id => @hub.id)
    @republished_feed.attributes = params[:republished_feed]
    respond_to do|format|
      if @republished_feed.save
        current_user.has_role!(:owner, @republished_feed)
        current_user.has_role!(:creator, @republished_feed)
        flash[:notice] = 'Created a new republished feed'
        format.html{redirect_to :action => :show, :id => @republished_feed.id}
      else
        flash[:error] = 'Could not add that republished feed'
        format.html {render :action => :new}
      end
    end
  end

  def find
    #Here's where we'll return a json object of possible feed sources.

    @search = Sunspot.new_search Feed, FeedItem, FeedItemTag

    @search.build do
      text_fields do
        any_of do
          with(:description).starting_with(params[:q])
          with(:content).starting_with(params[:q])
          with(:title).starting_with(params[:q])
          with(:tag).starting_with(params[:q])
          with(:authors).starting_with(params[:q])
        end
      end
    end

    @search.execute

    respond_to do|format|
      format.html{
        if request.xhr?
          render :partial => 'shared/search_results/list', :object => @search, :layout => false
        else
          render
        end
      }
      format.json{ render :json => @search }
    end
    

  end

  def edit
  end

  def destroy
  end

  def show
  end

  private

  def load_republished_feed
    republished_feed_id = (params[:input_source].blank?) ? params[:republished_feed_id] : params[:input_source][:republished_feed_id]
    @republished_feed = RepublishedFeed.find(republished_feed_id)
  end

  def load_input_source
    @input_source = InputSource.find(params[:id])
  end

end
