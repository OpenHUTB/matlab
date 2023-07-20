function c=checkUrbanMaxSpeed(data,params)





    vMode=data.v(data.opMode=='urban');
    c=max(vMode)-params.OperationModeBoundaries(1);
end