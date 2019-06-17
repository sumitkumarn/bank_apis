class Branch < ApplicationRecord

  self.table_name = "branches"

  belongs_to :bank, class_name: 'Bank', foreign_key: :bank_id

end
