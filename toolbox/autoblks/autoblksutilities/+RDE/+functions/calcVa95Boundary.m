function y=calcVa95Boundary(v,params)















    v_kmph=3.6*v;
    v0_kmph=3.6*params.VA95VelocityThreshold;

    i1=v_kmph<=v0_kmph;
    y=zeros(size(v));

    y(i1)=params.VA95BoundarySpeedCoeff1*v_kmph(i1)+params.VA95BoundaryBias1;
    y(~i1)=params.VA95BoundarySpeedCoeff2*v_kmph(~i1)+params.VA95BoundaryBias2;
end