function params=getCycleParams()








    params=struct();

    params.dt=1;
    params.StopSpeedTh=1/3.6;




    params.OperationModeBoundaries=[60,90]/3.6;


    params.UrbanRatioRange=[0.29,0.43];

    params.RuralRatioRange=[0.23,0.43];

    params.MotorwayRatioRange=[0.23,0.43];


    params.MotorwayUsualMaxSpeed=145/3.6;
    params.MotorwayAbsoluteSpeedTimeRatio=0.03;
    params.MotorwayAbsoluteMaxSpeed=160/3.6;


    params.UrbanAverageSpeedRange=[15,40]/3.6;


    params.UrbanStopRatioRange=[0.06,0.3];


    params.UrbanMinStopTime=10;
    params.UrbanMinStopCount=2;


    params.MotorwayUsualMinSpeed=100/3.6;
    params.MotorwayUsualMinSpeedTime=5*60;


    params.TripDurationRange=[90,120]*60;


    params.UrbanMinDistance=16000;
    params.RuralMinDistance=16000;
    params.MotorwayMinDistance=16000;


    params.RuralAverageSpeedRange=[60,90]/3.6;
    params.MotorwayAverageSpeedRange=[90,145]/3.6;






end