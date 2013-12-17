URL: http://192.241.228.72:3000

Youtube video to for product demo (its complicated): http://www.youtube.com/watch?v=lVSiwaYaWoY&feature=em-upload_owner
To get some really cool terrains you could generate (given some hard work in the UI), clone this repository and run 'rspec lib/terrain_lib/spec/terrain_lib_spec.rb'. To generate a different terrain, copy one of the *.gen files from lib/terrain_lib/spec/gen to lib/terrain_lib/spec/test.gen. Your fancy terrains will appear lib/terrain_lib/out.

Nick's Comments
===============

Sorry it doesnt look good, we spend our time getting the intricate client side JS working. Future work would be to get an application layout implimented and use Bootstrap site wide. Check the /app/assets/javascripts/component and the /app/assets/javascripts/generators and the /app/assets/javascripts/alert files

Things that work
================

 - [x] Generator creation
 - [x] Generator deletion
 - [x] Sign in
 - [x] List generators
 - [x] Download generators in valid .obj format

Things that almost work
=======================

 - [ ] Rendering 3D terrain in the browser
 - [ ] Sign up (hopefully will be fixed soon)

Things that do not work
=======================

 - [ ] Editing generators after created
