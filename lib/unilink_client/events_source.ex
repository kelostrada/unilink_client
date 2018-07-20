defmodule UnilinkClient.EventsSource do
  @callback get(integer, UnilinkClient.Setting.t) :: list(%{})
  @callback mark_as_sent(list(integer)) :: atom
end
