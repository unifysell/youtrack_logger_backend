:application.start(:logger)
ExUnit.start()
{:ok, _} = Application.ensure_all_started(:bypass)