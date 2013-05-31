# Load the templates for the pages we serve, so we don't have to re-read
#  them every time a request comes in.
# They're... not actually real ERB files, because I can't get ERB to
#  format them correctly, I think because I'm not clear what scope of
#  variable names the <% commands %> have access to.
PAGE_TEMPLATES = {:index => IO.read("index.html.erb"),
                  :user_list => IO.read("user_list.html.erb"),
                  :channel_list => IO.read("channel_list.html.erb"),
                  :post_list => IO.read("post_list.html.erb")}

def make_page(symbol, content)
  # Insert the content into the requested page template.
  # This will be obsolete once I figure out ERB scoping.
  return PAGE_TEMPLATES[symbol].sub("<% CONTENT %>", content.to_s)
end