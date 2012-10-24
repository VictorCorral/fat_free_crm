# http://michaelvanrooijen.com/articles/2011/06/01-more-concurrency-on-a-single-heroku-dyno-with-the-new-celadon-cedar-stack/

worker_processes 2 # amount of unicorn workers to spin up
timeout 30         # restarts workers that hang for 30 seconds
# By default, the Unicorn logger will write to stderr.
# Additionally, ome applications/frameworks log to stderr or stdout,
# so prevent them from going to /dev/null when daemonized here:
stderr_path "#{Rails.root}/log/unicorn.stderr.log"
stdout_path "#{Rails.root}/log/unicorn.stdout.log"
listen 4000
