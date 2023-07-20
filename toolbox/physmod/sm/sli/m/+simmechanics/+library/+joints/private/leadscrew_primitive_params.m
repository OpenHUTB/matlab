function maskParams=leadscrew_primitive_params()



    persistent LSPrimParams
    mlock;

    msgFcn=@pm_message;
    make_params=@simmechanics.library.helper.make_params;

    if isempty(LSPrimParams)

        maskParams(1)=pm.sli.MaskParameter;

        maskParams(end)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(fullId('direction'));
        maskParams(end).Value='RightHand';

        maskParams=[maskParams,make_params(...
        msgFcn(fullId('lead')),...
        '1.0',...
        msgFcn(fullId('leadUnits')),...
        'mm/rev',true)];

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(fullId('senseRotationPosition'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(fullId('senseRotationVelocity'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(fullId('senseRotationAcceleration'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(fullId('senseTranslationPosition'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(fullId('senseTranslationVelocity'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(fullId('senseTranslationAcceleration'));
        maskParams(end).Value='off';

        positionParams=simmechanics.library.helper.scalar_target_params(msgFcn(fullId('state:position')),'dual','position');
        velocityParams=simmechanics.library.helper.scalar_target_params(msgFcn(fullId('state:velocity')),'dual','velocity');

        maskParams=[maskParams(:);positionParams(:);velocityParams(:)];

        LSPrimParams=maskParams;
    else
        maskParams=LSPrimParams;
    end

end

function fullMsgId=fullId(msgId)
    fullMsgId=['mech2:messages:parameters:leadScrewPrimitive:',msgId,':ParamName'];
end
