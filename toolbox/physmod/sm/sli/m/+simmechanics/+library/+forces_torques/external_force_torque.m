function varargout=external_force_torque(varargin)



    persistent BlockInfoCache
    mlock;

    if isempty(BlockInfoCache)
        BlockInfoCache=simmechanics.sli.internal.BlockInfo;
        mfname=mfilename('fullpath');
        BlockInfoCache.SourceFile=which(mfname);
        BlockInfoCache.InitialVersion='R2012a';

        BlockInfoCache.SLBlockProperties.Name=...
        pm_message('sm:library:forcesAndTorques:external:Name');
        BlockInfoCache.SLBlockProperties.Position=[10,10,50,50];
        BlockInfoCache.SLBlockProperties.MaskIconUnits='normalized';
        BlockInfoCache.SLBlockProperties.Orientation='right';


        BlockInfoCache.setForwardingTableEntries('R2013b',...
        sprintf('sm_lib/Forces and\n Torques/External Force \nand Torque'));



        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.sl_postprocess',0,4.72);


        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.helper.translate_hertz_units',4.72,4.82);


        base_foll_ports=@simmechanics.library.helper.base_foll_ports;
        BlockInfoCache.addPorts(base_foll_ports('forcesTorques'));


        BlockInfoCache.IconFile=[mfname,'.svg'];


        msgFcn=@pm_message;

        maskParams(1)=simmechanics.library.helper.get_class_name_param(...
        pm_message('sm:model:blockNames:externalForceTorque:TypeId'));

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullParamId('forceResolutionFrame'));
        maskParams(end).Value=msgFcn(fullValueId('forceResolutionFrame:attachedFrame'));;

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullParamId('enableForceX'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullParamId('enableForceY'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullParamId('enableForceZ'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullParamId('enableForce'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullParamId('torqueResolutionFrame'));
        maskParams(end).Value=msgFcn(fullValueId('forceResolutionFrame:attachedFrame'));;

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullParamId('enableTorqueX'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullParamId('enableTorqueY'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullParamId('enableTorqueZ'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullParamId('enableTorque'));
        maskParams(end).Value='off';

        BlockInfoCache.addMaskParameters(maskParams);
    end

    if nargin==1
        varargout={simmechanics.library.helper.generate_outputs(BlockInfoCache,varargin{1})};
    else
        varargout{1}=BlockInfoCache.copy;
    end

end

function fullMsgId=fullParamId(msgId)
    fullMsgId=['mech2:messages:parameters:force:externalForceTorque:',msgId,':ParamName'];
end

function fullMsgId=fullValueId(msgId)
    fullMsgId=['mech2:sli:blockParameters:externalForceTorque:',msgId,':Value'];
end
