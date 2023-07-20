function r=checkRuralRatio(data,params)





    ratio=sum(data.v(data.opMode=='rural'))/sum(data.v);
    r=RDE.functions.constraintInsideBounds(ratio,params.RuralRatioRange(1),params.RuralRatioRange(2));
end