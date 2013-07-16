require 'active_support/core_ext/string/inflections'
require 'active_support/hash_with_indifferent_access'

module Reveille
  module Event
    # include Celluloid
    # include Celluloid::Notifications

    autoload :Handler,      'reveille/event/handler'
    autoload :HandlerMixin, 'reveille/event/handler_mixin'
    autoload :Hook,         'reveille/event/hook'
    autoload :Job,          'reveille/event/job'
    autoload :Payload,      'reveille/event/payload'
    autoload :Subscription, 'reveille/event/subscription'

    class << self
      def handlers
        @handlers ||= hash_from_constant(Event::Handler)
      end

      def jobs
        @jobs ||= hash_from_constant(Event::Job)
      end

      def hooks
        @hooks ||= hash_from_constant(Event::Hook)
      end

      # Due to Rails' preference for autoloading, we call every source here
      # because I have no idea what I'm doing.
      def sources
        @sources ||= Hash[{
                            incident: Incident,
                            policy: Policy,
                            policy_rule: PolicyRule,
                            schedule: Schedule,
                            schedule_layer: ScheduleLayer,
                            service: Service,
                            user: User
        }.sort].with_indifferent_access
      end

      def events
        @events ||= begin
          array = %w[ * ]
          sources.each do |name, klass|
            keys = klass.events.map {|event| "#{name}.#{event}" }
            array.concat %W[ #{name}.* ]
            array.concat keys
            array
          end
          array.sort
        end
      end

      def hash_from_constant(constant)
        Hash[constant.constants(false).map { |c| [c.to_s.underscore, constant.const_get(c)] }.sort]
      end
      private :hash_from_constant

    end

    def global_hooks
      Reveille::Event.hooks.values.uniq.map(&:new)
    end

    def hooks
      self.account.hooks.active + global_hooks
    end

    # TODO(dryan): how do we add default global hooks, like incident handling?
    def subscriptions
      @subscriptions ||= hooks.map do |hook|
        subscription = Event::Subscription.new(hook)
        subscription if subscription.handler
      end.compact
    end

    # Global subscriptions, for things that are not customized per-account (triggering, logging, etc)
    def global_subscriptions
    end

    def dispatch(event, source)
      subscriptions.each do |subscription|
        subscription.notify(format_event(event, source), source)
      end
      Rails.logger.info format_event(event, source)
    end


    def format_event(event, source)
      # event = "#{event}ed".gsub(/eded$|eed$/, 'ed') unless [:log, :ready].include?(event)
      namespace = source.class.name.underscore.gsub('/', '.')
      [namespace, event].join('.')
    end
    protected :format_event
  end
end
