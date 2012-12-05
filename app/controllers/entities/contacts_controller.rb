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

class ContactsController < EntitiesController
  before_filter :get_users, :only => [ :new, :create, :edit, :update ]
  before_filter :get_accounts, :only => [ :new, :create, :edit, :update ]

  # GET /contacts
  #----------------------------------------------------------------------------
  def index
    @last_query = params.select { |k,v| k == 'q' or k == 'query' }
    @contacts = get_contacts(:page     => params[:page],
                             :per_page => params[:per_page])
    if params.has_key?(:email)
      @contacts = Contact.find_by_email(params[:email])
      respond_with @contacts do |format|
        format.json { render :json =>
          @contacts.nil? ? [] : @contacts.to_json(:include => [:account, :business_address, :title_groups]) }
      end
    elsif params.has_key?(:contact_report)
        @contacts = Contact
                        .select("contacts.id, contacts.first_name, contacts.last_name, contacts.email, contacts.updated_at, contacts.status__c, contacts.phone, " +
                                "accounts.id AS account_id, accounts.name AS account_name, accounts.status__c AS account_status, accounts.corbil__c AS account_corbil")
                        .joins(:account, :title_groups)
                        .where("contacts.status__c = 'Active' " + 
                               "AND (accounts.name = 'APEX CLEARING CORPORATION (Internal)' " + 
                                    "OR (accounts.category = 'Correspondent' AND accounts.status__c = 'Active'))")
                        .uniq
        respond_with @contacts do |format|
            format.json { render :json => @contacts ? @contacts.to_json({
                                                                          :methods => :last_modified_date,
                                                                          :except  => :updated_at,
                                                                          :include => {
                                                                            :title_groups => {
                                                                                :include => {
                                                                                    :accounts => {
                                                                                        :only => [ :branch_code__c ]
                                                                                    },
                                                                                    :titles => {
                                                                                        :only => [ :name ]
                                                                                    }
                                                                                },
                                                                                :except => [ :created_at, :deleted_at, :updated_at ]
                                                                            }
                                                                          }
                                                                        }) : [] }
        end
    elsif params.has_key?(:email_list)
      @contacts = get_contacts(:page => 1, :per_page => 'all')
      render :text => @contacts.map(&:email).join("; ")
    else
      #For reasons unknown, localtion must equal nil to avoid an exception from respond_with
      respond_with @contacts, :location => nil do |format|
        format.xls { render :layout => 'header' }
      end
    end
  end

  # GET /contacts/1
  #----------------------------------------------------------------------------
  def show
    respond_with(@contact) do |format|
      format.html do
        @stage = Setting.unroll(:opportunity_stage)
        @comment = Comment.new
        @timeline = timeline(@contact)
      end
    end
  end

  # GET /contacts/new
  #----------------------------------------------------------------------------
  def new
    @contact.attributes = {:user => current_user, :access => Setting.default_access, :assigned_to => nil}
    @account = Account.new(:user => current_user)

    if params[:related]
      model, id = params[:related].split('_')
      if related = model.classify.constantize.my.find_by_id(id)
        instance_variable_set("@#{model}", related)
      else
        respond_to_related_not_found(model) and return
      end
    end

    respond_with(@contact)
  end

  # GET /contacts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    @account = @contact.account || Account.new(:user => current_user)
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Contact.my.find_by_id($1) || $1.to_i
    end

    respond_with(@contact)
  end

  # POST /contacts
  #----------------------------------------------------------------------------
  def create
    @comment_body = params[:comment_body]
    respond_with(@contact) do |format|
      if @contact.save_with_account_and_permissions(params)
        @contact.add_comment_by_user(@comment_body, current_user)
        @contacts = get_contacts if called_from_index_page?
      else
        unless params[:account][:id].blank?
          @account = Account.find(params[:account][:id])
        else
          if request.referer =~ /\/accounts\/(.+)$/
            @account = Account.find($1) # related account
          else
            @account = Account.new(:user => current_user)
          end
        end
        @opportunity = Opportunity.my.find(params[:opportunity]) unless params[:opportunity].blank?
      end
    end
  end

  # PUT /contacts/1
  #----------------------------------------------------------------------------
  def update
    respond_with(@contact) do |format|
      unless @contact.update_with_account_and_permissions(params)
        @users = User.except(current_user)
        if @contact.account
          @account = Account.find(@contact.account.id)
        else
          @account = Account.new(:user => current_user)
        end
      end
    end
  end

  # DELETE /contacts/1
  #----------------------------------------------------------------------------
  def destroy
    @contact.destroy

    respond_with(@contact) do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
    end
  end

  # PUT /contacts/1/attach
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :attach

  # POST /contacts/1/discard
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :discard

  # POST /contacts/1/add_title_group
  #----------------------------------------------------------------------------
  def add_title_group
    @title_group = @contact.title_groups.create
    respond_with(@contact)
  end

  # POST /contacts/auto_complete/query                                     AJAX
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :auto_complete

  # GET /contacts/options                                                  AJAX
  #----------------------------------------------------------------------------
  def options
    unless params[:cancel].true?
      @per_page = current_user.pref[:contacts_per_page] || Contact.per_page
      @outline  = current_user.pref[:contacts_outline]  || Contact.outline
      @sort_by  = current_user.pref[:contacts_sort_by]  || Contact.sort_by
      @naming   = current_user.pref[:contacts_naming]   || Contact.first_name_position
    end
  end

  # POST /contacts/redraw                                                  AJAX
  #----------------------------------------------------------------------------
  def redraw
    current_user.pref[:contacts_per_page] = params[:per_page] if params[:per_page]
    current_user.pref[:contacts_outline]  = params[:outline]  if params[:outline]

    # Sorting and naming only: set the same option for Leads if the hasn't been set yet.
    if params[:sort_by]
      current_user.pref[:contacts_sort_by] = Contact::sort_by_map[params[:sort_by]]
      if Lead::sort_by_fields.include?(params[:sort_by])
        current_user.pref[:leads_sort_by] ||= Lead::sort_by_map[params[:sort_by]]
      end
    end
    if params[:naming]
      current_user.pref[:contacts_naming] = params[:naming]
      current_user.pref[:leads_naming] ||= params[:naming]
    end
    @contacts = get_contacts(:page => 1) # Start on the first page.
    render :index
  end

  def bulk_comment
    @contacts = get_list_of_records(:page => 1, :per_page => 'all')
    @contacts.each do |contact|
      @comment = Comment.new(params[:comment].merge(:commentable_id => contact.id))
      model, id = @comment.commentable_type, @comment.commentable_id
      unless model.constantize.my.find_by_id(id)
        #respond_to_related_not_found(model.downcase) and return
        render :text => 'error: could not find id '+id.to_s+' in model '+model.to_s and return
      end
      @comment.without_versioning do
        @comment.save
      end
    end
    flash[:notice] = "Notes posted successfully to current list of contacts"
    redirect_to contacts_path
  end

  private
  #----------------------------------------------------------------------------
  alias :get_contacts :get_list_of_records

  #----------------------------------------------------------------------------
  def get_accounts
    @accounts = Account.my.order('name')
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      if called_from_index_page?
        @contacts = get_contacts
        if @contacts.blank?
          @contacts = get_contacts(:page => current_page - 1) if current_page > 1
          render :index and return
        end
      else
        self.current_page = 1
      end
      # At this point render destroy.js.rjs
    else
      self.current_page = 1
      flash[:notice] = t(:msg_asset_deleted, @contact.full_name)
      redirect_to contacts_path
    end
  end
end
