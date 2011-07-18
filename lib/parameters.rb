require "delegate"

module CustomMacro

  module Parameters

    class Parameters < SimpleDelegator
      def initialize(parameters = {}, defaults = {})
        __setobj__ parameters
        @defaults = Hash.new { |h, k| h[k]=k }
        @defaults.merge! defaults
      end

      def defaults
        @defaults
      end
    end

    def parameters
      @parameters || Parameters.new
    end

    def defaults
      parameters.defaults
    end

    def parameter_to_field(param)
      param.gsub('_', ' ').scan(/\w+/).collect { |word| word.capitalize }.join(' ')
    end

    def method_missing(method_sym, *arguments, &block)
      if method_sym.to_s =~ /^(.*)_field$/
        parameter_to_field(send "#{$1}_parameter".to_s)
      elsif  method_sym.to_s =~ /^(.*)_(parameter|type)$/
        param = parameters[$1] || defaults[$1]
        if param.respond_to? :call
          param.call
        else
          param
        end
      else
        super method_sym, *arguments, &block
      end
    end

    def respond_to?(method_sym, include_private = false)
      if method_sym.to_s =~ /^(.*)_[field|parameter|type]$/
        true
      else
        super method_sym, include_private
      end
    end

  end

end