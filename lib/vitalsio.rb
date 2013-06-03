require 'net/https'
require 'cgi'
require 'uri'

module VitalsIO
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
      if uri.scheme == 'https'
        http.use_ssl = true
        http.ca_file = File.expand_path("../ca.crt", File.dirname(__FILE__))
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

    def report_task_error(project, property, task, message)
      params = {}
      params[:property] = property if property
      params[:error] = message

      call_api("#{@base_uri}/#{CGI.escape(@apikey)}/#{CGI.escape(@server)}/#{CGI.escape(project)}/#{CGI.escape(task)}/error", params)
    end

    def configure_task(project, isPropertyBased, task, priority, repeat_every)
      params = {}
      params[:propertyBased] = "true" if isPropertyBased
      params[:priority] = priority
      params[:repeats] = repeat_every.to_s

      call_api("#{@base_uri}/#{CGI.escape(@apikey)}/#{CGI.escape(@server)}/#{CGI.escape(project)}/#{CGI.escape(task)}/configure", params)
    end

    def configure_property(project, property, priority)
      raise "Unimplemented "
    end
  end
end
