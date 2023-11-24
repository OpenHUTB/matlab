function flags=generateScriptCommandFlags(h,operatingSystem)

    if h.DataFlow.contains("Send")
        sendFlag="--fdm=null --native-fdm=socket,in,30,"+...
        Aero.internal.flightgear.resolveAddress(h.DestinationIpAddress)+","+h.DestinationPort+",udp";
    else
        sendFlag="";
    end


    if h.DataFlow.contains("Receive")
        receiveFlag="--native-ctrls=socket,out,30,"+...
        Aero.internal.flightgear.resolveAddress(h.OriginIpAddress)+","+h.OriginPort+",udp";
    else
        receiveFlag="";
    end


    if h.InstallScenery
        terrasyncFlag="--enable-terrasync";
    else
        terrasyncFlag="";
    end
    if h.DisableShaders
        shadersFlag="--prop:/sim/rendering/shaders/quality-level=0";
    else
        shadersFlag="";
    end

    flags=[
    sendFlag;
    receiveFlag;
    terrasyncFlag;
shadersFlag
    ];


    flags(end+1)="--aircraft="+h.GeometryModelName;
    flags(end+1)="--fog-fastest";
    flags(end+1)="--disable-clouds";
    flags(end+1)="--start-date-lat=2004:06:01:09:00:00";
    flags(end+1)="--disable-sound";
    flags(end+1)="--in-air";
    flags(end+1)="--airport="+h.AirportId;
    flags(end+1)="--runway="+h.RunwayID;
    flags(end+1)="--altitude="+h.InitialAltitude;
    flags(end+1)="--heading="+h.InitialHeading;
    flags(end+1)="--offset-distance="+h.OffsetDistance;
    flags(end+1)="--offset-azimuth="+h.OffsetAzimuth;


    flags=join(flags);

end
