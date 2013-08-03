require 'nokogiri'
require 'open-uri'
require 'net/ftp'

# allen, cat, any breed, young, any gender
# url breaks at &No=##
url_begin = "http://www.petfinder.com/pet-search?N=&Nf=coords%7CGCLT+33.1034%2C-96.671+161%7Clat%7CBTWN+31.6574+34.5494%7Clon%7CBTWN+-154060.479+153867.137&No="
url_end = "&Ns=coords%2833.1034%2C-96.671%29%7C%7Cshelter_name%7C%7Canimal_type%7C%7Cpet_breed_1%7C%7Cpet_breed_2%7C%7Cidentifier&Ntk=animal_type%7Cpet_age%7Crecord_type%7Cstatus&Ntt=Cat%7Cyoung%7Cpet%7CA&distance=100&lat=33.1034&location=75013&lon=-96.671&pet_breed&pet_gender&startsearch=Go"

# checks for & and case insensitive 'and'
amp_and_regex = /(.*\s?&amp;\s?.*|.*\sand\s.*)/i

match_total = 0

def paragraph_me(name, link)
	'<p><a href="http://www.petfinder.com/' + link + '">' + name + '</a></p>'
end

File.open('cat-list.html', 'w') do |file|
	puts "Searching cattes..."
	(0..1100).step(25) do |n|
		puts n.to_s + " to " + (n + 24).to_s
		url = url_begin + n.to_s + url_end
		doc = Nokogiri::HTML(open(url))
		doc.xpath("//td[@class='pet-name']").map do |entry|
			name = entry.xpath("./a[@class='petlink']/text()")
			if (amp_and_regex.match(name.to_s))
				file.print paragraph_me(name.to_s, entry.xpath("./a[@class='petlink']/@href").to_s)
				match_total += 1
			end
		end
	end
	time = Time.new
	file.puts "\n" + match_total.to_s + " matches found.  Generated: " + time.strftime('%m-%d-%Y at %I:%M:%S')
end
puts "Done!"
puts "FTP cat-list.html to poemdexter.com/cat-list.html"
html_file = File.new('cat-list.html')
###
### INSERT DOMAIN, USERNAME, AND PASSWORD HERE
###
Net::FTP.open('DOMAIN', 'USERNAME', 'PASSWORD') do |ftp|
	ftp.putbinaryfile(html_file, '/var/www/poemdexter/cat-list.html')
end
puts "Done!"