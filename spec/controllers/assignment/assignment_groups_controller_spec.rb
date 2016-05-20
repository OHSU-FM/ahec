require "spec_helper"

describe Assignment::AssignmentGroupsController do

  let(:admin) { create :superadmin }
  let(:coach) { create(:coach) }
  let(:student) { create(:student) }
  let(:agt) { FactoryGirl.create(:assignment_group_template, :with_surveys) }

  ##############################################################################
  # Public user tests
  ##############################################################################

  describe "not logged in" do
    it "should get redirect" do
      get :index
      expect(response.status).to eq 302
    end
  end

  ##############################################################################
  # admin tests
  ##############################################################################
  describe 'admin' do

    it "can get new assignment_group" do
      sign_in admin
      get :new
      assert_response :success
    end

    #crud
    it "can create assignment_group" do
      sign_in admin
      agt = create :assignment_group_template, :with_surveys
      group_params = FactoryGirl.attributes_for(:assignment_group, assignment_group_template_id: agt)

      expect {
        post :create, assignment_assignment_group: group_params
      }.to change(Assignment::AssignmentGroup, :count).by(1)
    end

    it "get index should be redirected to assignment group" do
      # redirects to first available assignment_group
      ag = create :assignment_group, :with_users
      sign_in admin

      get :index
      expect(subject).to redirect_to(assignment_assignment_group_path(ag))
    end

    it "can update assignment_group" do
      sign_in admin
      ag = create :assignment_group, title: 'title', desc_md: 'desc'
      put :update, assignment_group_id: ag.id,
        assignment_assignment_group: {
                                   title: 'different title',
                                   desc_md: 'different desc'
      }
      ag.reload
      expect(ag.title).to eq 'different title'
      expect(ag.desc_md).to eq 'different desc'
    end

    it "can delete assignment_group" do
      ag = create :assignment_group
      sign_in admin

      expect {
        delete :destroy, assignment_group_id: ag
      }.to change(Assignment::AssignmentGroup, :count).by(-1)

      expect(subject).to redirect_to(assignment_assignment_groups_path)
    end
  end

  ##############################################################################
  # coach tests
  ##############################################################################
  describe 'coach' do
    it "cannot view admin assignment groups" do
      ag = create :assignment_group, user_id: admin.id, user_ids: [student.id.to_s]
      sign_in coach
      get :index
      expect(coach.assignment_groups).not_to include(ag)
    end

    it "cannot get new assignment_group" do
      sign_in coach

      get :new
      expect(response.status).to eq 403
    end

    # crud
    it "cannot create assignment_group" do
      sign_in coach

      expect {
        post :create, assignment_assignment_group: {
          assignment_group_template_id: agt.id
        }
      }.not_to change(Assignment::AssignmentGroup, :count)
    end

    it "get index should be redirected to assignment group" do
      coach = create :coach
      ag = create :assignment_group, user_id: coach.id, user_ids: [student.id.to_s]
      sign_in coach

      get :index
      expect(subject).to redirect_to(ag)
    end

    it "cannot update assignment_group" do
      sign_in coach
      ag = create :assignment_group, title: 'title', desc_md: 'desc'
      put :update, assignment_group_id: ag.id,
        assignment_assignment_group: {
                                   title: 'different title',
                                   desc_md: 'different desc'
      }
      expect(ag).not_to receive(:update_attributes)
      ag.reload
      expect(ag.title).to eq 'title'
      expect(ag.desc_md).to eq 'desc'
    end

    it "cannot delete assignment_group" do
      ag = create :assignment_group
      sign_in coach

      expect {
        delete :destroy, assignment_group_id: ag
      }.not_to change(Assignment::AssignmentGroup, :count)

      expect(response.status).to eq 403
    end
  end

  ##############################################################################
  # student tests
  ##############################################################################
  describe 'student' do

    it "cannot get new" do
      sign_in student
      get :new

      expect(response.status).to eq 403
    end

    # crud
    it "cannot create assignment_group" do
      group_params = FactoryGirl.attributes_for(:assignment_group)
      sign_in student

      expect {
        post :create, assignment_group: group_params
      }.not_to change(Assignment::AssignmentGroup, :count)
    end

    it "get index should be redirected to first assignment group" do
      sign_in student
      ag = create :assignment_group, user_ids:  [student.id.to_s]

      get :index
      expect(subject).to redirect_to(ag)
    end

    it "cannot update assignment_group" do
      ag = create :assignment_group, title: 'title'
      sign_in student

      put :update, assignment_group_id: ag,
        assignment_assignment_group: { title: "a different title" }
      expect(ag.title).to eq 'title'
    end

    it "cannot delete assignment_group" do
      ag = create :assignment_group
      sign_in student

      expect {
        delete :destroy, assignment_group_id: ag
      }.not_to change(Assignment::AssignmentGroup, :count)

      expect(response.status).to eq 403
    end
  end
end
