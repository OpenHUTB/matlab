function varargout=pulley(varargin)



    persistent BlockInfoCache
    mlock;

    if isempty(BlockInfoCache)
        BlockInfoCache=simmechanics.sli.internal.BlockInfo;
        mfname=mfilename('fullpath');
        BlockInfoCache.SourceFile=which(mfname);
        BlockInfoCache.InitialVersion='R2018a';

        msgFcn=@pm_message;

        BlockInfoCache.SLBlockProperties.Name=...
        msgFcn('sm:library:beltsCables:pulley:Name');
        BlockInfoCache.SLBlockProperties.Position=[10,10,50,50];
        BlockInfoCache.SLBlockProperties.MaskIconUnits='normalized';


        framePort=sm_ports_info('frame');
        frameName=msgFcn('sm:model:blockNames:pulley:ports:Frame');
        BlockInfoCache.addPorts(simmechanics.sli.internal.PortInfo(...
        framePort.PortType,frameName,'left',frameName));

        beltCableAPort=sm_ports_info('beltcable');
        beltCableAName=msgFcn('sm:model:blockNames:pulley:ports:BeltCableA');
        BlockInfoCache.addPorts(simmechanics.sli.internal.PortInfo(...
        beltCableAPort.PortType,beltCableAName,'right',beltCableAName));

        beltCableBPort=sm_ports_info('beltcable');
        beltCableBName=msgFcn('sm:model:blockNames:pulley:ports:BeltCableB');
        BlockInfoCache.addPorts(simmechanics.sli.internal.PortInfo(...
        beltCableBPort.PortType,beltCableBName,'right',beltCableBName));


        BlockInfoCache.IconFile=[mfname,'.svg'];


        make_params=@simmechanics.library.helper.make_params;

        maskParams(1)=simmechanics.library.helper.get_class_name_param(...
        pm_message('sm:model:blockNames:pulley:TypeId'));


        maskParams=[maskParams,make_params(msgFcn(paramId('pitchRadius')),...
        msgFcn(defValId('pitchRadius')),...
        msgFcn(paramId('pitchRadiusUnits')),...
        msgFcn(defValId('pitchRadiusUnits')),...
        true)];


        maskParams=[...
        maskParams,make_params(msgFcn(paramId('initialWrapAngle:lowerBound')),...
        msgFcn(defValId('initialWrapAngle:lowerBound')),...
        msgFcn(paramId('initialWrapAngle:lowerBoundUnits')),...
        msgFcn(defValId('initialWrapAngle:lowerBoundUnits')),...
        true)];


        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(paramId('senseWrapAngle'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(paramId('sensePulleyAngleA'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(paramId('sensePulleyAngleB'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(paramId('senseFleetAngleA'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(paramId('senseFleetAngleB'));
        maskParams(end).Value='off';

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
    param_id=['mech2:messages:parameters:beltCable:pulley:',msgId,':ParamName'];
end

function param_id=defValId(pId)
    param_id=['sm:sli:defaults:pulley:',pId];
end


