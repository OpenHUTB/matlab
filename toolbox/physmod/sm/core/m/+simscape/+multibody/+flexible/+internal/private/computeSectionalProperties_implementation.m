





















































































































function props=computeSectionalProperties_implementation(...
    XY,doComputeShearDefProps,nu,varargin)




    if~iscell(XY)
        XY={XY};
    end

    assert(nargin<=4,'Too many input arguments.');







    if isempty(varargin)
        numDofsRequested=estimateNumberOfDofs(XY);
    else
        numDofsRequested=varargin{1};
        numHoles=numel(XY)-1;
        if numHoles>0
            numDofsRequested=ceil(numDofsRequested/2);
            numDofsPerHole=ceil(numDofsRequested/numHoles);
            numDofsRequested=[numDofsRequested,numDofsPerHole*ones(1,numHoles)];
        end
    end
    assert(numel(numDofsRequested)==numel(XY));


    BMesh=generateBoundaryMesh(XY,numDofsRequested);






    [quadWeights,GPX,GPY]=computeGaussProperties(BMesh);



    props=computeAreaMoments(BMesh,quadWeights,GPX,GPY);
    props=transformAreaMoments(props);
    props.Izz=props.Ixx+props.Iyy;


    [props,recipcond,H]=...
    computeTorsionalProperties(BMesh,quadWeights,GPX,GPY,props);



    BMesh.DofNodes=BMesh.DofNodes-[props.Cx,props.Cy];
    BMesh.StartXY=BMesh.StartXY-[props.Cx,props.Cy];
    BMesh.EndXY=BMesh.EndXY-[props.Cx,props.Cy];
    GPX=GPX-props.Cx;
    GPY=GPY-props.Cy;





    if doComputeShearDefProps
        props=computeShearProperties(BMesh,quadWeights,GPX,GPY,nu,props,H);
    end















    props.isValid=isfinite(props.J)&&props.J>0...
    &&~isnan(recipcond)&&recipcond>=1e-6;

end












function numDofs=estimateNumberOfDofs(XY)

    numHoles=numel(XY)-1;




















    IR_outer=computeIsoperimetricRatio(XY(1));
    abscissa=sqrt(IR_outer)+1;
    numDofs=max(500,ceil(63*abscissa.^2-645*abscissa+1850));
















    numDofs=min(numDofs,max(10000-500*numHoles,5000));


    if numHoles>0











        minNumHoleDofs=min(500,ceil(5000/numHoles));
        maxNumHoleDofs=max(10,ceil(10000/numHoles));




        numDofsPerHole=max(2150-150*numHoles,min(750,ceil(7500/numHoles)));
        numDofsPerHole=max(minNumHoleDofs,numDofsPerHole);
        numDofsPerHole=min(maxNumHoleDofs,numDofsPerHole);



        numDofs=[numDofs,numDofsPerHole*ones(1,numHoles)];

    end

    assert(numel(numDofs)==numel(XY));

end













function IR=computeIsoperimetricRatio(XY)
    P=0;A=0;
    for i=1:numel(XY)
        xyS=XY{i};
        xyE=[xyS(2:end,:);xyS(1,:)];
        P=P+sum(sqrt(sum((xyE-xyS).^2,2)));
        A=A+0.5*(sum(xyS(:,1).*xyE(:,2)-xyS(:,2).*xyE(:,1)));
    end
    IR=P^2/A;
end


























function BMesh=generateBoundaryMesh(XY,numDofsRequested)




    meshNodes=[];
    meshElems=[];
    nodalIndexOffset=0;
    for k=1:numel(XY)
        [boundaryMeshNodes,boundaryMeshElems]=...
        analyzeIndividualBoundary(XY{k},numDofsRequested(k));
        meshNodes=[meshNodes;boundaryMeshNodes];
        meshElems=[meshElems;nodalIndexOffset+boundaryMeshElems];
        nodalIndexOffset=nodalIndexOffset+size(boundaryMeshNodes,1);
    end
    assert(size(meshNodes,1)==size(meshElems,1));



    n=size(meshNodes,1);
    BMesh.DofNodes=zeros(n,2);
    BMesh.Lengths=zeros(n,1);
    BMesh.Normals=zeros(n,2);
    BMesh.StartXY=zeros(n,2);
    BMesh.EndXY=zeros(n,2);
    for e=1:n
        nodeI=meshNodes(meshElems(e,1),:);
        nodeJ=meshNodes(meshElems(e,2),:);
        BMesh.DofNodes(e,:)=(nodeI+nodeJ)/2;
        BMesh.Lengths(e)=norm(nodeJ-nodeI);
        BMesh.Normals(e,:)=getUnitNormal(nodeI,nodeJ);
        BMesh.StartXY(e,:)=nodeI;
        BMesh.EndXY(e,:)=nodeJ;
    end




