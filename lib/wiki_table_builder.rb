module CustomMacro
  $col_separator = "|"
  $header = "_."
  $empty_column = "%{color:white}-%"
  $empty_column_header = "%{color:#EEEEEE}-%"

  class WikiTableBuilder
    def self.table
      return WikiTableBuilder.new
    end

    def initialize
      @rows = []
    end

    def row
      @rows << WikiRowBuilder.new(self)
      @rows.last
    end

    def build
      to_s
    end

    def to_s
      @rows.join "\n"
    end
  end

  class WikiRowBuilder
    def initialize(table_builder)
      @cols = []
      @col_separator = $col_separator
      @table_builder = table_builder
    end

    def col(text = "")
      @cols << WikiColBuilder.new(self, text, @col_separator)
      @cols.last
    end

    def header
      @col_separator = $col_separator + $header
      self
    end

    def build
      @table_builder
    end

    def to_s
      "#{@cols.join" "} #{$col_separator}"
    end
  end

  class WikiColBuilder

    attr_accessor :separator
    
    def initialize(row_builder, text = "", separator = $col_separator)
      @row_builder = row_builder
      @text = text.to_s
      @separator = separator
    end

    def header
      @separator = $col_separator + $header
      self
    end

    def build
      @row_builder
    end

    def empty_value
      @separator.include?($header) ? $empty_column_header : $empty_column
    end

    def text
      @text.empty? ? empty_value : @text
    end

    def to_s
      "#{@separator} #{text}"
    end
  end

end
