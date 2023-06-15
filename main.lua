if (host:isHost()) then
    require("host.main");
else
    require("client.main");
end


events.WORLD_RENDER:register(function (delta, ctx)
    models.camera:setVisible(CameraTransform ~= nil);
    if (CameraTransform ~= nil) then
        local camHandle = models.camera;
        local rollHandle = camHandle.RollHandle;
        camHandle:setPos(CameraTransform.pos * 16);
        local rot = -CameraTransform.rot + vec(0,180,0);
        camHandle:setRot(rot.xy_);
        rollHandle:setRot(rot.__z);
        nameplate.ENTITY:setPivot(CameraTransform.pos + vec(0, 1, 0) - player:getPos(delta));
    else
        nameplate.ENTITY:setPivot(nil);
    end
end)