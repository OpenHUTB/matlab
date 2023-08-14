function c=checkRuralMinSpeed(data,params)





    vMode=data.v(data.opMode=='rural');
    c=params.OperationModeBoundaries(1)-min(vMode);
end