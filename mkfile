MKSHELL = rc
sitedir = site
destdir = .

dist = template style.css nav_template path_template
tools = site-gen tools/build_site tools/configure tools/postprocess

install:V:
	mkdir -p $destdir $sitedir
	if(! ~ $destdir . '')
		cp $tools $destdir
	cp $dist $sitedir 
