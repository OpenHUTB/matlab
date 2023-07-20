function r=checkUrbanStopRatio(data,params)





    tStop=RDE.functions.findStops(data.v(data.opMode=='urban'),params.StopSpeedTh,params.dt);
    tTot=nnz(data.opMode=='urban')*params.dt;
    tStopTot=sum(tStop);
    ratio=tStopTot/tTot;
    r=RDE.functions.constraintInsideBounds(ratio,params.UrbanStopRatioRange(1),params.UrbanStopRatioRange(2));
end