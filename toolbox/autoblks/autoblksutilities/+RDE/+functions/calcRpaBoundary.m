function y=calcRpaBoundary(v,params)











    v0=params.RPAVelocityThreshold;
    i1=v<=v0;
    y=zeros(size(v));
    v_kmh=3.6*v(i1);
    y(i1)=params.RPABoundarySpeedCoeff*v_kmh+params.RPABoundaryBias;
    y(~i1)=params.RPALowerBound;

end