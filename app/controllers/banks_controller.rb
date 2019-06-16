class BanksController < ApplicationController

  def show
    @item = scoper.find_by_id(params[:id])
    render json: @item, status: 200
  end

  private

  def scoper
    Bank.all
  end
end
