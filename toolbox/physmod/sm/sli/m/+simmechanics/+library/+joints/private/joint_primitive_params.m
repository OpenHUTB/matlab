function maskParams=joint_primitive_params()



    msgFcn=@pm_message;

    maskParams(1)=pm.sli.MaskParameter;
    maskParams(end).VarName=[msgFcn(fullId('torqueActuationMode'))];
    maskParams(end).Value='NoTorque';

    maskParams(end+1)=pm.sli.MaskParameter;
    maskParams(end).VarName=[msgFcn(fullId('motionActuationMode'))];
    maskParams(end).Value='ComputedMotion';

end

function fullMsgId=fullId(msgId)
    fullMsgId=['mech2:messages:parameters:jointPrimitive:',msgId,':ParamName'];
end


