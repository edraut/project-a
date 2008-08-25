class PagesController < ApplicationController
  before_filter :get_page

  def index
    render :action => 'show'
  end
  
  def show
  end
  
  def get_page
    @page = Page.named(params[:name])
  end
  
end