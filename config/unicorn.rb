# http://michaelvanrooijen.com/articles/2011/06/01-more-concurrency-on-a-single-heroku-dyno-with-the-new-celadon-cedar-stack/

worker_processes 2 # amount of unicorn workers to spin up
timeout 30         # restarts workers that hang for 30 seconds
listen 4000
