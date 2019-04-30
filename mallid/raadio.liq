#!/usr/bin/liquidsoap
# Lines starting with # are comments, they are ignored.

# Put the log file in some directory where
# you have permission to write.
set("log.file.path","/tmp/raadio.log")
# Print log messages to the console,
# can also be done by passing the -v option to liquidsoap.
set("log.stdout", true)
# Use the telnet server for requests
set("server.telnet", true)

# A bunch of files and playlists,
# supposedly all located in the same base dir.

default = single("/home/dj/raadio/avalik/vaikimisi.ogg")

music   = playlist("/home/dj/raadio/avalik/muusika.m3u",reload_mode="watch")
jingles = playlist("/home/dj/raadio/avalik/teated.m3u",reload_mode="watch")

# Play user requests if there are any,
# otherwise one of our playlists,
# and the default file if anything goes wrong.
program = fallback([ request.queue(id="request"),music,default])

# Add the normal jingles
radio = mksafe(random(weights=[1,8],[ jingles, program ]))

# Add the ability to relay live shows
full =
  mksafe(fallback(track_sensitive=false,
           [input.http("http://localhost:8000/otse-eeter.ogg"),
            radio]))

# Output the full stream in OGG
output.icecast(%vorbis, 
  host="localhost",port=8000,password="hackme",
  mount="raadio.ogg",full)

# Output the full stream in MP3
output.icecast(%mp3, 
  host="localhost",port=8000,password="hackme",
  mount="radio",full)

## Output the stream without live in OGG
#output.icecast(%vorbis, 
#  host="localhost",port=8000,password="hackme",
#  mount="raadio_otse-eetrita.ogg",radio)