end





function[meshNodes,meshElems]=analyzeIndividualBoundary(XY0,numDofsRequested)






    XY1=circshift(XY0,-1,1);
    edgeLengths=sqrt(sum((XY1-XY0).^2,2));
    estimatedElemLength=sum(edgeLengths)/max(numDofsRequested,size(XY0,1));
    nodesPerEdgeCounts=max(ceil(edgeLengths/estimatedElemLength),2);



    meshNodes=[];
    idx=0;
    for edge=1:size(XY0,1)
        numNodesToAdd=nodesPerEdgeCounts(edge)-1;
        P0=XY0(edge,:);
        P1=XY1(edge,:);
        u=getEdgeDirection(P0,P1);
        s=linspace(0,1,numNodesToAdd+1)';
        s(end)=[];
        meshNodes(idx+(1:numNodesToAdd),:)=P0+s*u;
        idx=idx+numNodesToAdd;
    end


    idxs=(1:size(meshNodes,1));
    meshElems=[idxs;circshift(idxs,-1)]';

end














function[quadWeights,GPX,GPY]=computeGaussProperties(BMesh)

    numQuadPts=4;
    [quadPoints,quadWeights]=getQuadratureRule(numQuadPts);

    XStart=repmat(BMesh.StartXY(:,1),1,numQuadPts);
    YStart=repmat(BMesh.StartXY(:,2),1,numQuadPts);
    XEnd=repmat(BMesh.EndXY(:,1),1,numQuadPts);
    YEnd=repmat(BMesh.EndXY(:,2),1,numQuadPts);

    GPX=(XStart+XEnd)/2+quadPoints'.*((XEnd-XStart)/2);
    GPY=(YStart+YEnd)/2+quadPoints'.*((YEnd-YStart)/2);

end



function props=computeAreaMoments(BMesh,quadWeights,GPX,GPY)

    ElementLengths=BMesh.Lengths;
    Nx=BMesh.Normals(:,1);
    Ny=BMesh.Normals(:,2);


    props.A=sum(ElementLengths.*(Nx.*GPX)*quadWeights/2);
    props.Ix=sum(ElementLengths.*(Nx.*GPX.*GPY)*quadWeights/2);
    props.Iy=sum(ElementLengths.*(Ny.*GPX.*GPY)*quadWeights/2);
    props.Ixx=sum(ElementLengths.*(Ny.*GPY.^3)*quadWeights/6);
    props.Iyy=sum(ElementLengths.*(Nx.*GPX.^3)*quadWeights/6);
    props.Ixy=sum(ElementLengths.*(Nx.*GPX.^2.*GPY)*quadWeights/4);


    props.Cx=props.Iy/props.A;
    props.Cy=props.Ix/props.A;

end




function props=transformAreaMoments(props)


    Ixx_c=props.Ixx-props.A*props.Cy^2;
    Iyy_c=props.Iyy-props.A*props.Cx^2;
    Ixy_c=props.Ixy-props.A*props.Cx*props.Cy;










    if abs(Ixy_c)<1e-12
        if Ixx_c<=Iyy_c||abs(Ixx_c-Iyy_c)<=1e-12
            alpha=0;
            Ixx_p=Ixx_c;
            Iyy_p=Iyy_c;
        else
            alpha=pi/2;
            Ixx_p=Iyy_c;
            Iyy_p=Ixx_c;
        end
    else
        gamma=(Iyy_c+Ixx_c)/2;
        omega=(Iyy_c-Ixx_c)/2;
        delta=sqrt(omega^2+Ixy_c^2);
        alpha=atan(Ixy_c/omega)/2;
        Ixx_p=gamma-delta;
        Iyy_p=gamma+delta;
    end


    props.Ixx_c=Ixx_c;
    props.Iyy_c=Iyy_c;
    props.Ixy_c=Ixy_c;
    props.Ixx_p=Ixx_p;
    props.Iyy_p=Iyy_p;
    props.alpha=alpha;

end




