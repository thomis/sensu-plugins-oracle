require 'spec_helper'

describe SensuPluginsOracle::Session do

  context 'general' do

    it 'has a version' do
      expect(SensuPluginsOracle::VERSION).not_to eq(nil)
      expect(SensuPluginsOracle::VERSION.split('.').size).to eq(3)
    end

  end

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
      expect(@session.error_message).to eq('a_name: ORA-12154: TNS:could not resolve the connect identifier specified')
    end

    it 'return error message' do
      @session.alive?
      expect(@session.error_message).to eq('a_name: ORA-12154: TNS:could not resolve the connect identifier specified')
    end

    it 'handles invalid query' do
      expect(@session.query('select 1 from dual')).to eq(false)
      expect(@session.error_message).to eq('a_name: ORA-12154: TNS:could not resolve the connect identifier specified')
    end

    it 'handles empty query results' do
      method, message = @session.handle_query_result
      expect(method).to eq(:ok)
      expect(message).to eq(nil)
    end

    it 'handles simple query results' do
      @session.rows = [[1]]

      method, message = @session.handle_query_result(show: true)
      expect(method).to eq(:ok)
      expect(message).to eq('- 1')
    end

    it 'handles simple query results with tuples' do
      @session.rows = [[1]]

      method, message = @session.handle_query_result(show: true, tuples: true)
      expect(method).to eq(:ok)
      expect(message).to eq('- 1')
    end

    it 'handles simple query results with critical formula' do
      @session.rows = [[1]]

      method, message = @session.handle_query_result(show: true, critical: 'value > 0')
      expect(method).to eq(:critical)
      expect(message).to eq('- 1')
    end

    it 'handles simple query results with tuples and warning formula' do
      @session.rows = [[1]]

      method, message = @session.handle_query_result(show: true, tuples: true, warning: 'value > 0')
      expect(method).to eq(:warning)
      expect(message).to eq('- 1')
    end

    it 'handles simple query critical formula and provided name in result' do
      session = SensuPluginsOracle::Session.new(connect_string: "a/b@c", name: 'a_name', provide_name_in_result: true)
      session.rows = [[1,2]]

      method, message = session.handle_query_result(show: true, tuples: true, critical: 'value > 0')
      expect(method).to eq(:critical)
      expect(message).to eq("a_name (1)\n- 1, 2")
    end

  end

  context 'connection with username, password, database, and priviledges' do

    before(:each) do
      @session = SensuPluginsOracle::Session.new(username: 'a', password: 'b', database: 'c', module: 'd', priviledge: 'SYSDBA', name: 'a_name')
    end

    it "creates a session" do
      expect(@session.name).to eq('a_name')
      expect(@session.username).to eq('a')
      expect(@session.password).to eq('b')
      expect(@session.database).to eq('c')
      expect(@session.database).to eq('d')
      expect(@session.priviledge).to eq(:SYSDBA)
    end

    it "handles invalid aliveness" do
      expect(@session.alive?).to eq(false)
      expect(@session.error_message).to eq('a_name: ORA-12154: TNS:could not resolve the connect identifier specified')
    end

    it 'return error message' do
      @session.alive?
      expect(@session.error_message).to eq('a_name: ORA-12154: TNS:could not resolve the connect identifier specified')
    end

    it 'handles invalid query' do
      expect(@session.query('select 1 from dual')).to eq(false)
      expect(@session.error_message).to eq('a_name: ORA-12154: TNS:could not resolve the connect identifier specified')
    end
  end

end
