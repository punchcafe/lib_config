defmodule LibConfig do
  @moduledoc """
  Documentation for `LibConfig`.
  """

  alias __MODULE__.Error
  import __MODULE__.Codegen

  def validate!(module) do
    case validate(module) do
      :ok ->
        :ok

      {:error, error} ->
        app_name = module.__lib_config_field__(:app_name)
        raise Error, message: "Configuration error for application #{app_name}: #{inspect(error)}"
    end
  end

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

    key_functions = generate_key_functions(app_name, definition)
    env_function = generate_env_function(app_name, definition)

    quote do
      def __lib_config_field__(:app_name), do: unquote(app_name)
      def __lib_config_field__(:definition), do: unquote(Macro.escape(definition))

      def validate(), do: LibConfig.validate(__MODULE__)
      def validate!(), do: LibConfig.validate!(__MODULE__)

      unquote(env_function)
      unquote(key_functions)
    end
  end
end
