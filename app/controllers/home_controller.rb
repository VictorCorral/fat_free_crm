class HomeController < ApplicationController
  before_filter :require_user, :except => [ :toggle_form_section ]
  before_filter "set_current_tab(:home)", :except => [ :toggle_form_section ]
  
  #----------------------------------------------------------------------------
  def index
  end
  
  # Ajax PUT /toggle_form_section
  #----------------------------------------------------------------------------
  def toggle_form_section
    render :update do |page|
      if params[:visible] == "false"
        page["#{params[:id]}_arrow"].replace_html "&#9660;"
        callback = "beforeStart"
      else
        page["#{params[:id]}_arrow"].replace_html "&#9658;"
        callback = "afterFinish"
      end
      page << "Effect.toggle('#{params[:id]}', 'slide', { duration: 0.25, #{callback}: function() { $('#{params[:id]}_intro').toggle(); } });"
    end
  end

end
