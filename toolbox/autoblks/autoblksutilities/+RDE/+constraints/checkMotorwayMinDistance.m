function c=checkMotorwayMinDistance(data,params)





    vMode=data.v(data.opMode=='motorway');
    d=sum(vMode)*params.dt;
    c=params.MotorwayMinDistance-d;
end
