function maskParams=inertia_params(prefix)

    if nargin<1||isempty(prefix)
        prefix='';
    else
        prefix=genvarname(prefix);
    end

    msgFcn=@pm_message;
    make_params=@simmechanics.library.helper.make_params;

    maskParams(1)=pm.sli.MaskParameter;

    maskParams(end).VarName=[prefix,msgFcn(fullParamId('inertiaType'))];
    maskParams(end).Value=msgFcn(fullId('pointMass:ParamValue'));


    maskParams=[maskParams,make_params(msgFcn(fullParamId('pointMass:mass')),...
    '1',...
    msgFcn(fullParamId('pointMass:massUnits')),...
    'kg',true)];


    maskParams=[maskParams,make_params(...
    msgFcn(fullParamId('generalInertia:centerOfMass')),...
    '[0 0 0]',...
    msgFcn(fullParamId('generalInertia:centerOfMassUnits')),...
    'm',true)];

    maskParams=[maskParams,make_params(...
    msgFcn(fullParamId('generalInertia:momentsOfInertia')),...
    '[1 1 1]',...
    msgFcn(fullParamId('generalInertia:momentsOfInertiaUnits')),...
    'kg*m^2',true)];

    maskParams=[maskParams,make_params(...
    msgFcn(fullParamId('generalInertia:productsOfInertia')),...
    '[0 0 0]',...
    msgFcn(fullParamId('generalInertia:productsOfInertiaUnits')),...
    'kg*m^2',true)];

end

function fullMsgId=fullParamId(msgId)
    fullMsgId=['mech2:messages:parameters:inertia:',msgId,':ParamName'];
end

function fullMsgId=fullId(msgId)
    fullMsgId=['mech2:messages:parameters:inertia:',msgId];
end
