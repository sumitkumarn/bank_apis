class Bank < ApplicationRecord

  self.table_name = "banks"


  def decorate
    {
      id: id,
      name: name
    }
  end

end