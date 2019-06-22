defmodule Quarantine do
  @moduledoc File.read!("README.md")

  @doc """
  Check if the given `feature` is enabled or disabled for the given `id`.

  Returns `true` or `false`.

  ## Examples

  iex> Quarantine.enabled?(:some_feature, 1)
  false

  """
  @type feature_name :: atom() | String.t()
  @type id :: integer() | String.t()

  @spec enabled?(feature_name, id) :: boolean()
  def enabled?(feature, id) do
    Quarantine.Server.enabled?(feature, id)
  end

  @doc """
  Compute the scores of the given `feature` for the `ids`.

  Returns float between 0.0 and 1.0

  ## Examples

  iex> Quarantine.scores(:some_feature, [10, 11])
  [{10, 0.21571679255359733}, {11, 0.7114824139772641}]

  iex> Quarantine.scores(:other_feature, [10, 11])
  [{10, 0.7513847562371252}, {11, 0.9227740901808195}]

  """
  @spec scores(feature_name, id) :: float()
  def scores(feature, ids) do
    Enum.map(ids, fn id ->
      {id, Quarantine.Core.score(feature, id)}
    end)
  end
end
