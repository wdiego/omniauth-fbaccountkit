######################################################################################
#
#
#
#
#
#
######################################################################################

require 'omniauth'

module OmniAuth
  module Strategies
    class FBAccountKit
      include OmniAuth::Strategy

      attr_accessor :user_data
      attr_accessor :token_data

      GRANT_TYPE = 'authorization_code'
      DEFAULT_API_VERSION = 'v1.0'

      args [:client_id, :client_secret]
      
      option :name, 'fbaccountkit'

      option :api_version, nil

      option :require_app_secret, true

      option :client_options, 
        {
          :access_token_url => "https://graph.accountkit.com/v1.0/access_token",
          :me_url => "https://graph.accountkit.com/v1.0/me"
        }

      option :app_access_token, ['AA', :client_id, :client_secret].join('|')

      uid { raw_info['id'] }

      info do
        {
          :email => raw_info['email.address'],
          :phone => raw_info['phone.number']
        }
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end

      credentials do 
        {
          :token => token_data["request_token"]
        }
      end


      def raw_info
        @raw_info ||= user_data
      end

      ############################################################################
      # Phase methods
      ############################################################################

      def request_phase
        omniauth_params = env["omniauth.params"]
        code = omniauth_params["code"]

        #https://graph.accountkit.com/v1.0/access_token?grant_type=authorization_code&code=<authorization_code>&access_token=AA|<facebook_app_id>|<app_secret>
        #{
        #  "id" : <account_kit_user_id>,
        #  "access_token" : <account_access_token>,
        #  "token_refresh_interval_sec" : <refresh_interval>
        #}
        resp = Faraday.get access_token_uri(code)
        request_token = resp.body.access_token
        
        session["omniauth.fbaccountkit"] ||= {}
        session["omniauth.fbaccountkit"] = { "request_token" => request_token }

        #redirecionar para o callback com os parâmetros
        redirect callback_url

      end

      def callback_phase
        #pegar o access token e recuperar os dados de uid, email e telefone
        #GET https://graph.accountkit.com/v1.0/me/?access_token=<access_token>
        #{  
        #   "id":"12345",
        #   "phone":{  
        #      "number":"+15551234567"
        #      "country_prefix": "1",
        #      "national_number": "5551234567"
        #   }
        #}
        resp = Faraday.get me_uri(session["omiauth.fbaccountkit"].delete("request_token"))

        @user_data = resp.body
        @token_data = session["omniauth.fbaccountkit"]

      end

      ############################################################################
      # Private methods
      ############################################################################

      private

      def access_token_uri(code)
        uri = URI(option.client_options['access_token_url'])
        uri.query = URI.encode_www_form(access_token_params(code))
        uri
      end

      def me_uri(access_token)
        uri = URI(option.client_option['me_url'])
        uri.query = URI.encode_www_form(me_params(access_token))
        uri
      end

      def access_token_params(code)
        {
          grant_type: GRANT_TYPE,
          code: code,
          access_token: app_access_token
        }
      end

      def me_params(access_token)
          params = { access_token: nil }
          params[:appsecret_proof] = appsecret_proof(access_token) if option.require_app_secret
      end

      def api_version
        option.api_version || DEFAULT_API_VERSION
      end

    end
  end
end

OmniAuth.config.add_camelization "fbaccountkit", "FBAccountKit"
