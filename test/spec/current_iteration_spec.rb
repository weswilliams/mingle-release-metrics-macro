require "rspec"
require "./lib/release_metrics"

describe "remaining stories" do
  before do
    @current_release = [ {'end_date' => '2011-07-05' } ]
    @parameters = {}
    @project = double('project',
                      :value_of_project_variable => '#1 Release 1',
                      :execute_mql => @current_release)
    @macro = CustomMacro::ReleaseMetrics.new(@parameters, @project, nil)
  end

  context "retrieve current release end date" do
    before do
      @project.should_receive(:execute_mql).with("SELECT 'End Date' WHERE Number = 1")
    end

    subject { @macro.current_release({:iteration => [], :remaining_stories => []}).end_date }
    it { should == '2011-07-05' }
  end
end
