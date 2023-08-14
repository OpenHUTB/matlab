function maskParams=simple_primitive_params(primType)



    persistent RevoluteParams
    persistent PrismaticParams
    mlock;

    isRev=strcmpi(primType,'Revolute');

    if(isRev&&isempty(RevoluteParams))||...
        (~isRev&&isempty(PrismaticParams))

        msgFcn=@pm_message;
        make_params=@simmechanics.library.helper.make_params;

        stateUnits='m';
        springUnits='N/m';
        dampUnits='N/(m/s)';
        if isRev
            stateUnits='deg';
            springUnits='N*m/deg';
            dampUnits='N*m/(deg/s)';
        end

        maskParams=make_params(...
        msgFcn(fullId('equilibriumPosition')),'0',...
        msgFcn(fullId('equilibriumPositionUnits')),stateUnits,true);

        maskParams=[maskParams,make_params(...
        msgFcn(fullId('springStiffness')),'0',...
        msgFcn(fullId('springStiffnessUnits')),springUnits,true)];

        maskParams=[maskParams,make_params(...
        msgFcn(fullId('dampingCoefficient')),'0',...
        msgFcn(fullId('dampingCoefficientUnits')),dampUnits,true)];

        jpParams=joint_primitive_params();
        maskParams=[maskParams(:);jpParams(:)];

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=[msgFcn(fullId('sensePosition'))];
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=[msgFcn(fullId('senseVelocity'))];
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=[msgFcn(fullId('senseAcceleration'))];
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=[msgFcn(fullId('senseTorqueForce'))];
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=[msgFcn(fullId('senseLowerLimitTorqueForce'))];
        maskParams(end).Value='off';

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=[msgFcn(fullId('senseUpperLimitTorqueForce'))];
        maskParams(end).Value='off';


        lowerLimitParams=joint_limit_params(msgFcn(fullId('limit:lower')),primType);
        upperLimitParams=joint_limit_params(msgFcn(fullId('limit:upper')),primType);

        positionParams=simmechanics.library.helper.scalar_target_params([msgFcn(fullId('state:position'))],primType,'position');
        velocityParams=simmechanics.library.helper.scalar_target_params([msgFcn(fullId('state:velocity'))],primType,'velocity');

        maskParams=[maskParams(:);lowerLimitParams(:);upperLimitParams(:);...
        positionParams(:);velocityParams(:)];

        if isRev
            RevoluteParams=maskParams;
        else
            PrismaticParams=maskParams;
        end
    else
        if isRev
            maskParams=RevoluteParams;
        else
            maskParams=PrismaticParams;
        end
    end

end

function fullMsgId=fullId(msgId)
    fullMsgId=['mech2:messages:parameters:simplePrimitive:',msgId,':ParamName'];
end


