defmodule LibConfigTestModule do
  use LibConfig,
    otp_app: :my_test_app,
    definition: [
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
    ]
end
