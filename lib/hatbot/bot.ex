defmodule Hatbot.Bot do
  use Slack

  def init(initial_state, slack) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, initial_state}
  end

  def handle_message(message = %{type: "message", text: "hatbot peek"}, slack, state) do
    send_message("Current state: #{inspect(state)}", message.channel, slack)
    {:ok, state}
  end

  def handle_message(message = %{type: "message", text: "hatbot help"}, slack, state) do
    response = """
    This is how you use the hatbot™
    Send a direct message to me to add something to the hat.
    Send 'hatbot stats' to show a count of items in the hat and who has added items.
    Send 'hatbot draw' to draw a random item from the hat.
    Send 'hatbot reset' to empty the hat.
    Send 'hatbot peek' to peek into the hat.
    """
    send_message(response, message.channel, slack)
    {:ok, state}
  end

  def handle_message(message = %{type: "message", text: "hatbot crash"}, slack, state) do
    raise("Crash boom bang!")
  end

  def handle_message(message = %{type: "message", text: "hatbot stats"}, slack, state) when state == %{} do
    send_message("My hat is empty... I have no stats to give you.", message.channel, slack)
    {:ok, state}
  end
  def handle_message(message = %{type: "message", text: "hatbot stats"}, slack, state) do
    adders = Enum.map(state, fn {_, {name, _}} -> name end) |> Enum.join(", ")
    response = """
    There are #{map_size(state)} items in my hat!
    Added by: #{adders}
    """
    send_message(response, message.channel, slack)
    {:ok, state}
  end

  def handle_message(message = %{type: "message", text: "hatbot draw"}, slack, state) when state == %{} do
    send_message("My poor hat is empty :cry: Send me a direct message to add something!", message.channel, slack)
    {:ok, state}
  end
  def handle_message(message = %{type: "message", text: "hatbot draw"}, slack, state) do
    :random.seed(:os.timestamp)
    keys = Map.keys(state)
    selected_key = Enum.at(keys, :random.uniform(length(keys)) - 1)
    {name, pick} = state[selected_key]
    response= """
    The pick was: '#{pick}'.
    It was added by #{name}! :tada:
    """
    send_message(response, message.channel, slack)
    {:ok, state}
  end

  def handle_message(message = %{type: "message", text: "hatbot reset"}, slack, _state) do
    send_message("Resetting the hat.", message.channel, slack)
    {:ok, %{}}
  end

  def handle_message(message = %{type: "message", channel: "D" <> _rest}, slack, state) do
    state = Map.put(state, message.user, {slack.users[message.user].name, message.text})
    message_to_send = "Added to hat. Thank you!"
    send_message(message_to_send, message.channel, slack)
    {:ok, state}
  end

  def handle_message(_message, _slack, state) do
    {:ok, state}
  end
end
