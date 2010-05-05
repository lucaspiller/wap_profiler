require 'init'

$stdout.sync = true

CHILDREN = 10
SIGNALS = %w{ TERM HUP INT }

CHILDREN.times do |n|
  fork do
    @running = true

    SIGNALS.each do |sig|
      trap(sig) do
        @running = false
        abort "Child ##{n} caught #{sig}"
      end
    end

    while @running
      attempted = 0
      UaProf.find(:status => 'pending').each do |uaprof|
        break if uaprof.mutex_no_wait do
          puts "Child ##{n} got lock on #{uaprof.id}"

          uaprof.process!

          puts "Child ##{n} released lock on #{uaprof.id}"
        end

        # this stops us processing everything event after a kill
        # signal has been received
        break if (attempted += 1) > CHILDREN
      end

      # don't go killing redis
      sleep 5
    end
  end
end

SIGNALS.each do |sig|
  trap(sig) do
    puts "Watcher caught #{sig}"
  end
end

Process.waitall
