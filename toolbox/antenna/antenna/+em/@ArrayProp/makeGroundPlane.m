function[pointsGP,maxFeatureSize,poly,boundary]=makeGroundPlane(obj)

    propertyNames=properties(obj);
    if any(strcmpi('GroundPlaneLength',propertyNames))
        groundPlaneShape='Rectangle';
    else
        groundPlaneShape='Circle';
    end

    if isa(obj.Element,'reflectorCircular')
        groundPlaneShape='Circle';
    end


    switch groundPlaneShape
    case 'Rectangle'
        gp_L=obj.GroundPlaneLength;
        gp_W=obj.GroundPlaneWidth;
        cornersGP=em.internal.makerectangle(gp_L,gp_W);
        pointsGP=cornersGP;
        maxFeatureSize=sqrt(gp_L^2+gp_W^2);
        poly=[[1,2,3];[1,3,4]];
        boundary=[1,2,3,4];
    case 'Circle'
        R=obj.GroundPlaneRadius;
        N=40;
        phi=0:2*pi/N:2*pi*(N-1)/N;
        bx=R*cos(phi);by=R*sin(phi);
        P=[bx;by];
        P(3,:)=0;
        center=[0;0;0];
        pointsGP=[center,P];
        poly=zeros(3,N);
        for m=2:size(pointsGP,2)-1
            poly(:,m-1)=[m,1,m+1];
        end
        poly(:,m)=[m+1,1,2];
        boundary=[2:m+1,2];
        maxFeatureSize=2*R;
        poly=poly.';
    end


end