require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

before do
  @contents = File.readlines "data/toc.txt"
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").each_with_index.map do |line, index|
      "<p id=paragraph#{index}>#{line}</p>"
    end.join
  end

  def highlight(text, term)
    text.gsub(term, %(<strong>#{term}</strong>))
  end
end

def chapters_matching(query)
  results = []

  return results unless query

  each_chapter do |number, name, contents|
    matches = {}
    contents.split("\n\n").each_with_index do |paragraph, index|
      matches[index] = paragraph if paragraph.include?(query)
    end
    results << {number: number, name: name, paragraphs: matches} if matches.any?
  end
  results
end

not_found do
  redirect "/"
end

get "/" do
  @title = "Sherlock Homes"
  erb :home
end

get "/chapters/:number" do
  number = params[:number]

  chapter_title = @contents[number.to_i - 1]
  @title = "Chapter #{number} : #{chapter_title}"
  @chapter = File.read("data/chp#{number}.txt")
  erb :chapter
end

def each_chapter(&block)
  @contents.each_with_index do |name, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield(number, name, contents)
  end
end

def search_chapters(query)
  results = []

  return results unless query

  each_chapter do |number, name, contents|
    results << { number: number, name: name } if contents.include?(query)
  end
  results
end

get "/search" do
  @results = chapters_matching(params[:query])
  erb :search
end