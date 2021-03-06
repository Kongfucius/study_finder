class Admin::GroupsController < ApplicationController
  before_filter :authorize_admin

  require 'csv'
  
  def index
    @groups = StudyFinder::Group.all

    add_breadcrumb 'Groups'
  end

  def new
    @group = StudyFinder::Group.new
    @conditions = StudyFinder::Condition.all.order(:condition)

    add_breadcrumb 'Groups', :admin_groups_path
    add_breadcrumb 'Add Group'
  end

  def create
    @group = StudyFinder::Group.new(group_params)
    if @group.save(@group)
      redirect_to admin_groups_path, flash: { success: 'Group added successfully' }
    else
      render action: 'new'
    end
  end

  def edit
    @group = StudyFinder::Group.find(params[:id])
    @conditions = StudyFinder::Condition.all.order(:condition)
    
    add_breadcrumb 'Groups', :admin_groups_path
    add_breadcrumb 'Edit Group'

    respond_to do |format|
      format.html
      format.csv { send_data generate_csv, filename: "#{friendly_filename(@group.group_name.downcase)}_categories.csv" }
    end
  end

  def update
    @group = StudyFinder::Group.find(params[:id])
    
    params[:condition_ids] = [] if params[:condition_ids].nil?
    params[:children] = false if params[:children].nil?
    params[:adults] = false if params[:adults].nil?
    params[:healthy_volunteers] = false if params[:healthy_volunteers].nil?

    if @group.update(group_params)
      unless params[:tags].nil?
        StudyFinder::Subgroup.delete_all({ group_id: @group.id })
        params[:tags][0].split(',').each do |t|
          StudyFinder::Subgroup.create!({
            group_id: @group.id,
            name: t
          })
        end
      end
      redirect_to edit_admin_group_path(params[:id]), flash: { success: 'Group updated successfully' }
    else
      render 'edit'
    end
  end

  def destroy
    @group = StudyFinder::Group.find(params[:id])
    if @group.destroy
      redirect_to admin_groups_path, flash: { success: 'Group removed successfully' }
    else
      redirect_to admin_groups_path, flash: { error: 'Unable to remove group' }
    end
  end

  def reindex
    StudyFinder::Trial.import force: true

    add_breadcrumb 'Groups', :admin_groups_path
  end

  private
    def group_params
      params.permit(:group_name, :children, :adults, :healthy_volunteers, condition_ids: [])
    end

    def generate_csv
      column_names = ['Condition Name', 'Selected']
      group_conditions = @group.conditions

      CSV.generate do |csv|
        csv << column_names
        @conditions.each do |item|
          selected = !group_conditions.select { |gc| gc.id == item.id }.empty?
          row = [item.condition, (selected) ? 'X': '']
          csv << row
        end
      end
    end

    def friendly_filename(filename)
      filename.gsub(/[^\w\s_-]+/, '')
        .gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2')
        .gsub(/\s+/, '_')
    end

end