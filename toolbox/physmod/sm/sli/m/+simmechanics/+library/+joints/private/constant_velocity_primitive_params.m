function maskParams=constant_velocity_primitive_params()





    persistent CvPrimParams
    mlock;

    if isempty(CvPrimParams)


        msgFcn=@pm_message;
        maskParams(1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(fullCvParamId('internalState'));
        maskParams(end).Value=msgFcn(defCvValId('internalState'));


        sensingParams=cvSensingParams();



        lowerLimitParams={};
        upperLimitParams={};


        positionTargetParams=cvTargetParams('position');


        velocityTargetParams=cvTargetParams('velocity');


        maskParams=[maskParams;sensingParams(:);lowerLimitParams(:);upperLimitParams(:);...
        positionTargetParams(:);velocityTargetParams(:)];

        CvPrimParams=maskParams;
    else
        maskParams=CvPrimParams;
    end

end



function maskParams=cvTargetParams(targetType)



    msgFcn=@pm_message;
    make_params=@simmechanics.library.helper.make_params;

    assert(strcmp(targetType,'position')||strcmp(targetType,'velocity'));

    prefix=msgFcn(fullCvParamId(['state:',targetType]));




    maskParams(1)=pm.sli.MaskParameter;

    maskParams(end).VarName=[prefix,msgFcn(fullTargetParamId('specify'))];
    maskParams(end).Value=msgFcn(defTargetValId('specify'));

    maskParams(end+1)=pm.sli.MaskParameter;

    maskParams(end).VarName=[prefix,msgFcn(fullTargetParamId('strength'))];
    maskParams(end).Value=msgFcn(defTargetValId('strength'));

    maskParams(end+1)=pm.sli.MaskParameter;

    maskParams(end).VarName=[prefix,msgFcn(fullTargetParamId('constantVelocityTarget:specificationMethod'))];
    maskParams(end).Value=msgFcn(defTargetValId('constantVelocityTarget:specificationMethod'));



    maskParams=[maskParams,make_params(...
    [prefix,msgFcn(fullTargetParamId('constantVelocityTarget:polarAngleValue'))],...
    defValueBasedOnTargetType(targetType,'constantVelocityTarget:polarAngleValue'),...
    [prefix,msgFcn(fullTargetParamId('constantVelocityTarget:polarAngleValueUnits'))],...
    defValueBasedOnTargetType(targetType,'constantVelocityTarget:polarAngleValueUnits'),...
    true)];



    maskParams=[maskParams,make_params(...
    [prefix,msgFcn(fullTargetParamId('constantVelocityTarget:azimuthValue'))],...
    defValueBasedOnTargetType(targetType,'constantVelocityTarget:azimuthValue'),...
    [prefix,msgFcn(fullTargetParamId('constantVelocityTarget:azimuthValueUnits'))],...
    defValueBasedOnTargetType(targetType,'constantVelocityTarget:azimuthValueUnits'),...
    true)];

end


function value=defValueBasedOnTargetType(targetType,valueType)



    msgFcn=@pm_message;

    assert(strcmp(targetType,'position')||strcmp(targetType,'velocity'));

    value='';
    if strcmp(targetType,'position')
        value=msgFcn(defTargetValId([valueType,':angle']));
    elseif strcmp(targetType,'velocity')
        value=msgFcn(defTargetValId([valueType,':angularVelocity']));
    end

end



function maskParams=cvSensingParams()


    msgFcn=@pm_message;

    maskParams(1)=pm.sli.MaskParameter;

    maskParams(end).VarName=msgFcn(fullCvParamId('sensePolarAnglePosition'));
    maskParams(end).Value=msgFcn(defCvValId('sensePolarAnglePosition'));

    maskParams(end+1)=pm.sli.MaskParameter;

    maskParams(end).VarName=msgFcn(fullCvParamId('sensePolarAngleVelocity'));
    maskParams(end).Value=msgFcn(defCvValId('sensePolarAngleVelocity'));

    maskParams(end+1)=pm.sli.MaskParameter;

    maskParams(end).VarName=msgFcn(fullCvParamId('sensePolarAngleAcceleration'));
    maskParams(end).Value=msgFcn(defCvValId('sensePolarAngleAcceleration'));

    maskParams(end+1)=pm.sli.MaskParameter;

    maskParams(end).VarName=msgFcn(fullCvParamId('senseAzimuthPosition'));
    maskParams(end).Value=msgFcn(defCvValId('senseAzimuthPosition'));

    maskParams(end+1)=pm.sli.MaskParameter;

    maskParams(end).VarName=msgFcn(fullCvParamId('senseAzimuthVelocity'));
    maskParams(end).Value=msgFcn(defCvValId('senseAzimuthVelocity'));

    maskParams(end+1)=pm.sli.MaskParameter;

    maskParams(end).VarName=msgFcn(fullCvParamId('senseAzimuthAcceleration'));
    maskParams(end).Value=msgFcn(defCvValId('senseAzimuthAcceleration'));

end



function fullMsgId=fullCvParamId(msgId)
    fullMsgId=['mech2:messages:parameters:constantVelocityPrimitive:',msgId,':ParamName'];
end

function fullMsgId=defCvValId(msgId)
    fullMsgId=['sm:sli:defaults:constantVelocityPrimitive:',msgId];
end



function fullMsgId=fullTargetParamId(msgId)
    fullMsgId=['mech2:messages:parameters:target:',msgId,':ParamName'];
end

function fullMsgId=defTargetValId(msgId)
    fullMsgId=['sm:sli:defaults:target:',msgId];
end

