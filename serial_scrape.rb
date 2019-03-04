# encoding: utf-8

require 'optparse'
require 'nokogiri'
require 'open-uri'
require 'uri'

@pact_url="https://pactwebserial.wordpress.com/category/story/arc-1-bonds/1-01/"
@twig_url="https://twigserial.wordpress.com/2014/12/24/taking-root-1-1/"
@worm_url="https://parahumans.wordpress.com/2011/06/11/1-1/"
@ward_url="https://www.parahumans.net/2017/10/21/glow-worm-0-1/"

story = { "pact" => @pact_url, "twig" => @twig_url, "worm" => @worm_url, "ward" => @ward_url}

options = {:first_arc => 0, :last_arc => 999999}
OptionParser.new do |opts|
	opts.banner = "Usage: serial_scrape.rb [options]"

	opts.on("-s", "--series NAME", "Select web series") do |name|
		options[:stories] = [name]
	end

	opts.on("-a", "select all") do 
		options[:stories] = ["worm", "pact", "twig", "ward"]
	end

    opts.on("-bARC", "begin at this arc") do |arc|
        options[:first_arc] = arc.to_i
    end

    opts.on("-eARC", "end at this arc") do |arc|
        options[:last_arc] = arc.to_i
    end
end.parse!

def write_story(starting_chapter, first_arc, last_arc)
	@next_chapter = starting_chapter
	@toc = "<h1>Table of Contents</h1>"
	@book_body = ""
	@index = 1
    @last_known_arc_number = 0
	while @next_chapter
    #check if url is weird
    if @next_chapter.to_s.include?("½")
      @next_chapter = URI.escape(@next_chapter)
    end
    if @next_chapter.to_s.start_with?("//")
      @next_chapter = "https:" + @next_chapter
    end
    #converts http to https to prevent ruby2.3's problem with open_loop redirection
    @next_chapter.sub! "http://", "https://"
    doc = Nokogiri::HTML(open(@next_chapter))
    #get
    @chapter_title = doc.css('h1.entry-title').first #html formatted

    #modify chapter to have link
    @chapter_title_plain = @chapter_title.content
    # NB: (/[[:space:]]/) is important.
    # We can't split just on ' ' because in some chapter titles
    # we have ascii 160 (non breaking space) instead of ascii 32 (classic space)
    @arc_number = @chapter_title_plain.split(/[[:space:]]/)[-1].to_i
    if @arc_number == 0
        @arc_number = @last_known_arc_number
    else
        @last_known_arc_number = @arc_number
    end
    if first_arc <= @arc_number && @arc_number <= last_arc
        $stderr.puts @chapter_title_plain + " (Arc " + @arc_number.to_s + ")"
        @chapter_content = doc.css('div.entry-content').first #gsub first p
        #clean
        @chapter_content.search('.//div').remove
        @to_remove = doc.css('div.entry-content p').first #gsub first p
        @chapter_content = @chapter_content.to_s.gsub(@to_remove.to_s,"")
        #write
        @book_body << "<h1 id=\"chap#{@index.to_s}\">#{@chapter_title_plain}</h1>"
        @book_body << @chapter_content
        @toc << "<a href=\"#chap#{@index.to_s}\">#{@chapter_title_plain}</a><br>"
    end
    @index += 1
    #next
    @next_chapter = if @arc_number <= last_arc && doc.css('div.entry-content p a').last.content.to_s.include?("Next")
    doc.css('div.entry-content p a').last['href']
    else
      false
    end
	end

	$stderr.puts "Writing Book..."

	puts @toc
	puts @book_body
end	

story.each{ |key, val| if options[:stories].include?(key)
	write_story(val, options[:first_arc], options[:last_arc])
	end
}
