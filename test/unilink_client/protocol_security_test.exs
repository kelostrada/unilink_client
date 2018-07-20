defmodule UnilinkClient.ProtocolSecurityTest do
  use ExUnit.Case
  alias UnilinkClient.ProtocolSecurity

  @signature "CF3C354B1C9AEF090C96D1ED92CEAB9AB8B6ED293953137EA7323374F420523D"

  describe "signature/4" do
    test "calculates signature" do
      assert @signature == ProtocolSecurity.signature("{}", "?a=1", 123123123123, "secret")
    end
  end

  describe "check_signature/6" do
    setup do
      time = :os.system_time(:seconds)
      signature = ProtocolSecurity.signature("{}", "?a=1", time, "secret")
      %{signature: signature, time: to_string(time)}
    end

    test "checks signature", %{signature: signature, time: time} do
      assert :ok == ProtocolSecurity.check_signature("{}", "?a=1", time, "secret", signature, 0)
    end

    test "checks clock skew", %{signature: signature, time: time} do
      assert :ok == ProtocolSecurity.check_signature("{}", "?a=1", time, "secret", signature, 6)
    end

    test "checks incorrect clock skew", %{signature: signature, time: time} do
      :timer.sleep(1000)
      assert {:error, :timestamp_outside_margin} == ProtocolSecurity.check_signature("{}", "?a=1", time, "secret", signature, 0)
    end

    test "checks incorrect signature", %{time: time} do
      assert {:error, :signature_not_matching} == ProtocolSecurity.check_signature("{}", "?a=1", time, "secret", "ABCD", 5)
    end

  end

end
