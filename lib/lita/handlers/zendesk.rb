require 'zendesk_api'

module Lita
  module Handlers
    class Zendesk < Handler

      API_VERSION_URL_PATH = 'api/v2'
      WEB_TICKETS_URL_PATH = 'tickets'
      QUERY_TICKETS_ALL = 'type:ticket'
      QUERY_TICKETS_ESCALATED = 'type:ticket tags:escalated status:open status:pending'
      QUERY_TICKETS_HOLD = 'type:ticket status:hold'
      QUERY_TICKETS_OPEN = 'type:ticket status:open'
      QUERY_TICKETS_NEW = 'type:ticket status:new'
      QUERY_TICKETS_PENDING = 'type:ticket status:pending'
      QUERY_TICKETS_UNSOLVED = 'type:ticket status<solved'
      QUERY_USERS = 'users'

      config :subdomain, type: String, required: true
      config :username, type: String, required: true
      config :token, type: String, default: ''
      config :password, type: String, default: ''

      config :max_results, type: Integer, default: 10

      def client
        return @_client if @_client
        Lita.logger.info "#{logger_prefix}Connecting Zendesk Client to #{api_version_url}"
        @_client = ZendeskAPI::Client.new do |client|
          client.url = api_version_url.to_s
          client.username = config.username || config.user
          client.token = config.token
          client.password = config.password
        end
      end

      def base_url
        "https://#{config.subdomain}.zendesk.com"
      end

      def api_version_url
        uri_join base_url, API_VERSION_URL_PATH
      end

      def web_tickets_url
        uri_join base_url, WEB_TICKETS_URL_PATH
      end

      # General

      route(/^(?:zd|zendesk)\s+connection\s*$/i, :zd_instance_info, command: true, help: { 'zd connection' => 'returns information on the Zendesk connection' })
      def zd_instance_info(response)
        response.reply "Using Zendesk instance at: #{base_url}"
      end

      route(/^(?:zd|zendesk)\s+search\s+tickets?\s+(\S.*?)\s*$/i, :search_tickets, command: true, help: { 'zd search tickets <QUERY>' => 'returns search results' })
      def search_tickets(response)
        ticket_search response, response.matches[0][0]
      end

      # Ticket Counts

      route(/^(?:zd|zendesk)(\s+unsolved)?\s+tickets?\s*$/i, :unsolved_tickets, command: true, help: { 'zd tickets' => 'returns the total count of all unsolved tickets' })
      def unsolved_tickets(response)
        ticket_count response, QUERY_TICKETS_UNSOLVED, 'unsolved'
      end

      route(/^(?:zd|zendesk)\s+(all|total)\s+tickets?\s*$/i, :total_tickets, command: true, help: { 'zd all tickets' => 'returns the count of all tickets' })
      def total_tickets(response)
        ticket_count response, QUERY_TICKETS_ALL, 'total'
      end

      route(/^(?:zd|zendesk)\s+pending\s+tickets?\s*$/i, :pending_tickets, command: true, help: { 'zd pending tickets' => 'returns a count of tickets that are pending' })
      def pending_tickets(response)
        ticket_count response, QUERY_TICKETS_PENDING, 'pending'
      end

      route(/^(?:zd|zendesk)\s+new\s+tickets?\s*$/i, :new_tickets, command: true, help: { 'zd new tickets' => 'returns the count of all new (unassigned) tickets' })
      def new_tickets(response)
        ticket_count response, QUERY_TICKETS_NEW, 'new'
      end

      route(/^(?:zd|zendesk)\s+escalated\s+tickets?\s*$/i, :escalated_tickets, command: true, help: { 'zd escalated tickets' => 'returns a count of tickets with escalated tag that are open or pending' })
      def escalated_tickets(response)
        ticket_count response, QUERY_TICKETS_ESCALATED, 'escalated'
      end

      route(/^(?:zd|zendesk)\s+open\s+tickets?\s*$/i, :open_tickets, command: true, help: { 'zd open tickets' => 'returns the count of all open tickets' })
      def open_tickets(response)
        ticket_count response, QUERY_TICKETS_OPEN, 'open'
      end

      route(/^(?:zd|zendesk)\s+on\s*hold\s+tickets?\s*$/i, :onhold_tickets, command: true, help: { 'zd on hold tickets' => 'returns the count of all on hold tickets' })
      def onhold_tickets(response)
        ticket_count response, QUERY_TICKETS_HOLD, 'on hold'
      end

      # Ticket Lists

      route(/^(?:zd|zendesk)\s+list(\s+unsolved)?\s+tickets?\s*$/i, :unsolved_tickets_list, command: true, help: { 'zd list tickets' => 'returns a list of unsolved tickets' })
      def unsolved_tickets_list(response)
        ticket_list response, QUERY_TICKETS_UNSOLVED, 'unsolved'
      end

      route(/^(?:zd|zendesk)\s+list\s+(all|total)\s+tickets?\s*$/i, :total_tickets_list, command: true, help: { 'zd list all tickets' => 'returns a list of all tickets' })
      def total_tickets_list(response)
        ticket_list response, QUERY_TICKETS_ALL, 'total'
      end

      route(/^(?:zd|zendesk)\s+list\s+pending\s+tickets?\s*$/i, :pending_tickets_list, command: true, help: { 'zd list pending tickets' => 'returns a list of pending tickets' })
      def pending_tickets_list(response)
        ticket_list response, QUERY_TICKETS_PENDING, 'pending'
      end

      route(/^(?:zd|zendesk)\s+list\s+new\s+tickets?\s*$/i, :new_tickets_list, command: true, help: { 'zd list new tickets' => 'returns a list of new tickets' })
      def new_tickets_list(response)
        ticket_list response, QUERY_TICKETS_NEW, 'new'
      end

      route(/^(?:zd|zendesk)\s+list\s+escalated\s+tickets?\s*$/i, :escalated_tickets_list, command: true, help: { 'zd list esclated tickets' => 'returns a list of escalated tickets' })
      def escalated_tickets_list(response)
        ticket_list response, QUERY_TICKETS_ESCALATED, 'escalated'
      end

      route(/^(?:zd|zendesk)\s+list\s+open\s+tickets?\s*$/i, :open_tickets_list, command: true, help: { 'zd list open tickets' => 'returns a list of open tickets' })
      def open_tickets_list(response)
        ticket_list response, QUERY_TICKETS_OPEN, 'open'
      end

      route(/^(?:zd|zendesk)\s+list\s+on\s*hold\s+tickets?\s*$/i, :onhold_tickets_list, command: true, help: { 'zd list on hold tickets' => 'returns a list of on hold tickets' })
      def onhold_tickets_list(response)
        ticket_list response, QUERY_TICKETS_HOLD, 'on hold'
      end

      # Ticket Details

      route(/^(?:zd|zendesk)\s+ticket\s+(\d+)\s*$/i, :ticket_details_with_comments, command: true, help: { 'zd ticket <ID>' => 'returns information about the specified ticket' })
      def ticket_details_with_comments(response)
        Lita.logger.info "#{logger_prefix}Processing Zendesk Ticket Details"
        ticket_id = response.matches[0][0].to_i
        begin
          ticket = client.ticket.find!(id: ticket_id)
          response.reply get_text_for_ticket_with_comments(ticket)
        rescue => e
          Lita.logger.warn "#{logger_prefix}#{e}"
          response.reply "Error processing ticket #{ticket_id}"
        end
      end

      private

      def get_text_for_ticket(ticket, include_description = true)
        Lita.logger.info "#{logger_prefix}Processing Zendesk ticket details for [#{ticket.id}]"
        unless ticket.is_a? ZendeskAPI::Ticket
          raise 'ticket is not a ZendeskAPI::Ticket'
        end
        message = "# Ticket #{ticket.id}: #{ticket_url_web(ticket.id)}"
        message += "\n- Subject: #{ticket.subject}"
        message += "\n- Status: #{ticket.status}"
        message += "\n- Updated: #{ticket.updated_at}"
        message += "\n- Created: #{ticket.created_at}"
        message += "\n- Requester: #{user_display(ticket.requester)}"  
        message += "\n- Description: #{ticket.description}" if include_description
        return message
      end

      def get_text_for_ticket_comments(ticket)
        Lita.logger.info "#{logger_prefix}Processing Zendesk ticket comments for [#{ticket.id}]"
        unless ticket.is_a? ZendeskAPI::Ticket
          raise 'ticket is not a ZendeskAPI::Ticket'
        end
        comments_text = []
        ticket.audits.each_with_index do |audit,i|
          if (comment = audit.events.detect {|e| e.type.downcase == 'comment'})
            author_text = user_display comment.author
            comment_text = "## Comment: #{author_text}"
            comment_text += "\n- Created: #{audit.created_at}"
            comment_text += "\n- Comment: #{comment.body}"
            comments_text.push comment_text
          end
        end
        return comments_text.reverse.join("\n")
      end

      def get_text_for_ticket_with_comments(ticket)
        Lita.logger.info "#{logger_prefix}Processing Zendesk ticket details for [#{ticket.id}] with comments"
        message = get_text_for_ticket ticket, false
        comments = get_text_for_ticket_comments ticket
        if !comments.nil? && comments.length>0
          message += "\n#{comments}"
        end
        return message
      end

      def ticket_count(response, query, ticket_type = '')
        Lita.logger.info "#{logger_prefix}Processing Zendesk Ticket Count Query [#{query}]"
        begin
          ticket_count = client.search!(query: query).count
          Lita.logger.info "#{logger_prefix}Ticket count #{ticket_count}"
          ticket_desc  = ticket_type == '' ? '' : "#{ticket_type} "
          ticket_word  = ticket_count == 1 ? 'ticket' : 'tickets'
          response.reply "#{ticket_count} #{ticket_desc}#{ticket_word}."
        rescue
          response.reply "A Zendesk error has been encountered."
        end
      end

      def ticket_search(response, raw_query)
        Lita.logger.info "#{logger_prefix}Processing Zendesk Ticket Search"
        tickets = client.search!(query: "#{QUERY_TICKETS_ALL} #{raw_query}")
        serp_count = reply_tickets response, tickets
        response.reply "Listing #{serp_count} of #{tickets.count} #{ticket_word(tickets.count)} matching #{raw_query}."
      end

      def ticket_list(response, query, ticket_status = '')
        Lita.logger.info "#{logger_prefix}Processing Zendesk ticket list query"
        tickets = client.search!(query: query)
        serp_count = reply_tickets response, tickets
        ticket_desc = ticket_status == '' ? '' : "#{ticket_status} "
        response.reply "Listing #{serp_count} of #{tickets.count} #{ticket_desc}#{ticket_word(tickets.count)}."
      end

      def reply_tickets(response, tickets)
        serp_count = 0
        tickets.each_with_index do |ticket, i|
          break if i >= config.max_results
          serp_count += 1
          response.reply "Ticket #{ticket.id} is #{ticket.status}: #{ticket_url_web(ticket.id)} - #{ticket.subject}"
        end
        return serp_count
      end

      def ticket_url_web(ticket_id)
        uri_join web_tickets_url.to_s, ticket_id.to_s
      end

      def ticket_word(count)
        count == 1 ? 'ticket' : 'tickets'
      end

      def user_display(user)
        parts = []
        if user.name.to_s.length > 0
          parts.push user.name
        end
        if user.email.to_s.length > 0
          if parts.length < 1 || user.email != user.name
            parts.push "(#{user.email})"
          end
        end
        user_text = parts.join(' ')
      end

      def uri_join(*args)
        args.join('/').gsub(/\/\s*\//, '/').gsub(/\/+/, '/').gsub(/^(https?:\/)/i, '\1/')
      end

      def logger_prefix
        " -- #{self.class.name}: "
      end
    end

    Lita.register_handler(Zendesk)
  end
end