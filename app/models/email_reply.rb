# Removes the quoted earlier conversation that email clients add below a reply,
# so a ticket only stores what the customer actually wrote this time.
module EmailReply
  # "On Tue, 18 Nov 2026 at 09:00, Support <support@example.com> wrote:"
  # Gmail sometimes wraps this line in two, so allow one line break inside it.
  ATTRIBUTION = /^On\s.+?(?:\n.+?)?\swrote:\s*$/
  OUTLOOK_SEPARATOR = /^(-{2,}\s*Original Message\s*-{2,}|_{5,})\s*$/i
  OUTLOOK_HEADER = /^From:\s.+\n(?:.+\n)*?(?:Sent|Date):\s/

  def self.strip_quoted(text)
    text = text.to_s.gsub("\r\n", "\n")
    cut = [ ATTRIBUTION, OUTLOOK_SEPARATOR, OUTLOOK_HEADER ].filter_map { |pattern| text =~ pattern }.min
    text = text[0...cut] if cut
    text = text.lines.reject { |line| line.start_with?(">") }.join
    text.strip
  end
end
