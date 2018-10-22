class ProposalsController < ApplicationController
  before_action :authenticate_user!

  def index
    @received_proposals = Proposal.where(receiver: current_user)
    @sent_proposals = Proposal.where(sender: current_user)
  end

  def show
    @proposal = Proposal.find(params[:id])
    redirect_to root_path unless @proposal.user_related?(current_user)
  end

  def accept
    @proposal = Proposal.find(params[:proposal_id])
    redirect_to root_path unless @proposal.user_related?(current_user)
    @proposal.accepted!
    redirect_to @proposal
  end

  def new
    @proposal = Proposal.new
    @product = Product.find(params[:product_id])
  end

  def create
    @proposal = current_user.proposals.new(proposal_params)
    @proposal.receiver = @proposal.desired.user
    if @proposal.save
      ProposalMailer.notify_receiver(@product, @proposal)
      redirect_to proposals_path
    end
  end

  private

  def proposal_params
    @product = Product.find(params[:product_id])
    params.require(:proposal).permit(:offered_id, :price, :comment)
          .merge(desired: @product)
  end
end
