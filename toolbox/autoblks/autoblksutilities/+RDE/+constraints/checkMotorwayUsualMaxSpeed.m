function c=checkMotorwayUsualMaxSpeed(data,params)





    vMotor=data.v(data.opMode=='motorway');


    c=prctile(vMotor,100-params.MotorwayAbsoluteSpeedTimeRatio*100)-params.MotorwayUsualMaxSpeed;
end