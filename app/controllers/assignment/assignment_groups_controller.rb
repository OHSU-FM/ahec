class Assignment::AssignmentGroupsController < Assignment::AssignmentBaseController
  respond_to :html
  authorize_resource 
  before_filter :load_resource, only: [:show, :edit, :update, :destroy]

  def index
    @assignment_groups = Assignment::AssignmentGroup.all
    if @assignment_groups.count > 0
      redirect_to assignment_assignment_group_path(@assignment_groups.first)
    end
  end

  def show
    respond_with @assignment_group
  end

  def new
    @assignment_group = Assignment::AssignmentGroup.new
    respond_with @assignment_group
  end

  def create
    @assignment_group = Assignment::AssignmentGroup.create create_params
  end

  def edit
    respond_with @assignment_group
  end

  def update
    @assignment_group.update(update_params)
    respond_with @assignment_group
  end

  def destroy
    @assignment_group.destroy
  end

  protected
 
  def load_resource
    @assignment_group = Assignment::AssignmentGroup.find(params[:assignment_group_id])
  end

  def create_params
    update_params
  end

  def update_params
    params.require(:assignment_assignment_group).
      permit(:title, :desc_md, :user_ids).
      merge(user_id: current_user.id)
  end

end
