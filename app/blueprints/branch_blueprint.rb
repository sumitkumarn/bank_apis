class BranchBlueprint < Blueprinter::Base

  view :api_v1 do
    fields :ifsc, :branch, :address, :city, :district, :state, :bank_id
  end

  view :api_v1_detail do
    include_view :api_v1
    field :bank_name do |branch|
      branch.bank.name
    end
  end

end