#!/usr/bin/env ruby
#
# cropbox.rb: trim white spaces in (non image) PDF file by changing CropBox
#
# usage: cropbox.rb source.pdf > out.pdf
#

# ADJUST FOR EACH PDF FILES
# left, bottom, right, top
OFFSET = [60, 50, -60, -70]

print( ARGF.read.force_encoding( 'ASCII-8BIT' ).gsub( %r|(/CropBox\s*\[\s*([^\[]+?)\])| ) do
   orig, box = $1, $2
   offset = OFFSET.dup
   crop = "/CropBox[#{box.split( /\s+/ ).map{|s| s.to_i + offset.shift}.join(' ')}]"
   blank = orig.length - crop.length
   blank > 0 ? crop + ' ' * blank : orig
end )
