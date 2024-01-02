defmodule LibConfig.CodegenTest do
  use ExUnit.Case, async: false

  alias LibConfig.Codegen

  @sample_definition [
    test_integer: [
      type: :non_neg_integer,
      required: true
    ],
    test_url: [
      type: :string,
      required: true
    ],
    "2invalid_name_key": [type: :string, required: false]
  ]

  describe "generate_env_function/2" do
    test "it generates an env function which takes keys" do
      expected = """
      @spec env(atom()) :: term()
      def env(key) when key in [:test_integer, :test_url, :"2invalid_name_key"] do
        Application.fetch_env!(:my_app, key)
      end\
      """

      assert expected ==
               Codegen.generate_env_function(:my_app, @sample_definition) |> Macro.to_string()
    end
  end

  describe "generate_key_functions/2" do
    test "it generates an key functions and their type specs" do
      expected = """
      @spec test_integer() :: non_neg_integer()
      def test_integer() do
        Application.get_env(:my_app, :test_integer)
      end

      @spec test_url() :: binary()
      def test_url() do
        Application.get_env(:my_app, :test_url)
      end\
      """

      assert expected ==
               Codegen.generate_key_functions(:my_app, @sample_definition) |> Macro.to_string()
    end
  end
end
