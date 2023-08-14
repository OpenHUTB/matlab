function[Mesh]=generateMeshForStripFeedAndVia(obj,mesherInput)




    vias=mesherInput.vias;
    p_temp=mesherInput.p_temp;
    t_temp=mesherInput.t_temp;
    startLayer=mesherInput.startLayer;
    stopLayer=mesherInput.stopLayer;
    viapolys=mesherInput.viapolys;
    viaHeight=mesherInput.viaHeight;
    layer_heights=mesherInput.layer_heights;
    smoothing_iter=mesherInput.smoothing_iter;
    refinecontours=mesherInput.refinecontours;

    tempMetalLayers=obj.MetalLayersCopy;

    if isa(obj.BoardShape,'antenna.Rectangle')
        L=obj.BoardShape.Length;
        W=obj.BoardShape.Width;
    elseif isa(obj.BoardShape,'antenna.Circle')
        R=obj.BoardShape.Radius;
    elseif isa(obj.BoardShape,'antenna.Polygon')
        V=obj.BoardShape.ShapeVertices;
    end






    metalMeshGenFailure=false;
    if isempty(vias)
        viaVertex=[];
        via_pt1=[];
        via_pt2=[];
        [feed_edgept1,feed_edgept2,isFeedEdgeEmpty]=findFeedEdgePoints(obj,p_temp,t_temp,startLayer,...
        viapolys,false);
        if isFeedEdgeEmpty
            metalMeshGenFailure=true;
        else
            [p,t]=em.MeshGeometry.assembleMesh(p_temp,t_temp);

            p=orientGeom(obj,p);


            T=[];
            EpsilonR=[];
            LossTangent=[];
            Mesh=em.internal.makeMeshStructure(p,t,T,EpsilonR,LossTangent);
        end
    else
        feed_edgept1=[];
        feed_edgept2=[];
        isFeedEdgeEmpty=[];








        startLayers=unique(vias(:,3));
        stopLayers=unique(vias(:,4));

        for i=1:numel(startLayers)
            startLayerVias{i}=vias(vias(:,3)==startLayers(i),:);%#ok<AGROW>
            viaHeightPerLayer{i}=viaHeight(vias(:,3)==startLayers(i));%#ok<AGROW>
        end

        for i=1:numel(stopLayers)
            stopLayerVias{i}=vias(vias(:,4)==stopLayers(i),:);%#ok<AGROW>
        end







        [p_tempVia,t_tempVia,viaVertex,via_pt1,via_pt2,metalMeshGenFailure,via_order]=buildViaMesh(obj,p_temp,t_temp,startLayers,...
        startLayerVias,stopLayers,...
        stopLayerVias,viaHeightPerLayer,...
        viapolys,isDielectricSubstrate(obj));
        if~metalMeshGenFailure









            A=zeros(numel(obj.MetalLayers));
            for i=1:size(vias,1)
                m=vias(i,3);
                n=vias(i,4);
                A(m,n)=1;
                A(n,m)=1;
            end


            g=graph(A);
            partitions=conncomp(g,'OutputForm','cell');
            pPartitions=cell(size(partitions));
            tPartitions=cell(size(partitions));
            conn=table2cell(g.Edges(:,1));
            conn=unique(cell2mat(conn'),'stable');


            for i=1:numel(partitions)
                pPartitions{i}=p_tempVia{partitions{i}(1)};
                tPartitions{i}=t_tempVia{partitions{i}(1)};
                range=conn((conn>partitions{i}(1))&(conn<=partitions{i}(end)));
                if numel(partitions{i})>1
                    for j=range
                        pIndx=find(partitions{i}==j);
                        try
                            [pPartitions{i},tPartitions{i}]=em.internal.joinmesh(pPartitions{i},tPartitions{i},...
                            p_tempVia{partitions{i}(pIndx)},...
                            t_tempVia{partitions{i}(pIndx)});
                        catch ME
                            metalMeshGenFailure=true;
                        end
                    end
                end
            end
            if~metalMeshGenFailure

                [p,t]=em.MeshGeometry.assembleMesh(pPartitions,tPartitions);


                p=orientGeom(obj,p);


                T=[];
                EpsilonR=[];
                LossTangent=[];
                Mesh=em.internal.makeMeshStructure(p,t,T,EpsilonR,LossTangent);
            end
        end
    end

    rectBoardShape=isa(obj.BoardShape,'antenna.Rectangle');


    if isequal(numel(obj.MetalLayers),1)
        singleLayerMetal=true;
    else
        singleLayerMetal=false;
    end

    if isequal(numel(obj.MetalLayers),2)&&rectBoardShape

        [minLayer,maxLayer]=em.PCBStructures.calculateMinMaxOfLayerPoints(p_temp(2));
        deltaLx=abs(minLayer(1)+(L/2))<1e-6&&abs(maxLayer(1)-(L/2))<1e-6;
        deltaLy=abs(minLayer(2)+(W/2))<1e-6&&abs(maxLayer(2)-(W/2))<1e-6;

        holeInLayer=isequal(obj.MetalLayers{2}.InternalPolyShape.NumHoles,0);




        [~,tf]=isLayerWithinBoardLimits(obj,p_temp(1));
        if deltaLx&&deltaLy&&tf&&holeInLayer
            twoLayerWithFloodFillGnd=true;
        else
            twoLayerWithFloodFillGnd=false;
        end
    else
        twoLayerWithFloodFillGnd=false;
    end


    numLayers=checkSubstrateThicknessVsLambda(obj.Substrate,obj);






































    if isDielectricSubstrate(obj)||metalMeshGenFailure

        createGeometry(obj.BoardShape);
        subShape=obj.BoardShape.InternalPolyShape;
        if subShape.NumHoles>0
            subHoleShape=holes(subShape);
            subNoHoleShape=rmholes(subShape);
            cornersSub={subNoHoleShape.Vertices};
            for i=1:numel(subHoleShape)
                cornersSub{i+1}=subHoleShape(i).Vertices;
            end
            numBoardHoles=subShape.NumHoles;
        else
            cornersSub={obj.BoardShape.ShapeVertices(:,1:2)};
            numBoardHoles=0;
        end


        maxEdgeLength=getMeshEdgeLength(obj);
        minContourEdgeLength=getMinContourEdgeLength(obj);
        growthRate=getMeshGrowthRate(obj);
        allBoundaries=cornersSub;


        for i=1:numel(obj.MetalLayers)
            tempBoundary=getPolygonBoundariesForLayer(obj,tempMetalLayers{i},sqrt(eps));
            allBoundaries=[allBoundaries,tempBoundary];%#ok<AGROW> tempMetalLayers{i}.Polygons
        end



        if minContourEdgeLength>maxEdgeLength
            minContourEdgeLength=0.75*maxEdgeLength;
            setMeshMinContourEdgeLength(obj,minContourEdgeLength);
        end


        [~,domainCodes,domains]=em.MeshGeometry.constructDomainFromBoundary(allBoundaries);
        gd=em.MeshGeometry.buildgeometrymatrix(domains,domainCodes);


        PCell=makeContourArray(obj,gd,tempMetalLayers,viapolys,'rawContour');
        if metalMeshGenFailure

        end
        [unsplitviaedges,unsplitfeededges]=makeUnsplitEdgeArray(obj,via_pt1,via_pt2,feed_edgept1,feed_edgept2);

        feeds=obj.FeedLocations(:,1:2);
        if~isempty(obj.ViaLocations)
            feeds=[feeds;obj.ViaLocations(:,1:2)];
        end
        if~twoLayerWithFloodFillGnd&&~singleLayerMetal&&getMesherType(obj)
            smoothing_iter=0;
        else
            smoothing_iter=10;
        end
        edgeStatus=mesherInput.EdgeConnStatus;
        edgeStatus=edgeStatus(edgeStatus>0);
        minFeatureSize=getFeedWidth(obj);
        for m=1:size(PCell,2)
            P=PCell{m};
            for n=1:size(PCell,2)
                if n==m
                    continue;
                end
                Pb=PCell{n};

                [lia,locb]=ismembertol(P,Pb,'ByRows',true);
                ida=find(lia);
                idb=locb(locb>0);
                Pb(idb,:)=P(ida,:);
                PCell{n}=Pb;
            end
        end
        BaseMeshChoice='Unstructured';
        [ps,ts,~,edges]=em.internal.meshprinting.multiLayerMetalImprint(PCell,...
        gd,numBoardHoles,feeds,...
        [],...
        maxEdgeLength,...
        minContourEdgeLength,...
        growthRate,...
        smoothing_iter,...
        BaseMeshChoice,...
        refinecontours,...
        minFeatureSize,...
        edgeStatus);
        ps=ps';
        ts=ts';
        ts(4,:)=0;

        if getMesherType(obj)

            ps(3,:)=0;
            hardnodes=setdiff(1:size(ps,2),unique(edges(:)));
            [ps,ts,~]=em.MeshGeometry.cm2_remesher(ps,ts,maxEdgeLength,...
            growthRate,...
            minContourEdgeLength,...
            [],[],0,0,edges');

            ps(3,:)=[];
        end





        for i=1:numel(obj.MetalLayers)
            ps(3,:)=layer_heights(i);
            Center=em.internal.meshprinting.meshtricenter(ps',ts');
            layerPoly=obj.MetalLayers{i}.InternalPolyShape;
            INFILL=isinterior(layerPoly,Center(:,1),Center(:,2));



            warnState=warning('Off','MATLAB:triangulation:PtsNotInTriWarnId');
            Tr=triangulation(ts(1:3,:)',ps(1:2,:)');
            warning(warnState);
            ti=pointLocation(Tr,Center(INFILL,1:2));


            fills{:,i}=unique(ti,'Rows','Stable');

        end


        tsBlocks=[];
        blockSize=[];
        for i=1:numel(fills)
            tsBlocks=[tsBlocks,ts(:,fills{i})];
            blockSize=[blockSize,numel(fills{i})];
        end

        tsBlocks=fliplr(tsBlocks);
        blockSize=fliplr(blockSize);


        nonMetalTris=setdiff([1:size(ts,2)]',unique(cell2mat(fills')),'rows','stable');
        tsBlocks=[tsBlocks,ts(:,nonMetalTris)];



        Mi.P=ps';
        Mi.t=ts(1:3,:)';


        Mi.Fills=fliplr(fills);
        Mi.PatchTriangles=blockSize;
        Mi.FeedVertex1=[];
        Mi.FeedVertex2=[];
        if~isempty(via_pt1)


            Mi.FeedVertex1=unsplitviaedges(1:2:end-1,:);
            Mi.FeedVertex1(:,3)=0;
            Mi.FeedVertex2=unsplitviaedges(2:2:end,:);
            Mi.FeedVertex2(:,3)=0;















        end
        Mi.NumLayers=numLayers;
        mapValue=calculateLayerMapForMultiLayerMesher(obj,numLayers);
        if~isempty(vias)


            connIndex=via_order;
            connIndex=fliplr(connIndex);
            Nlayers=numel(obj.MetalLayers);

            mapKey=Nlayers:-1:1;
            mapObj=containers.Map(mapKey,mapValue);
            for i=1:size(connIndex,1)
                Mi.LayerMap(i,:)=[mapObj(connIndex(i,1)),mapObj(connIndex(i,2))];
            end

        end
        Mi.NumConnEdges=1;


        [T,B]=calculateTopandBottomDielectricCoverThickness(obj);
        Mi.TopSubThickness=T;
        Mi.BottomSubThickness=B;
        Mi.BottomMetalLayerOffset=min(mapValue);






        if singleLayerMetal
            MetalIdx=cell2mat(cellfun(@(x)isa(x,'antenna.Shape'),obj.Layers,'UniformOutput',false));
            MetalId=find(MetalIdx);
            if MetalId==1
                Mi.TopSubThickness=0;
                Mi.BottomSubThickness=sum(cell2mat(cellfun(@(x)get(x,'Thickness'),obj.Layers(2:end),'UniformOutput',false)));
                Mi.RemoveLayer='gnd';
            elseif MetalId==numel(obj.Layers)
                Mi.TopSubThickness=sum(cell2mat(cellfun(@(x)get(x,'Thickness'),obj.Layers(1:end-1),'UniformOutput',false)));
                Mi.BottomSubThickness=0;
                Mi.RemoveLayer='patch';
            else
                Mi.TopSubThickness=sum(cell2mat(cellfun(@(x)get(x,'Thickness'),obj.Layers(1:MetalId-1),'UniformOutput',false)));
                Mi.BottomSubThickness=sum(cell2mat(cellfun(@(x)get(x,'Thickness'),obj.Layers(MetalId+1:end),'UniformOutput',false)));
                Mi.RemoveLayer='gnd';
            end

        end

        if isscalar(layer_heights)
            MultiMesh=makeMultiLayerMesh(obj.Substrate,layer_heights,Mi,false,false);
        else
            MultiMesh=makeMultiLayerMesh(obj.Substrate,fliplr(layer_heights(1:end-1)),Mi,false,false);
        end



        pall=MultiMesh.P;
        t=sortrows(MultiMesh.t')';
        tetsByLayer=unique(MultiMesh.T','rows','stable')';
        epsilonRByLayer=MultiMesh.EPSR(1:size(tetsByLayer,2));
        lossTangentByLayer=MultiMesh.LOSSTANG(1:size(tetsByLayer,2));

        Mesh=em.internal.makeMeshStructure(pall,t,tetsByLayer,epsilonRByLayer,lossTangentByLayer);

        Mesh.Points=orientGeom(obj,Mesh.Points);

    end


end

