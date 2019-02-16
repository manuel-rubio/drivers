defmodule GatewayConfigTest do
  use ExUnit.Case
  doctest Gateway.Config

  test "parse correct configuration file" do
    urls = [%{"method" => "PATCH",
              "nsq" => %{"topic" => "locations"},
              "path" => "/drivers/:id/locations"},
            %{"http" => %{"host" => "zombie-driver"},
              "method" => "GET",
              "path" => "/drivers/:id"}]
    Application.put_env(:gateway, :config_yaml, "test/files/config.yaml")
    assert urls == Gateway.Config.get_urls()
  end

  test "incorrect configuration file" do
    Application.put_env(:gateway, :config_yaml, "test/files/config_error.yaml")
    assert nil == Gateway.Config.get_urls()
  end

  test "no configuration file" do
    Application.put_env(:gateway, :config_yaml, "test/files/notfound.yaml")
    assert nil == Gateway.Config.get_urls()
  end

  test "ports to start server" do
    Application.put_env(:gateway, :port, 8080)
    assert 8080 == Gateway.Config.get_port()

    Application.put_env(:gateway, :port, 80)
    assert 80 == Gateway.Config.get_port()
  end

  test "config filename to retrieve configuration" do
    Application.put_env(:gateway, :config_yaml, "config.yaml")
    assert "config.yaml" == Gateway.Config.filename()

    Application.put_env(:gateway, :config_yaml, "test/files/config.yaml")
    assert "test/files/config.yaml" == Gateway.Config.filename()
  end

  test "get correct paths" do
    Application.put_env(:gateway, :config_yaml, "test/files/config.yaml")
    urls = Gateway.Config.get_urls()
    paths = [{'/drivers/:id/locations', Gateway.Server, ["PATCH", :nsq, :locations]},
             {'/drivers/:id', Gateway.Server, ["GET", :http, "zombie-driver"]}]
    assert paths == Gateway.Config.get_paths(urls)
  end

  test "get incorrect paths" do
    Application.put_env(:gateway, :config_yaml, "test/files/config_error.yaml")
    urls = Gateway.Config.get_urls()
    assert {:error, :config_yaml} == catch_throw(Gateway.Config.get_paths(urls))
  end
end
