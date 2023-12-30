defmodule LibConfigTest do
  use ExUnit.Case

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
             ],
             "2invalid_name_key": [type: :string, required: false]
           ] == LibConfigTestModule.__lib_config_field__(:definition)
  end

  describe "validate/0" do
    test "validates a config list when correct" do
      Application.put_env(:my_test_app, :test_integer, 5)
      Application.put_env(:my_test_app, :test_url, "http://www.helloworld.com")
      assert LibConfigTestModule.validate() == :ok
    end

    test "returns an error when invalid application config" do
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

  describe "validate!/0" do
    test "validates a config list when correct" do
      Application.put_env(:my_test_app, :test_integer, 5)
      Application.put_env(:my_test_app, :test_url, "http://www.helloworld.com")
      assert LibConfigTestModule.validate!() == :ok
    end

    test "raises an exception when invalid application config" do
      Application.put_env(:my_test_app, :test_integer, "not_an_integer")
      Application.put_env(:my_test_app, :test_url, "http://www.helloworld.com")

      assert_raise LibConfig.Error,
                   "Configuration error for application my_test_app: %NimbleOptions.ValidationError{message: \"invalid value for :test_integer option: expected non negative integer, got: \\\"not_an_integer\\\"\", key: :test_integer, value: \"not_an_integer\", keys_path: []}",
                   fn -> LibConfigTestModule.validate!() end
    end
  end

  describe "generated value functions" do
    # TODO: add testing for generated specs
    test "creates zero arity functions for defined env vars" do
      Application.put_env(:my_test_app, :test_integer, 5)
      Application.put_env(:my_test_app, :test_url, "http://www.helloworld.com")
      assert LibConfigTestModule.test_integer() == 5
      assert LibConfigTestModule.test_url() == "http://www.helloworld.com"
    end

    test "doesn't create function if invalid function name" do
      assert LibConfigTestModule.__info__(:functions) == [
               __lib_config_field__: 1,
               test_integer: 0,
               test_url: 0,
               validate: 0,
               validate!: 0
             ]
    end
  end
end
