build:
	docker build -t ssg:latest .

run: build
	docker run -it -p 8080:8080 -e PORT=8080 ssg:latest