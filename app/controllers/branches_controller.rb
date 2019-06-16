class BranchesController < ApplicationController

  def index
    @item = scoper.find_by_ifsc(params[:ifsc])
    render json: @item, status: 200
  end

  private

  def scoper
    Branch.all
  end

end
