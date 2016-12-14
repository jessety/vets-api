# frozen_string_literal: true
require 'common/client/configuration'
require 'common/client/middleware/response/json_parser'
require 'common/client/middleware/response/raise_error'
require 'common/client/middleware/response/snakecase'

module EVSS
  module MHVCF
    class Configuration < Common::Client::Configuration
      def base_path
        'https://pint.vdc.va.gov:444/wssweb/domain1/vii-app-1.2/rest'
      end

      def service_name
        'MHVCF'
      end

      # :nocov:
      def ssl_options
        {
          version: :TLSv1_2,
          verify: true,
          client_cert: client_cert,
          client_key: client_key,
          ca_file: root_ca
        }
      end

      def client_cert
        OpenSSL::X509::Certificate.new File.read(ENV['EVSS_CERT_FILE_PATH'])
      end

      def client_key
        OpenSSL::PKey::RSA.new File.read(ENV['EVSS_CERT_KEY_PATH'])
      end

      def root_ca
        ENV['EVSS_ROOT_CERT_FILE_PATH']
      end
      # :nocov:

      def connection
        Faraday.new(base_path, headers: base_request_headers, request: request_options) do |conn|
          conn.use :breakers
          conn.request :json
          # Uncomment this out for generating curl output to send to MHV dev and test only
          conn.request :curl, ::Logger.new(STDOUT), :warn

          conn.response :logger, ::Logger.new(STDOUT), bodies: true
          conn.response :snakecase
          conn.response :json_parser

          conn.adapter Faraday.default_adapter
        end
      end
    end
  end
end