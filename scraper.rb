require 'open-uri'
require 'nokogiri'
require 'sqlite3'

# Create the database
db = SQLite3::Database.new( "db/studentbody.db" )
sql = <<SQL
CREATE table students
( 
id INTEGER PRIMARY KEY,
first_name TEXT,
last_name TEXT,
email TEXT DEFAULT "#",
tag_line TEXT,
bio TEXT,
image_class TEXT,
app_1 TEXT,
app_1_desc TEXT,
app_2 TEXT,
app_2_desc TEXT,
app_3 TEXT,
app_3_desc TEXT,
linked_in TEXT,
blog TEXT,
twitter_url TEXT,
github_url TEXT,
code_school TEXT,
coder_wall TEXT,
stack_overflow TEXT,
treehouse TEXT,
twitterfeed TEXT,
tagline2 TEXT,
image_url TEXT,
page_link TEXT,
excerpt TEXT,
profile_photo TEXT,
twitter_username TEXT,
github_username TEXT,
slug TEXT
);
SQL

db.execute_batch( sql )

# Index Parser (get URLs for each student)
urlnoki = "http://students.flatironschool.com/"
profile_links = []

doc = Nokogiri::HTML(open(urlnoki))
doc.css('div.one_third a').map do |link|
  profile_links << urlnoki + link['href']
end
doc.css('div.one_third').each do |studentelement|
  full_name = studentelement.search("h2").inner_text
  first_name, last_name = full_name.split
  tagline = studentelement.search(".position").inner_text
  image_url = studentelement.search("img.person").first['src']
  page_link = studentelement.search("a").first['href']
  excerpt = studentelement.search(".excerpt").inner_text

  if full_name.downcase.include?('billy')
    next
  end

  db.execute("INSERT into students (
                                          tagline2,
                                          image_url,
                                          page_link,
                                          excerpt,
                                          first_name,
                                          last_name) VALUES (?, ?, ?, ?, ?, ?)", tagline, image_url, page_link, excerpt, first_name, last_name)


end

# Iterating through all profile_links (array), running scraper, and saving into DB
profile_links.delete_if {|url| url.include?('billy')}
css = Nokogiri::HTML(open(urlnoki + "/css/matz.css"))

images = css.to_s.scan(/\.(.*?-photo)[^}]+?background:.*\(([\S\s]+?)\)/)

profile_links.each do |link|
    doc = Nokogiri::HTML(open(link))


    name = doc.css('h1').text
    name = name.split(" ")

    first_name = name[0]
    last_name = name[1]

    slug = "#{first_name.downcase}#{last_name.downcase}"
    image_class = doc.css('div#navcontainer.one_third div')[0]['class']

    app_1 = doc.css('h4')[0].text
    app_1_desc = doc.css('div.one_third p')[0].text
    app_2 = doc.css('h4')[1].text
    app_2_desc = doc.css('div.one_third p')[1].text
    app_3 = doc.css('h4')[2].text
    app_3_desc = doc.css('div.one_third p')[2].text
    unless doc.css('.mail a').empty?
      email = doc.css('.mail a')[0]["href"]
    end
    if email.include?("mailto:")
      email["mailto:"] = ""
    end
    tag_line = doc.css('#tagline')[0].text
    bio = doc.css('.two_third > p').text
    linked_in = doc.css('.linkedin a')[0]["href"]
    blog = doc.css('.blog a')[0]["href"]
    twitter_url = doc.css('.twitter a')[0]["href"]
    github_url = doc.css('a[href*="github"]')[0]["href"]
    code_school = doc.css('a[href*="codeschool"]')[0]["href"]
    coder_wall = doc.css('a[href*="coderwall"]')[0]["href"]
    stack_overflow = doc.css('a[href*="stack"]')[0]["href"]
    treehouse = doc.css('a[href*="treehouse"]')[0]["href"]
    twitterfeed_selector = doc.css('a.twitter-timeline')[0]
    twitterfeed = twitterfeed_selector["data-widget-id"] if twitterfeed_selector
    twitter_url.match(".com\/(.+)")
    twitter_username = $1
    github_username = github_url.split(/\.|\//).select{|item| !item.empty? && item !~ /github|http|\Acom\Z/}.first

    my_css = css.css("p")[0].text.match(/.#{image_class}\s*{(\s|.)*?}/)
    my_css.to_s.match(/\.\.(.*)?\)/)
    profile_photo = $1

    ps = db.prepare("UPDATE students SET image_class = :image_class,
      email = :email,
      tag_line = :tag_line,
      bio = :bio,
      app_1 = :app_1,
      app_1_desc = :app_1_desc,
      app_2 = :app_2,
      app_2_desc = :app_2_desc,
      app_3 = :app_3,
      app_3_desc = :app_3_desc,
      linked_in = :linked_in,
      blog = :blog,
      twitter_url = :twitter_url,
      github_url = :github_url,
      code_school = :code_school,
      coder_wall = :coder_wall,
      stack_overflow = :stack_overflow,
      treehouse = :treehouse,
      twitterfeed = :twitterfeed,
      profile_photo = :profile_photo,
      twitter_username = :twitter_username,
      github_username = :github_username,
      slug = :slug WHERE last_name = :last_name")

    ps.execute('image_class' => image_class,
    'email' => email,
    'tag_line' => tag_line,
    'bio' => bio,
    'app_1' => app_1,
    'app_1_desc' => app_1_desc,
    'app_2' => app_2,
    'app_2_desc' => app_2_desc,
    'app_3' => app_3,
    'app_3_desc' => app_3_desc,
    'linked_in' => linked_in,
    'blog' => blog,
    'twitter_url' => twitter_url,
    'github_url' => github_url,
    'code_school' => code_school,
    'coder_wall' => coder_wall,
    'stack_overflow' => stack_overflow,
    'treehouse' => treehouse,
    'twitterfeed' => twitterfeed,
    'last_name' => last_name,
    'profile_photo' => profile_photo,
    'twitter_username' => twitter_username,
    'github_username' => github_username,
    'slug' => slug)

    ps.close
end