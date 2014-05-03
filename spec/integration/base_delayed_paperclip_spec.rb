require 'spec_helper'

describe "Base Delayed Paperclip Integration" do
  before :all do
    DelayedPaperclip.options[:background_job_class] = DelayedPaperclip::Jobs::Resque
    Resque.remove_queue(:paperclip)
  end

  let(:dummy) { Dummy.create }

  before :each do
    reset_dummy(paperclip: { default_url: "/../../fixtures/missing.png" })
  end

  describe "double save" do
    before :each do
      dummy.image_processing.should be_false
      dummy.image = File.open("#{ROOT}/spec/fixtures/12k.png")
      dummy.save!
    end

    it "processing column remains true" do
      dummy.image_processing.should be_true
      dummy.save!
      dummy.image_processing.should be_true
    end
  end

end