# Adds and removes tags on a ticket.
class TaggingsController < ApplicationController
  before_action :set_ticket

  def create
    name = params.expect(tagging: [ :name ])[:name]
    if name.blank?
      redirect_to @ticket, alert: "Type a tag name first."
    else
      tag = @ticket.add_tag(name)
      redirect_to @ticket, notice: "Tagged #{tag.name}."
    end
  rescue ActiveRecord::RecordInvalid => e
    redirect_to @ticket, alert: e.record.errors.full_messages.to_sentence
  end

  def destroy
    @ticket.taggings.joins(:tag).find_by!(tags: { name: params[:id] }).destroy
    redirect_to @ticket, notice: "Removed tag #{params[:id]}."
  end

  private
    def set_ticket
      @ticket = Ticket.find(params[:ticket_id])
    end
end
