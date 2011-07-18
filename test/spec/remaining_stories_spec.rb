require "rspec"
require "./lib/release_metrics"
require "./lib/iterations"
require "./lib/release"

describe "remaining stories" do
  before do
    @iterations = [
        {'number' => '5', 'name' => 'Iteration 5', 'end_date' => '2011-07-05', 'velocity' => '12'},
        {'number' => '4', 'name' => 'Iteration 4', 'end_date' => '2011-06-28', 'velocity' => '8'},
        {'number' => '3', 'name' => 'Iteration 3', 'end_date' => '2011-06-21', 'velocity' => '10'},
        {'number' => '2', 'name' => 'Iteration 2', 'end_date' => '2011-06-14', 'velocity' => '5'},
    ]
    @r_iterations = CustomMacro::Iterations.new @iterations
    @parameters = {}
    @stories = [
        {'story_points' => '5'},
        {'story_points' => '3'},
        {'story_points' => '8'},
        {'story_points' => ''},
    ]
    @project = double('project',
                      :value_of_project_variable => '#1 Release 1',
                      :execute_mql => @stories)
    @macro = CustomMacro::ReleaseMetrics.new(@parameters, @project, nil)

  end

  context "iteration names" do
    subject { @r_iterations.names }
    it { should == "'Iteration 5','Iteration 4','Iteration 3','Iteration 2'" }
  end

  context "retrieve incomplete stories" do
    before do
      @project.should_receive(:execute_mql).with(
          "SELECT 'Story Points' WHERE Type = story AND release = 'Release 1' AND " +
          "NOT iteration in ('Iteration 5','Iteration 4','Iteration 3','Iteration 2')")
    end

    subject { @macro.stories(@r_iterations).length }
    it { should == @stories.length }
  end

  context "calculate remaining story points" do
    subject { CustomMacro::Stories.new(@stories).story_points }
    it { should == 16 }
  end

  context "calculate remaining story points when no stories exists" do
    subject { CustomMacro::Stories.new([]).story_points }
    it { should == 0 }
  end

end
