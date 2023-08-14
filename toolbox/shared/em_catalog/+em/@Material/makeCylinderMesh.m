function[Mesh,Parts]=makeCylinderMesh(obj,antobj,varargin)






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
    pcavityBoundaryVertices=[M.P(boundarypoints{1},1),...
    M.P(boundarypoints{1},2),zeros(numel(boundarypoints{1}),1)];


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
        warnState=warning('Off','MATLAB:triangulation:PtsNotInTriWarnId');
        DT=triangulation(t(1:3,:)',pall');
        warning(warnState);

        fe=freeBoundary(DT);
        fe=unique(fe(:),'stable');
        P0=pall(:,fe);
        val1=sqrt(P0(1,:).^2+P0(2,:).^2);

        fe=find(val1==antobj.Radius);
        fe=unique(fe(:),'stable');
        P0=P0(:,fe);
        val3=atan2d(P0(2,:),P0(1,:));
        [~,bb]=sort(val3);
        P0=P0(:,bb);

        edgeLength=antobj.MesherStruct.Mesh.MaxEdgeLength;
        NN=ceil((H-TotalLayerHeight)/edgeLength);

        pb=size(P0,2);
        barsb=[1:pb;[2:pb,1]]';


        Ps=P0;Ps(3,:)=h;
        ts=[];t1=[];t2=[];

        for m=1:NN
            Ps(1:2,end+1:end+pb)=P0(1:2,:);
            if h+edgeLength*m<H
                Ps(3,end+1-pb:end)=h+edgeLength*m;
            else
                Ps(3,end+1-pb:end)=H;
            end
            t1(:,1:2)=barsb+pb+pb*(m-2);
            t1(:,3)=barsb(:,1)+pb+pb*(m-1);
            t2(:,1:2)=barsb+pb+pb*(m-1);
            t2(:,3)=barsb(:,2)+pb+pb*(m-2);
            ts=[ts',t1',t2']';
        end
        ts=ts';
        ts(4,:)=0;


        [pall,t]=em.internal.joinmesh(pall,t,Ps,ts,'tri',false);
    end

    warnState=warning('Off','MATLAB:triangulation:PtsNotInTriWarnId');
    obj.DielectricTriangulation=triangulation(tetsByLayer',pall');
    warning(warnState);
    Mesh=em.internal.makeMeshStructure(pall,t,tetsByLayer,epsilonRByLayer,...
    lossTangentByLayer);
    Parts=em.internal.makeMeshPartsStructure('Gnd',[{pall},{tCavity}],...
    'Rad',[{M.PRad'},{M.tRad'}]);

end