defmodule Quarantine.Core do
  @max_int16 65535

  @type feature_name :: atom() | String.t()

  @spec score(feature_name, integer() | String.t()) :: float()
  def score(feature, id) do
    salt = to_string(feature)
    binary_id = to_string(id)
    <<int16::16, _::binary>> = :crypto.hash(:md5, salt <> binary_id)
    int16 / @max_int16
  end

  @spec enabled?(float(), feature_name, integer() | String.t()) :: boolean()
  def enabled?(config, feature, id) when is_float(config) do
    score(feature, id) <= config
  end

  @spec enabled?(list(), feature_name, String.t()) :: boolean()
  def enabled?(config, _feature, id) when is_list(config) do
    id in config
  end

  @spec enabled?(any(), atom(), String.t()) :: boolean()
  def enabled?(_, _, _) do
    false
  end
end
