function Mesh=generateMeshForSolidFeedAndVia(obj,mesherInput)






















    vias=mesherInput.vias;
    viapolys=mesherInput.viapolys;
    layer_heights=mesherInput.layer_heights;
    smoothing_iter=mesherInput.smoothing_iter;
    refinecontours=mesherInput.refinecontours;
    if isfield(mesherInput,'EdgeFeedStatus')
        isEdgeFed=mesherInput.EdgeFeedStatus;
    else
        isEdgeFed=mesherInput.EdgeConnStatus{2};
    end



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



    tempMetalLayers=obj.MetalLayersCopy;
    maxEdgeLength=getMeshEdgeLength(obj);
    minContourEdgeLength=getMinContourEdgeLength(obj);
    growthRate=getMeshGrowthRate(obj);
    allBoundaries=cornersSub;


    for i=1:numel(obj.MetalLayers)
        tempBoundary=getPolygonBoundariesForLayer(obj,tempMetalLayers{i},sqrt(eps));
        allBoundaries=[allBoundaries,tempBoundary];%#ok<AGROW> tempMetalLayers{i}.Polygons
    end


    [~,domainCodes,domains]=em.MeshGeometry.constructDomainFromBoundary(allBoundaries);
    gd=em.MeshGeometry.buildgeometrymatrix(domains,domainCodes);


    PCell=makeContourArray(obj,gd,tempMetalLayers,viapolys,'rawContour');


    [feeds,unsplitviaedges,via_order,viamap_orig,viamap_order]=makeUnsplitEdgeArray(obj,tempMetalLayers,vias,layer_heights,isEdgeFed);




    contourAreas=cellfun(@(x)em.internal.areaOfPolygon(x),allBoundaries);

    if minContourEdgeLength>maxEdgeLength
        minContourEdgeLength=0.75*maxEdgeLength;
        setMeshMinContourEdgeLength(obj,minContourEdgeLength);
    end


    minFeatureSize=getFeedWidth(obj);
    BaseMeshChoice='Unstructured';

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
    [ps,ts,~,edges,~,~,~,viamap_order]=em.internal.meshprinting.multiLayerMetalImprint(PCell,gd,...
    numBoardHoles,feeds,...
    [],...
    maxEdgeLength,...
    minContourEdgeLength,...
    growthRate,...
    smoothing_iter,...
    BaseMeshChoice,...
    refinecontours,...
    minFeatureSize,...
    true,...
    viamap_order);

    ps=ps';
    ts=ts';
    ts(4,:)=0;


    if 0
        plot_dbStack=dbstack;disp(['Debug plot active on line ',num2str((plot_dbStack(1).line)),' of ',plot_dbStack(1).file]);%#ok
        figure;patch('faces',transpose(ts(1:3,:)),'vertices',transpose(ps),'FaceColor','c','EdgeColor','k');axis equal;

        title('After imprinting');
    end


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
        layerPoly=tempMetalLayers{i}.InternalPolyShape;
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
        tsBlocks=[tsBlocks,ts(:,fills{i})];%#ok<AGROW>
        blockSize=[blockSize,numel(fills{i})];%#ok<AGROW>
    end


    tsBlocks=fliplr(tsBlocks);
    blockSize=fliplr(blockSize);



    nonMetalTris=setdiff([1:size(ts,2)]',unique(cell2mat(fills')),'rows','stable');
    tsBlocks=[tsBlocks,ts(:,nonMetalTris)];




    Mi.P=ps';
    Mi.t=ts(1:3,:)';




    Mi.Fills=fliplr(fills);
    Mi.PatchTriangles=blockSize;
    if size(obj.FeedLocations,2)>3||~isempty(obj.ViaLocations)
        Mi.FeedVertex1=unsplitviaedges(1:2:end-1,:);
        Mi.FeedVertex1(:,3)=0;
        Mi.FeedVertex2=unsplitviaedges(2:2:end,:);
        Mi.FeedVertex2(:,3)=0;
        Mi.FeedViaMap=viamap_order;
    else
        Mi.FeedVertex1=[];
        Mi.FeedVertex2=[];
    end



    numLayers=checkSubstrateThicknessVsLambda(obj.Substrate,obj);
    Mi.NumLayers=numLayers;
    Mi.NumConnEdges=obj.NumFeedViaModelSides;
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


    [T,B]=calculateTopandBottomDielectricCoverThickness(obj);
    Mi.TopSubThickness=T;
    Mi.BottomSubThickness=B;
    Mi.BottomMetalLayerOffset=min(mapValue);








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



