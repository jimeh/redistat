require "spec_helper"

module Redistat
  describe Synchronize do

    let(:klass) { Synchronize }

    describe '.included' do
      it 'includes InstanceMethods in passed object' do
        base = mock('Base')
        base.should_receive(:include).with(klass::InstanceMethods)
        klass.included(base)
      end
    end # included

    describe '.monitor' do
      it 'returns a Monitor instance' do
        klass.monitor.should be_a(Monitor)
      end

      it 'caches Monitor instance' do
        klass.monitor.object_id.should == klass.monitor.object_id
      end
    end # monitor

    describe '.thread_safe' do
      after { klass.instance_variable_set('@thread_safe', nil) }

      it 'returns value of @thread_safe' do
        klass.instance_variable_set('@thread_safe', true)
        klass.thread_safe.should be_true
      end

      it 'defaults to false' do
        klass.thread_safe.should be_false
      end

      it 'uses #synchronize' do
        klass.monitor.should_receive(:synchronize).once
        klass.thread_safe.should be_nil
      end
    end # thread_safe

    describe '.thread_safe=' do
      after { klass.instance_variable_set('@thread_safe', nil) }

      it 'sets @thread_safe' do
        klass.instance_variable_get('@thread_safe').should be_nil
        klass.thread_safe = true
        klass.instance_variable_get('@thread_safe').should be_true
      end

      it 'uses #synchronize' do
        klass.monitor.should_receive(:synchronize).once
        klass.thread_safe = true
        klass.instance_variable_get('@thread_safe').should be_nil
      end
    end # thread_safe=

    describe "InstanceMethods" do
      subject { SynchronizeSpecHelper.new }

      describe '.monitor' do
        it 'defers to Redistat::Synchronize' do
          klass.should_receive(:monitor).once
          subject.monitor
        end
      end # monitor

      describe '.thread_safe' do
        it ' defers to Redistat::Synchronize' do
          klass.should_receive(:thread_safe).once
          subject.thread_safe
        end
      end # thread_safe

      describe '.thread_safe=' do
        it 'defers to Redistat::Synchronize' do
          klass.should_receive(:thread_safe=).once.with(true)
          subject.thread_safe = true
        end
      end # thread_safe=

      describe 'when #thread_safe is true' do
        before { subject.stub(:thread_safe).and_return(true) }

        describe '.synchronize' do
          it 'defers to #monitor' do
            subject.monitor.should_receive(:synchronize).once
            subject.synchronize { 'foo' }
          end

          it 'passes block along to #monitor.synchronize' do
            yielded = false
            subject.synchronize { yielded = true }
            yielded.should be_true
          end
        end # synchronize
      end # when #thread_safe is true

      describe 'when #thread_safe is false' do
        before { subject.stub(:thread_safe).and_return(false) }

        describe '.synchronize' do
          it 'does not defer to #monitor' do
            subject.monitor.should_not_receive(:synchronize)
            subject.synchronize { 'foo' }
          end

          it 'yields block' do
            yielded = false
            subject.synchronize { yielded = true }
            yielded.should be_true
          end
        end # synchronize
      end # when #thread_safe is false

    end

  end # Synchronize
end # Redistat

class SynchronizeSpecHelper
  include Redistat::Synchronize
end
