# Fat Free CRM
# Copyright (C) 2008-2010 by Michael Dvorkin
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

module AccountsHelper
  # Quick account summary for RSS/ATOM feeds.
  #----------------------------------------------------------------------------
  def summary(account)
    [ number_to_currency(account.opportunities.not_lost.map(&:weighted_amount).sum, :precision => 0),
      t(:added_by, :time_ago => time_ago_in_words(account.created_at), :user => account.user_id_full_name),
      t('pluralize.contact', account.contacts.count),
      t('pluralize.opportunity', account.opportunities.count),
      t('pluralize.comment', account.comments.count)
    ].join(', ')
  end
end
