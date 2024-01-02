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

  @valid_function_names ~r/^[a-z_][A-z!?_]+$/

  defp should_make_function?(function_name) when is_atom(function_name) do
    function_name |> to_string() |> String.match?(@valid_function_names)
  end

  defp generate_env_function(app_name, definition) do
    quote do
      @spec env(atom()) :: term()
      def env(key) when key in unquote(Keyword.keys(definition)) do
        Application.fetch_env!(unquote(app_name), key)
      end
    end
  end

  defp generate_key_functions(app_name, definition) do
    all_envs =
      definition
      |> Enum.map(fn opt_definition = {opt_key, _} ->
        {^opt_key, typespec_type} = NimbleOptions.option_typespec([opt_definition])
        {opt_key, typespec_type}
      end)

    Enum.reduce(
      all_envs,
      quote do
      end,
      fn {key, typespec_type}, def_accumulator ->
        env_typespec_accumulator =
          if should_make_function?(key) do
            quote do
              unquote(def_accumulator)

              @spec unquote(key)() :: unquote(typespec_type)
              def unquote(key)() do
                Application.get_env(unquote(app_name), unquote(key))
              end
            end
          else
            def_accumulator
          end
      end
    )
  end
end
