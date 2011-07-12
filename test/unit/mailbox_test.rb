require 'test_helper'
require 'minitest/autorun'

class MailboxTest < MiniTest::Spec

  describe '#archive' do
    describe 'first time for label' do
      before do
        @mock = MiniTest::Mock.new
        @mock.expect :list, [], ['', '*']
        @mock.expect :create, nil, ['archived']
        @mock.expect :create, nil, ['archived/foo']
        @mock.expect :examine, nil, ['INBOX']
        @mock.expect :uid_copy, MockCopyResponse.new(123, 321), [123, 'archived/foo']
        @mock.expect :select, nil, ['archived/foo']
        @mock.expect :uid_store, nil, [321, '+FLAGS', [:Seen]]
        @mock.expect :select, nil, ['INBOX']
        @mock.expect :uid_store, nil, [123, '+FLAGS', [:Deleted]]
      end

      it 'logs in' do
        mailbox = Mailbox.new @mock
        mailbox.archive 123, 'archived/foo'
        assert @mock.verify
      end
    end

    describe 'second time for label' do
      before do
        @mock = MiniTest::Mock.new
        @mock.expect :list, MockListResponse.new('archived', 'archived/foo', 'something/else'), ['', '*']
        @mock.expect :examine, nil, ['INBOX']
        @mock.expect :uid_copy, MockCopyResponse.new(123, 321), [123, 'archived/foo']
        @mock.expect :select, nil, ['archived/foo']
        @mock.expect :uid_store, nil, [321, '+FLAGS', [:Seen]]
        @mock.expect :select, nil, ['INBOX']
        @mock.expect :uid_store, nil, [123, '+FLAGS', [:Deleted]]
      end

      it 'logs in' do
        mailbox = Mailbox.new @mock
        mailbox.archive 123, 'archived/foo'
        assert @mock.verify
      end
    end
  end

  describe '#search' do
    describe 'by subject' do
      before do
        @mock = MiniTest::Mock.new
        @mock.expect :list, [], ['', '*']
        @mock.expect :examine, nil, ['INBOX']
        @mock.expect :uid_search, nil, [['SUBJECT', 'foo']]
      end

      it 'searches correctly' do
        mailbox = Mailbox.new @mock
        mailbox.search 'foo'
        assert @mock.verify
      end
    end

    describe 'by sender' do
      before do
        @mock = MiniTest::Mock.new
        @mock.expect :list, [], ['', '*']
        @mock.expect :examine, nil, ['INBOX']
        @mock.expect :uid_search, nil, [['FROM', 'foo']]
      end

      it 'searches correctly' do
        mailbox = Mailbox.new @mock
        mailbox.search 'from:foo'
        assert @mock.verify
      end
    end

    describe 'by recipient' do
      before do
        @mock = MiniTest::Mock.new
        @mock.expect :list, [], ['', '*']
        @mock.expect :examine, nil, ['INBOX']
        @mock.expect :uid_search, nil, [['TO', 'foo']]
      end

      it 'searches correctly' do
        mailbox = Mailbox.new @mock
        mailbox.search 'to:foo'
        assert @mock.verify
      end
    end

    describe 'in other label' do
      before do
        @mock = MiniTest::Mock.new
        @mock.expect :list, [], ['', '*']
        @mock.expect :examine, nil, ['label']
        @mock.expect :uid_search, nil, [['SUBJECT', 'foo']]
      end

      it 'searches correctly' do
        mailbox = Mailbox.new @mock
        mailbox.search 'foo', 'label'
        assert @mock.verify
      end
    end
  end

end

class MockListResponse < Array
  def initialize(*args)
    args.each do |str|
      self << OpenStruct.new(:name => str)
    end
  end
end

class MockCopyResponse
  attr_reader :data
  def initialize(old_uid, new_uid)
    @data = OpenStruct.new(:code => OpenStruct.new(:data => "0 #{old_uid} #{new_uid}"))
  end
end