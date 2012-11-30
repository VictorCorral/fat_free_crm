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

module ContactsHelper
  def remove_field_and_strikeout_label_js(builder, attribute)
    "jQuery('##{field_id_for_js(builder, attribute)}').remove(); jQuery('label[for=\"#{field_id_for_js(builder, attribute)}\"]').addClass('pending-delete'); jQuery(this).hide()"
  end

  def add_field_and_label_js(container_div_id, builder, attribute)
    "crm.insert_hidden_field_and_label('#{container_div_id}', '#{new_array_member_name_for_js(builder, attribute)}', jQuery('#_add_#{attribute.to_s}_#{container_div_id} :selected').val(), jQuery('#_add_#{attribute.to_s}_#{container_div_id} :selected').text())"
  end
  # Contact summary for RSS/ATOM feeds.
  #----------------------------------------------------------------------------
  def contact_summary(contact)
    summary = [""]
    summary << contact.title.titleize if contact.title?
    summary << contact.department if contact.department?
    if contact.account && contact.account.name?
      summary.last << " #{t(:at)} #{contact.account.name}"
    end
    summary << contact.email if contact.email.present?
    summary << "#{t(:phone_small)}: #{contact.phone}" if contact.phone.present?
    summary << "#{t(:mobile_small)}: #{contact.mobile}" if contact.mobile.present?
    summary.join(', ')
  end
end

