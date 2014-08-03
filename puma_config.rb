min_threads = ENV['MIN_THREADS'] || 0
max_threads = ENV['MAX_THREADS'] || 16

threads min_threads, max_threads

port ENV['PORT'] || 3000

environment ENV['RACK_ENV'] || 'development'
