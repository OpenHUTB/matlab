function maskParams=spherical_primitive_params()




    persistent SphPrimParams
    mlock;

    msgFcn=@pm_message;
    make_params=@simmechanics.library.helper.make_params;

    if isempty(SphPrimParams)
        maskParams=simmechanics.library.helper.rotation_params(msgFcn(fullId('equilibriumPosition')));

        maskParams=[maskParams,make_params(...
        msgFcn(fullId('springStiffness')),'0',...
        msgFcn(fullId('springStiffnessUnits')),'N*m/deg',true)];

        maskParams=[maskParams,make_params(...
        msgFcn(fullId('dampingCoefficient')),'0',...
        msgFcn(fullId('dampingCoefficientUnits')),'N*m/(deg/s)',true)];

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('actuateTorqueX'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('actuateTorqueY'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('actuateTorqueZ'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('actuateTorque'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn('mech2:messages:parameters:jointPrimitive:torqueActuationMode:ParamName');
        maskParams(end).Value='NoTorque';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn('mech2:messages:parameters:jointPrimitive:motionActuationMode:ParamName');
        maskParams(end).Value='ComputedMotion';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('actuationFrame'));
        maskParams(end).Value='BaseFrame';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('sensePosition'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseVelocityX'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseVelocityY'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseVelocityZ'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseVelocity'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseAccelerationX'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseAccelerationY'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseAccelerationZ'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseAcceleration'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseTorqueX'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseTorqueY'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseTorqueZ'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseTorqueForce'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(fullId('senseLowerLimitTorqueMag'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(fullId('senseUpperLimitTorqueMag'));
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('sensingFrame'));
        maskParams(end).Value='BaseFrame';


        lowerLimitParams=joint_limit_params(msgFcn(fullId('limit:lower')),'spherical');
        upperLimitParams=joint_limit_params(msgFcn(fullId('limit:upper')),'spherical');

        posPrefix=msgFcn(fullId('state:position'));
        positionStateParams=simmechanics.library.helper.rotation_target_params(posPrefix);

        velPrefix=msgFcn(fullId('state:velocity'));
        velocityStateParams=simmechanics.library.helper.sphericalvel_target_params(velPrefix);

        maskParams=[maskParams(:);lowerLimitParams(:);upperLimitParams(:);positionStateParams(:);velocityStateParams(:)];
        SphPrimParams=maskParams;
    else
        maskParams=SphPrimParams;
    end

end

function fullMsgId=fullId(msgId)
    fullMsgId=['mech2:messages:parameters:sphericalPrimitive:',msgId,':ParamName'];
end
