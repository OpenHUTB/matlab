function[geom,const]=function_BASISmetal(P,t,NumRWG)









    P=P.';
    t=t.';
    t=t(:,1:3);

    const.epsilon=8.85418782e-012;
    const.mu=1.25663706e-006;
    const.c=1/sqrt(const.epsilon*const.mu);
    const.eta=sqrt(const.mu/const.epsilon);



    edgesdup=[t(:,[1,2]);t(:,[1,3]);t(:,[2,3])];

    e1=sort(edgesdup,2);

    [edges,eia(:,1)]=unique(e1,'rows');

    [~,eia(:,2)]=unique(e1,'last','rows');

    e2t=mod(eia-1,size(t,1))+1;

    e2t=sort(e2t,2);


    e2tnondup=e2t(:,1)~=e2t(:,2);
    e2t=e2t(e2tnondup,:);
    edges=edges(e2tnondup,:);
    TriP=e2t(:,1);
    TriM=e2t(:,2);
    Edge=edges;
    temp=P(edges(:,1),:)-P(edges(:,2),:);
    EdgeLength=sqrt(dot(temp,temp,2));
    FacesTotal=size(t,1);
    EdgesTotal=size(edges,1);
    d12=P(t(:,2),:)-P(t(:,1),:);
    d13=P(t(:,3),:)-P(t(:,1),:);
    temp=cross(d12,d13,2);
    temp_norm=vecnorm(temp,2,2);
    normals=temp./temp_norm;
    AreaF=0.5*sqrt(dot(temp,temp,2));
    CenterF=1/3*(P(t(:,1),:)+P(t(:,2),:)+P(t(:,3),:));
    edgeSum=sum(edges,2);

    VerP=sum(t(TriP,:),2)-edgeSum;
    VerM=sum(t(TriM,:),2)-edgeSum;
    FCRhoP=+(CenterF(TriP,:)-P(VerP,:));
    FCRhoM=-(CenterF(TriM,:)-P(VerM,:));


    RWGCenter=1/2*(P(edges(:,1),:)+P(edges(:,2),:));
    RWGevector=zeros(EdgesTotal,3);
    for n=1:EdgesTotal
        t1=TriP(n);
        t2=TriM(n);
        evector=P(edges(n,1),:)-P(edges(n,2),:);
        tp=cross(normals(t1,:),evector);
        tp=sign(dot(tp,FCRhoP(n,:)))*tp;
        tm=cross(normals(t2,:),evector);
        tm=sign(dot(tm,FCRhoM(n,:)))*tm;
        RWGtvector=1/2*(tp+tm);
        RWGtvector=RWGtvector/norm(RWGtvector);
        RWGNormal=1/2*(normals(t1,:)+normals(t2,:));
        CROSS=cross(evector,RWGtvector);
        DOT=dot(CROSS,RWGNormal);
        RWGevector(n,:)=sign(DOT)*evector/norm(evector);
    end


    temp=CenterF(TriP,:)-CenterF(TriM,:);
    RWGDistance=sqrt(sum(temp.*temp,2));
    DipoleCenter=zeros(EdgesTotal,3);

    for m=1:EdgesTotal
        Point1=CenterF(TriP(m),:);
        Point2=CenterF(TriM(m),:);
        DipoleCenter(m,:)=0.5*(Point1+Point2);
    end

    IS=zeros(FacesTotal,1);
    for m=1:FacesTotal
        IS(m)=em.EmStructures.function_SELF_INTEGRALS(P(t(m,:),:));
    end










    Neighbors=[];


    geom.FacesTotal=FacesTotal;
    geom.EdgesTotal=EdgesTotal;
    geom.t=t;
    geom.P=P;
    geom.AreaF=AreaF;
    geom.CenterF=CenterF;
    geom.NormalF=normals;
    geom.EdgeLength=EdgeLength;
    geom.Edge=Edge;
    geom.TriP=TriP;
    geom.TriM=TriM;
    geom.VerP=VerP;
    geom.VerM=VerM;
    geom.FCRhoP=FCRhoP;
    geom.FCRhoM=FCRhoM;
    geom.RWGCenter=RWGCenter;
    geom.RWGevector=RWGevector;
    geom.RWGDistance=RWGDistance;
    geom.IS=IS;
    geom.NumRWG=NumRWG;
    geom.Neighbors=Neighbors;
    geom.DipoleCenter=DipoleCenter;
end