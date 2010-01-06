require File.join(File.dirname(__FILE__), 'ping')
require 'win32ole'

# The Net module serves as a namespace only.
#
module Net
   
   # The Ping::WMI class encapsulates the Win32_PingStatus WMI class for
   # MS Windows.
   #
   class Ping::WMI < Ping

      PingStatus = Struct.new(
         'PingStatus',
         :address,
         :buffer_size,
         :no_fragmentation,
         :primary_address_resolution_status,
         :protocol_address,
         :protocol_address_resolved,
         :record_route,
         :reply_inconsistency,
         :reply_size,
         :resolve_address_names,
         :response_time,
         :response_time_to_live,
         :route_record,
         :route_record_resolved,
         :source_route,
         :source_route_type,
         :status_code,
         :timeout,
         :timestamp_record,
         :timestamp_record_address,
         :timestamp_record_address_resolved,
         :timestamp_route,
         :time_to_live,
         :type_of_service
      )

      # Unlike the ping method for other Ping subclasses, this version returns
      # a PingStatus struct which contains various bits of information about
      # the results of the ping itself, such as response time.
      #
      # In addition, this version allows you to pass certain options that are
      # then passed on to the underlying WQL query. See the MSDN documentation
      # on Win32_PingStatus for details.
      #
      # Examples:
      #
      #  # Ping with no options
      #  Ping::WMI.ping('www.perl.com')
      #
      #  # Ping with options
      #  Ping::WMI.ping('www.perl.com', :BufferSize => 64, :NoFragmentation => true)
      #--
      # The PingStatus struct is a wrapper for the Win32_PingStatus WMI class.
      #
      def ping(host = @host, options = {})
         super(host)

         lhost = Socket.gethostname

         cs = "winmgmts:{impersonationLevel=impersonate}!//#{lhost}/root/cimv2"
         wmi = WIN32OLE.connect(cs)

         query = "select * from win32_pingstatus where address = '#{host}'"

         unless options.empty?
            options.each{ |key, value|
               if value.is_a?(String)
                  query << " and #{key} = '#{value}'"
               else
                  query << " and #{key} = #{value}"
               end
            }
         end

         status = Struct::PingStatus.new

         wmi.execquery(query).each{ |obj|
            status.address                           = obj.Address
            status.buffer_size                       = obj.BufferSize
            status.no_fragmentation                  = obj.NoFragmentation
            status.primary_address_resolution_status = obj.PrimaryAddressResolutionStatus
            status.protocol_address                  = obj.ProtocolAddress
            status.protocol_address_resolved         = obj.ProtocolAddressResolved
            status.record_route                      = obj.RecordRoute 
            status.reply_inconsistency               = obj.ReplyInconsistency
            status.reply_size                        = obj.ReplySize
            status.resolve_address_names             = obj.ResolveAddressNames
            status.response_time                     = obj.ResponseTime
            status.response_time_to_live             = obj.ResponseTimeToLive
            status.route_record                      = obj.RouteRecord
            status.route_record_resolved             = obj.RouteRecordResolved
            status.source_route                      = obj.SourceRoute
            status.source_route_type                 = obj.SourceRouteType
            status.status_code                       = obj.StatusCode
            status.timeout                           = obj.Timeout
            status.timestamp_record                  = obj.TimeStampRecord
            status.timestamp_record_address          = obj.TimeStampRecordAddress
            status.timestamp_record_address_resolved = obj.TimeStampRecordAddressResolved
            status.timestamp_route                   = obj.TimeStampRoute
            status.time_to_live                      = obj.TimeToLive
            status.type_of_service                   = obj.TypeOfService
         }

         status.freeze # Read-only data
      end      

      # Unlike Net::Ping::WMI#ping, this method returns true or false to
      # indicate whether or not the ping was successful.
      #
      def ping?(host = @host, options = {})
         ping(host, options).status_code == 0
      end
   end   
end
