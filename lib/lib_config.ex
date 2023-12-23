defmodule LibConfig do
  @moduledoc """
  Documentation for `LibConfig`.
  """

  def validate(module) do
    definition = module.__lib_config_field__(:definition)
    all_envs = Application.get_all_env(module.__lib_config_field__(:app_name))

    with {:ok, _} <- NimbleOptions.validate(all_envs, definition) do
      :ok
    end
  end

  defmacro __using__(opts) do
    definition = opts[:definition] || raise "must provide a definition"
    app_name = opts[:app_name] || raise "must provide an app name"

    quote do
      def __lib_config_field__(:app_name), do: unquote(app_name)
      def __lib_config_field__(:definition), do: unquote(Macro.escape(definition))

      def validate() do
        LibConfig.validate(__MODULE__)
      end
    end
  end
end
