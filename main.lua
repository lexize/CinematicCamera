if (host:isHost()) then
    require("host.main");
else
    require("client.main");
end
