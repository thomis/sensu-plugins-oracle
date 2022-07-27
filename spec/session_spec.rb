require "spec_helper"

RSpec.describe SensuPluginsOracle::Session do
  context "general" do
    it "has a version" do
      expect(SensuPluginsOracle::VERSION).not_to eq(nil)
      expect(SensuPluginsOracle::VERSION.split(".").size).to eq(3)
    end

    it "allows to set timeout" do
      expect {
        SensuPluginsOracle::Session.timeout_properties(30)
      }.not_to raise_error
    end

    it "creates session from file" do
      sessions = SensuPluginsOracle::Session.parse_from_file("spec/fixtures/connections.txt")

      expect(sessions.size).to eq(2)
      expect(sessions[0].name).to eq("name1")
      expect(session[0].connect_string).to eq("a/b@c")
      expect(session[1].name).to eq("name2")
      expect(session[1].connect_string).to eq("d/e@f")
    end
  end

  context "connect string" do
    let!(:session) {
      SensuPluginsOracle::Session.new(connect_string: "a/b@c", name: "a_name", module: "m")
    }

    it "creates a session" do
      expect(session.name).to eq("a_name")
      expect(session.connect_string).to eq("a/b@c")
      expect(session.module).to eq("m")
    end

    it "handles invalid aliveness" do
      expect(session.alive?).to eq(false)
      expect(session.error_message).to eq("a_name: ORA-12154: TNS:could not resolve the connect identifier specified")
    end

    it "return error message" do
      session.alive?
      expect(session.error_message).to eq("a_name: ORA-12154: TNS:could not resolve the connect identifier specified")
    end

    it "handles invalid query" do
      expect(session.query("select 1 from dual")).to eq(false)
      expect(session.error_message).to eq("a_name: ORA-12154: TNS:could not resolve the connect identifier specified")
    end

    it "handles empty query results" do
      method, message = session.handle_query_result
      expect(method).to eq(:ok)
      expect(message).to eq(nil)
    end

    it "handles simple query results" do
      session.rows = [[1]]

      method, message = session.handle_query_result(show: true)
      expect(method).to eq(:ok)
      expect(message).to eq("- 1")
    end

    it "handles simple query results with tuples" do
      session.rows = [[1]]

      method, message = session.handle_query_result(show: true, tuples: true)
      expect(method).to eq(:ok)
      expect(message).to eq("- 1")
    end

    it "handles simple query results with critical formula" do
      session.rows = [[1]]

      method, message = session.handle_query_result(show: true, critical: "value > 0")
      expect(method).to eq(:critical)
      expect(message).to eq("- 1")
    end

    it "handles simple query results with tuples and warning formula" do
      session.rows = [[1]]

      method, message = session.handle_query_result(show: true, tuples: true, warning: "value > 0")
      expect(method).to eq(:warning)
      expect(message).to eq("- 1")
    end

    it "handles simple query critical formula and provided name in result" do
      session = SensuPluginsOracle::Session.new(connect_string: "a/b@c", name: "a_name", provide_name_in_result: true)
      session.rows = [[1, 2]]

      method, message = session.handle_query_result(show: true, tuples: true, critical: "value > 0")
      expect(method).to eq(:critical)
      expect(message).to eq("a_name (1)\n- 1, 2")
    end
  end

  context "connection with username, password, database, and priviledges" do
    let!(:session) {
      SensuPluginsOracle::Session.new(username: "a", password: "b", database: "c", module: "d", priviledge: "SYSDBA", name: "a_name")
    }

    it "creates a session" do
      expect(session.name).to eq("a_name")
      expect(session.username).to eq("a")
      expect(session.password).to eq("b")
      expect(session.database).to eq("c")
      expect(session.module).to eq("d")
      expect(session.priviledge).to eq(:SYSDBA)
    end

    it "handles invalid aliveness" do
      expect(session.alive?).to eq(false)
      expect(session.error_message).to eq("a_name: ORA-12154: TNS:could not resolve the connect identifier specified")
    end

    it "return error message" do
      session.alive?
      expect(session.error_message).to eq("a_name: ORA-12154: TNS:could not resolve the connect identifier specified")
    end

    it "handles invalid query" do
      expect(session.query("select 1 from dual")).to eq(false)
      expect(session.error_message).to eq("a_name: ORA-12154: TNS:could not resolve the connect identifier specified")
    end
  end
end
