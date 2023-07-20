function r=checkMotorwayRatio(data,params)





    ratio=sum(data.v(data.opMode=='motorway'))/sum(data.v);
    r=RDE.functions.constraintInsideBounds(ratio,params.MotorwayRatioRange(1),params.MotorwayRatioRange(2));
end