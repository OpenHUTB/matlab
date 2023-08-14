function r=checkUrbanMinimumStopTime(data,params)





    tStop=RDE.functions.findStops(data.v(data.opMode=='urban'),params.StopSpeedTh,params.dt);
    n=nnz(tStop>=params.UrbanMinStopTime);
    r=params.UrbanMinStopCount-n;
end