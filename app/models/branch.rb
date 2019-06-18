class Branch < ApplicationRecord

  self.table_name = "branches"

  #associating a branch to a bank through foreign key bank_id
  belongs_to :bank, class_name: 'Bank', foreign_key: :bank_id

end
