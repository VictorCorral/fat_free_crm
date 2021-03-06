# Fat Free CRM
# Copyright (C) 2008-2011 by Michael Dvorkin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

class AccountsController < EntitiesController
  before_filter :get_data_for_sidebar, :only => :index
  
  # GET /accounts
  #----------------------------------------------------------------------------
  def index
      # Get /accounts.json?email=person@example.com
      if params.has_key?(:email)
        respond_to do |format|
          @accounts = Account.find_by_email(params[:email])
          format.json { render :json =>
            @accounts.nil? ? [] : @accounts.to_json(:include => [:contacts, :billing_address, :shipping_address])}
        end
      # GET /accounts.json?since=yyyy-MM-ddThh:mm:ss
      elsif params.has_key?(:since)
        respond_to do |format|
          begin
            Time.zone = "Central Time (US & Canada)"
            dt = Time.zone.local_to_utc(params[:since].to_datetime)
          rescue ArgumentError, NoMethodError
            format.json { render :json => 'Invalid DateTime' }
          else
            @accounts = Account.since(dt)
            format.json { render :json => @accounts.nil? ? [] : @accounts.to_json }
          end
        end

      #GET /accounts.json?correspondent_listing
      elsif params.has_key?(:correspondent_listing)
        @accounts = Account.select("id, name, ridge_branch__c, mpids__c, corbil__c, status__c, firm__c, " +
                                   "correspondentid__c, category, ridge_correspondent__c, owdb_corres_id_n__c, " +
                                   "relationship_manager__c, rm_email__c, r_base_rate_code__c, r_bps__c, " +
                                   "r_dk_rate__c, r_daily_factor__c, r_dk_fee__c")
                           .where(:category => "Correspondent",
                                  :firm__c  => "10 (Client 10)")
        respond_with @accounts do |format|
            format.json { render :json => @accounts ? @accounts.to_json() : [] }
        end

      #GET /accounts.json?branch_listing
      elsif params.has_key?(:branch_listing)
        @accounts = Account.select("id, name, corbil__c, status__c, mpids__c, firm__c, category, " +
                                   "ridge_branch__c, office_mpid__c")
                           .where(:category => "Branch")
        respond_with @accounts do |format|
            format.json { render :json => @accounts ? @accounts.to_json() : [] }
        end

      # GET /accounts
      else
        @accounts = get_accounts(:page => params[:page])
        respond_with @accounts, :location => nil do |format|
          format.xls { render :layout => 'header' }
      end
    end
  end

  # GET /accounts/1
  #----------------------------------------------------------------------------
  def show
    respond_with(@account) do |format|
      format.html do
        @stage = Setting.unroll(:opportunity_stage)
        @comment = Comment.new
        @timeline = timeline(@account)
      end
    end
  end

  # GET /accounts/new
  #----------------------------------------------------------------------------
  def new
    @account.attributes = {:user => current_user, :access => Setting.default_access, :assigned_to => nil}

    if params[:related]
      model, id = params[:related].split('_')
      instance_variable_set("@#{model}", model.classify.constantize.find(id))
    end

    respond_with(@account)
  end

  # GET /accounts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Account.my.find_by_id($1) || $1.to_i
    end

    respond_with(@account)
  end

  # POST /accounts
  #----------------------------------------------------------------------------
  def create
    @comment_body = params[:comment_body]
    respond_with(@account) do |format|
      if @account.save
        @account.add_comment_by_user(@comment_body, current_user)
        # None: account can only be created from the Accounts index page, so we
        # don't have to check whether we're on the index page.
        @accounts = get_accounts
        get_data_for_sidebar
      end
    end
  end

  # PUT /accounts/1
  #----------------------------------------------------------------------------
  def update
    respond_with(@account) do |format|
      if @account.update_attributes(params[:account])
        get_data_for_sidebar
      else
        @users = User.except(current_user) # Need it to redraw [Edit Account] form.
      end
    end
  end

  # DELETE /accounts/1
  #----------------------------------------------------------------------------
  def destroy
    @account.destroy

    respond_with(@account) do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
    end
  end

  # PUT /accounts/1/attach
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :attach

  # PUT /accounts/1/discard
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :discard

  # POST /accounts/auto_complete/query                                     AJAX
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :auto_complete

  # GET /accounts/options                                                  AJAX
  #----------------------------------------------------------------------------
  def options
    unless params[:cancel].true?
      @per_page = current_user.pref[:accounts_per_page] || Account.per_page
      @outline  = current_user.pref[:accounts_outline]  || Account.outline
      @sort_by  = current_user.pref[:accounts_sort_by]  || Account.sort_by
    end
  end

  # POST /accounts/redraw                                                  AJAX
  #----------------------------------------------------------------------------
  def redraw
    current_user.pref[:accounts_per_page] = params[:per_page] if params[:per_page]
    current_user.pref[:accounts_outline]  = params[:outline]  if params[:outline]
    current_user.pref[:accounts_sort_by]  = Account::sort_by_map[params[:sort_by]] if params[:sort_by]
    @accounts = get_accounts(:page => 1)
    render :index
  end

  # POST /accounts/filter                                                  AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:accounts_filter] = params[:category]
    @accounts = get_accounts(:page => 1)
    render :index
  end

private

  #----------------------------------------------------------------------------
  alias :get_accounts :get_list_of_records

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      @accounts = get_accounts
      get_data_for_sidebar
      if @accounts.empty?
        @accounts = get_accounts(:page => current_page - 1) if current_page > 1
        render :index and return
      end
      # At this point render default destroy.js.rjs template.
    else # :html request
      self.current_page = 1 # Reset current page to 1 to make sure it stays valid.
      flash[:notice] = t(:msg_asset_deleted, @account.name)
      redirect_to accounts_path
    end
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    @account_category_total = Hash[
      Setting.account_category.map do |key|
        [ key, Account.my.where(:category => key.to_s).count ]
      end
    ]
    categorized = @account_category_total.values.sum
    @account_category_total[:all] = Account.my.count
    @account_category_total[:other] = @account_category_total[:all] - categorized
  end
end