function[props,recipcond,H]=computeTorsionalProperties(BMesh,quadWeights,GPX,GPY,props)

    DofNodes=BMesh.DofNodes;
    numNodes=size(DofNodes,1);

    ElementLengths=BMesh.Lengths;

    Nx=BMesh.Normals(:,1);
    Ny=BMesh.Normals(:,2);

    xI=BMesh.StartXY(:,1);
    yI=BMesh.StartXY(:,2);
    xJ=BMesh.EndXY(:,1);
    yJ=BMesh.EndXY(:,2);


    H=zeros(numNodes,numNodes);
    u_n=zeros(numNodes,1);
    for k=1:numNodes
        xK=DofNodes(k,1);
        yK=DofNodes(k,2);
        n=BMesh.Normals(k,:);
        u_n(k)=[yK,-xK]*n';
        dy1=yI-yK;
        dy2=yJ-yK;
        dx1=xI-xK;
        dx2=xJ-xK;
        dl1=sqrt(dx1.^2+dy1.^2);
        cos1=dx1./dl1;
        sin1=dy1./dl1;
        dx2r=dx2.*cos1+dy2.*sin1;
        dy2r=-dx2.*sin1+dy2.*cos1;
        H(k,:)=atan2(dy2r,dx2r)'/(2*pi);
        H(k,k)=-0.5;
    end




    F=zeros(numNodes,1);
    elementLengthThreshold=max(ElementLengths)/1e3;
    maxMeanG=-inf;
    idxToConstrain=1;
    for k=1:numNodes
        radiusMatrix=sqrt((DofNodes(k,1)-GPX).^2+(DofNodes(k,2)-GPY).^2);
        G_row=(log(radiusMatrix)*quadWeights/2)';
        G_row(k)=(log(ElementLengths(k)/2)-1);
        G_row=G_row.*ElementLengths';
        F(k)=G_row*u_n/(2*pi);
        meanG=mean(G_row);
        if meanG>maxMeanG&&ElementLengths(k)>elementLengthThreshold
            maxMeanG=meanG;
            idxToConstrain=k;
        end
    end












    H(idxToConstrain,:)=zeros(1,numNodes);
    H(:,idxToConstrain)=zeros(numNodes,1);
    H(idxToConstrain,idxToConstrain)=1;
    F(idxToConstrain)=0;












    dH=decomposition(H,'lu');
    origState=warning('off','all');
    w=dH\F;
    warning(origState);



    recipcond=dH.rcond;





    props.J=sum(ElementLengths.*(Nx.*(GPX.*GPY.^2-GPY.*w)...
    +Ny.*(GPY.*GPX.^2+GPX.*w))*quadWeights/2);






    M=[-props.Ixx,props.Ixy,props.Ix;...
    -props.Ixy,props.Iyy,props.Iy;...
    -props.Ix,props.Iy,props.A];
    Term3=Nx.*(2*w.*GPX.*GPY-GPX.^2.*GPY.^2-GPY.^4);
    Term4=Ny.*(w.*GPX.^2+3*w.*GPY.^2+GPX.^3.*GPY+GPX.*GPY.^3);
    Term5=Nx.*(w.*GPY.^2+3*w.*GPX.^2-GPX.^3.*GPY-GPX.*GPY.^3);
    Term6=Ny.*(2*w.*GPX.*GPY+GPX.^2.*GPY.^2+GPX.^4);
    Term7=Nx.*(2*GPX.*w-(GPX.^2+GPY.^2).*GPY);
    Term8=Ny.*(2*GPY.*w+(GPX.^2+GPY.^2).*GPX);
    R=[sum(ElementLengths.*(Term3+Term4)*quadWeights/16);...
    sum(ElementLengths.*(Term5+Term6)*quadWeights/16);...
    sum(ElementLengths.*(Term7+Term8)*quadWeights/8)];
    origState=warning('off','all');
    x=M\R;
    warning(origState);
    props.Tx=x(1);
    props.Ty=x(2);

end






