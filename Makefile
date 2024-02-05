.PHONY: docs

docs:
	swift package \
		--allow-writing-to-directory "docs" \
		generate-documentation \
		--target SwiftErrorKit \
		--disable-indexing \
		--transform-for-static-hosting \
		--hosting-base-path swift-error-kit \
		--output-path "docs"
