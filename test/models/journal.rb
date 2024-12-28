class Journal < ActiveRecord::Base
  belongs_to :journalized, :polymorphic => true
  belongs_to :issue, :foreign_key => :journalized_id

  belongs_to :user
end
