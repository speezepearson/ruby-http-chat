# Load the templates for the pages we serve, so we don't have to re-read
#  them every time a request comes in.
# They're... not actually real ERB files, because I can't get ERB to
#  format them correctly, I think because I'm not clear what scope of
#  variable names the <% commands %> have access to.
PAGE_TEMPLATES = {:index => IO.read("index.html.erb"),
                  :list => IO.read("list.html.erb"),
                  :posts => IO.read("posts.html.erb"),
                  :status => IO.read("status.html.erb")}

def make_page(symbol, options={})
  # Insert the content into the requested page template.
  # This will be obsolete once I figure out ERB scoping.
  result = String.new(PAGE_TEMPLATES[symbol])
  options.each do |key, value|
    value = value.join("<br />") if value.instance_of? Array
    result.sub!("<% #{key.to_s} %>", value.to_s)
  end
  return result
end

def index_page
  return make_page(:index)
end

def list_page(title, content)
  return make_page(:list, :title => title, :content => content)
end

def posts_page(chname, posts)
  return make_page(:posts, :title => "Posts in #{chname}", :content => posts)
end

def status_page(content)
  return make_page(:status, :content => content)
end