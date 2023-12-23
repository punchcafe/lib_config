defmodule LibConfig do
  @moduledoc """
  Documentation for `LibConfig`.
  """

  alias __MODULE__.Error

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

    env_functions = generate_env_functions(app_name, definition)

    quote do
      def __lib_config_field__(:app_name), do: unquote(app_name)
      def __lib_config_field__(:definition), do: unquote(Macro.escape(definition))

      def validate(), do: LibConfig.validate(__MODULE__)
      def validate!(), do: LibConfig.validate!(__MODULE__)

      unquote(env_functions)
    end
  end

  defp generate_env_functions(app_name, definition) do
    all_keys = Keyword.keys(definition)

    Enum.reduce(
      all_keys,
      quote do
      end,
      fn key, def_accumulator ->
        quote do
          unquote(def_accumulator)

          def unquote(key)() do
            Application.get_env(unquote(app_name), unquote(key))
          end
        end
      end
    )
  end
end
