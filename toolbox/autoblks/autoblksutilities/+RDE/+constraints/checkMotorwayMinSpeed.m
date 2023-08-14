function c=checkMotorwayMinSpeed(data,params)





    vMode=data.v(data.opMode=='motorway');
    c=params.OperationModeBoundaries(2)-min(vMode);
end