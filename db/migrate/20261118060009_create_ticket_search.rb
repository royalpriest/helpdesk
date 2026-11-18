# A SQLite full-text index over each ticket's subject, messages and customer,
# so search stays fast as the inbox grows. Kept up to date by Ticket::Searchable.
class CreateTicketSearch < ActiveRecord::Migration[8.1]
  def up
    create_virtual_table :ticket_search, :fts5, [ "subject", "body", "customer", "tokenize='unicode61 remove_diacritics 2'" ]

    execute <<~SQL
      INSERT INTO ticket_search (rowid, subject, body, customer)
      SELECT tickets.id,
             tickets.subject,
             (SELECT group_concat(messages.body, char(10)) FROM messages WHERE messages.ticket_id = tickets.id),
             customers.name || ' ' || customers.email_address
      FROM tickets JOIN customers ON customers.id = tickets.customer_id
    SQL
  end

  def down
    drop_table :ticket_search
  end
end
