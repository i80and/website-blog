.PHONY: build deploy

build:
	hugo
	./node_modules/.bin/html-minifier -c html-minifier.json --file-ext=html --input-dir=public/ --output-dir=public/
	find ./public \( -name "*.html" -o -name "*.js" -o -name "*.css" -o -name "*.svg" -o -name "*.xml" -o -name "*.ico" \) -exec zopfli {} --i50 \; -exec bro --input {} --output {}.bro \;

deploy: build
	fab deploy -H andrew@foxquill.com -s "/bin/ksh -c"
