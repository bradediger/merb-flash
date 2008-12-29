# make sure we're running inside Merb
if defined?(Merb::Plugins)

  # Merb gives you a Merb::Plugins.config hash...feel free to put your stuff in your piece of it
  Merb::Plugins.config[:merb_flash] = {}
  
  Merb::BootLoader.before_app_loads do
    class Merb::Request
      def message
        session[:flash_messages] || {}
      end
    end

    class Merb::Controller
      before :process_flash

      alias :orig_redirect :redirect

      def redirect(url, opts = {})
        if opts[:message]
          msg = opts.delete(:message)
          raise ArgumentError if msg && !msg.is_a?(Hash)
          msg = Mash.new(:notice => msg) if msg.is_a?(String)
          session[:flash] = msg
        end

        orig_redirect(url, opts)
      end

      protected

      def process_flash
        session[:flash_messages] = session[:flash]
        session[:flash] = {}
      end
    end
  end
  
end