require 'test_helper'
require 'minitest/autorun'

class FlashEmailTest < MiniTest::Spec

  @@sources = []

  def self.load_fixtures
    dirs = Dir.glob "#{Rails.root}/test/fixtures/emails/*"
    dirs.each do |dir|
      source = { :name => File.basename(dir), :actual => {}, :expected => {} }
      @@sources << source

      actuals = Dir.glob "#{dir}/*.txt"
      actuals.each do |actual|
        message_id = actual.match(/.*\/(\d)\.txt$/).captures[0]
        File.open actual do |f|
          email = FlashEmail.parse f.read
          if email.parsed?
            email.message_id = message_id
            source[:actual][message_id] = email
          end
        end
      end

      yaml = YAML::load File.open("#{dir}/emails.yml")
      yaml.each do |email|
        source[:expected][email['message_id']] = email
      end

    end
  end

  load_fixtures

  @@sources.each do |source|

    describe source[:name] do
      it 'fetches correct amount of emails' do
        source[:actual].length.must_equal source[:expected].length
      end

      it 'sets correct properties' do
        source[:actual].each do |message_id, actual|
          expected = source[:expected][message_id.to_i]

          actual.source.must_equal expected['source']
          actual.subject.must_equal expected['subject']
          actual.deals.length.must_equal expected['deals'].length

          actual.deals.each_with_index do |actual_deal, i|
            expected_deal = expected['deals'][i]

            actual_deal.wine.must_equal expected_deal['wine']
            actual_deal.varietal.must_equal expected_deal['varietal']
            actual_deal.vintage.must_equal expected_deal['vintage'].to_s
            actual_deal.price.must_equal expected_deal['price']
            actual_deal.country.must_equal expected_deal['country']
            actual_deal.size.must_equal expected_deal['size']
          end
        end
      end
    end

  end
end