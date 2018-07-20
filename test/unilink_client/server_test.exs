defmodule UnilinkClient.ServerTest do
  use ExUnit.Case, async: false
  alias UnilinkClient.{Server, Setting, TestEventsSourceFull}

  import Mock
  import UnilinkClient.TestEventsSource.Mocks

  describe "init/1" do

    test "inits with Setting list" do
      module = Application.get_env(:unilink_client, :module)
      Application.put_env(:unilink_client, :module, UnilinkClient.TestClientWithList)

      assert {:ok, []} == Server.init(:ok)
      Application.put_env(:unilink_client, :module, module)
    end

    test "inits with single Setting" do
      module = Application.get_env(:unilink_client, :module)
      Application.put_env(:unilink_client, :module, UnilinkClient.TestClient)

      assert {:ok, []} == Server.init(:ok)
      Application.put_env(:unilink_client, :module, module)
    end

  end

  describe "handle_info/2 :work" do

    test "processes empty event sources" do
      assert {:noreply, [%Setting{}]} == Server.handle_info(:work, [%Setting{}])
    end

    test "processes full test event source" do
      with_mocks([
        full_batch_source_mock(TestEventsSourceFull),
        api_client_mock()
      ]) do

        event_sources = Application.get_env(:unilink_client, :event_sources)
        Application.put_env(:unilink_client, :event_sources, [TestEventsSourceFull])

        assert {:noreply, []} == Server.handle_info(:work, [])

        Application.put_env(:unilink_client, :event_sources, event_sources)
      end
    end

  end


end
