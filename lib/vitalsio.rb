require 'net/https'
require 'cgi'
require 'uri'

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
    when NORMAL_PRIORITY
      3
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
    def initialize(apikey, server = nil)
      @apikey = apikey
      @base_uri = "https://vitals.io/api/1"
      @server = server || `hostname`.strip
    end

    @debug = false
    def debug!
      @debug = true
    end

    def call_api(url, params)
      uri = URI.parse(url + "?".concat(params.find_all{|k,v| v != nil}.collect{|k, v| "#{k}=#{CGI.escape(v)}"}.join("&")))
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 2
      http.open_timeout = 2
      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      request = Net::HTTP::Get.new(uri.path + "?" + uri.query)
      puts ">>> " + request.path if @debug
      begin
        response = http.request(request)
        puts "<<< " + response.body if @debug
        return response.body
      rescue => exc
        if @debug
          raise exc
        end
        return nil
      end
    end

    def start_task(project, property, task)
      params = {}
      params[:property] = property if property

      call_api("#{@base_uri}/#{CGI.escape(@apikey)}/#{CGI.escape(@server)}/#{CGI.escape(project)}/#{CGI.escape(task)}/start", params)
    end

    def task_progress(project, property, task, subtask)
      params = {}
      params[:property] = property if property
      params[:subtask] = subtask if subtask

      call_api("#{@base_uri}/#{CGI.escape(@apikey)}/#{CGI.escape(@server)}/#{CGI.escape(project)}/#{CGI.escape(task)}/progress", params)
    end

    def complete_task(project, property, task)
      params = {}
      params[:property] = property if property

      call_api("#{@base_uri}/#{CGI.escape(@apikey)}/#{CGI.escape(@server)}/#{CGI.escape(project)}/#{CGI.escape(task)}/complete", params)
    end

    def archive_task(project, property, task)
      params = {}
      params[:property] = property if property

      call_api("#{@base_uri}/#{CGI.escape(@apikey)}/#{CGI.escape(@server)}/#{CGI.escape(project)}/#{CGI.escape(task)}/archive", params)
    end

    def report_task_error(project, property, task, message)
      params = {}
      params[:property] = property if property
      params[:error] = message

      call_api("#{@base_uri}/#{CGI.escape(@apikey)}/#{CGI.escape(@server)}/#{CGI.escape(project)}/#{CGI.escape(task)}/error", params)
    end

    def configure_task(project, property, task, priority, repeat_every)
      params = {}
      params[:property] = property if property
      params[:priority] = priority
      params[:repeats] = repeat_every.to_s

      call_api("#{@base_uri}/#{CGI.escape(@apikey)}/#{CGI.escape(@server)}/#{CGI.escape(project)}/#{CGI.escape(task)}/configure", params)
    end

    def configure_property(project, property, priority)
      raise "Unimplemented "
    end
  end
end
