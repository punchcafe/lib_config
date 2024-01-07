defmodule LibConfig do
  @moduledoc """
  Documentation for `LibConfig`.
  """

  alias __MODULE__.Error
  import __MODULE__.Codegen

  @spec validate!(atom()) :: :ok | no_return()
  def validate!(module) do
    case validate(module) do
      :ok ->
        :ok

      {:error, error} ->
        otp_app = module.__lib_config_field__(:otp_app)
        raise Error, message: "Configuration error for application #{otp_app}: #{inspect(error)}"
    end
  end

  @spec validate(atom()) :: :ok | {:error, struct()}
  def validate(module) do
    definition = module.__lib_config_field__(:definition)
    all_envs = Application.get_all_env(module.__lib_config_field__(:otp_app))

    with {:ok, _} <- NimbleOptions.validate(all_envs, definition) do
      :ok
    end
  end

  defmacro __using__(opts) do
    definition = opts[:definition] || raise "must provide a definition"
    otp_app = opts[:otp_app] || raise "must provide an app name"

    key_functions = generate_key_functions(otp_app, definition)
    env_function = generate_env_function(otp_app, definition)

    quote do
      def __lib_config_field__(:otp_app), do: unquote(otp_app)
      def __lib_config_field__(:definition), do: unquote(Macro.escape(definition))

      def validate(), do: LibConfig.validate(__MODULE__)
      def validate!(), do: LibConfig.validate!(__MODULE__)

      unquote(env_function)
      unquote(key_functions)
    end
  end
end
