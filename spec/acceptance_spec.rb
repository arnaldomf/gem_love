$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'gem_love'
require 'shellwords'
require 'data_mapper'


module GemLove
  def self.gem_named(name)
    Rubygem.get(name)
  end
  Rubygem = Struct.new(:name) do
    def self.get(name)
      new(name)
    end
    def endorsements
      endorsement_list.all_for_gem_named(name)
    end
    def endorsement_list
      Endorsement
    end
  end

  class Endorsement
    include DataMapper::Resource
    property :gem_name, String, key: true
    def self.all_for_gem_named(name)
      all(gem_name: name)
    end
  end
end


describe 'gem love command' do
  before :all do
    DataMapper.setup(:default, 'sqlite::memory:')
    DataMapper.auto_migrate!
  end
  specify 'endorsing a gen' do
    run 'gem love fattr'
    gem_named('fattr').should have(1).endorsements
  end

  def run(shell_command)
    args = shell_command.shellsplit
    command = Gem::Commands::LoveCommand.new
    command.invoke(*args)
  end
  def gem_named(name)
    GemLove.gem_named(name)
  end
end
