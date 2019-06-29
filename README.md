# Quarantine
[![Build Status](https://travis-ci.org/leorog/quarantine.svg?branch=master)](https://travis-ci.org/leorog/quarantine)
[![Quarantine Version](https://img.shields.io/hexpm/v/quarantine.svg)](https://hex.pm/packages/quarantine)

Quarantine is a tiny OTP application for feature toggles.

Currently it supports two strategies:

* `whitelist` list of ids that can access some feature
* `percentage` compute a score from the given `id` check with `score <= percentage`. Note that the combination of `feature` name and `id` produce a deterministic score

## Setup

Add quarantine to your application deps

```elixir
def deps do
  [
    {:quarantine, "~> 0.1.2"}
  ]
end
```

You can setup flags using config environment or provide a [Quarantine.Driver](lib/quarantine/driver.ex) to [fetch configuration from an external source](https://github.com/leorog/quarantine/tree/master#refresh-config-without-re-deploying-your-application)

When hardcoded config is good enough you can provide it as below

```elixir
config :quarantine, 
   some_percentage_flag: 0.5,
   some_whitelist_flag: [1, 2, 3]
   other_whitelist_flag: ["08362804-bdc0-11e8-9407-24750000045e", "9fbc6c6e-f2dd-4f9d-8944-b81dd5a25fed"]
```

## Usage

Simply call `enabled?/2` where you want to split the control flow

```elixir
Quarantine.enabled?(:some_percentage_flag, 1)
=> false

Quarantine.enabled?(:some_percentage_flag, 2)
=> true

Quarantine.enabled?(:some_whitelist_flag, 1)
=> true

Quarantine.enabled?(:some_whitelist_flag, 9)
=> false
```

When using `percentage` you can check current ids distribution if needed with `scores/2` 

```elixir
Quarantine.scores(:some_percentage_flag, [1, 2, 3])
=>  [{1, 0.9967498283360037},
     {2, 0.18811322194247349},
     {3, 0.30522621499961855}]
```

## Testing

Flags can be enabled for a specific test with `Quarantine.Server.start_link/1`.

```elixir
Quarantine.Server.start_link(feature1: [1], feature2: [3,4])
```

## Refresh config without re-deploying your application

To do that you should provide an implementation of [Quarantine.Driver](lib/quarantine/driver.ex) that fetch flags configuration from a external source

Redis Driver example:
```elixir
defmodule RedisDriver do
  @behaviour Quarantine.Driver

  def get_flags() do
    Redix.command!(:my_redix, ["GET", "my_flags"])
  end
end
```

S3 Driver example:
```elixir
defmodule S3Driver do
  @behaviour Quarantine.Driver

  def get_flags() do
    "bucket"
    |> ExAws.S3.get_object("path")
    |> ExAws.request!()
  end
end
```

Then add it to `:quarantine` configuration:

```elixir
config :quarantine, 
   driver: RedisDriver,
   poll_interval: 60_000 # in ms
```
