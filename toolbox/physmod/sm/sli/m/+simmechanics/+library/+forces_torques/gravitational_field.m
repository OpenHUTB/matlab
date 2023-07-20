function varargout=gravitational_field(varargin)



    persistent BlockInfoCache
    mlock;

    if isempty(BlockInfoCache)
        BlockInfoCache=simmechanics.sli.internal.BlockInfo;
        mfname=mfilename('fullpath');
        BlockInfoCache.SourceFile=which(mfname);
        BlockInfoCache.InitialVersion='R2014a';

        BlockInfoCache.SLBlockProperties.Name=...
        pm_message('sm:library:forcesAndTorques:gravitationalField:Name');
        BlockInfoCache.SLBlockProperties.Position=[10,10,50,50];
        BlockInfoCache.SLBlockProperties.MaskIconUnits='normalized';
        BlockInfoCache.SLBlockProperties.Orientation='right';



        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.sl_postprocess',0,4.72);


        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.helper.translate_hertz_units',4.72,4.82);

        msgFcn=@pm_message;
        make_params=@simmechanics.library.helper.make_params;

        framePort=sm_ports_info('frame');


        rightPort=simmechanics.sli.internal.PortInfo(framePort.PortType,...
        'F','right',pm_message('sm:model:blockNames:gravitationalField:ports:Frame'));
        BlockInfoCache.addPorts(rightPort);


        BlockInfoCache.IconFile=[mfname,'.svg'];


        maskParams(1)=simmechanics.library.helper.get_class_name_param(...
        pm_message('sm:model:blockNames:gravitationalField:TypeId'));

        maskParams=[maskParams,make_params(...
        msgFcn(fullId('mass')),...
        msgFcn(defValId('mass')),...
        msgFcn(fullId('massUnits')),...
        msgFcn(defValId('massUnits')),true)];

        BlockInfoCache.addMaskParameters(maskParams);
    end

    if nargin==1
        varargout={simmechanics.library.helper.generate_outputs(BlockInfoCache,varargin{1})};
    else
        varargout{1}=BlockInfoCache.copy;
    end

end

function fullMsgId=fullId(msgId)
    fullMsgId=['mech2:messages:parameters:force:gravitationalField:',msgId,':ParamName'];
end

function param_id=defValId(pId)
    param_id=['sm:sli:defaults:gravitationalField:',pId];
end
