defmodule LibConfig.Codegen do
  @moduledoc false
  # Private module with functions extracted to enable easier testing

  @valid_function_names ~r/^[a-z_][A-z!?_]+$/

  @doc false
  @spec generate_env_function(module, NimbleOptions.schema()) :: Macro.t()
  def generate_env_function(app_name, definition) do
    quote do
      @spec env(atom()) :: term()
      def env(key) when key in unquote(Keyword.keys(definition)) do
        Application.fetch_env!(unquote(app_name), key)
      end
    end
  end

  @doc false
  @spec generate_key_functions(module, NimbleOptions.schema()) :: Macro.t()
  def generate_key_functions(app_name, definition) do
    all_envs =
      definition
      |> Enum.map(fn opt_definition = {opt_key, _} ->
        {^opt_key, typespec_type} = NimbleOptions.option_typespec([opt_definition])
        {opt_key, typespec_type}
      end)

    all_envs
    |> Enum.reduce({app_name, []}, &map_reduce_key_functions/2)
    |> then(fn {_, statements} -> {:__block__, [], statements} end)
  end

  defp map_reduce_key_functions({key, typespec_type}, {app_name, statement_acc}) do
    if should_skip_function?(key) do
      {app_name, statement_acc}
    else
      {:__block__, _, statements} =
        quote do
          @spec unquote(key)() :: unquote(typespec_type)
          def unquote(key)() do
            Application.get_env(unquote(app_name), unquote(key))
          end
        end

      {app_name, statement_acc ++ statements}
    end
  end

  defp should_skip_function?(function_name) when function_name in [:validate, :validate!],
    do: true

  defp should_skip_function?(function_name) when is_atom(function_name) do
    function_name
    |> to_string()
    |> String.match?(@valid_function_names)
    |> Kernel.not()
  end
end
