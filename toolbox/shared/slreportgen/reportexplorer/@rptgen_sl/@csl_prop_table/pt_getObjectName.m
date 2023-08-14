function objName=pt_getObjectName(c,isOutline)

















    if isOutline
        objName=c.ObjectType;
    else
        objName='Simulink';
    end
