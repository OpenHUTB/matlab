function makeCylinderGeometry(obj)

    H=obj.Thickness;
    numLayers=numel(H);
    thickness=cumsum(H);
    if numLayers==1
        R=0.995*obj.Radius;
    else
        R=0.985*obj.Radius;
    end
    Rb=obj.Radius;
    if isa(obj.Parent,'reflectorCircular')
        R=obj.Radius;
    end


    N=40;
    phi=0:2*pi/N:2*pi*(N-1)/N;
    bx=R*cos(phi);by=R*sin(phi);
    P0=[bx;by];
    P0(3,:)=0;
    center=[0;0;0];
    P0=[center,P0];
    poly1=zeros(3,N);
    for m=2:size(P0,2)-1
        poly1(:,m-1)=[m,1,m+1];
    end
    poly1(:,m)=[m+1,1,2];


    bx=Rb*cos(phi);by=Rb*sin(phi);
    Pb=[bx;by];
    Pb(3,:)=0;
    Pb=[center,Pb];


    Ptemp=P0;
    Pbtemp=Pb;
    polylayers=zeros(3,2*N,numLayers);
    for n=1:numLayers
        Ptop=P0(:,2:end);
        Ptop(3,:)=thickness(n);
        Ptemp=[Ptemp,Ptop];%#ok<*AGROW>

        Ptop=Pb(:,2:end);
        Ptop(3,:)=thickness(n);
        Pbtemp=[Pbtemp,Ptop];%#ok<*AGROW>

        poly2=zeros(3,N);
        poly3=zeros(3,N);
        for m=2:size(Ptop,2)
            poly2(:,m-1)=[m,m+1,m+N+1]+(n-1)*N;
            poly3(:,m-1)=[m+N,m+N+1,m]+(n-1)*N;
        end
        poly2(:,m)=[N+1,2,N+2]+(n-1)*N;
        poly3(:,m)=[2*N+1,N+2,N+1]+(n-1)*N;
        polylayers(:,:,n)=[poly2,poly3];
    end
    P=Ptemp;
    Pb=Pbtemp;


    center=[0;0;thickness(end)];
    P=[P,center];
    Pb=[Pb,center];
    poly4=zeros(3,N);
    for m=1:size(P0,2)-2
        poly4(:,m)=[(N*n)+1+m,size(P,2),m+(N*n)+2];
    end
    poly4(:,m+1)=[m+(N*n)+2,size(P,2),poly4(1,1)];

    Geometry.Vertices=P';
    Geometry.BoundaryVertices=Pb';
    if numLayers==1
        Geometry.Polygons{1}=[poly1,polylayers(:,:,1),poly4]';
        Geometry.BoundaryEdges{1}=[2:N+1;N+2:2*N+1];
    elseif numLayers==2
        Geometry.Polygons{1}=[poly1,polylayers(:,:,1)]';
        Geometry.BoundaryEdges{1}=[2:N+1;N+2:2*N+1];
        Geometry.Polygons{2}=[polylayers(:,:,2),poly4]';
        Geometry.BoundaryEdges{2}=[N+2:2*N+1;2*N+2:3*N+1];
    else
        Geometry.Polygons{1}=[poly1,polylayers(:,:,1)]';
        Geometry.BoundaryEdges{1}=[2:N+1;N+2:2*N+1];
        for m=2:numLayers-1
            Geometry.Polygons{m}=polylayers(:,:,m)';
            Geometry.BoundaryEdges{m}=[(m-1)*N+2:m*N+1;m*N+2:(m+1)*N+1];
        end
        Geometry.Polygons{numLayers}=[polylayers(:,:,numLayers),poly4]';
        Geometry.BoundaryEdges{numLayers}=[m*N+2:(m+1)*N+1;...
        (m+1)*N+2:(numLayers+1)*N+1];
    end


    obj.Geometry=Geometry;






end