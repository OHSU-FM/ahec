class Assignment::AssignmentGroupsController < Assignment::AssignmentBaseController
  layout 'full_width'
  authorize_resource
  before_filter :load_resource, only: [:show, :edit, :update, :destroy]

  def index
    @assignment_groups = Assignment::AssignmentGroup.all
    if @assignment_groups.count > 0
      redirect_to assignment_assignment_group_path(@assignment_groups.first)
    end
  end

  def show
    @assignment_groups = Assignment::AssignmentGroup.all
  end

  def new
    @assignment_group = Assignment::AssignmentGroup.new
    simple_respond
  end

  def create
    @assignment_group = Assignment::AssignmentGroup.create create_params
    flash[:success] = "#{Settings.assignment_route_name.singularize.titleize} successfully created!"
    redirect_to assignment_assignment_group_path(@assignment_group)
  end

  def edit
  end

  def update
    @assignment_group.update_attributes(update_params)
    @assignment_group.save!
    flash[:success] = "#{Settings.assignment_route_name.singularize.titleize} successfully updated!"
    redirect_to assignment_assignment_group_path(@assignment_group)
  end

  def destroy
    @assignment_group.destroy
    flash[:success] = "#{Settings.assignment_route_name.singularize.titleize} successfully deleted!"
    redirect_to assignment_assignment_groups_path
  end

  protected

  def load_resource
    @assignment_group = Assignment::AssignmentGroup.find(params[:assignment_group_id])
  end

  def create_params
    update_params.merge(user_id: current_user.id)
  end

  def update_params
    params.require(:assignment_assignment_group).
      permit(:assignment_group_template_id, :title, :desc_md, user_ids: [])
  end

end
