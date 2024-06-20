defmodule PunkmadeWeb.ErrorJSONTest do
  use PunkmadeWeb.ConnCase, async: true

  test "renders 404" do
    assert PunkmadeWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert PunkmadeWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
