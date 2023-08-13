function transform=BlockTransform(Block)

    transform=[];

    if~autoblkschecksimstopped(Block)
        return
    end

    mountSelection=sim3d.utils.internal.StringMap.fwd(get_param(Block,'mountLoc'));
    if strcmp(mountSelection,'Origin')
        positionOrigin=[0,0,0];
        rotationOrigin=[0,0,0];
    else
        vehicleTag=get_param(Block,'vehTag');
        vehicleBlock=sim3d.utils.SimPool.getActorBlock(Block,'SimulinkVehicle',vehicleTag);

        if isempty(vehicleBlock)
            vehicleBlock=sim3d.utils.SimPool.getActorBlock(Block,'Custom',vehicleTag);
        end

        if isempty(vehicleBlock)
            return
        end

        vehicleMaskObject=get_param(vehicleBlock,'MaskObject');
        ParamNames={vehicleMaskObject.Parameters.Name};
        meshParamName=ParamNames{contains(ParamNames,'Mesh')};
        vehicleMesh=sim3d.utils.internal.StringMap.fwd(get_param(vehicleBlock,meshParamName));

        aircraft={'SkyHogg','Airliner','GeneralAviation','AirTransport'};
        if any(strcmp(aircraft,vehicleMesh))
            positionOrigin=sim3d.aircraft.(vehicleMesh).(mountSelection).translation;
            rotationOrigin=sim3d.aircraft.(vehicleMesh).(mountSelection).rotation;
        else
            positionOrigin=sim3d.auto.internal.(vehicleMesh).(mountSelection).translation;
            rotationOrigin=sim3d.auto.internal.(vehicleMesh).(mountSelection).rotation;
        end
    end

    autoblksgetmaskparms(Block,{'offsetFlag'},true);

    if~offsetFlag
        tmountOffset=[0,0,0];
        rmountOffset=[0,0,0];
    else
        autoblksgetmaskparms(Block,{'tmountOffset','rmountOffset'},true);
    end


    mountPoint=positionOrigin+[tmountOffset(1),-tmountOffset(2),tmountOffset(3)];

    mountOrientation=rad2deg(rotationOrigin)+[rmountOffset(1),-rmountOffset(2),-rmountOffset(3)];

    transform=struct(...
    "translation",mountPoint,...
    "rotation",mountOrientation...
    );
end