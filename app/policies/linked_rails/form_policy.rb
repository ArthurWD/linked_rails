# frozen_string_literal: true

module LinkedRails
  class FormPolicy < LinkedRails.policy_parent_class
    def show?
      true
    end

    def public_resource?
      true
    end
  end
end
