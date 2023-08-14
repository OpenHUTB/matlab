function barrierParam=barrierAdaptiveUpdate(lambda_ip,slacks,sizes,options)


















    mu=dot(lambda_ip(sizes.mEq+1:end,1),slacks)/sizes.mIneq;
    xi=min(lambda_ip(sizes.mEq+1:end,1).*slacks)/mu;
    sigma=0.1*min(0.05*(1-xi)/xi,2)^3;
    sigma=max(sigma,options.SigmaFloor);
    barrierParam=sigma*mu;
end