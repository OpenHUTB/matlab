function c=checkMotorwayUsualMinSpeed(data,params)





    vMode=data.v(data.opMode=='motorway');
    isAboveTh=vMode>params.MotorwayUsualMinSpeed;
    T=nnz(isAboveTh)*params.dt;
    c=params.MotorwayUsualMinSpeedTime-T;
end