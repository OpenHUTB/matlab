function[Points,n_s,Area_s]=generateRadiationSphere(R,ant)

    load([matlabroot,('/toolbox/antenna/antenna/+em/@FieldAnalysisWithFeed/spherenew.mat')]);
    if any(ant.Tilt~=0)
        p_s=em.internal.rotateshape(p_s,[0,0,0],ant.TiltAxis,ant.Tilt);%#ok<NODEF>
        TrianglesTotal=length(t_s);

        Area_s=zeros(1,TrianglesTotal);
        Center_s=zeros(3,TrianglesTotal);
        n_s=zeros(3,TrianglesTotal);
        for m=1:TrianglesTotal
            N=t_s(1:3,m);
            Vec1=p_s(:,N(1))-p_s(:,N(2));
            Vec2=p_s(:,N(3))-p_s(:,N(2));
            crossval=cross(Vec1,Vec2);
            Area_s(m)=norm(crossval)/2;
            n_s(:,m)=crossval/norm(crossval);
            Center_s(:,m)=1/3*sum(p_s(:,N),2);
        end
    end
    Points=R*Center_s;