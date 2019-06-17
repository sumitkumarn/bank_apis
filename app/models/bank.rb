class Bank < ApplicationRecord

  self.table_name = "banks"

  has_many :branches, class_name: 'Branch'

end