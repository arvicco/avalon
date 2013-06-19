module Avalon

  # Mix-in for extraction of properties from a given input String or Hash
  module Extractable

    # type = :absolute_time | :absolute_date | :relative_time
    def my_time t, type=:absolute_time
      time = Time.at(t.to_f)
      case type
      when :absolute_date
        time.getlocal.strftime("%Y-%m-%d %H:%M:%S")
      when :absolute_time
        time.getlocal.strftime("%H:%M:%S")
      when :relative_time
        time.utc.strftime("#{(time.day-1)*24+time.hour}:%M:%S")
      end
    end

    def print_headers
      puts self::FIELDS.map {|name, (width,_,_ )| name.to_s.ljust(width)}.join(' ')
    end


    # Extract data from String OR Hash
    def extract_data_from input
      if input.nil? || input.empty?
        {}
      else
        # Convert the input into usable data pairs
        pairs = self::FIELDS.map do |name, (_, pattern, type)|
          val = input[pattern] # works for both pattern and key
          unless val.nil?
            case type
            when Symbol
              [name, val.send("to_#{type}")]
            when Proc
              [name, type.call(val)]
            when '' # no conversion
              [name, val]
            else
              nil
            end
          end
        end
        Hash[*pairs.compact.flatten]
      end
    end

  end
end
