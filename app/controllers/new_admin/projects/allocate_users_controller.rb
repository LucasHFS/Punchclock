# frozen_string_literal: true

module NewAdmin
  module Projects
    class AllocateUsersController < ApplicationController
      layout 'new_admin'

      before_action :authenticate_user!
      before_action :set_project, only: %i[new create]

      def new
        @allocation = @project.allocations.new

        AbilityAdmin.new(current_user).authorize! :manage, @allocation
      end

      def create
        @allocation = Allocation.new(allocation_params)
        AbilityAdmin.new(current_user).authorize! :manage, @allocation

        if @allocation.save
          flash[:notice] = I18n.t(:notice, scope: "flash.actions.create",
                                           resource_name: Allocation.model_name.human)
          redirect_to new_admin_user_allocation_path(@allocation)
        else
          flash.now[:alert] = @allocation.errors.full_messages.to_sentence
          render :new, status: :unprocessable_entity
        end
      end

      private

      def allocation_params
        params.require(:allocation).permit(:user_id, :project_id, :start_at, :end_at, :hourly_rate_cents)
      end

      def set_project
        @project = Project.find(allocation_params[:project_id])
      end
    end
  end
end