function[f,viaEdges,via_order,viamap_toOrig,viamap_toOrder]=makeUnsplitEdgeArray(obj,tempMetalLayers,vias,layer_heights,isEdgeFed)


    feeds=obj.modifiedFeedLocations;


    edgeFeeds=feeds(isEdgeFed,:);
    falseVias=false(size(vias,1),1);
    feedInfoLength=size(feeds,2);
    for j=1:size(edgeFeeds,1)
        falseVias=falseVias|all(edgeFeeds(j,:)==vias(:,1:feedInfoLength),2);
    end
    vias(falseVias,:)=[];

    isProbeFed=size(obj.modifiedFeedLocations,2)>3;
    feedLayers=obj.modifiedFeedLocations(:,3);





    if strcmpi(obj.FeedViaModel,'strip')
        if~isempty(vias)
            f=[feeds;vias];
            viamap_toOrig=1:size(f,1);
        end
    else

        Nlayers=numel(obj.MetalLayers);
        Nholes=cellfun(@(x)numel(x.HolePolygons),tempMetalLayers);
        holePerLayer=cell(Nlayers,max(Nholes));
        viaHoleAssoc=zeros(size(holePerLayer));
        via_order=[];

        for i=1:Nlayers


            tempHoles=tempMetalLayers{i}.HolePolygons;






            activeViaIdx=find(vias(:,3)==i);
            stopVias=vias(activeViaIdx,1:2);
            via_order=[via_order;vias(activeViaIdx,3:4)];
            testVias=unique([stopVias],'rows');
            if~isempty(testVias)

                tempH=[];
                for j=1:numel(tempHoles)
                    xHoles=tempHoles{j}(:,1);
                    yHoles=tempHoles{j}(:,2);



                    inHole=[(inpolygon(testVias(:,1),testVias(:,2),xHoles,yHoles))];%#ok<AGROW>

                    tempH=tempHoles(logical(inHole));
                    tempViaIdx=activeViaIdx(logical(inHole));
                    if~isempty(tempH)
                        holePerLayer(i,j)=tempHoles(j);
                        viaHoleAssoc(i,j)=tempViaIdx;
                    end
                end

            end
        end





        f=edgeFeeds(:,1:2);


        viaEdges=[];
        viamap_toOrig=[];
        viamap_toOrder=[];

        viaCounter=1;
        for i=1:Nlayers
            for j=1:max(Nholes)
                h=holePerLayer{i,j};
                if~isempty(h)
                    m=size(h,1);
                    e=[1:m;2:m,1]';
                    fp=(h(e(:,1),:)+h(e(:,2),:))/2;
                    f=[f;fp];%#ok<AGROW>
                    id=e';
                    id=id(:);
                    viaEdges=[viaEdges;h(id,:)];%#ok<AGROW>
                    viamap_toOrig=[viamap_toOrig;repmat(viaHoleAssoc(i,j),size(fp,1),1)];%#ok<AGROW> % Track the via to which each edge belongs 
                    viamap_toOrder=[viamap_toOrder;repmat(viaCounter,size(fp,1),1)];%#ok<AGROW> % Groups viaorder by via index
                    viaCounter=viaCounter+1;
                end
            end
        end

        if isProbeFed


            feedHolesOnLayer=[];
            terminatingFeedLayer=obj.modifiedFeedLocations(:,3);
            uniqFeedLayers=unique(feedLayers);
            fctr=1;
            for iter=1:numel(uniqFeedLayers)
                i=uniqFeedLayers(iter);
                testFeedHoles=holePerLayer(i,:);
                feedlocs=obj.modifiedFeedLocations(i==terminatingFeedLayer,1:2);
                isFeedLocEdgeFed=isEdgeFed(i==terminatingFeedLayer);

                for k=1:size(feedlocs,1)

                    if isFeedLocEdgeFed(k)
                        feedCenters{fctr}=[feedlocs(k,:),layer_heights(i)];
                        feedCenters{fctr}=orientGeom(obj,feedCenters{fctr}')';
                        fctr=fctr+1;

                    else
                        for j=find(cellfun(@(x)~isempty(x),testFeedHoles))
                            xHoles=testFeedHoles{j}(:,1);
                            yHoles=testFeedHoles{j}(:,2);
                            feedHole=logical([(inpolygon(feedlocs(k,1),feedlocs(k,2),xHoles,yHoles))]);%#ok<AGROW>
                            if feedHole

                                fh=testFeedHoles{j};
                                m=size(fh,1);
                                e=[1:m;2:m,1]';
                                feedCenters{fctr}=(fh(e(:,1),:)+fh(e(:,2),:))/2;
                                feedCenters{fctr}(:,3)=layer_heights(i);
                                feedCenters{fctr}=orientGeom(obj,feedCenters{fctr}')';
                                fctr=fctr+1;
                            end
                        end
                    end
                end
            end


            setNumFeedEdgesForSolidFeed(obj,sum(cellfun(@(x)size(x,1),feedCenters)));

            obj.FeedEdgeCenters=feedCenters;
        end

    end
end