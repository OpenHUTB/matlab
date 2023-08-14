function SetMountPointOptions(Block)


    if~autoblkschecksimstopped(Block)
        return
    end

    vehTag=get_param(Block,'vehTag');
    MaskObj=get_param(Block,'MaskObject');
    mountOptions=MaskObj.getParameter('mountLoc');

    if strcmp(vehTag,'Scene Origin')
        mountOptions.TypeOptions={'Origin'};
        return
    end

    vehicleBlock=sim3d.utils.SimPool.getActorBlock(Block,'SimulinkVehicle',vehTag);
    if isempty(vehicleBlock)
        vehicleBlock=sim3d.utils.SimPool.getActorBlock(Block,'Custom',vehTag);
    end

    if isempty(vehicleBlock)










        if blockFromAerospaceLibrary(Block)
            vehicleType='SkyHogg';
        else
            vehicleType='MuscleCar';
        end
    else


        type=get_param(vehicleBlock,'ActorType');
        if strcmp(type,'Sim3dActor')
            mountOptions.TypeOptions={'Origin'};
            return;
        end
        vehicleMaskObject=get_param(vehicleBlock,'MaskObject');
        ParamNames={vehicleMaskObject.Parameters.Name};
        meshParamName=ParamNames{contains(ParamNames,'Mesh')};
        vehicleType=sim3d.utils.internal.StringMap.fwd(get_param(vehicleBlock,meshParamName));
    end

    aircraft={'SkyHogg','Airliner','GeneralAviation','AirTransport'};
    uav={'Quadrotor','FixedWing'};
    if any(strcmp(aircraft,vehicleType))
        pointStrings=[properties(sim3d.aircraft.(vehicleType))','Origin'];
    elseif any(strcmp(uav,vehicleType))
        pointStrings=[properties(sim3d.uav.(vehicleType))','Origin'];
    else
        pointStrings=[properties(sim3d.auto.internal.(vehicleType))','Origin'];
    end

    mountOptions.TypeOptions=...
    cellfun(@sim3d.utils.internal.StringMap.inv,pointStrings,'UniformOutput',false);
end

function status=blockFromAerospaceLibrary(Block)
    status=strcmp(get_param(Block,'aMode'),'0');
end