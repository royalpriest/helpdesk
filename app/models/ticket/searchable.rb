# Full-text search over a ticket's subject, every message and the customer's
# name and email, using SQLite's FTS5 (the ticket_search table).
module Ticket::Searchable
  extend ActiveSupport::Concern

  included do
    after_save_commit :update_search_index
    after_destroy_commit :remove_from_search_index
  end

  class_methods do
    # Each word matches as a prefix, and every word has to match:
    # "inv pass" finds a ticket mentioning "invoice" and "password".
    def search(query)
      terms = query.to_s.scan(/[[:alnum:]]+/)
      return all if query.blank?
      return none if terms.empty?

      match = terms.map { |term| %("#{term}"*) }.join(" ")
      where("tickets.id IN (SELECT rowid FROM ticket_search WHERE ticket_search MATCH ?)", match)
    end

    def rebuild_search_index
      connection.execute("DELETE FROM ticket_search")
      includes(:customer, :messages).find_each(&:update_search_index)
    end
  end

  def update_search_index
    remove_from_search_index
    self.class.connection.execute(self.class.sanitize_sql_array([
      "INSERT INTO ticket_search (rowid, subject, body, customer) VALUES (?, ?, ?, ?)",
      id, subject, messages.map(&:body).join("\n"), "#{customer.name} #{customer.email_address}"
    ]))
  end

  private
    def remove_from_search_index
      self.class.connection.execute(self.class.sanitize_sql_array([ "DELETE FROM ticket_search WHERE rowid = ?", id ]))
    end
end
