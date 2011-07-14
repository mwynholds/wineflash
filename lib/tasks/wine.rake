require 'rake'

namespace :wine do
  namespace :fetch do
    desc 'Fetch all new wine flash emails'
    task :all => :environment do
      Fetcher.new.fetch :verbose => true
    end

    desc 'Fetch $max new wine flash emails (in no specific order)'
    task :some, [:max] => [:environment] do |t, args|
      Fetcher.new.fetch :max => args[:max], :verbose => true
    end

    desc 'Fetch $max new wine flash emails with $from in the sender'
    task :from, [:from, :max] => [:environment] do |t, args|
      Fetcher.new.fetch :query => "from:#{args[:from]}", :max => args[:max], :verbose => true
    end
  end

  namespace :parse do
    desc 'Re-parse all existing emails'
    task :all => :environment do
      FlashEmail.re_parse :verbose => true
    end

    desc 'Re-parse existing emails from $source'
    task :source, [:source] => [:environment] do |t, args|
      FlashEmail.re_parse :source => args[:source], :verbose => true
    end
  end
end