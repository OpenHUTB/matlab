function maskParams=var_inertia_params()




    msgFcn=@pm_message;
    make_params=@simmechanics.library.helper.make_params;

    maskParams(1)=pm.sli.MaskParameter;
    maskParams(end).VarName=msgFcn(fullParamId('variableInertiaType'));
    maskParams(end).Value=msgFcn(fullId('generalVariableInertia:ParamValue'));

    maskParams(end+1)=pm.sli.MaskParameter;
    maskParams(end).VarName=msgFcn(fullParamId('variablePointMass:massType'));
    maskParams(end).Value=msgFcn('mech2:messages:parameters:type:TimeVarying');

    maskParams=[maskParams,make_params(msgFcn(fullParamId('variablePointMass:mass')),...
    msgFcn(defValId('mass')),...
    msgFcn(fullParamId('variablePointMass:massUnits')),...
    msgFcn(defValId('massUnits')),true)];

    maskParams(end+1)=pm.sli.MaskParameter;
    maskParams(end).VarName=msgFcn(fullParamId('variablePointMass:centerOfMassType'));
    maskParams(end).Value=msgFcn('mech2:messages:parameters:type:TimeVarying');

    maskParams=[maskParams,make_params(...
    msgFcn(fullParamId('generalVariableInertia:centerOfMass')),...
    msgFcn(defValId('centerOfMass')),...
    msgFcn(fullParamId('generalVariableInertia:centerOfMassUnits')),...
    msgFcn(defValId('centerOfMassUnits')),true)];

    maskParams(end+1)=pm.sli.MaskParameter;
    maskParams(end).VarName=msgFcn(fullParamId('generalVariableInertia:inertiaMatrixType'));
    maskParams(end).Value=msgFcn('mech2:messages:parameters:type:TimeVarying');

    maskParams=[maskParams,make_params(...
    msgFcn(fullParamId('generalVariableInertia:momentsOfInertia')),...
    msgFcn(defValId('momentsOfInertia')),...
    msgFcn(fullParamId('generalVariableInertia:momentsOfInertiaUnits')),...
    msgFcn(defValId('momentsOfInertiaUnits')),true)];

    maskParams=[maskParams,make_params(...
    msgFcn(fullParamId('generalVariableInertia:productsOfInertia')),...
    msgFcn(defValId('productsOfInertia')),...
    msgFcn(fullParamId('generalVariableInertia:productsOfInertiaUnits')),...
    msgFcn(defValId('productsOfInertiaUnits')),true)];

end

function fullMsgId=fullParamId(msgId)
    fullMsgId=['mech2:messages:parameters:inertia:variableInertia:',msgId,':ParamName'];
end

function fullMsgId=fullId(msgId)
    fullMsgId=['mech2:messages:parameters:inertia:variableInertia:',msgId];
end

function defValId=defValId(msgId)
    defValId=['sm:sli:defaults:inertia:variableInertia:',msgId];
end
