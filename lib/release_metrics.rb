require "date"
require "parameters"
require "release"
require 'erb'

module CustomMacro

  class ReleaseMetrics
    include CustomMacro, CustomMacro::Parameters

    def initialize(parameters, project, current_user)
      @project = project
      @current_user = current_user
      @parameters = Parameters::Parameters.new( parameters,
         'iteration' => lambda { @project.value_of_project_variable('Current Iteration') },
         'release' => lambda { @project.value_of_project_variable('Current Release') },
         'time_box' => 'iteration',
         'show_what_if' => false,
         'mini' => false,
         'debug' => false,
         'view' => 'full_table',
         'mingle_url' => '')
    end

    def execute
      begin
        iterations = completed_iterations
        release_data = {
          :iterations => iterations,
          :remaining_stories => stories(iterations),
          :completed_stories => stories(iterations, false)
        }
        # release used in erb files
        release = current_release release_data
        render_view view_parameter, binding
      rescue Exception => e
        error_view(e)
      end
    end

    def error_view(e)
      template = ERB.new <<-ERROR
    h2. Release Metrics:

    An Error occurred: <%= e %><br>
    Stack trace: <%= e.backtrace.join("<br>") %>
      ERROR
      template.result binding
    end

    def render_view(view_file_name, binding)
      file = File.open("./vendor/plugins/release_metrics/views/#{view_file_name}.erb")
      ERB.new(file.read).result binding
    end

    def current_release(release_data)
      begin
        release_where = "Number = #{card_number release_parameter}"
        release_where = "Number = #{release_parameter.upcase}.'Number'" if this_card(release_parameter)
        data_rows = @project.execute_mql("SELECT '#{end_date_field}' WHERE #{release_where}")
        raise "##{release_parameter} is not a valid release" if data_rows.empty?
        Release.new data_rows[0], release_data, @parameters
      rescue Exception => e
        raise "[error retrieving release for #{release_parameter}: #{e}]"
      end
    end

    def completed_iterations
      begin
        completed_iterations = @project.execute_mql(
            "SELECT name, '#{start_date_field}', '#{end_date_field}', #{velocity_field} " +
                "WHERE Type = #{time_box_type} AND '#{end_date_field}' < today AND #{release_where} " +
                "ORDER BY '#{end_date_field}' desc")
        Iterations.new completed_iterations, velocity_parameter, end_date_parameter, start_date_parameter
      rescue Exception => e
        raise "[error retrieving completed iterations for #{release_parameter}: #{e}]"
      end
    end

    def this_card(card_identifier_name)
      card_identifier_name.upcase == 'THIS CARD'
    end

    def release_where
      this_card(release_parameter) ? "release = #{release_parameter.upcase}" : "release = '#{card_name release_parameter}'"
    end

    def stories(completed_iterations, remaining_stories = true)
      return Stories.new [], story_points_parameter if completed_iterations.length == 0 && !remaining_stories
      iter_names = completed_iterations.names
      if completed_iterations.length > 0
        mql = "SELECT '#{story_points_field}' WHERE Type = story AND #{release_where} AND " +
            "#{remaining_stories ? 'NOT ' : ''}#{time_box_type} in (#{iter_names})"
      else
        mql = "SELECT '#{story_points_field}' WHERE Type = story AND #{release_where}"
      end
      begin
        Stories.new @project.execute_mql(mql), story_points_parameter
      rescue Exception => e
        raise "[error retrieving stories for release '#{release_parameter}': #{e}]"
      end
    end

    def can_be_cached?
      false # if appropriate, switch to true once you move your macro to production
    end

    def get_binding
      binding
    end

  end

  def find_first_match(data, regex)
    match_data = regex.match(data)
    if  match_data
      match_data[1]
    else
      'Unknown'
    end
  end

  def card_link(card_identifier_name)
    return "#{card_name card_identifier_name} #{@project.identifier}/##{card_number card_identifier_name}" if @parameters['project']
    card_identifier_name
  end

  def card_property_selector(card_identifier_name, regex)
    return card_identifier_name if this_card(card_identifier_name)
    find_first_match(card_identifier_name, regex)
  end

  def card_name(card_identifier_name)
    card_property_selector(card_identifier_name, /#\d+ (.*)/)
  end

  def card_number(card_identifier_name)
    card_property_selector(card_identifier_name, /#(\d+).*/)
  end

  def card_description(card_identifier_name)
    return card_identifier_name if this_card(card_identifier_name)
    "##{card_number(card_identifier_name)} #{card_name(card_identifier_name)}"
  end

  def card_url(card_identifier_name)
    return '' if this_card(card_identifier_name)
    "/projects/#{@project.identifier}/cards/#{card_number card_identifier_name}"
  end

end

