class BanksController < ApplicationController

private  
  def load_object
    @item = Bank.find_by_id(params[:id])
    render json: @item, status: 200
  end

end
