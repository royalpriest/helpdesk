class CannedRepliesController < ApplicationController
  before_action :set_canned_reply, only: %i[edit update destroy]

  def index
    @canned_replies = CannedReply.alphabetical
  end

  def new
    @canned_reply = CannedReply.new
  end

  def create
    @canned_reply = CannedReply.new(canned_reply_params)
    if @canned_reply.save
      redirect_to canned_replies_path, notice: "Canned reply saved."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @canned_reply.update(canned_reply_params)
      redirect_to canned_replies_path, notice: "Canned reply saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @canned_reply.destroy
    redirect_to canned_replies_path, notice: "Canned reply deleted."
  end

  private
    def set_canned_reply
      @canned_reply = CannedReply.find(params[:id])
    end

    def canned_reply_params
      params.expect(canned_reply: %i[title body])
    end
end
