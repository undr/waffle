require 'spec_helper'

describe Waffle do
  describe ".configure" do
    after do
      Waffle.reset_config!
    end

    context "when no block supplied" do
      let(:config_hash){{
        'development' => {
          'transport' => 'redis',
          'url' => 'redis://localhost:port/0',
          'encoder' => 'json'
        }
      }}

      before do
        YAML.stub(:load_file => config_hash)
        File.stub(:exists? => true)
        Waffle::Config.stub(:environment => 'development')
        Waffle.configure
      end

      specify{Waffle.config.should == Waffle::Config}
      specify{Waffle.config.transport.should == 'redis'}
      specify{Waffle.config.encoder.should == 'json'}
      specify{Waffle.config.connection_attempt_timeout.should == 30}
      specify{Waffle.config.url.should == 'redis://localhost:port/0'}
    end

    context "when a block is supplied" do
      before do
        Waffle.configure do
          default do |config|
            config.transport = 'redis'
          end
        end
      end

      after do
        Waffle.configure do |config|
          config.transport = nil
        end
      end

      specify{Waffle.config.transport.should == 'redis'}
    end
  end

  context do
    before do
      Waffle.configure
      Waffle::Config.stub(:queues => {:default => transport})
    end

    let(:transport){mock(:transport)}

    describe '#publish' do
      let(:args){['flow', 'message']}

      before do
        transport.should_receive(:publish).with(*args)
      end

      specify{Waffle.publish(*args)}
    end

    describe '#subscribe' do
      before do
        transport.should_receive(:subscribe).with('flow')
      end

      specify{Waffle.subscribe('flow')}
    end
  end
end
