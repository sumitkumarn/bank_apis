class Bank < ApplicationRecord

  self.table_name = "banks"

  #associating a bank with many branches. By default, rails takes the colum 'id' as the foreign key
  has_many :branches, class_name: 'Branch'

end