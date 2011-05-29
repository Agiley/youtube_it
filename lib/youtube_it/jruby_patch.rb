if (defined?(JRUBY_VERSION) && RUBY_VERSION >= "1.9")
  #Bug in JRuby 1.9 -> http://jira.codehaus.org/browse/JRUBY-5529
  Net::BufferedIO.class_eval do
    BUFSIZE = 1024 * 16

    def rbuf_fill
      timeout(@read_timeout) {
        @rbuf << @io.sysread(BUFSIZE)
      }
    end
  end
end