function[fcnVal,dfcn]=mv_risk_as_objective(x,H,g,objScalingFactor)
















    fcnVal=objScalingFactor*(0.5*x'*H*x+g'*x);


    if nargout>1
        dfcn=objScalingFactor*(H*x+g);
    end

end