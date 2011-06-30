require 'test_helper'
require 'minitest/autorun'

class FlashEmailTest < MiniTest::Spec

  def self.load_actual_emails
    files = Dir.glob("#{Rails.root}/test/fixtures/emails/wtso/*.txt")
    files.each_with_object({}) do |file, memo|
      message_id = file.match(/.*\/(\d)\.txt$/).captures[0]
      File.open file do |f|
        email = FlashEmail.parse f.read
        unless email.nil?
          email.message_id = message_id
          memo[message_id] = email
        end
      end
    end
  end

  def self.load_expected_emails
    yaml = YAML::load File.open("#{Rails.root}/test/fixtures/emails/wtso/emails.yml")
    yaml.each_with_object({}) do |email, memo|
      memo[email['message_id']] = email
    end
  end

  @@actual = load_actual_emails
  @@expected = load_expected_emails

  describe '#fetch_latest' do
    it 'fetches correct amount of emails' do
      @@actual.length.must_equal @@expected.length
    end

    it 'sets correct properties' do
      @@actual.each do |message_id, actual|
        expected = @@expected[message_id.to_i]

        actual.source.must_equal expected['source']
        actual.subject.must_equal expected['subject']
        actual.deals.length.must_equal expected['deals'].length

        actual.deals.each_with_index do |actual_deal, i|
          expected_deal = expected['deals'][i]

          actual_deal.wine.must_equal expected_deal['wine']
          actual_deal.varietal.must_equal expected_deal['varietal']
          actual_deal.vintage.must_equal expected_deal['vintage']
          actual_deal.price.must_equal expected_deal['price']
          actual_deal.country.must_equal expected_deal['country']
          actual_deal.size.must_equal expected_deal['size']
        end
      end
    end
  end
end