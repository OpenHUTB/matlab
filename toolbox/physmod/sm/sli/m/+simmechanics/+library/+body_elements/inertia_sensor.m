function varargout=inertia_sensor(varargin)



    persistent BlockInfoCache
    mlock;

    if isempty(BlockInfoCache)
        msgFcn=@pm_message;
        make_params=@simmechanics.library.helper.make_params;

        BlockInfoCache=simmechanics.sli.internal.BlockInfo;
        mfname=mfilename('fullpath');
        BlockInfoCache.SourceFile=which(mfname);
        BlockInfoCache.InitialVersion='R2019b';

        BlockInfoCache.SLBlockProperties.Name=...
        msgFcn('sm:library:bodyElements:inertiaSensor:Name');
        BlockInfoCache.SLBlockProperties.Position=[10,10,50,50];
        BlockInfoCache.SLBlockProperties.MaskIconUnits='normalized';
        BlockInfoCache.SLBlockProperties.Orientation='right';


        framePort=sm_ports_info('frame');
        frameName=msgFcn('sm:model:blockNames:inertiaSensor:ports:SensorExtent');
        BlockInfoCache.addPorts(simmechanics.sli.internal.PortInfo(...
        framePort.PortType,frameName,'left',frameName));

        frameName=msgFcn('sm:model:blockNames:inertiaSensor:ports:MeasurementFrame');
        BlockInfoCache.addPorts(simmechanics.sli.internal.PortInfo(...
        framePort.PortType,frameName,'left',frameName));


        BlockInfoCache.IconFile=[mfname,'.svg'];


        maskParams(1)=pm.sli.MaskParameter;
        maskParams(end).VarName=...
        msgFcn('mech2:messages:parameters:block:className:ParamName');
        maskParams(end).Value=msgFcn('sm:model:blockNames:inertiaSensor:TypeId');
        maskParams(end).ReadOnly='on';


        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(paramId('sensorExtent'));
        maskParams(end).Value=msgFcn(defValId('sensorExtent'));


        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(paramId('spanWeldJoints'));
        maskParams(end).Value=msgFcn(defValId('spanWeldJoints'));


        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(paramId('excludeGroundedBodies'));
        maskParams(end).Value=msgFcn(defValId('excludeGroundedBodies'));


        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(paramId('measurementFrame'));
        maskParams(end).Value=msgFcn(defValId('measurementFrame'));


        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(paramId('senseMass'));
        maskParams(end).Value=msgFcn(defValId('senseMass'));


        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(paramId('senseCenterOfMass'));
        maskParams(end).Value=msgFcn(defValId('senseCenterOfMass'));


        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(paramId('senseInertiaMatrix'));
        maskParams(end).Value=msgFcn(defValId('senseInertiaMatrix'));


        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(paramId('senseCenteredInertiaMatrix'));
        maskParams(end).Value=msgFcn(defValId('senseCenteredInertiaMatrix'));


        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(paramId('sensePrincipalInertiaMatrix'));
        maskParams(end).Value=msgFcn(defValId('sensePrincipalInertiaMatrix'));


        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(paramId('senseRotationMatrix'));
        maskParams(end).Value=msgFcn(defValId('senseRotationMatrix'));


        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(paramIdGraphic('graphicType'));
        maskParams(end).Value=msgFcn(defValIdGraphic('graphicType'));


        maskParams=[maskParams,make_params(...
        msgFcn(paramIdGraphic('principalInertiaFrame:principalInertiaFrameSize')),...
        msgFcn(defValIdGraphic('principalInertiaFrameSize')),...
        msgFcn(paramIdGraphic('principalInertiaFrame:principalInertiaFrameSizeUnits')),'',true)];


        visual_params=@simmechanics.library.helper.visual_params;
        prefix=msgFcn('mech2:messages:parameters:graphic:visualProperties:Prefix');
        maskParams=[maskParams,visual_params(prefix)];

        BlockInfoCache.addMaskParameters(maskParams);
    end

    if nargin==1
        varargout={simmechanics.library.helper.generate_outputs(BlockInfoCache,...
        varargin{1})};
    else
        varargout{1}=BlockInfoCache.copy;
    end

end

function param_id=paramId(msgId)
    param_id=['mech2:messages:parameters:inertiaSensor:',msgId,':ParamName'];
end

function param_id=defValId(pId)
    param_id=['sm:sli:defaults:inertiaSensor:',pId];
end

function param_id=paramIdGraphic(msgId)
    param_id=['mech2:messages:parameters:graphic:',msgId,':ParamName'];
end

function param_id=defValIdGraphic(msgId)
    param_id=['sm:sli:defaults:inertiaSensor:graphic:',msgId];
end