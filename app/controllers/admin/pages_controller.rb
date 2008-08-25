class Admin::PagesController < Admin::ApplicationController
  before_filter :get_page, :except => [:index, :new, :create]
  before_filter :set_render
  
  def index
    @pages = Page.all
    render @render_key => 'index'
  end
  
  def show
  end
  
  def new
    @page = Page.new
  end
  
  def create
    @page = Page.new(params[:page])
    if @page.save
      render :action => 'edit'
    else
      render :action => 'new'
    end
  end
  
  def edit
  end
  
  def update
    @page.update_attributes(params[:page])
    render :action => 'edit'
  end
  
  protected
  
  def get_page
    @page = Page.find(params[:id])
  end
  
  def set_render
    
    if params[:partial]
      @render_key = :partial
    else
      @render_key = :action
    end
  end
end