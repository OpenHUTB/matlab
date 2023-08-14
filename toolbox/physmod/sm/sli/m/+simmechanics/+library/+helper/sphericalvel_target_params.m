function maskParams=sphericalvel_target_params(prefix)

    if nargin<1||isempty(prefix)
        prefix='';
    else
        prefix=genvarname(prefix);
    end

    msgFcn=@pm_message;
    make_params=@simmechanics.library.helper.make_params;

    maskParams=make_params(...
    [prefix,msgFcn(fullId('value'))],...
    '[0 0 0]',...
    [prefix,msgFcn(fullId('valueUnits'))],...
    'deg/s',true);

    maskParams(end+1)=pm.sli.MaskParameter;

    maskParams(end).VarName=[prefix,msgFcn('mech2:messages:parameters:target:specify:ParamName')];
    maskParams(end).Value='off';

    maskParams(end+1)=pm.sli.MaskParameter;

    maskParams(end).VarName=[prefix,msgFcn('mech2:messages:parameters:target:strength:ParamName')];
    maskParams(end).Value=msgFcn('mech2:sli:blockParameters:target:strength:high:Value');

    maskParams(end+1)=pm.sli.MaskParameter;

    maskParams(end).VarName=[prefix,msgFcn(fullId('inFollowerFrame'))];
    maskParams(end).Value='on';

end

function fullMsgId=fullId(msgId)
    fullMsgId=['mech2:messages:parameters:target:sphericalVelocityTarget:',msgId,':ParamName'];
end
