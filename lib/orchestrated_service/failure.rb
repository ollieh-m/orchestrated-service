module OrchestratedService

  class Failure
    include Rails.application.routes.url_helpers if defined?(Rails)

    attr_reader :reason, :type

    def initialize(reason, **options)
      @reason = reason
      @type = options[:type]
      @next = options[:next]
      @alert = options[:alert]
    end

    def now
      type == :now
    end

    def alert
      @alert || reason
    end

    def next
      if @next && @next.to_s =~ /path/
        send(@next)
      elsif @next
        @next
      else
        root_path
      end
    end
  end

end
