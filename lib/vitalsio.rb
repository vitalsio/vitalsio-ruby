require 'net/https'
require 'cgi'
require 'uri'
require 'redis'
require 'json'

module VitalsIO
  HIGHEST_PRIORITY = "highest"
  HIGH_PRIORITY = "high"
  NORMAL_PRIORITY = "normal"
  LOW_PRIORITY = "low"
  LOWEST_PRIORITY = "lowest"

  def self.priority_string_to_int(priority)
    case priority
    when HIGHEST_PRIORITY
      5
    when HIGH_PRIORITY
      4
    when LOW_PRIORITY
      2
    when LOWEST_PRIORITY
      1
    else
      3
    end
  end

  def self.priority_int_to_string(priority)
    if priority > 4
      HIGHEST_PRIORITY
    elsif priority > 3
      HIGH_PRIORITY
    elsif priority > 2
      NORMAL_PRIORITY
    elsif priority > 1
      LOW_PRIORITY
    else
      LOWEST_PRIORITY
    end
  end

  class API
    def initialize(apikey, redis = nil, server = nil)
      @apikey = apikey
      if redis.nil?
        @redis = Redis.new(host: 'mccoy.coreapps.xyz', port: 6370)
        puts "Initialized VitalsIO::API without specifying a redis connection. Please pass in a redis connection."
      else
        @redis = redis
      end
      @server = server || `hostname`.strip
    end

    @debug = false
    def debug!
      @debug = true
    end

    def call_api(method, params)
      params[:server] = @server
      ts = Time.now.to_i
      begin
        @redis.lpush("vitalsio_api", {
          method: method,
          params: params,
          timestamp: ts,
          auth: Digest::SHA1.hexdigest(@server + ts.to_s + @apikey)
        }.to_json)
        return "OK"
      rescue => exc
        if @debug
          raise exc
        end
        return nil
      end
    end

    def start_task(project, property, task)
      params = {}
      params[:project] = project if project
      params[:task] = task if task
      params[:property] = property if property

      call_api("start", params)
    end

    def task_progress(project, property, task, subtask)
      params = {}
      params[:project] = project if project
      params[:task] = task if task
      params[:property] = property if property
      params[:subtask] = subtask if subtask

      call_api("progress", params)
    end

    def complete_task(project, property, task)
      params = {}
      params[:project] = project if project
      params[:task] = task if task
      params[:property] = property if property

      call_api("complete", params)
    end

    def archive_task(project, property, task)
      params = {}
      params[:project] = project if project
      params[:task] = task if task
      params[:property] = property if property

      call_api("archive", params)
    end

    def report_task_error(project, property, task, message)
      params = {}
      params[:project] = project if project
      params[:task] = task if task
      params[:property] = property if property
      params[:error] = message

      call_api("error", params)
    end

    def configure_task(project, property, task, priority, repeat_every)
      params = {}
      params[:property] = property if property
      params[:project] = project if project
      params[:task] = task if task
      params[:priority] = VitalsIO.priority_string_to_int(priority)
      params[:repeats] = repeat_every

      call_api("configure", params)
    end

    def configure_property(project, property, priority)
      raise "Unimplemented "
    end
  end
end
