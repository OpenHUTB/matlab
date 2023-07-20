function[E,H]=calculatePOEfield(obj,freq,Point)

    const.epsilon=8.85418782e-012;
    const.mu=1.25663706e-006;
    const.c=1/sqrt(const.epsilon*const.mu);
    const.eta=sqrt(const.mu/const.epsilon);
    omega=2*pi*freq;
    k=omega/const.c;
    for m=1:obj.SolverStruct.RWG.EdgesTotal
        IPO=obj.SolverStruct.RCSSolution.I;
        Node1=obj.SolverStruct.RWG.Center(:,obj.SolverStruct.RWG.TrianglePlus(m)+1);
        Node2=obj.SolverStruct.RWG.Center(:,obj.SolverStruct.RWG.TriangleMinus(m)+1);
        DipoleCenter(:,m)=0.5*(Node1+Node2);
        DipoleMoment(:,m)=obj.SolverStruct.RWG.EdgeLength(m)*IPO(m)*(-Node1+Node2);
    end
    [EField,HField]=mom_point(Point,const.eta,1i*k,DipoleMoment,DipoleCenter);
    E=sum(EField,2);
    H=sum(HField,2);
end

function[EField,HField]=mom_point(Point,eta_,K,DipoleMoment,DipoleCenter)











    C=4*pi;
    ConstantH=K/C;
    ConstantE=eta_/C;

    m=DipoleMoment;
    c=DipoleCenter;
    r=repmat(Point,[1,length(c)])-c(1:3,:);
    PointRM=repmat(sqrt(sum(r.*r)),[3,1]);
    EXP=exp(-K*PointRM);
    PointRM2=PointRM.^2;

    C=1./PointRM2.*(1+1./(K*PointRM));
    D=repmat(sum(r.*m),[3,1])./PointRM2;
    M=D.*r;
    HField=ConstantH*cross(m,r).*C.*EXP;
    EField=ConstantE*((M-m).*(K./PointRM+C)+2*M.*C).*EXP;
end