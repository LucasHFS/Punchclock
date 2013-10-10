class UserAbility
  include CanCan::Ability

  def initialize(user)
  	if user.is_admin?
    	can :manage, Punch, company_id: user.company.id
    	can :read, Company, id: user.company.id
      can :update, Company, id: user.company.id
    	can :manage, Project, company_id: user.company.id
      can :manage, User, company_id: user.company.id
      can :read, Comment, company_id: user.company_id
      can :manage, Comment, user_id: user.id, company_id: user.company_id
  	else
  		can :manage, Punch, company_id: user.company.id, user_id: user.id
      can :read, User, company_id: user.company.id
      can :edit, User, id: user.id
      can :update, User, id: user.id
      can :manage, Comment, user_id: user.id, company_id: user.company_id
  	end

    can :read, Notification, user_id: user.id
    can :update, Notification, user_id: user.id
  end
end
