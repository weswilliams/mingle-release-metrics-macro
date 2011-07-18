require "date"
module CustomMacro

  class Iterations

    def initialize(iterations, velocity_parameter = 'velocity',
        end_date_parameter = 'end_date', start_date_parameter = 'start_date')
      @iterations = iterations
      @velocity_parameter = velocity_parameter
      @end_date_parameter = end_date_parameter
      @start_date_parameter = start_date_parameter
    end

    def [] key
      @iterations[key]
    end

    def first(n=1)
      @iterations.first(n)
    end

    def last_3()
      @iterations.first(3)
    end

    def best_velocity
      return 0 if @iterations.length == 0
      @iterations.inject(1) do |best, iter|
        velocity = iter[@velocity_parameter]
        (velocity && velocity.to_i > best ? velocity.to_i : best).to_f
      end
    end

    def worst_velocity
      return 0 if @iterations.length == 0
      @iterations.inject(best_velocity()) do |worst, iter|
        iter_velocity = iter[@velocity_parameter].to_i
        iter_velocity && iter_velocity < worst && iter_velocity > 0 ? iter_velocity : worst
      end.to_f
    end

    def last_3_average
      average_velocity_for last_3
    end

    def average_velocity
      average_velocity_for @iterations
    end

    def average_velocity_for(iterations)
      return 0 if iterations.length == 0
      total_velocity = iterations.inject(0) do |total, hash|
        velocity = hash[@velocity_parameter]
        velocity ? total + velocity.to_i : total
      end
      total_velocity / (iterations.length * 1.0)
    end

    def names
      @iterations.collect { |iter| "'#{iter['name']}'" }.join ","
    end

    def last_end_date
      @iterations.length == 0 ? Date.today : Date.parse(@iterations[0][@end_date_parameter])
    end

    def last_start_date
      @iterations.length == 0 ? Date.today : Date.parse(@iterations[0][@start_date_parameter])
    end

    def days_in_iteration
      return 7 if @iterations.length == 0
      (last_end_date - last_start_date) + 1
    end

    def length
      @iterations.length
    end

  end
end
