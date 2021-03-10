ExUnit.start(trace: true)

# Set mock
Mox.defmock(SlMillan.APIMock, for: Tesla.Adapter)

Application.put_env(:tesla, :adapter, SlMillan.APIMock)
