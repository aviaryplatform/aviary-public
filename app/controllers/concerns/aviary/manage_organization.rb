# controllers/concerns/manage_organization.rb
# Module Aviary::CheckOrganization
# The module is written to get manage common methods those are needed or the organization and super admins
#
# Author::    Nouman Tayyab  (mailto:nouman@weareavp.com)
module Aviary::ManageOrganization
  extend ActiveSupport::Concern

  def new
    @organization = Organization.new
  end

  def edit; end

  def display_settings; end

  def update
    if @organization.update(org_params)
      respond_to do |format|
        flash[:notice] = 'Organization updated successfully.'
        format.html { redirect_back(fallback_location: root_path) }
        format.json { render json: [@organization], status: :ok, location: @organization }
      end
    else
      begin
        current_action = request.referer.include?('display_settings') ? :display_settings : :edit
      rescue StandardError
        current_action = :edit
      end
      respond_to do |format|
        format.html { render current_action }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_organization
    @organization = if admin_signed_in?
                      Organization.find(params[:id])
                    else
                      current_organization
                    end
  end

  def org_params
    params.require(:organization).permit(:name, :url, :description, :address_line_1,
                                         :address_line_2, :city, :state, :country, :zip, :logo_image,
                                         :banner_image, :display_banner, :logo_image, :status, :storage_type, :banner_image,
                                         :banner_title_text, :banner_type, :banner_slider_resources, :default_tab_selection,
                                         :title_font_color, :title_font_family, :title_font_size, :favicon, :hide_on_home,
                                         :custom_domain, :custom_url_for_resource, :search_panel_bg_color, :search_panel_font_color)
  end
end
