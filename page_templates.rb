# Load the templates for the pages we serve, so we don't have to re-read
#  them every time a request comes in.
# They're... not actually real ERB files, because I can't get ERB to
#  format them correctly, I think because I'm not clear what scope of
#  variable names the <% commands %> have access to.
def absname(relname)
    return File.join(File.dirname(__FILE__), relname)
end
PAGE_TEMPLATES = {:index => IO.read(absname("index.html.erb")),
                  :list => IO.read(absname("list.html.erb")),
                  :posts => IO.read(absname("posts.html.erb")),
                  :status => IO.read(absname("status.html.erb"))}

def make_page(symbol, params={})
  template = PAGE_TEMPLATES[symbol]
  return ERB.new(template).result(binding)
end