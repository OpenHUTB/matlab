function c=checkMotorwayAbsoluteMaxSpeed(data,params)





    vMotor=data.v(data.opMode=='motorway');


    c=max(vMotor)-params.MotorwayAbsoluteMaxSpeed;
end