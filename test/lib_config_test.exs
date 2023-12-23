defmodule LibConfigTest do
  use ExUnit.Case
  doctest LibConfig

  defmodule LibConfigTestModule do
    use LibConfig,
      app_name: :my_test_app,
      definition: [
        test_integer: [
          type: :non_neg_integer,
          required: true
        ],
        test_url: [
          type: :string,
          required: true
        ]
      ]
  end

  test "validates a config list when correct" do
    Application.put_env(:my_test_app, :test_integer, 5)
    Application.put_env(:my_test_app, :test_url, "http://www.helloworld.com")
    assert LibConfigTestModule.validate() == :ok
  end

  test "adds private function __lib_config_field__(:app_name)" do
    assert :my_test_app == LibConfigTestModule.__lib_config_field__(:app_name)
  end

  test "adds private function __lib_config_field__(:definition)" do
    assert [
             test_integer: [
               type: :non_neg_integer,
               required: true
             ],
             test_url: [
               type: :string,
               required: true
             ]
           ] == LibConfigTestModule.__lib_config_field__(:definition)
  end

  test "raises an exception when invalid application config" do
    Application.put_env(:my_test_app, :test_integer, "not_an_integer")
    Application.put_env(:my_test_app, :test_url, "http://www.helloworld.com")

    assert LibConfigTestModule.validate() ==
             {:error,
              %NimbleOptions.ValidationError{
                message:
                  "invalid value for :test_integer option: expected non negative integer, got: \"not_an_integer\"",
                key: :test_integer,
                value: "not_an_integer",
                keys_path: []
              }}
  end
end
