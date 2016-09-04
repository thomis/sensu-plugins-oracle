require 'spec_helper'

describe SensuPluginsOracle::Session do

  context 'connect string' do

    before(:each) do
      @session = SensuPluginsOracle::Session.new(connect_string: "a/b@c", name: 'a_name')
    end

    it "creates a session" do
      expect(@session.name).to eq('a_name')
      expect(@session.connect_string).to eq('a/b@c')
    end

    it "handles invalid aliveness" do
      expect(@session.alive?).to eq(false)
    end

    it 'return error message' do
      @session.alive?
      expect(@session.error_message).to eq('a_name: ORA-12154: TNS:could not resolve the connect identifier specified')
    end

  end

  context 'connection with username, password, database, and priviledges' do

    before(:each) do
      @session = SensuPluginsOracle::Session.new(username: 'a', password: 'b', database: 'c', priviledge: 'SYSDBA', name: 'a_name')
    end

    it "creates a session" do
      expect(@session.name).to eq('a_name')
      expect(@session.username).to eq('a')
      expect(@session.password).to eq('b')
      expect(@session.database).to eq('c')
      expect(@session.priviledge).to eq(:SYSDBA)
    end

    it "handles invalid aliveness" do
      expect(@session.alive?).to eq(false)
    end

    it 'return error message' do
      @session.alive?
      expect(@session.error_message).to eq('a_name: ORA-12154: TNS:could not resolve the connect identifier specified')
    end

  end

end
