module ApplicationHelper
  # Ticket counts for the sidebar views, e.g. { "mine" => 2, "open" => 5 }.
  def ticket_counts
    @ticket_counts ||= TicketsController::FILTERS.index_with { |filter| Ticket.for_filter(filter, Current.user).count }
  end

  def view_label(filter)
    { "mine" => "Assigned to me", "unassigned" => "Unassigned", "open" => "Open", "all" => "All tickets" }.fetch(filter)
  end

  # Initials for an avatar: "Casey Customer" => "CC", "sam@example.com" => "S".
  def initials(name)
    name.to_s.split(/[\s@._-]+/).reject(&:blank?).first(2).map { |part| part[0] }.join.upcase.presence || "?"
  end

  # A round avatar with the person's initials. The colour is picked from the
  # name, so the same person always gets the same colour.
  def avatar(name, size: :md)
    hue = name.to_s.sum % AVATAR_COLORS.size
    tag.span initials(name), class: "avatar avatar-#{size} avatar-#{AVATAR_COLORS[hue]}", aria: { hidden: true }
  end
  AVATAR_COLORS = %w[peach mint lilac sky sand rose].freeze

  # "Waiting 3h" for tickets waiting on the team, "On customer" for pending ones.
  def waiting_badge(ticket)
    text, level =
      if ticket.closed? then [ "Closed", "calm" ]
      elsif ticket.pending? then [ "On customer", "calm" ]
      elsif ticket.waiting_for then [ "Waiting #{short_duration(ticket.waiting_for)}", ticket.waiting_level ]
      else [ "New", "calm" ]
      end
    tag.span text, class: "badge badge-#{level}"
  end

  def short_duration(seconds)
    minutes = (seconds / 60).floor
    if minutes < 60 then "#{[ minutes, 1 ].max}m"
    elsif minutes < 60 * 24 then "#{minutes / 60}h"
    else "#{minutes / (60 * 24)}d"
    end
  end

  # "4m", "3h", "Yesterday" or "12 Nov" for list timestamps.
  def short_time(time)
    if time > 1.hour.ago then "#{[ ((Time.current - time) / 60).floor, 1 ].max}m"
    elsif time.to_date == Date.current then "#{((Time.current - time) / 3600).floor}h"
    elsif time.to_date == Date.yesterday then "Yesterday"
    else l(time.to_date, format: "%-d %b")
    end
  end

  def status_pill(ticket)
    tag.span ticket.status.humanize, class: "pill pill-#{ticket.status}"
  end

  # Inline stroke icons, so the app needs no icon font or extra requests.
  ICONS = {
    search: '<circle cx="11" cy="11" r="7"/><path d="M20 20l-3.5-3.5"/>',
    check: '<path d="M5 12l5 5L20 7"/>',
    list: '<path d="M4 6h16M4 12h10M4 18h7"/>',
    clip: '<path d="M21 11.5l-8.6 8.6a5 5 0 01-7.1-7.1l8.6-8.6a3.3 3.3 0 014.7 4.7l-8.6 8.6a1.7 1.7 0 01-2.4-2.4l7.9-7.9"/>',
    link: '<path d="M10 14a5 5 0 007 0l3-3a5 5 0 00-7-7l-1 1"/><path d="M14 10a5 5 0 00-7 0l-3 3a5 5 0 007 7l1-1"/>',
    back: '<path d="M15 18l-6-6 6-6"/>',
    inbox: '<path d="M4 13l2.5-7h11L20 13v5a1 1 0 01-1 1H5a1 1 0 01-1-1z"/><path d="M4 13h4l1.5 2h5L16 13h4"/>'
  }.freeze

  def icon(name, size: 16)
    tag.svg ICONS.fetch(name).html_safe, width: size, height: size, viewBox: "0 0 24 24", fill: "none", stroke: "currentColor",
      "stroke-width": 2, "stroke-linecap": "round", "stroke-linejoin": "round", aria: { hidden: true }, class: "icon"
  end
end
