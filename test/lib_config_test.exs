defmodule LibConfigTest do
  use ExUnit.Case

  test "adds private function __lib_config_field__(:otp_app)" do
    assert :my_test_app == LibConfigTestModule.__lib_config_field__(:otp_app)
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
             validate: [
               type: :boolean,
               required: true
             ],
             validate!: [
               type: :boolean,
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
      Application.put_env(:my_test_app, :validate, true)
      Application.put_env(:my_test_app, :validate!, false)
      assert LibConfigTestModule.validate!() == :ok
    end

    test "raises an exception when invalid application config" do
      Application.put_env(:my_test_app, :test_integer, "not_an_integer")
      Application.put_env(:my_test_app, :test_url, "http://www.helloworld.com")
      Application.put_env(:my_test_app, :validate, true)
      Application.put_env(:my_test_app, :validate!, false)

      assert_raise LibConfig.Error,
                   "Configuration error for application my_test_app: %NimbleOptions.ValidationError{message: \"invalid value for :test_integer option: expected non negative integer, got: \\\"not_an_integer\\\"\", key: :test_integer, value: \"not_an_integer\", keys_path: []}",
                   fn -> LibConfigTestModule.validate!() end
    end
  end

  describe "env/1" do
    test "it fetches application variables" do
      Application.put_env(:my_test_app, :test_integer, 5)
      Application.put_env(:my_test_app, :test_url, "http://www.helloworld.com")
      Application.put_env(:my_test_app, :"2invalid_name_key", "hello, world!")
      Application.put_env(:my_test_app, :validate, true)
      Application.put_env(:my_test_app, :validate!, true)

      assert LibConfigTestModule.env(:test_integer) == 5
      assert LibConfigTestModule.env(:test_url) == "http://www.helloworld.com"
      assert LibConfigTestModule.env(:"2invalid_name_key") == "hello, world!"
      assert LibConfigTestModule.env(:validate) == true
      assert LibConfigTestModule.env(:validate!) == true
    end

    test "it raises an function clause error if unknown environment" do
      assert_raise FunctionClauseError, fn -> LibConfigTestModule.env(:unknown_variable) end
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
               env: 1,
               test_integer: 0,
               test_url: 0,
               validate: 0,
               validate!: 0
             ]
    end
  end
end