function props=computeShearProperties(BMesh,quadWeights,GPX,GPY,v,props,H)

    DofNodes=BMesh.DofNodes;
    numNodes=size(DofNodes,1);
    ElementLengths=BMesh.Lengths;

    A=props.A;
    B=2*(1+v)*(props.Ixx_c*props.Iyy_c-(props.Ixy_c)^2);

    phi_n=zeros(numNodes,1);
    theta_n=zeros(numNodes,1);

    for k=1:numNodes
        xK=DofNodes(k,1);
        yK=DofNodes(k,2);
        n=BMesh.Normals(k,:);

        a=(xK^2-yK^2)/2;
        b=xK*yK;


        dx=v*(props.Iyy_c*b-props.Ixy_c*a);
        dy=-v*(props.Iyy_c*a+props.Ixy_c*b);

        ex=v*(props.Ixx_c*a-props.Ixy_c*b);
        ey=v*(props.Ixx_c*b+props.Ixy_c*a);

        phi_n(k)=[dx,dy]*n';
        theta_n(k)=[ex,ey]*n';

    end


    F1=zeros(numNodes,1);
    F2=zeros(numNodes,1);
    elementLengthThreshold=max(ElementLengths)/1e3;
    maxMeanG=-inf;
    idxToConstrain=1;


    for k=1:numNodes



        radiusMatrix=sqrt((DofNodes(k,1)-GPX).^2+(DofNodes(k,2)-GPY).^2);
        G1_row=(log(radiusMatrix)*quadWeights/2)';
        G1_row(k)=(log(ElementLengths(k)/2)-1);
        G1_row=G1_row.*ElementLengths';
        F1(k)=G1_row*phi_n/(2*pi);

        G2_row=((log(radiusMatrix)-1).*(radiusMatrix.^2)*quadWeights)';
        G2_row(k)=(log(ElementLengths(k)/2)+2/3)*(ElementLengths(k)^2)/6;

        nX=repmat(BMesh.Normals(:,1),1,4);
        nY=repmat(BMesh.Normals(:,2),1,4);

        G3_row=(((props.Ixy_c*GPX-props.Iyy_c*GPY).*(2*log(radiusMatrix)-1).*(nX.*(GPX-...
        DofNodes(k,1))+nY.*(GPY-DofNodes(k,2))))*quadWeights)';
        G3_row(k)=0;

        n=BMesh.Normals;
        K=n*[props.Ixy_c;-props.Iyy_c];

        F1(k)=F1(k)+(((G2_row.*ElementLengths'/2)*K)-G3_row*ElementLengths/2)/(4*pi);

        meanG=mean(G1_row);
        if meanG>maxMeanG&&ElementLengths(k)>elementLengthThreshold
            maxMeanG=meanG;
            idxToConstrain=k;
        end

    end

    H(idxToConstrain,:)=zeros(1,numNodes);
    H(:,idxToConstrain)=zeros(numNodes,1);
    H(idxToConstrain,idxToConstrain)=1;
    F1(idxToConstrain)=0;

    dH=decomposition(H,'lu');
    origState=warning('off','all');
    phi=dH\F1;
    warning(origState);


    for k=1:numNodes
        radiusMatrix=sqrt((DofNodes(k,1)-GPX).^2+(DofNodes(k,2)-GPY).^2);
        G1_row=(log(radiusMatrix)*quadWeights/2)';
        G1_row(k)=(log(ElementLengths(k)/2)-1);
        G1_row=G1_row.*ElementLengths';
        F2(k)=G1_row*theta_n/(2*pi);

        G2_row=((log(radiusMatrix)-1).*(radiusMatrix.^2)*quadWeights)';
        G2_row(k)=(log(ElementLengths(k)/2)+2/3)*(ElementLengths(k)^2)/6;

        nX=repmat(BMesh.Normals(:,1),1,4);
        nY=repmat(BMesh.Normals(:,2),1,4);

        G3_row=(((props.Ixy_c*GPY-props.Ixx_c*GPX).*(2*log(radiusMatrix)-1).*(nX.*(GPX-...
        DofNodes(k,1))+nY.*(GPY-DofNodes(k,2))))*quadWeights)';
        G3_row(k)=0;

        n=BMesh.Normals;
        K=n*[-props.Ixx_c;props.Ixy_c];

        F2(k)=F2(k)+((G2_row.*ElementLengths'/2)*K-G3_row*ElementLengths/2)/(4*pi);

        meanG=mean(G1_row);
        if meanG>maxMeanG&&ElementLengths(k)>elementLengthThreshold
            maxMeanG=meanG;
            idxToConstrain=k;
        end

    end

    H(idxToConstrain,:)=zeros(1,numNodes);
    H(:,idxToConstrain)=zeros(numNodes,1);
    H(idxToConstrain,idxToConstrain)=1;
    F2(idxToConstrain)=0;

    dH=decomposition(H,'lu');
    origState=warning('off','all');
    theta=dH\F2;
    warning(origState);


    I1=(theta.*ElementLengths)'*theta_n;
    I2=(phi.*ElementLengths)'*theta_n;
    I3=(phi.*ElementLengths)'*phi_n;

    n=BMesh.Normals;
    n1=repmat(n(:,1),1,4);
    n2=repmat(n(:,2),1,4);
    I4=(GPX.*(GPY.^4).*n1+((GPX.^4).*GPY+(2/3)*(GPX.^2).*(GPY.^3)).*n2)*quadWeights;
    I4=(I4'*ElementLengths)/2;
    I51=(props.Ixy_c*(GPX.^3).*(GPY.^2).*n2-2*props.Ixx_c*(GPX.^4).*(GPY).*n2)*quadWeights;
    I52=3*theta.*n(:,1).*((GPX.^2)*quadWeights)-theta_n.*((GPX.^3)*quadWeights);
    I5=((I51+I52)'*ElementLengths)/12;
    I61=(2*props.Ixy_c*(GPX).*(GPY.^4).*n1-props.Ixx_c*(GPX.^2).*(GPY.^3).*n1)*quadWeights;
    I62=3*theta.*n(:,2).*((GPY.^2)*quadWeights)-theta_n.*((GPY.^3)*quadWeights);
    I6=((I61+I62)'*ElementLengths)/12;
    I71=(2*props.Ixy_c*(GPY).*(GPX.^4).*n2-props.Iyy_c*(GPY.^2).*(GPX.^3).*n2)*quadWeights;
    I72=3*phi.*n(:,1).*((GPX.^2)*quadWeights)-phi_n.*((GPX.^3)*quadWeights);
    I7=((I71+I72)'*ElementLengths)/12;
    I81=(props.Ixy_c*(GPX.^2).*(GPY.^3).*n1-2*props.Iyy_c*(GPX).*(GPY.^4).*n1)*quadWeights;
    I82=3*phi.*n(:,2).*((GPY.^2)*quadWeights)-phi_n.*((GPY.^3)*quadWeights);
    I8=((I81+I82)'*ElementLengths)/12;


    props.ax=(A/(B^2))*((4*v+2)*(props.Ixx_c*I5-props.Ixy_c*I6)+0.25*(v^2)*(props.Ixx_c^2+props.Ixy_c^2)*I4-I1);
    props.ay=(A/(B^2))*((4*v+2)*(props.Iyy_c*I8-props.Ixy_c*I7)+0.25*(v^2)*(props.Iyy_c^2+props.Ixy_c^2)*I4-I3);
    props.axy=(A/(B^2))*((2*v+2)*(props.Iyy_c*I6-props.Ixy_c*I5)-0.25*(v^2)*(props.Ixx_c+props.Iyy_c)*props.Ixy_c*I4-I2...
    +2*v*(props.Ixx_c*I7-props.Ixy_c*I8));


    props.Sx=(((v*props.Iyy_c*(0.5*(GPX.^4)+(GPX.^2).*(GPY.^2)).*n1+v*props.Ixy_c*(0.5*(GPY.^4)+(GPX.^2).*(GPY.^2)).*n2)*quadWeights...
    -(4*phi.*(GPY.*n1-GPX.*n2))*quadWeights)'*ElementLengths)/(8*B);

    props.Sy=(((v*props.Ixx_c*(0.5*(GPY.^4)+(GPX.^2).*(GPY.^2)).*n2+v*props.Ixy_c*(0.5*(GPX.^4)+(GPX.^2).*(GPY.^2)).*n1)*quadWeights...
    +(4*theta.*(GPY.*n1-GPX.*n2))*quadWeights)'*ElementLengths)/(8*B);

end












function[qp,qw]=getQuadratureRule(n)
    switch n
    case 4
        qp1=0.3399810435848563;qw1=0.6521451548625461;
        qp2=0.8611363115940526;qw2=0.3478548451374538;
        qp=[-qp2;-qp1;qp1;qp2];
        qw=[qw2;qw1;qw1;qw2];
    otherwise
        error('Quadrature rule error.');
    end
end




function direction=getEdgeDirection(edgeStart,edgeEnd)
    direction=edgeEnd-edgeStart;
end





function normal=getUnitNormal(edgeStart,edgeEnd)
    direction=getEdgeDirection(edgeStart,edgeEnd);
    normal=[direction(2),-direction(1)];
    normal=normal/norm(normal);
end














...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...

