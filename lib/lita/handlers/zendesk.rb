require 'base64'
require 'faraday'
require 'faraday_middleware'

module Lita
  module Handlers
    class Zendesk < Handler
      is_command = false

      VERSION_URL = 'api/v2'
      QUERY_SEARCH_PREFIX = 'search.json?query='
      QUERY_TICKETS_SEARCH = 'search.json?query=type:ticket '
      QUERY_TICKETS_ALL = 'tickets'
      QUERY_TICKETS_ESCALATED = 'search.json?query=tags:escalated+status:open+status:pending+type:ticket'
      QUERY_TICKETS_HOLD = 'search.json?query=status:hold+type:ticket'
      QUERY_TICKETS_OPEN = 'search.json?query=status:open+type:ticket'
      QUERY_TICKETS_NEW = 'search.json?query=status:new+type:ticket'
      QUERY_TICKETS_PENDING = 'search.json?query=status:pending+type:ticket'
      QUERY_TICKETS_UNSOLVED = 'search.json?query=status<solved+type:ticket'
      QUERY_USERS = 'users'

      config :subdomain, type: String, required: true
      config :auth_type, type: String, default: 'password' # or token
      config :user, type: String, required: true
      config :token, type: String, default: ''
      config :password, type: String, default: ''

      def check_client(reload = false)
        return if @conn && !reload
        @base_url = base_url
        @version_url = "#{@base_url}/#{VERSION_URL}"
        @tickets_url = "#{@base_url}/tickets"

        if config.auth_type == 'password'
          @conn = Faraday.new(url: @version_url) do |faraday|
            faraday.headers['Authorization'] = "Basic #{basic_credentials}"
            faraday.response :json                    # JSON response
            faraday.response :logger                  # log requests to STDOUT
            faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
          end
        else
          @conn = Faraday.new(url: @version_url) do |faraday|
            faraday.response :json                    # JSON response
            faraday.response :logger                  # log requests to STDOUT
            faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
          end
          @conn.basic_auth("#{config.user}/token", config.token) 
        end
      end

      def base_url
        "https://#{config.subdomain.to_s}.zendesk.com"
      end

      def basic_credentials
        Base64.encode64("#{config.user}:#{config.password}").gsub(/\s/,'')
      end

      def zendesk_request(url)
        check_client
        if url.index('http') != 0
          url = "#{@version_url}/#{url}"
        end
        @conn.get url
      end

      # General

      route(/^(?:zd|zendesk)\s+connection\s*$/, :zd_instance_info, command: true, help: { 'zd connection' => 'returns information on the Zendesk connection' })
      def zd_instance_info(response)
        response.reply "Using Zendesk instance at: #{base_url}"
      end

      route(/^(?:zd|zendesk)\s+search\s+tickets?\s+(\S.*?)\s*$/, :search_tickets, command: true, help: { 'zd search tickets <QUERY>' => 'returns search results' })
      def search_tickets(response)
        ticket_search response, QUERY_TICKETS_SEARCH, response.matches[0][0]
      end

      # Ticket Counts

      route(/^(?:zd|zendesk)(\s+unsolved)?\s+tickets?\s*$/, :unsolved_tickets, command: true, help: { 'zd tickets' => 'returns the total count of all unsolved tickets' })
      def unsolved_tickets(response)
        ticket_count response, QUERY_TICKETS_UNSOLVED, 'unsolved'
      end

      route(/^(?:zd|zendesk)\s+(all|total)\s+tickets?\s*$/, :total_tickets, command: true, help: { 'zd all tickets' => 'returns the count of all tickets' })
      def total_tickets(response)
        ticket_count response, QUERY_TICKETS_ALL, 'total'
      end

      route(/^(?:zd|zendesk)\s+pending\s+tickets?\s*$/, :pending_tickets, command: true, help: { 'zd pending tickets' => 'returns a count of tickets that are pending' })
      def pending_tickets(response)
        ticket_count response, QUERY_TICKETS_PENDING, 'pending'
      end

      route(/^(?:zd|zendesk)\s+new\s+tickets?\s*$/, :new_tickets, command: true, help: { 'zd new tickets' => 'returns the count of all new (unassigned) tickets' })
      def new_tickets(response)
        ticket_count response, QUERY_TICKETS_NEW, 'new'
      end

      route(/^(?:zd|zendesk)\s+escalated\s+tickets?\s*$/, :escalated_tickets, command: true, help: { 'zd escalated tickets' => 'returns a count of tickets with escalated tag that are open or pending' })
      def escalated_tickets(response)
        ticket_count response, QUERY_TICKETS_ESCALATED, 'escalated'
      end

      route(/^(?:zd|zendesk)\s+open\s+tickets?\s*$/, :open_tickets, command: true, help: { 'zd open tickets' => 'returns the count of all open tickets' })
      def open_tickets(response)
        ticket_count response, QUERY_TICKETS_OPEN, 'open'
      end

      route(/^(?:zd|zendesk)\s+on\s+hold\s+tickets?\s*$/, :onhold_tickets, command: true, help: { 'zd on hold tickets' => 'returns the count of all on hold tickets' })
      def onhold_tickets(response)
        ticket_count response, QUERY_TICKETS_HOLD, 'on hold'
      end

      # Ticket Lists

      route(/^(?:zd|zendesk)\s+list(\s+unsolved)?\s+tickets?\s*$/, :unsolved_tickets_list, command: true, help: { 'zd list tickets' => 'returns a list of unsolved tickets' })
      def unsolved_tickets_list(response)
        ticket_list response, QUERY_TICKETS_UNSOLVED, 'unsolved'
      end

      route(/^(?:zd|zendesk)\s+list\s+(all|total)\s+tickets?\s*$/, :total_tickets_list, command: true, help: { 'zd list all tickets' => 'returns a list of all tickets' })
      def total_tickets_list(response)
        ticket_list response, QUERY_TICKETS_ALL, 'total'
      end

      route(/^(?:zd|zendesk)\s+list\s+pending\s+tickets?\s*$/, :pending_tickets_list, command: true, help: { 'zd list pending tickets' => 'returns a list of pending tickets' })
      def pending_tickets_list(response)
        ticket_list response, QUERY_TICKETS_PENDING, 'pending'
      end

      route(/^(?:zd|zendesk)\s+list\s+new\s+tickets?\s*$/, :new_tickets_list, command: true, help: { 'zd list new tickets' => 'returns a list of new tickets' })
      def new_tickets_list(response)
        ticket_list response, QUERY_TICKETS_NEW, 'new'
      end

      route(/^(?:zd|zendesk)\s+list\s+escalated\s+tickets?\s*$/, :escalated_tickets_list, command: true, help: { 'zd list esclated tickets' => 'returns a list of escalated tickets' })
      def escalated_tickets_list(response)
        ticket_list response, QUERY_TICKETS_ESCALATED, 'escalated'
      end

      route(/^(?:zd|zendesk)\s+list\s+open\s+tickets?\s*$/, :open_tickets_list, command: true, help: { 'zd list open tickets' => 'returns a list of open tickets' })
      def open_tickets_list(response)
        ticket_list response, QUERY_TICKETS_OPEN, 'open'
      end

      route(/^(?:zd|zendesk)\s+list\s+on\s+hold\s+tickets?\s*$/, :onhold_tickets_list, command: true, help: { 'zd list onhold tickets' => 'returns a list of on hold tickets' })
      def onhold_tickets_list(response)
        ticket_list response, QUERY_TICKETS_HOLD, 'on hold'
      end

      # Ticket Details

      route(/^(?:zd|zendesk)\s+ticket\s+(\d+)\s*$/, :ticket_details, command: true, help: { 'zd ticket <ID>' => 'returns information about the specified ticket' })
      def ticket_details(response)
        ticket_id = response.matches[0][0]
        url = "#{QUERY_TICKETS_ALL}/#{ticket_id}.json"
        res = zendesk_request url
        data = res.body

        message = "Ticket #{data['ticket']['id']}: #{@tickets_url}/#{data['ticket']['id']}"
        message += "\nStatus: #{data['ticket']['status'].upcase}"
        message += "\nUpdated: " + data['ticket']['updated_at']
        message += "\nAdded: #{data['ticket']['created_at']}"
        message += "\nSubject: #{data['ticket']['subject']}"
        message += "\nDescription:\n-----\n#{data['ticket']['description']}\n-----\n"
        response.reply message
      end

      private

      def ticket_count(response, url, ticket_type = '')
        res = zendesk_request url
        ticket_count = res.body['count']
        ticket_word  = ticket_count == 1 ? 'ticket' : 'tickets'
        ticket_desc  = ticket_type == '' ? '' : "#{ticket_type} "
        response.reply "#{ticket_count} #{ticket_desc}#{ticket_word}."
      end

      def ticket_search(response, url, query)
        url += query
        res = zendesk_request url
        tickets = res.body['results']
        tickets.each do |ticket|
          response.reply "Ticket #{ticket['id']} is #{ticket['status']}: #{@tickets_url}/#{ticket['id']} - #{ticket['subject']}"
        end
        ticket_length = tickets.length
        ticket_count = res.body['count']
        ticket_word  = ticket_count == 1 ? 'result' : 'results'
        response.reply "Listing #{ticket_length} of #{ticket_count} matching #{ticket_word}."
      end

      def ticket_list(response, url, ticket_type = '')
        res = zendesk_request url
        tickets = res.body['results']
        tickets.each do |ticket|
          response.reply "Ticket #{ticket['id']} is #{ticket['status']}: #{@tickets_url}/#{ticket['id']} - #{ticket['subject']}"
        end
        ticket_length = tickets.length
        ticket_count = res.body['count']
        ticket_word  = ticket_count == 1 ? 'ticket' : 'tickets'
        ticket_desc  = ticket_type == '' ? '' : "#{ticket_type} "
        response.reply "Listing #{ticket_length} of #{ticket_count} #{ticket_desc}#{ticket_word}."
      end

      def tickets(count)
        count == 1 ? 'ticket' : 'tickets'
      end
    end

    Lita.register_handler(Zendesk)
  end
end