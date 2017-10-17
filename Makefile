.PHONY: build deploy clean

build: themes/foxquill/static/static/main.min.css
	rm -rf public/*
	hugo
	./node_modules/.bin/html-minifier -c html-minifier.json --file-ext=html --input-dir=public/ --output-dir=public/
	cd public && ../tools/freeze.py
	find ./public \( -name "*.html" -o -name "*.js" -o -name "*.css" -o -name "*.svg" -o -name "*.xml" -o -name "*.ico" \) -exec zopfli {} --i50 \; -exec brotli {} \;

deploy: build
	fab deploy -H andrew@foxquill.com -s "/bin/ksh -c"

clean:
	rm -rf themes/foxquill/static/static/main.min.css public

themes/foxquill/static/static/main.min.css: themes/foxquill/static/static/main.css
	hasp $^ | ./node_modules/.bin/cleancss -O2 restructureRules:on,mergeSemantically:on -o $@
