function maskParams=constraint_params(prefix)

    if nargin<1||isempty(prefix)
        prefix='';
    else
        prefix=genvarname(prefix);
    end

    msgFcn=@pm_message;

    maskParams(1)=pm.sli.MaskParameter;

    maskParams(end).VarName=msgFcn(fullId('senseTorque'));
    maskParams(end).Value='off';
















    maskParams(end+1)=pm.sli.MaskParameter;

    maskParams(end).VarName=msgFcn(fullId('senseForce'));
    maskParams(end).Value='off';
















    maskParams(end+1)=pm.sli.MaskParameter;

    maskParams(end).VarName=msgFcn(fullId('wrenchDir'));
    maskParams(end).Value='FollowerOnBase';

    maskParams(end+1)=pm.sli.MaskParameter;

    maskParams(end).VarName=msgFcn(fullId('wrenchFrame'));
    maskParams(end).Value='BaseFrame';

end

function fullMsgId=fullId(msgId)
    fullMsgId=['mech2:messages:parameters:constraint:',msgId,':ParamName'];
end
