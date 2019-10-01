.PHONY: build deploy clean

build: themes/foxquill/static/static/main.min.css node_modules/.EXISTS
	rm -rf public/*
	hugo
	./node_modules/.bin/html-minifier -c html-minifier.json --file-ext=html --input-dir=public/ --output-dir=public/
	cd public && ../tools/freeze.py
	find ./public \( -name "*.html" -o -name "*.js" -o -name "*.css" -o -name "*.svg" -o -name "*.xml" -o -name "*.ico" \) -exec zopfli {} --i50 \; -exec brotli {} \;

clean:
	-rm -r themes/foxquill/static/static/main.min.css
	-rm -r public
	-rm -r node_modules
	-rm -r resources

themes/foxquill/static/static/main.min.css: themes/foxquill/static/static/main.css node_modules/.EXISTS
	tools/hasp $^ | ./node_modules/.bin/cleancss -O2 restructureRules:on,mergeSemantically:on -o $@

node_modules/.EXISTS:
	npm install
	touch $@
