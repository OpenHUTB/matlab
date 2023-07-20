function flags=generateScriptMultiplayerFlags(h)




    flags="";


    if~any([h.Multiplayer])
        return
    end

    flags=[
    "--callsign="+[h.Callsign];
    "--multiplay=out,10,"+[h.MultiplayerOutboundIpAddress]+","+[h.MultiplayerOutboundPort];
    "--multiplay=in,10,"+[h.MultiplayerInboundIpAddress]+","+[h.MultiplayerInboundPort];
    "--prop:bool:/sim/multiplay/hot="+string(logical([h.CollisionDetection]));
    ].';

    flags=flags.join();

end
