require 'active_job/logging'

module Lograge
  class JobSubscriber < ActiveJob::Logging::LogSubscriber
    def enqueue(event)
      job = event.payload[:job]
      message = "Enqueued #{job.class.name} (Job ID: #{job.job_id}) to #{queue_name(event)}"
      process_event(event, message, 'enqueue')
    end

    def enqueue_at(event)
      job = event.payload[:job]
      message = "Enqueued #{job.class.name} (Job ID: #{job.job_id}) to #{queue_name(event)} at #{scheduled_at(event)}"
      process_event(event, message, 'enqueue_at')
    end

    def perform(event)
      job = event.payload[:job]
      message = "Performed #{job.class.name} (Job ID: #{job.job_id}) from #{queue_name(event)} in #{event.duration.round(2)}ms"
      process_event(event, message, 'perform')
    end

    def perform_start(event)
      job = event.payload[:job]
      message = "Performing #{job.class.name} (Job ID: #{job.job_id}) from #{queue_name(event)}"
      process_event(event, message, 'perform_start')
    end

    def logger
      Lograge.logger.presence || super
    end

    private

    def process_event(event, message, type)
      data = extract_metadata(event)
      data.merge! extract_exception(event)
      data.merge! extract_scheduled_at(event) if type == 'enqueue_at'
      data.merge! extract_duration(event) if type == 'perform'
      tags = ['job']
      tags.push('exception') if data[:exception]
      data.merge!(state: type)
      data.merge!(tags: tags)
      data.merge!(message: message)

      payload = event.payload
      data = before_format(data, payload)

      formatted_message = Lograge.formatter.call(data, 'job')
      logger.send(Lograge.log_level, formatted_message)
    end

    def extract_metadata(event)
      { job_id: event.payload[:job].job_id,
        queue_name: event.payload[:job].queue_name,
        job_class: event.payload[:job].class.to_s,
        job_args: args_info(event.payload[:job]).compact }
    end

    def extract_duration(event)
      { duration: event.duration.to_f.round(2) }
    end

    def extract_exception(event)
      event.payload.slice(:exception)
    end

    def extract_scheduled_at(event)
      { scheduled_at: scheduled_at(event) }
    end

    def args_info(job)
      job.arguments.map { |arg| arg.try(:to_global_id).try(:to_s) || arg }
    end

    def before_format(data, payload)
      Lograge.before_format(data, payload)
    end
  end
end
