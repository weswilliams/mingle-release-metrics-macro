require "date"
require "parameters"

module CustomMacro

  class Release
    include CustomMacro::Parameters

    def initialize(data, release_data, parameters)
      @data = data
      @parameters = parameters
      @iterations = release_data[:iterations]
      @remaining_stories = release_data[:remaining_stories]
      @completed_stories = release_data[:completed_stories]
    end

    def remaining_iters(velocity_method)
      velocity = @iterations.send velocity_method.to_s
      return 'Unknown' if velocity <= 0
      (@remaining_stories.story_points / velocity).ceil
    end

    def completion_date(velocity_method)
      remaining_iterations = remaining_iters velocity_method
      return 'Unknown' if remaining_iterations == 'Unknown'
      @iterations.last_end_date + (@iterations.days_in_iteration * remaining_iterations)
    end

    def remaining_story_points
      @remaining_stories.story_points
    end

    def completed_story_points
      @completed_stories.story_points
    end

    def end_date
      @data[end_date_parameter]
    end

    def completed_iterations
      @iterations.length
    end

      #noinspection RubyUnusedLocalVariable
    def method_missing(method_sym, *arguments, &block)
      # this may be lazy of me
      if @iterations.respond_to? method_sym
        @iterations.send method_sym, *arguments, &block
      else
        super
      end
    end

    def respond_to?(method_sym, include_private = false)
      if @iterations.respond_to? method_sym
        true
      else
        super
      end
    end

  end

  class Stories
    def initialize(data, story_points_parameter = 'story_points')
      @data = data
      @story_points_parameter = story_points_parameter
    end

    def story_points
      @data.inject(0) do |total, story|
        story_points = story["#{@story_points_parameter}"]
        story_points ? total + story_points.to_i : total
      end
    end

    def length
      @data.length
    end
  end

end