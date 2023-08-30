#!/usr/bin/env ruby
# frozen_string_literal: true

require 'influxdb'
require 'thor'
require 'yaml'

require 'debug'
require 'method_source'
require 'pry'
# require 'pry_doc'

module Kernel
  def with_rescue(exceptions, logger, retries: 5, nap: 0)
    try = 0
    begin
      yield try
    rescue *exceptions => e
      try += 1
      raise if try > retries

      logger.warn "caught error #{e.inspect}, retrying (#{try}/#{retries})..."
      sleep nap
      retry
    end
  end
end

class BotBase < Thor
  attr_accessor :bot_name, :logger

  # useful for developing new features, hiding them from normal execution
  class_option :experimental, type: :boolean, aliases: '-X', desc: 'enable experimental features'

  no_commands do
    def initialize(_args = [], _local_options = {}, _config = {})
      @bot_name = self.class.to_s.downcase
      super
    end

    private

    def redirect_output
      logfile_path = File.expand_path(File.join(Dir.home, '.log', "#{bot_name}.log"))
      FileUtils.mkdir_p(File.dirname(logfile_path), mode: 0o755)
      FileUtils.touch logfile_path
      File.chmod 0o644, logfile_path
      $stdout.reopen logfile_path, 'a'
      $stderr.reopen $stdout
      $stdout.sync = $stderr.sync = true
    end

    protected

    def setup_logger
      redirect_output if options[:log]

      @logger = Logger.new $stdout
      @logger.level = options[:verbose] ? Logger::DEBUG : Logger::INFO
    end

    def load_credentials(source = bot_name)
      credentials_path = File.join(Dir.home, '.credentials', "#{source}.yaml")
      YAML.load_file credentials_path
    end

    def store_credentials(credentials, source = bot_name)
      credentials_path = File.join(Dir.home, '.credentials', "#{source}.yaml")
      File.open(credentials_path, 'w') { |file| file.write(credentials.to_yaml) }
    end

    def new_influxdb_client(db = bot_name)
      credentials_path = File.join(Dir.home, '.credentials', 'influx.yaml')
      influx_credentials = YAML.load_file credentials_path
      username = influx_credentials[:username]
      password = influx_credentials[:password]
      host = influx_credentials[:host]
      influxdb = InfluxDB::Client.new(db, host: host, username: username, password: password) unless options[:dry_run]
      influxdb
    end

    public

    def main
      puts "please provide (override) #{self.class}::#{__method__}"
    end
  end

  class_option :log,     type: :boolean, default: true, desc: 'log output to ~/.log/'
  class_option :verbose, type: :boolean, aliases: '-v', desc: 'increase verbosity'
end

class ScannerBotBase < BotBase
  desc 'scan', 'scan source and send notifications'
  method_option :dry_run, type: :boolean, aliases: '-n', desc: "don't send notifications"
  def scan
    setup_logger

    @logger.info 'starting'
    # credentials = load_credentials
    main
    @logger.info 'done'
  rescue StandardError => e
    @logger.error (["caught exception #{e.inspect}"] + e.backtrace).join("\n")
  end

  default_task :scan
end

class RecorderBotBase < BotBase
  desc 'record-status', 'record the current usage data to database'
  method_option :dry_run, type: :boolean, aliases: '-n', desc: "don't write to database"
  def record_status
    setup_logger

    @logger.info 'starting'
    # credentials = load_credentials
    main
    @logger.info 'done'
  rescue StandardError => e
    @logger.error (["caught exception #{e.inspect}"] + e.backtrace).join("\n")
  end

  default_task :record_status
end
