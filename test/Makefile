doc:
	@echo "make all" 
	@echo "make curl_form"
	@echo "make curl_static"
	@echo "make curl_files_upload"
	@echo "make curl_stream_upload"

curl_form:
	curl --location 'http://localhost:8080/form' \
		--header 'Content-Type: application/x-www-form-urlencoded' \
		--data-urlencode 'message=le message !!'

curl_static:
	curl --location 'http://localhost:8080/static/a.html' 

curl_files_upload:
	curl --location 'http://localhost:8080/files_upload' \
		--form 'files=@"file_A"' \
		--form 'files=@"file_B"'

curl_stream_upload:
	curl --location 'http://localhost:8080/stream_upload' \
		--form 'files=@"file_A"' \
		--form 'files=@"file_B"'
