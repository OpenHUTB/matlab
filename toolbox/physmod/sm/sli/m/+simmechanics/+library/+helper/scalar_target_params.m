function maskParams=scalar_target_params(prefix,primType,stateType)



    if nargin<1||isempty(prefix)
        prefix='';
    else
        prefix=matlab.lang.makeValidName(prefix);
    end

    msgFcn=@pm_message;
    make_params=@simmechanics.library.helper.make_params;

    maskParams(1)=pm.sli.MaskParameter;

    maskParams(end).VarName=[prefix,msgFcn('mech2:messages:parameters:target:specify:ParamName')];
    maskParams(end).Value='off';

    maskParams(end+1)=pm.sli.MaskParameter;

    maskParams(end).VarName=[prefix,msgFcn('mech2:messages:parameters:target:strength:ParamName')];
    maskParams(end).Value=msgFcn('mech2:sli:blockParameters:target:strength:high:Value');

    if strcmp(primType,'dual')
        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=[prefix,msgFcn(fullParamId('dualModeScalarTarget:isAngular'))];
        maskParams(end).Value='off';

        rotationParams=targetValueAndUnitsParams(prefix,'revolute',stateType,'dualModeScalarTarget:rotation:');
        translationParams=targetValueAndUnitsParams(prefix,'prismatic',stateType,'dualModeScalarTarget:translation:');
        maskParams=[maskParams(:);rotationParams(:);translationParams(:)];
    else
        valueParams=targetValueAndUnitsParams(prefix,primType,stateType,'');
        maskParams=[maskParams(:);valueParams(:)];
    end

end

function maskParams=targetValueAndUnitsParams(prefix,primType,stateType,msg)

    msgFcn=@pm_message;
    make_params=@simmechanics.library.helper.make_params;

    unit='m';
    if strcmp(primType,'revolute')
        if strcmp(stateType,'position')
            unit='deg';
        else
            unit='deg/s';
        end
    else
        if strcmp(stateType,'position')
            unit='m';
        else
            unit='m/s';
        end
    end

    maskParams=make_params(...
    [prefix,msgFcn(fullParamId([msg,'value']))],...
    '0',...
    [prefix,msgFcn(fullParamId([msg,'valueUnits']))],...
    unit,true);

end


function fullMsgId=fullParamId(msgId)
    fullMsgId=['mech2:messages:parameters:target:scalarTarget:',msgId,':ParamName'];
end


