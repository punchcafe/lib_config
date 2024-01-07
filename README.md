# LibConfig

LibConfig is a tiny library which handles a standard way to define, validate, access and document your Application configuration.

It's a very small library built on top of the awesome [NimbleOptions](https://github.com/dashbitco/nimble_options) library to make use of it's robust and idiomatic schema language.

While useable in any place you use Application config, `LibConfig` really shines when developing libraries which bring in their own otp applications.

## Installation

TODO

## Usage

LibConfig wraps around vanilla Elixir/OTP Application configuration, providing a number of convenience functions to simplify and standardise the way applications handle their configuration.

Let's demonstrate what it can do by using it for an imaginary app, `:alchemy_coffee`. First, we'll create the core configuraton module:

```elixir
defmodule AlchemyCoffee.Configuration do

  use LibConfig,
    app_name: :alchemy_coffee,
    definition: [
      coffee_price: [
        type: :non_neg_integer,
        required: true
      ],
      secret_witches_token: [
        type: :string,
        required: true
      ]
    ]
end
```

The module doesn't need to be called `Configuration`, it can be whatever you need. We've passed it two options:
- `:app_name`: which is the otp application's name
- `:definition`: This is a [NimbleOptions schema](https://hexdocs.pm/nimble_options/NimbleOptions.html#t:schema/0) definition of all the configuration terms the application accepts and requires.

In this example, we've created a module for the otp app `alchemy_coffee`, and declared that this app requires two configuration parameters: a non negative integer called `:coffee_price`, and a string token called `:secret_witches_token`.

Now we have our `AlchemyCoffee.Configuration`, let's look at some of the ways we can use it:

### Validating Application Configuration

Our usage of the `LibConfig` module means that we have a pair of functions `&AlchemyCoffee.Configuration.validate/0`, and `&AlchemyCoffee.Configuration.validate!/0`. When called, these functions assert that the application configuration for `:alchemy_coffee` is valid configuration and either returns an error tuple or raises an exception depending on which function you are using.

Let's look at a practical example of this. When developing a library application to be brought in to another application, the library must rely on the top level project to properly configure the application in its `config/` scripts. We want our application to fail fast if it's been misconfigured, so we can add a `validate!()` call to it's `start/2` function:

```elixir
defmodule AlchemyCoffee.Application do
  use Application

  def start(_type, _args) do
    AlchemyCoffee.Configuration.validate!()
    ...
  end
end
```

Now any elixir projects which bring in this application **must** provide valid configuration, otherwise the app will crash on start up.

### Accessing Application Configuration

LibConfig attempts to make accessing application configuration easier and safer by taking an explicitly typed approach to env access. For the two configuration variables defined above (`coffee_price` and `secret_witches_token`) `AlchemyCoffee.Configuration` will have two corresponding functions: `&AlchemyCoffee.Configuration.coffee_price/0` and `&AlchemyCoffee.Configuration.secret_witches_token/0`. For example, for the following configuration:

```elixir
# config/runtime.exs
config :alchemy_coffee, :coffee_price, 5
config :alchemy_coffee, :secret_witches_token, "salem_and_jiji"
```

We can access the value of `:coffee_price` as follows:

```elixir
...
  alias AlchemyCoffee.Configuration
  @spec calculate_total_price(integer()) :: integer()
  def calculate_total_price(number_of_coffees) do
    number_of_coffees * Configuration.coffee_price()
  end
...
```

The generated functions also have typespecs based off the type schema. Accessing environment variables in this way thus allows dialyzer to catch any unexpected type mismatches.

Let's look at one more example. Imagine the following configuration

```elixir
# config/runtime.exs
config :alchemy_coffee, :coffee_price, 5
config :alchemy_coffee, SpecialTechnique, [number_of_stirs: 5, drops_of_elixir: 5]
```

In some cases, we want to define configuration where the key wouldn't make a valid function name. In these cases, no function will be generated, but the value can still be accessed through `&AlchemyCoffee.Configuration.env/1`:

```elixir
AlchemyCoffee.Configuration.env(SpecialTechnique)
# [number_of_stirs: 5, drops_of_elixir: 5]
```


