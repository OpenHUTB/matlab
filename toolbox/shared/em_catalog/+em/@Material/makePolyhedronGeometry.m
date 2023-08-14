function makePolyhedronGeometry(obj)

    H=obj.Thickness;
    numLayers=numel(H);

    shapeObject=obj.Parent.BoardShape;
    if isa(shapeObject,'antenna.Shape')
        createGeometry(shapeObject);
        v=getShapeVertices(shapeObject);
    end

























    warnState=warning('off','MATLAB:polyshape:repairedBySimplify');
    pp=polyshape(v(:,1),v(:,2));
    warning(warnState);
    TRshape=triangulation(pp);
    pshape=TRshape.Points;
    tshape=TRshape.ConnectivityList;
    [~,boundaryID]=boundaryshape(TRshape);
    bptsID=boundaryID(~isnan(boundaryID));
    numHoles=pp.NumHoles;
    if numHoles>0
        holeBoundaryID=find(isnan(boundaryID));
    else
        holeBoundaryID=[];
    end
    pboundary=pshape(bptsID,:);
    pboundary(:,3)=0;

    [P,T]=em.internal.makeTetrahedra(pshape,tshape,H(1));
    Ph=pshape;
    Pt=P;
    Tt=T;
    pboundaryh=pboundary;
    pboundaryh(:,3)=H(1);
    offset=size(pboundary,1);
    pboundaryTot=[pboundary;pboundaryh];
    regionID=unique([0,holeBoundaryID',numel(boundaryID)+1]);
    boundaryEdges=[];
    for m=1:numHoles+1
        tboundaryID=boundaryID(regionID(m)+1:regionID(m+1)-1);

        bottomBoundary=[tboundaryID,circshift(tboundaryID,-1)];
        topBoundary=[bottomBoundary+offset];

        boundaryEdges=[boundaryEdges;bottomBoundary;topBoundary;...
        tboundaryID,tboundaryID+offset];
    end

    TR=triangulation(Tt,Pt);
    [FBtri,FBp]=freeBoundary(TR);
    BE=boundaryEdges;
    pSize=size(Pt,1);
    trii=FBtri;
    FBp2=FBp;
    FBp3=FBp;
    for n=2:numLayers
        pboundaryh(:,3)=sum(H(1:n));
        Ph(:,3)=sum(H(1:n));
        Pt=[Pt;Ph];
        Th=T;
        Th=Th+(n-1)*size(pshape,1);
        Tt=[Tt;Th];
        pboundaryTot=[pboundaryTot;pboundaryh];
        tempIdprev=tboundaryID+(n-1)*offset;
        tempIdnext=tboundaryID+n*offset;
        tempEdges=[tempIdnext,circshift(tempIdnext,-1)];
        boundaryEdges=[tempEdges;tempIdprev,tempIdnext];


        FBp2=[FBp2(:,1:2),FBp2(:,3)+obj.Thickness(n)];
        minH=min(FBp2(:,3));
        preH=sum(H(1:n-1));
        indH=find(FBp2(:,3)==minH);
        FBp2(indH,3)=preH;
        FBtri2=FBtri+(pSize*(n-1));
        trii=[trii,{FBtri2}];
        FBp=[FBp;FBp2];
        BE=[BE,{boundaryEdges}];
    end

    Geometry.Vertices=[FBp];
    if numLayers==1
        Geometry.Polygons={trii};
        Geometry.BoundaryEdges={BE};
    else
        Geometry.Polygons=trii;
        Geometry.BoundaryEdges=BE;
    end
    Geometry.BoundaryVertices=pboundaryTot;
    obj.Geometry=Geometry;





end