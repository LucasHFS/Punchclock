require 'rails_helper'

RSpec.describe NewAdmin::QuestionnairesController, type: :request do
  describe 'GET #index' do
    context 'when user is signed in' do
      context 'when user is admin' do
        let(:user) { create(:user, :admin) }
        before { sign_in user }

        context 'when no filters are applied' do
          let!(:questionnaires) { create_list(:questionnaire, 2) }

          it 'returns status code 200 ok' do
            get new_admin_questionnaires_path

            expect(response).to have_http_status(:ok)
          end

          it 'renders the index template' do
            get new_admin_questionnaires_path

            expect(response).to render_template(:index)
          end

          it 'shows the questionnaires' do
            get new_admin_questionnaires_path

            expect(response.body).to include(questionnaires[0].title)
              .and include(questionnaires[1].title)
          end
        end

        context 'when title filter is applied' do
          let!(:foo_questionnaire) { create(:questionnaire, title: 'Foo') }
          let!(:bar_questionnaire) { create(:questionnaire, title: 'Bar') }

          it 'returns only the filtered questionnaires', :aggregate_failures do
            get new_admin_questionnaires_path, params: { title: 'foo' }

            expect(response.body).to include('Foo')
            expect(response.body).not_to include('Bar')
          end
        end

        context 'when pagination is applied' do
          let!(:questionnaires_list) { create_list(:questionnaire, 3) }

          it 'paginates the results', :aggregate_failures do
            get new_admin_questionnaires_path, params: { per: 2 }

            expect(assigns(:questionnaires).count).to eq(2)
          end
        end
      end
    end

    context 'when user is not signed in' do
      it 'redirects to the sign in page' do
        get new_admin_questionnaires_path

        expect(response).to redirect_to(root_path)
      end
    end

    context 'when user is not admin' do
      let(:user) { create(:user) }

      before { sign_in user }

      it 'redirects to root page' do
        get new_admin_questionnaires_path

        expect(response).to redirect_to(root_path)
      end
    end
  end
end
