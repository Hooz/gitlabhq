require 'rails_helper'

feature 'Profile > Account', feature: true do
  given(:user) { create(:user, username: 'foo') }

  before do
    login_as(user)
  end

  describe 'Change username' do
    given(:new_username) { 'bar' }
    given(:new_user_path) { "/#{new_username}" }
    given(:old_user_path) { "/#{user.username}" }

    scenario 'the user is accessible via the new path' do
      update_username(new_username)
      visit new_user_path
      expect(current_path).to eq(new_user_path)
      expect(find('.user-info')).to have_content(new_username)
    end

    scenario 'the old user path redirects to the new path' do
      update_username(new_username)
      visit old_user_path
      expect(current_path).to eq(new_user_path)
      expect(find('.user-info')).to have_content(new_username)
    end

    context 'with a project' do
      given!(:project) { create(:project, namespace: user.namespace, path: 'project') }
      given(:new_project_path) { "/#{new_username}/#{project.path}" }
      given(:old_project_path) { "/#{user.username}/#{project.path}" }

      before(:context) { TestEnv.clean_test_path }
      after(:example) { TestEnv.clean_test_path }

      scenario 'the project is accessible via the new path' do
        update_username(new_username)
        visit new_project_path
        expect(current_path).to eq(new_project_path)
        expect(find('h1.project-title')).to have_content(project.name)
      end

      scenario 'the old project path redirects to the new path' do
        update_username(new_username)
        visit old_project_path
        expect(current_path).to eq(new_project_path)
        expect(find('h1.project-title')).to have_content(project.name)
      end
    end
  end
end

def update_username(new_username)
  allow(user.namespace).to receive(:move_dir)
  visit profile_account_path
  fill_in 'user_username', with: new_username
  click_button 'Update username'
end
