function maskParams=rotation_params(prefix)



    persistent RotationParams
    mlock;

    msgFcn=@pm_message;
    make_params=@simmechanics.library.helper.make_params;

    if isempty(RotationParams)
        maskParams(1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullParamId('rotationMethod'));
        maskParams(end).Value=msgFcn(defValId('rotationMethod'));

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullParamId('elementaryRotation:rotationAngleUnits'));
        maskParams(end).Value=msgFcn(defValId('elementaryRotation:rotationAngleUnits'));


        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullParamId('elementaryRotation:elementaryRotAxis'));
        maskParams(end).Value=msgFcn(defValId('elementaryRotation:elementaryRotAxis'));

        maskParams=[maskParams,make_params(...
        msgFcn(fullParamId('elementaryRotation:rotationAngle')),...
        msgFcn(defValId('elementaryRotation:rotationAngle')),true)];


        maskParams=[maskParams,make_params(...
        msgFcn(fullParamId('angleAxisRotation:equivalentRotAxis')),...
        msgFcn(defValId('angleAxisRotation:equivalentRotAxis')),true)];


        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullParamId('alignedAxesRotation:follAlignAxisA'));
        maskParams(end).Value=msgFcn(defValId('alignedAxesRotation:follAlignAxisA'));

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullParamId('alignedAxesRotation:baseAlignAxisA'));
        maskParams(end).Value=msgFcn(defValId('alignedAxesRotation:baseAlignAxisA'));

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullParamId('alignedAxesRotation:follAlignAxisB'));
        maskParams(end).Value=msgFcn(defValId('alignedAxesRotation:follAlignAxisB'));

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullParamId('alignedAxesRotation:baseAlignAxisB'));
        maskParams(end).Value=msgFcn(defValId('alignedAxesRotation:baseAlignAxisB'));


        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullParamId('rotationSequenceRotation:rotationAxes'));
        maskParams(end).Value=msgFcn(defValId('rotationSequenceRotation:rotationAxes'));

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullParamId('rotationSequenceRotation:rotationSequence'));
        maskParams(end).Value=msgFcn(defValId('rotationSequenceRotation:rotationSequence'));

        maskParams=[maskParams,make_params(...
        msgFcn(fullParamId('rotationSequenceRotation:rotationAngles')),...
        msgFcn(defValId('rotationSequenceRotation:rotationAngles')),...
        msgFcn(fullParamId('rotationSequenceRotation:rotationAnglesUnits')),...
        msgFcn(defValId('rotationSequenceRotation:rotationAnglesUnits')),true)];


        maskParams=[maskParams,make_params(...
        msgFcn(fullParamId('rotationMatrixRotation:rotationMatrix')),...
        msgFcn(defValId('rotationMatrixRotation:rotationMatrix')),true)];


        maskParams=[maskParams,make_params(...
        msgFcn(fullParamId('quaternionRotation:quaternion')),...
        msgFcn(defValId('quaternionRotation:quaternion')),true)];

        RotationParams=maskParams;
    else
        maskParams=RotationParams;
    end

    for idx=1:length(maskParams)
        maskParams(idx).VarName=[prefix,maskParams(idx).VarName];
    end

end

function fullMsgId=fullParamId(msgId)
    fullMsgId=['mech2:messages:parameters:rotation:',msgId,':ParamName'];
end

function fullMsgId=defValId(msgId)
    fullMsgId=['sm:sli:defaults:rotation:',msgId];
end
