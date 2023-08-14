function r=checkUrbanRatio(data,params)





    ratio=sum(data.v(data.opMode=='urban'))/sum(data.v);
    r=RDE.functions.constraintInsideBounds(ratio,params.UrbanRatioRange(1),params.UrbanRatioRange(2));
end