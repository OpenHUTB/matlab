function[Mesh,Parts]=makeBoxMesh(obj,antobj,varargin)








    L=obj.Length;
    W=obj.Width;
    H=antobj.Height;
    h=antobj.Spacing;
    LayerThicknesses=obj.Thickness;
    TotalLayerHeight=max(cumsum(LayerThicknesses));


    deltaTotalLayerHeight=TotalLayerHeight-H;
    if abs(deltaTotalLayerHeight)<sqrt(eps)
        TotalLayerHeight=H;
    end
    if TotalLayerHeight>H
        error(message('antenna:antennaerrors:SubstrateLayerCrossesCavityHeight'));
    elseif TotalLayerHeight<H
        extendMetalWalls=true;
    else
        extendMetalWalls=false;
    end


    M=varargin{1};
    if iscolumn(M.FeedVertex1)
        M.FeedVertex1=M.FeedVertex1';
    end

    if iscolumn(M.FeedVertex2)
        M.FeedVertex2=M.FeedVertex2';
    end


    em.Material.checkRadiatorConformality(M.PRad',h,1e-12);


    em.Material.checkRadiatorBounds(M.PGp',M.PRad');


    [boundarypoints,~]=em.internal.findBoundary(M.P,M.t);
    pcavityBoundaryVertices=[M.P(boundarypoints{1},1),M.P(boundarypoints{1},2),zeros(numel(boundarypoints{1}),1)];


    PtsPerSide=size(pcavityBoundaryVertices,1)/4;
    numSides=4;
    ns=0:numSides-1;
    indx=ns*PtsPerSide+1;











    indicator=false;

    isMetalSideWall=true;

    MultiMesh=makeMultiLayerMesh(obj,h,M,indicator,isMetalSideWall);

    pall=MultiMesh.P;
    t=MultiMesh.t;
    tCavity=MultiMesh.tGP';
    tP=MultiMesh.tRad';
    tetsByLayer=MultiMesh.T;
    epsilonRByLayer=MultiMesh.EPSR;
    lossTangentByLayer=MultiMesh.LOSSTANG;


    pTop=pall(:,pall(3,:)==h);





































    if extendMetalWalls
        edgeLength=antobj.MesherStruct.Mesh.MaxEdgeLength;
        fw=antobj.MesherStruct.Mesh.FeedWidth;
        growthRate=antobj.MesherStruct.Mesh.MeshGrowthRate;
        [leftEdge,frontEdge,rightEdge,backEdge]=...
        em.internal.classifyboundarypoints(pTop);
        N=ceil((H-TotalLayerHeight)/edgeLength);
        if N<=3
            N=4;
        end
        numPts=ceil(N)+1;
        verticalEdge=fliplr(em.internal.chebspace((H-TotalLayerHeight)/2,numPts,'II'))...
        +(H-TotalLayerHeight)/2+TotalLayerHeight;
        smoothingoptions={};

        cacheMesherChoice=antobj.MesherStruct.UseNewMesher;
        antobj.MesherStruct.UseNewMesher=0;

        [pleft,tleft]=planarmesher(antobj,...
        -L/2,leftEdge,verticalEdge,edgeLength,...
        0,growthRate,edgeLength,smoothingoptions);
        [pfront,tfront]=planarmesher(antobj,...
        frontEdge,-W/2,verticalEdge,edgeLength,...
        0,growthRate,edgeLength,smoothingoptions);
        [pright,tright]=planarmesher(antobj,...
        L/2,rightEdge,verticalEdge,edgeLength,...
        0,growthRate,edgeLength,smoothingoptions);
        [pback,tback]=planarmesher(antobj,...
        backEdge,W/2,verticalEdge,edgeLength,...
        0,growthRate,edgeLength,smoothingoptions);
        antobj.MesherStruct.UseNewMesher=cacheMesherChoice;

        if isempty(M.FeedVertex1)

            tleft(4,:)=0;
            tfront(4,:)=0;
            tright(4,:)=0;
            tback(4,:)=0;
        else

            tleft(4,:)=1;
            tfront(4,:)=1;
            tright(4,:)=1;
            tback(4,:)=1;
        end

        [pjoin,tjoin]=em.internal.joinmesh(pall,t,pleft,tleft,'tri',false);

        [pjoin,tjoin]=em.internal.joinmesh(pjoin,tjoin,pfront,tfront,'tri',false);

        [pjoin,tjoin]=em.internal.joinmesh(pjoin,tjoin,pright,tright,'tri',false);

        [pall,t]=em.internal.joinmesh(pjoin,tjoin,pback,tback,'tri',false);
    end

    warnState=warning('Off','MATLAB:triangulation:PtsNotInTriWarnId');
    obj.DielectricTriangulation=triangulation(tetsByLayer',pall');
    warning(warnState);
    Mesh=em.internal.makeMeshStructure(pall,t,tetsByLayer,epsilonRByLayer,lossTangentByLayer);
    prad=M.PRad';
    trad=[M.tRad';tCavity(4,1).*ones(1,size(M.tRad,1))];
    Parts=em.internal.makeMeshPartsStructure('Gnd',[{pall},{tCavity}],...
    'Rad',[{prad},{trad}]);

end

function[pBase,domains,domaincodes]=createBase(L,W,Np)

    pBase=createBaseBoundary(L,W,Np);
    domains=[{pBase}];
    domaincodes=2;

end

function[pBase,domains,domaincodes]=createImprintedBase(L,W,Np,pP)

    pBase=createBaseBoundary(L,W,Np);
    domains=[{pBase,pP}];
    domaincodes=[2,2];

end

function pboundary=createBaseBoundary(L,W,Np)
    pboundary=em.internal.makeplate(L,W,Np,'linear');
end

function p=createBaseMesh(domains,domaincodes,edgeLength,growthRate)

    gd=em.MeshGeometry.buildgeometrymatrix(domains,domaincodes);


    [dl,~]=decsg_atx(gd);
    [p,e,t]=initmesh_atx(dl,'MesherVersion','R2013a','Hmax',edgeLength,...
    'Hgrad',growthRate);
    p(3,:)=0;

end

function tface=extractMetalMesh(ftri,fpts,coordsearch,coordlim)
    tface=[];
    coordId=validatestring(coordsearch,{'X','Y','Z'});
    switch coordId
    case 'X'
        indx=1;
    case 'Y'
        indx=2;
    case 'Z'
        indx=3;
    end

    for i=1:size(ftri,1)
        triVerts=fpts(ftri(i,:),:);
        if all(abs(triVerts(:,indx)-coordlim)<1e-12)
            tface=[tface;ftri(i,:)];%#ok<AGROW>
        end
    end
end

function tfaces=extractTetrahedraFaces(T)

    faceCodes=[1,2,3;1,2,4;1,3,4;2,3,4];



    faces1=T(:,faceCodes(1,:));
    faces2=T(:,faceCodes(2,:));
    faces3=T(:,faceCodes(3,:));
    faces4=T(:,faceCodes(4,:));

    tfaces=unique([faces1;faces2;faces3;faces4],'rows');













end

function tfaces=eliminateDuplicateFaces(t)
    tfaces=t;
    excludeList=[];



















    for j=1:size(t,1)-1
        id=1;
        while(j+id)<=size(t,1)
            if all(ismember(t(j,:),t(j+id,:)))
                excludeList=[excludeList,j+id];%#ok<AGROW>
            end
            id=id+1;
        end
    end
    tfaces(excludeList,:)=[];
end
