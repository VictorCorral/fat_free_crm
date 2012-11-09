{:environment => 'production',
:jruby_max_runtimes => 1,
:jruby_min_runtimes => 1,
:port => 4000,
:extensions =>
  {:daemon =>
      {:pid => "#{File.dirname __FILE__}/../tmp/pids/trinidad.pid"}
  }
}
