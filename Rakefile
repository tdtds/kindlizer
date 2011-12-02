#
# Rakefile for self publishing ebook of Kindle made by scanning paper book.
#
# modify parameters by your environment:
#   SRC (must): source PDF file name.
#   TOP, BOTTOM, LEFT, RIGHT: default margins (pixel) of trimming.
#   SIZE: adjust image size by destination format.
#   LEVEL (optional): level option of ImageMagic.
#
# for Debian or Ubuntu user, needs packages below:
#   poppler-utils poppler-data imagemagick pdftk sam2p
#

SRC = 'sample.pdf'
TOP = 250
BOTTOM = 100
LEFT = 50
RIGHT = 50

SIZE = '560x735' # for small books reading portrait style
#SIZE = '720' # for large books reading landscape style
#SIZE = 'x693' # for generating mobi, portrait style only

LEVEL = '0%,100%'

#---------------------------------------------------------

PGM_DIR = './pgm'; directory PGM_DIR
PNG_DIR = './png'; directory PNG_DIR
PDF_DIR = './pdf'; directory PDF_DIR

DST = SRC.sub( /\.pdf$/, '.out.pdf' )
MOBI = SRC.sub( /\.pdf$/, '.mobi' )
OPF = SRC.sub( /\.pdf$/, '.opf' )
HTML = SRC.sub( /\.pdf$/, '.html' )

def count_pages
	open( "|pdfinfo #{SRC}", 'r:utf-8', &:read ).scan( /^Pages:\s*(\d+)/ ).flatten[0].to_i
end

def book_title
	open( "|pdfinfo #{SRC}", 'r:utf-8', &:read ).scan( /^Title:\s*(.+)$/ ).flatten[0]
end

def book_author
	open( "|pdfinfo #{SRC}", 'r:utf-8', &:read ).scan( /^Author:\s*(.+)$/ ).flatten[0]
end

def image_list( dir, ext, count )
	[].tap do |l|
		1.upto( count ) do |i|
			l << "#{dir}/tmp-#{'%03d' % i}.#{ext}"
		end
	end
end

def pgm2png( pgm, png )
	sh "convert #{pgm} -level '#{LEVEL}' \
		-chop #{LEFT}x#{TOP} \
		-gravity SouthEast -chop #{RIGHT}x#{BOTTOM}\
		-gravity NorthWest -fuzz 50% -trim -resize #{SIZE}\
		#{/x/ =~ SIZE ? '' : '-gravity SouthWest -splice 1x15 -gravity NorthEast -splice 1x15'}\
		#{png}"
end

def png2pdf( png, pdf )
	sh "sam2p -j:quiet #{png} #{pdf}"
end

pages = count_pages
PGMS = image_list( PGM_DIR, 'pgm', pages )
PNGS = image_list( PNG_DIR, 'png', pages )
PDFS = image_list( PDF_DIR, 'pdf', pages )

PNGS.each_with_index do |png, i|
	file PDFS[i] => [PDF_DIR, PNGS[i]] do |t|
		png2pdf( t.prerequisites[1], t.name )
	end

	file PNGS[i] => [PNG_DIR, PGMS[i]] do |t|
		pgm2png( t.prerequisites[1], t.name )
	end

	file PGMS[i] => [PGM_DIR, SRC] do
		unless File::exist?( PGMS[-1] ) then
			sh "pdftoppm -r 300 -gray #{SRC} #{PGM_DIR}/tmp"
		end
	end
end

task :default => :pdf

desc 'generate pdf file by concat all png files.'
task :pdf => DST

file DST => [PDF_DIR, 'metadata.txt'] + PDFS do
	sh "pdftk #{PDFS.join ' '} cat output #{PDF_DIR}/#{DST}"
	sh "pdftk #{PDF_DIR}/#{DST} update_info metadata.txt output #{DST}" 
end

desc 'generate metadata file from source pdf.'
task :metadata => 'metadata.txt'

file 'metadata.txt' => SRC do |t|
	sh "pdftk #{t.prerequisites.join ' '} dump_data output ./#{t.name}"
end

desc 'crop pgm files to png files.'
task :png => [PNG_DIR] + PNGS

rule '.png' => '.pgm' do |t|
	pgm2png( t.prerequisites[0], t.name )
end

desc 'extract image files from source pdf.'
task :pgm => [PGM_DIR, SRC] + PGMS

desc 'cleanap pgm images.'
task 'clean-pgm' do
	begin
		rm PGMS
	rescue
	end
end

desc 'cleanap png images.'
task 'clean-png' do
	begin
		rm PNGS
	rescue
	end
end

desc 'cleanap temporaly pdf files.'
task 'clean-pdf' do
	rm FileList["#{PDF_DIR}/*.pdf"]
end

desc 'cleanap all tmp files.'
task :clean => ['clean-png', 'clean-pgm', 'clean-pdf'] do
	rm 'metadata.txt'
	rm [HTML, OPF]
	rmdir PGM_DIR
	rmdir PNG_DIR
	rmdir PDF_DIR
end

desc 'generate MOBI file.'
task :mobi => [OPF, HTML] + PNGS do |t|
	sh "kindlegen #{OPF} -o #{MOBI}"
end

rule '.opf' => '.pdf' do |t|
	opf = <<-OPF.gsub( /^\t/, '' )
	<?xml version="1.0" encoding="utf-8"?>
	<package unique-identifier="uid">
		<metadata>
			<dc-metadata xmlns:dc="http://purl.org/metadata/dublin_core"
			xmlns:oebpackage="http://openebook.org/namespaces/oeb-package/1.0/">
			  <dc:Title>#{book_title}</dc:Title>
			  <dc:Language>en-US</dc:Language>
			  <dc:Creator>#{book_author}</dc:Creator>
			  <dc:Date>#{Time::now.strftime '%m/%d/%Y'}</dc:Date>
			</dc-metadata>
			<x-metadata>
			  <output encoding="utf-8" content-type="text/x-oeb1-document"></output>
			  <EmbeddedCover>#{PNGS[0]}</EmbeddedCover>
			</x-metadata>
		</metadata>
		<manifest>
			<item id="contents" media-type="text/html" href="#{HTML}"></item>
		</manifest>
		<spine>
			<itemref idref="contents" />
		</spine>
		<tours></tours>
		<guide>
			<reference type="start" title="contents" href="#{HTML}"></reference>
		</guide>
	</package>
	OPF
	open( t.name, 'w:utf-8' ){|f| f.write opf}
end

rule '.html' => '.pdf' do |t|
	html = <<-HTML.gsub( /^\t/, '' )
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
	<html lang="ja-JP">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<title>#{book_title}</title>
	</head>
	<body style="text-align: right;">
		#{PNGS.map{|j| %Q|<img style="height: 100%;" src="#{j}" />|}.join "<mbp:pagebreak />\n\t\t"}
	</body>
	</html>
	HTML
	open( t.name, 'w:utf-8' ){|f| f.write html}
end

