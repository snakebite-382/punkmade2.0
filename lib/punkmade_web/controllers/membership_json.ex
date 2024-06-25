defmodule PunkmadeWeb.MembershipJSON do
  alias Punkmade.Scenes.Membership

  @doc """
  Renders a list of memberships.
  """
  def index(%{memberships: memberships}) do
    %{data: for(membership <- memberships, do: data(membership))}
  end

  @doc """
  Renders a single membership.
  """
  def show(%{membership: membership}) do
    %{data: data(membership)}
  end

  defp data(%Membership{} = membership) do
    %{
      id: membership.id,
      user_id: membership.user_id,
      scene_id: membership.scene_id
    }
  end
end
