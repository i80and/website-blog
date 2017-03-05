.PHONY: build deploy

build:
	hugo
	find ./public -name "*.html" -exec zopfli {} --i50 \;
	find ./public -name "*.js" -exec zopfli {} --i50 \;
	find ./public -name "*.css" -exec zopfli {} --i50 \;
	find ./public -name "*.svg" -exec zopfli {} --i50 \;
	find ./public -name "*.xml" -exec zopfli {} --i50 \;
	find ./public -name "*.ico" -exec zopfli {} --i50 \;

deploy: build
	fab deploy -H andrew@foxquill.com -s "/bin/ksh -c"
