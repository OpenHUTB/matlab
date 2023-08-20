function[varargout]=sim3dblksvisiondetectiongenerator(varargin)

    varargout{1}={};

    Block=varargin{1};
    Context=varargin{2};

    switch Context
    case 'Initialization'
        Initialization(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    case 'MountOffsetToggle'
        MountOffsetToggle(Block);
    case 'SetSensorName'
        SetSensorName(Block);
    case 'SetMountPointOptions'
        SetMountPointOptions(Block);
    case 'UpdateDropdowns'
        UpdateDropdowns(Block);
    case 'InitVehTagList'
        InitVehTagList(Block);
    case 'SetSampleTime'
        SetSampleTime(Block);
    case 'busNameSourceToggle'
        busNameSourceToggle(Block);
    end
end


function Initialization(Block)
    if bdIsLibrary(bdroot(Block))
        return
    end

    configureTruthOutports(Block);
    configureLanesAndObjectsOutports(Block);
    sim3d.utils.internal.SensorCallback.addSensorTag(Block);
    MaskObj=get_param(Block,'MaskObject');
    vehTag=MaskObj.getParameter('vehTag');
    set_param([Block,'/Simulation 3D Scenario Reader'],'VehicleIdentifier',vehTag.Value);

    autoblkscheckparams(Block,{'SampleTime',[1,1],{'st',0}});

    SetSampleTime(Block);

    setTransform(Block);
    checkSensorHeightAtModelInit(Block);

    SetSubsystemIntrinsics(Block);

    sensorId=get_param(Block,"sensorId");
    if str2double(sensorId)>0
        set_param(Block+"/Vision Detection Generator","SensorIndex",sensorId);
    end

end

function InitVehTagList(block)
    maskObj=get_param(block,'MaskObject');
    vehTagList=maskObj.getParameter('vehTagList');
    vehTag=maskObj.getParameter('vehTag');
    vehTag.TypeOptions=eval(vehTagList.Value);
end

function IconInfo=DrawCommands(Block)

    AliasNames={};
    IconInfo=autoblksgetportlabels(Block,AliasNames);


    IconInfo.ImageName='sim3d_vision_detection.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,40,'white');

    IconInfo.position(1)=max(0,IconInfo.position(1)-25);
end

function SetSampleTime(block)
    if bdIsLibrary(bdroot(block))
        return
    end



    modelStatus=get_param(bdroot(block),'SimulationStatus');
    if~strcmp(modelStatus,"updating")&&~strcmp(modelStatus,"initializing")
        return
    end

    SampleTime=get_param(block,'SampleTime');
    if strcmp(SampleTime,'-1')
        engineSampleTime=Simulation3DEngine.getEngineSampleTime(eval(SampleTime));
        set_param(block,'checkedSampleTime',num2str(engineSampleTime));
    else
        set_param(block,'checkedSampleTime',SampleTime);
    end
end

function SetSubsystemIntrinsics(block)
    template="driving.internal.cameraIntrinsics('FocalLength',%s,'PrincipalPoint',%s,'ImageSize',%s,'RadialDistortion',%s,'TangentialDistortion',%s,'Skew',%s)";

    FocalLength=get_param(block,'focalLength');
    PrincipalPoint=get_param(block,'opticalCenter');
    ImageSize=get_param(block,'imageSize');
    RadialDistortion=get_param(block,'radialDistortionCoefficients');
    TangentialDistortion=get_param(block,'tangentialDistortionCoefficients');
    Skew=get_param(block,'cameraAxisSkew');

    intrinsics=sprintf(template,FocalLength,PrincipalPoint,ImageSize,RadialDistortion,TangentialDistortion,Skew);
    set_param([block,'/Vision Detection Generator'],'Intrinsics',intrinsics);
end


function setTransform(block)



    transform=BlockTransform(block);

    set_param(block,'mountPoint',mat2str(transform.translation));
    set_param(block,'mountOrientation',mat2str(transform.rotation));

    vdg=[block,'/Vision Detection Generator'];
    set_param(vdg,"SensorLocation",mat2str(transform.translation(1:2)));
    set_param(vdg,"Height",mat2str(max(transform.translation(3),eps(1))));
    set_param(vdg,"Roll",mat2str(transform.rotation(1)));
    set_param(vdg,"Pitch",mat2str(transform.rotation(2)));
    set_param(vdg,"Yaw",mat2str(transform.rotation(3)));
end

function configureLanesAndObjectsOutports(block)
    outputType=lower(get_param(block,"DetectorOutput"));

    lanesOutportOptions={...
    'simulink/Sinks/Terminator','Lane Detections Terminator';...
    'simulink/Sinks/Out1','Lane Detections'...
    };


    if~contains(outputType,"lanes")
        autoblksreplaceblock(block,lanesOutportOptions,1);
    else
        autoblksreplaceblock(block,lanesOutportOptions,2);

        set_param(block+"/Lane Detections","Port","1");
    end

    objectsOutportOptions={...
    'simulink/Sinks/Terminator','Object Detections Terminator';...
    'simulink/Sinks/Out1','Object Detections'...
    };


    if~contains(outputType,"objects")
        autoblksreplaceblock(block,objectsOutportOptions,1);
    else
        autoblksreplaceblock(block,objectsOutportOptions,2);
    end
end

function configureTruthOutports(block)
    configureOptionalOutport(block,'actorTruthOutportEnabled',...
    {...
    'simulink/Sinks/Terminator','Actor Truth Terminator';...
    'simulink/Sinks/Out1','Actor Truth'...
    }...
    );

    configureOptionalOutport(block,'laneTruthOutportEnabled',...
    {...
    'simulink/Sinks/Terminator','Lane Truth Terminator';...
    'simulink/Sinks/Out1','Lane Truth'...
    }...
    );
end

function checkSensorHeightAtModelInit(block)
    status=get_param(bdroot,"SimulationStatus");
    if~strcmp(status,"initializing")&&~strcmp(status,"updating")
        return
    end

    MIN_SENSOR_HEIGHT=0.1;
    autoblksgetmaskparms(block,{'mountPoint'},true);
    assert(mountPoint(3)>=MIN_SENSOR_HEIGHT,message('shared_sim3dblks:sim3dblkVisDetect:blkErr_sensorTooLow'));
end

function busNameSourceToggle(block)
    autoblksenableparameters(block,{'BusName','BusName2'});

    objectBusNameSource=get_param(block,"BusNameSource");
    if strcmp(objectBusNameSource,"Auto")
        autoblksenableparameters(block,{},{'BusName'});
    end

    lanesBusNameSource=get_param(block,"BusName2Source");
    if strcmp(lanesBusNameSource,"Auto")
        autoblksenableparameters(block,{},{'BusName2'});
    end
end
