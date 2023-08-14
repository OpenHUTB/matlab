

function LockStatus=autoblksdrumbrake(block)

    LockStatus=false;

    MaskObject=get_param(block,'MaskObject');
    MaskVarNames={MaskObject.getWorkspaceVariables.Name};
    MaskVarValues={MaskObject.getWorkspaceVariables.Value};

    [~,i]=intersect(MaskVarNames,'drum_a');
    a=MaskVarValues{i};

    [~,i]=intersect(MaskVarNames,'drum_r');
    r=MaskVarValues{i};

    [~,i]=intersect(MaskVarNames,'mu_kinetic');
    mu=MaskVarValues{i};

    [~,i]=intersect(MaskVarNames,'drum_theta1');
    theta1=MaskVarValues{i}*pi/180.;

    [~,i]=intersect(MaskVarNames,'drum_theta2');
    theta2=MaskVarValues{i}*pi/180.;

    sigma=cos(theta2)-cos(theta1);

    Denominator1=2.*mu.*(-2.*r.*sigma-a.*(cos(theta1).^2-cos(theta2).^2));

    Denominator2=a.*(2.*theta1-2.*theta2-sin(2.*theta1)+sin(2.*theta2));

    if any((Denominator1+Denominator2)>=0)
        LockStatus=true;
    end

end