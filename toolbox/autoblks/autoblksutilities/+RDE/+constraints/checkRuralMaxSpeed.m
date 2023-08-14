function c=checkRuralMaxSpeed(data,params)





    vMode=data.v(data.opMode=='rural');
    c=max(vMode)-params.OperationModeBoundaries(2);
end