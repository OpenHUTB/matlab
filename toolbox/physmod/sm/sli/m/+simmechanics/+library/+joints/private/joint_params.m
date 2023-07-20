function maskParams=joint_params()



    persistent JointParams
    mlock;

    msgFcn=@pm_message;

    if isempty(JointParams)

        maskParams(1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(fullId('mode'));
        maskParams(end).Value='Normal';


        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseConstraintForce'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseConstraintForceX'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseConstraintForceY'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseConstraintForceZ'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseConstraintTorque'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseConstraintTorqueX'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseConstraintTorqueY'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseConstraintTorqueZ'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseTotalForce'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseTotalForceX'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseTotalForceY'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseTotalForceZ'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseTotalTorque'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseTotalTorqueX'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseTotalTorqueY'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseTotalTorqueZ'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('compositeWrenchDir'));
        maskParams(end).Value='FollowerOnBase';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('compositeWrenchFrame'));
        maskParams(end).Value='BaseFrame';
        JointParams=maskParams;
    else
        maskParams=JointParams;
    end

end

function fullMsgId=fullId(msgId)
    fullMsgId=['mech2:messages:parameters:joint:',msgId,':ParamName'];
end
