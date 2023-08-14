function maskParams=rotation_target_params(prefix)

    if nargin<1||isempty(prefix)
        prefix='';
    else
        prefix=genvarname(prefix);
    end

    msgFcn=@pm_message;

    tgtPrefix=msgFcn('mech2:messages:parameters:target:Prefix');
    maskParams=simmechanics.library.helper.rotation_params([prefix,tgtPrefix]);

    maskParams(end+1)=pm.sli.MaskParameter;

    maskParams(end).VarName=[prefix,msgFcn('mech2:messages:parameters:target:specify:ParamName')];
    maskParams(end).Value='off';

    maskParams(end+1)=pm.sli.MaskParameter;

    maskParams(end).VarName=[prefix,msgFcn('mech2:messages:parameters:target:strength:ParamName')];
    maskParams(end).Value=msgFcn('mech2:sli:blockParameters:target:strength:high:Value');

end

function fullMsgId=fullId(msgId)
    fullMsgId=['mech2:messages:parameters:target:rotationTarget:',msgId,':ParamName'];
end
