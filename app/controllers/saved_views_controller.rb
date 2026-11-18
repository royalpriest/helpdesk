# Lets an agent save the current inbox filter, tag and search under a name.
class SavedViewsController < ApplicationController
  def create
    view = Current.user.saved_views.new(params.expect(saved_view: %i[name filter tag query]))
    if view.save
      redirect_to tickets_path(view.params), notice: "Saved view \"#{view.name}\"."
    else
      redirect_back_or_to tickets_path, alert: view.errors.full_messages.to_sentence
    end
  end

  def destroy
    view = Current.user.saved_views.find(params[:id])
    view.destroy
    redirect_to tickets_path, notice: "Deleted view \"#{view.name}\"."
  end
end
