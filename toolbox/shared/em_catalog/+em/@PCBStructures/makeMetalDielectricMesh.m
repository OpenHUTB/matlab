function Mesh=makeMetalDielectricMesh(obj,mesherInput)

    isProbeFed=mesherInput.EdgeConnStatus{1};
    isEdgeFed=mesherInput.EdgeConnStatus{2};
    isEdgeVia=mesherInput.EdgeConnStatus{3};
    isViaPresent=~isempty(obj.ViaLocations);
    connModel=mesherInput.ConnModel;
    buildStripMesh=true;
    if any(strcmpi(mesherInput.ConnModel,{'square','hexagon','octagon'}))
        connModel='solid';
        buildStripMesh=false;
    end
    if strcmpi(connModel,'solid')&&any(isEdgeFed)&&~isViaPresent||...
        strcmpi(connModel,'solid')&&any(isEdgeFed)&&isViaPresent&&any(isEdgeVia)||...
        strcmpi(connModel,'solid')&&~all(isProbeFed)&&~all(isEdgeFed)
        buildStripMesh=true;
    elseif strcmpi(connModel,'solid')&&~all(isEdgeFed)&&isViaPresent&&~all(isEdgeVia)||...
        strcmpi(connModel,'solid')&&all(isEdgeFed)&&isViaPresent&&~all(isEdgeVia)
        buildStripMesh=false;
    end
    if~buildStripMesh
        localConnModel=mesherInput.ConnModel;
        [tempMetalLayers,startLayer,stopLayer,gndLayers,viapolys]=makeFeaturesOnLayers(obj,isProbeFed,isEdgeFed,isEdgeVia);
        [~,~,~]=runMeshGeneratorForEachLayer(obj,tempMetalLayers,...
        gndLayers,localConnModel);
        mesherInput.viapolys=viapolys;
        Mesh=generateMeshForSolidFeedAndVia(obj,mesherInput);
        setFeedType(obj,'multiedge');


        if 0
            plot_dbStack=dbstack;disp(['Debug plot active on line ',num2str((plot_dbStack(1).line)),' of ',plot_dbStack(1).file]);%#ok
            t_temp=transpose(Mesh.Triangles(1:3,:));
            P_temp=transpose(Mesh.Points);
            figure;patch('Faces',t_temp,'Vertices',P_temp,'FaceColor','c','EdgeColor','k');axis equal;
            title('after generateMeshForSolidFeedAndVia()')
        end

    else

        vias=mesherInput.vias;
        layer_heights=mesherInput.layer_heights;


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
        allBoundaries=cornersSub;
        tempMetalLayers=cellfun(@(x)copy(x),obj.MetalLayers,'UniformOutput',false);


        for i=1:numel(obj.MetalLayers)
            tempBoundary=getPolygonBoundariesForLayer(obj,tempMetalLayers{i},sqrt(eps));
            allBoundaries=[allBoundaries,tempBoundary];%#ok<AGROW> tempMetalLayers{i}.Polygons
        end










        if~isempty(obj.ViaLocations)
            Wv=cylinder2strip(obj.ViaDiameter/2);
            for i=1:size(obj.ViaLocations,1)
                x=obj.modifiedViaLocations(i,1);
                y=obj.modifiedViaLocations(i,2);
                fromLayer=obj.modifiedViaLocations(i,3);
                toLayer=obj.modifiedViaLocations(i,4);
                poly=appendFeedViaPolyVertices(obj,tempMetalLayers,fromLayer,toLayer,x,y,Wv);

                if~isempty(poly)
                    allBoundaries=[allBoundaries,poly.InternalPolyShape.Vertices];%#ok<AGROW>
                end
            end
        end


        Wf=cylinder2strip(obj.FeedDiameter/2);
        for i=1:size(obj.FeedLocations,1)
            x=obj.modifiedFeedLocations(i,1);
            y=obj.modifiedFeedLocations(i,2);

            fromLayer=obj.modifiedFeedLocations(i,3);
            toLayer=[];
            if size(obj.FeedLocations,2)==4
                toLayer=obj.modifiedFeedLocations(i,4);
            end

            poly=appendFeedViaPolyVertices(obj,tempMetalLayers,fromLayer,toLayer,x,y,Wf);
            if~isempty(poly)

                allBoundaries=[allBoundaries,poly.InternalPolyShape.Vertices];%#ok<AGROW>
            end
        end



        maxEdgeLength=getMeshEdgeLength(obj);
        minContourEdgeLength=getMinContourEdgeLength(obj);
        growthRate=getMeshGrowthRate(obj);
        if minContourEdgeLength>maxEdgeLength
            minContourEdgeLength=0.75*maxEdgeLength;
            setMeshMinContourEdgeLength(obj,minContourEdgeLength);
        end








        edgeStatus=0;

        minFeatureSize=getFeedWidth(obj);
        PCell=allBoundaries;

        smoothing_iter=1;



        feeds=obj.FeedLocations(:,1:2);
        via=[];

        if~isempty(obj.ViaLocations)

            via=obj.ViaLocations(:,1:2);
        end

        BaseMeshChoice='pcb';
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

        [ps,ts,~,edges,psplit,esplit,feed_new,feed_map]=em.internal.meshprinting.multiLayerMetalImprint(PCell,...
        [],numBoardHoles,feeds,via,...
        maxEdgeLength,...
        minContourEdgeLength,...
        growthRate,...
        smoothing_iter,...
        BaseMeshChoice,...
        0,...
        minFeatureSize,...
        edgeStatus);
        ps=ps';
        ts=ts';
        ts(4,:)=0;


        if 0
            plot_dbStack=dbstack;disp(['Debug plot active on line ',num2str((plot_dbStack(1).line)),' of ',plot_dbStack(1).file]);%#ok
            figure;patch('faces',transpose(ts(1:3,:)),'vertices',transpose(ps),'FaceColor','c','EdgeColor','k');axis equal;
            hold on;plot(psplit{1}(:,1),psplit{1}(:,2),'*r');
            title('After imprinting');
        end





        if isempty(esplit)
            [viaedges,via_order,via_ID]=makeUnsplitEdgeArray(obj,ps',ts',vias,feedMap,isEdgeFed);
            numconnedges=1;
            setFeedType(obj,'singleedge');
        else

            [viaedges,via_order,~,via_ID]=makeSplitEdgeArray(obj,vias,psplit,esplit,feed_new,feed_map,isEdgeFed);
            numconnedges=getNumFeedEdgesForSolidFeed(obj);
            setFeedType(obj,'multiedge');
        end


        if 0
            plot_dbStack=dbstack;disp(['Debug plot active on line ',num2str((plot_dbStack(1).line)),' of ',plot_dbStack(1).file]);%#ok
            figure;patch('faces',transpose(ts(1:3,:)),'vertices',transpose(ps),'FaceColor','c','EdgeColor','k');axis equal;%#ok<UNRCH> 
            hold on;plot(viaedges(:,1),viaedges(:,2),'*r');
            title('After edge array');
        end


        ps(3,:)=0;







        [ps,ts,~]=em.MeshGeometry.cm2_remesher(ps,ts,maxEdgeLength,...
        growthRate,...
        minContourEdgeLength,...
        [],[],0,0,edges');




        ps(3,:)=[];


        extractFeedPolygons(obj,ps,ts,viaedges,via_ID,via_order);





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




        Mi.P=ps';
        Mi.t=ts(1:3,:)';
        Mi.Fills=fliplr(fills);
        Mi.PatchTriangles=blockSize;
        Mi.FeedVertex1=[];
        Mi.FeedVertex2=[];
        Mi.FeedViaMap=[];






























        if any(isProbeFed)||any(isEdgeFed)||any(isEdgeVia)


            Mi.FeedVertex1=viaedges(1:2:end-1,:);
            Mi.FeedVertex1(:,3)=0;
            Mi.FeedVertex2=viaedges(2:2:end,:);
            Mi.FeedVertex2(:,3)=0;
            Mi.FeedViaMap=via_ID;

















        end

        numLayers=checkSubstrateThicknessVsLambda(obj.Substrate,obj);
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
        Mi.NumConnEdges=numconnedges;


        [T,B]=calculateTopandBottomDielectricCoverThickness(obj);
        Mi.TopSubThickness=T;
        Mi.BottomSubThickness=B;
        Mi.BottomMetalLayerOffset=min(mapValue);






        if isequal(numel(obj.MetalLayers),1)
            singleLayerMetal=true;
        else
            singleLayerMetal=false;
        end
        if singleLayerMetal
            if numel(obj.Layers)==1
                Mi.TopSubThickness=0;
                Mi.BottomSubThickness=0;
                Mi.RemoveLayer='gnd';
            else
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
        end

        if isscalar(layer_heights)
            MultiMesh=makeMultiLayerMesh(obj.Substrate,layer_heights,Mi,false,false);
        else
            MultiMesh=makeMultiLayerMesh(obj.Substrate,fliplr(layer_heights(1:end-1)),Mi,false,false);
        end


        P_GP=zeros(0,3);t_GP=zeros(0,3);
        if~isempty(MultiMesh.tGP)
            [P_GP,t_GP]=em.internal.meshprinting.meshreduce(transpose(MultiMesh.P),MultiMesh.tGP(:,1:3));
            t_GP(:,4)=MultiMesh.tGP(:,4);
        end

        P_Feed=zeros(0,3);t_Feed=zeros(0,3);
        if~isempty(MultiMesh.tFeed)
            [P_Feed,t_Feed]=em.internal.meshprinting.meshreduce(transpose(MultiMesh.P),MultiMesh.tFeed(:,1:3));
            t_Feed(:,4)=MultiMesh.tFeed(:,4);
        end

        P_Rad=zeros(0,3);t_Rad=zeros(0,3);
        if~isempty(MultiMesh.tRad)
            [P_Rad,t_Rad]=em.internal.meshprinting.meshreduce(transpose(MultiMesh.P),MultiMesh.tRad(:,1:3));
            t_Rad(:,4)=MultiMesh.tRad(:,4);
        end

        Parts=em.internal.makeMeshPartsStructure('Gnd',[{transpose(P_GP)},{transpose(t_GP)}],...
        'Feed',[{transpose(P_Feed)},{transpose(t_Feed)}],...
        'Rad',[{transpose(P_Rad)},{transpose(t_Rad)}]);
        savePartMesh(obj,Parts);



        pall=MultiMesh.P;
        t=sortrows(MultiMesh.t')';
        tetsByLayer=unique(MultiMesh.T','rows','stable')';
        epsilonRByLayer=MultiMesh.EPSR(1:size(tetsByLayer,2));
        lossTangentByLayer=MultiMesh.LOSSTANG(1:size(tetsByLayer,2));

        Mesh=em.internal.makeMeshStructure(pall,t,tetsByLayer,epsilonRByLayer,lossTangentByLayer);

        Mesh.Points=orientGeom(obj,Mesh.Points);
        for j=1:length(obj.FeedEdgeCenters)
            obj.FeedEdgeCenters{j}=transpose(orientGeom(obj,transpose(obj.FeedEdgeCenters{j})));
        end

    end
end








function notPoly=appendFeedViaLineVertices(obj,tempMetalLayers,fromLayer,toLayer,x,y,Wv)



    if 0
        poly1=testPointOnLayerAndWidth(obj,tempMetalLayers,fromLayer,x,y,Wv);
        poly2=testPointOnLayerAndWidth(obj,tempMetalLayers,toLayer,x,y,Wv);

        notPoly=poly2;
        if isempty(notPoly)
            notPoly=poly1;
        end

        if~isempty(notPoly)&&~isempty(notPoly.InternalPolyShape.Vertices)
            notPoly=notPoly.InternalPolyShape.Vertices;return;
        end
    end



    lineTemplates=cell(2,1);
    lineTemplates{1}=[x,y+Wv/2;x,y-Wv/2];
    lineTemplates{2}=[x-Wv/2,y;x+Wv/2,y];


    in_from=zeros(2,length(lineTemplates));on_from=in_from;
    in_to=in_from;on_to=in_from;
    if isempty(toLayer)
        in_to(:)=1;on_to(:)=1;
    end


    for j=1:length(lineTemplates)
        [in_from(:,j),on_from(:,j)]=contains(tempMetalLayers{fromLayer},lineTemplates{j}(:,1),lineTemplates{j}(:,2));
        [in_to(:,j),on_to(:,j)]=contains(tempMetalLayers{toLayer},lineTemplates{j}(:,1),lineTemplates{j}(:,2));
    end


    if(any(~all(in_from))||any(~all(in_to)))&&any(all(in_from)&all(in_to))
        locString=['[',num2str(x),', ',num2str(y),']'];
        warning(message('antenna:antennaerrors:ImprintedStripViaUnrealistic',locString));
    end


    for j=1:length(lineTemplates)
        if all(on_from(:,j))&&all(on_to(:,j))
            notPoly=lineTemplates{j};return;
        end
    end


    for j=1:length(lineTemplates)
        if all(in_from(:,j)|on_from(:,j))&&all(in_to(:,j)|on_to(:,j))
            notPoly=lineTemplates{j};return;
        end
    end


    if 0
        plot_dbStack=dbstack;disp(['Debug plot active on line ',num2str((plot_dbStack(1).line)),' of ',plot_dbStack(1).file]);%#ok
        figure;
        vertFrom=tempMetalLayers{fromLayer}.getShapeVertices();
        vertTo=tempMetalLayers{toLayer}.getShapeVertices();
        plot(vertFrom(:,1),vertFrom(:,2),'-ok');hold on;
        plot(vertTo(:,1),vertTo(:,2),'-ob');
        for j=1:length(lineTemplates)
            plot(lineTemplates{j}(:,1),lineTemplates{j}(:,2),'-*r');
        end
    end


    locString=['[',num2str(x),', ',num2str(y),']'];
    error(message('antenna:antennaerrors:FailedToImprintStripVia',locString))
end

function poly=appendFeedViaPolyVertices(obj,tempMetalLayers,fromLayer,toLayer,x,y,Wv)
    poly=[];
    if~isempty(toLayer)


        [in_from,on_from]=contains(tempMetalLayers{fromLayer},x,y);

        [in_to,on_to]=contains(tempMetalLayers{toLayer},x,y);

        if(in_from)&&(in_to)&&~(on_from)&&~(on_to)




            v_from=em.PCBStructures.pickRefiningPolygon(Wv,tempMetalLayers{fromLayer},[x,y]);

            v_to=em.PCBStructures.pickRefiningPolygon(Wv,tempMetalLayers{toLayer},[x,y]);

            [in_vf,on_vf]=contains(tempMetalLayers{toLayer},v_from.Vertices(:,1),v_from.Vertices(:,2));

            [in_vt,on_vt]=contains(tempMetalLayers{fromLayer},v_to.Vertices(:,1),v_to.Vertices(:,2));
            if all(in_vf)&&~all(in_vt)||all(in_vf)&&all(in_vt)
                poly=v_from;
            elseif all(in_vt)&&~all(in_vf)||all(in_vt)&&all(in_vf)
                poly=v_to;
            else







                notPoly=appendFeedViaLineVertices(obj,tempMetalLayers,fromLayer,toLayer,x,y,Wv);

                poly.InternalPolyShape.Vertices=notPoly;
            end
        else




            if(in_from)&&(in_to)&&~(on_from)&&(on_to)

                poly=testPointOnLayerAndWidth(obj,tempMetalLayers,toLayer,x,y,Wv);
            elseif(in_from)&&(on_from)&&(in_to)&&~(on_to)

                poly=testPointOnLayerAndWidth(obj,tempMetalLayers,fromLayer,x,y,Wv);
            elseif(in_from)&&(on_from)&&(in_to)&&(on_to)
                poly1=testPointOnLayerAndWidth(obj,tempMetalLayers,fromLayer,x,y,Wv);
                poly2=testPointOnLayerAndWidth(obj,tempMetalLayers,toLayer,x,y,Wv);
                if isempty(poly1)&&~isempty(poly2)
                    poly=poly1;
                elseif~isempty(poly1)&&isempty(poly2)
                    poly=poly2;
                elseif~isempty(poly1)
                    poly=poly1;
                else
                    poly=poly2;
                end
            end
        end
    else

        [in_from,on_from]=contains(tempMetalLayers{fromLayer},x,y);

        if(in_from)&&~(on_from)




            v_from=em.PCBStructures.pickRefiningPolygon(Wv,tempMetalLayers{fromLayer},[x,y]);
            poly=v_from;
        end
    end
end

function poly=testPointOnLayerAndWidth(~,tempMetalLayers,layerId,x,y,Wv)
    warnState=warning('Off','MATLAB:triangulation:PtsNotInTriWarnId');
    TR=triangulation(tempMetalLayers{layerId}.InternalPolyShape);
    e=edges(TR);


    f=[x,y,0];
    [D,IND]=em.internal.meshprinting.inter2_point_seg(TR.Points,e,f);
    tempIndex=find(D<sqrt(eps)&IND==-1);%#ok<AGROW>
    if~isempty(tempIndex)&&isscalar(tempIndex)
        index=tempIndex;
    else
        closestEdgeId=find(D==min(D));
        index=closestEdgeId(1);
    end

    poly=[];


    tf=abs(norm(diff(TR.Points(e(index,:),:)))-Wv)<sqrt(eps);
    if~tf
        poly=em.PCBStructures.pickRefiningPolygon(Wv,tempMetalLayers{layerId},[x,y]);
    end
    warning(warnState);
end

function[viaEdges,via_order,viaMap]=makeUnsplitEdgeArray(obj,ps,ts,vias,viaMap,isEdgeFed)

    Nlayers=numel(obj.MetalLayers);
    via_order=[];
    viaEdges=[];

    if(any(isEdgeFed))
        vias((end-sum(isEdgeFed)+1):end,:)=[];
    end





    warnState=warning('Off','MATLAB:triangulation:PtsNotInTriWarnId');
    for i=1:Nlayers
        stopVias=vias(vias(:,4)==i,[1:2,5]);
        via_order=[via_order;vias(vias(:,4)==i,3:4)];
        testVias=unique([stopVias(:,1:2)],'rows');
        if~isempty(testVias)
            for j=1:size(testVias,1)
                TR=triangulation(ts(:,1:3),ps);
                e=edges(TR);

                testPoint=testVias(j,1:2);
                [D,IND]=em.internal.meshprinting.inter2_point_seg(TR.Points,e,testPoint);
                tempIndex=find(D<sqrt(eps)&IND==-1);%#ok<AGROW>
                if~isempty(tempIndex)&&isscalar(tempIndex)
                    index=tempIndex;
                else
                    closestEdgeId=find(D==min(D));
                    index=closestEdgeId(1);
                end




















                viaEdges=[viaEdges;TR.Points(e(index,:),:)];
            end
        end

    end


    setNumFeedEdgesForSolidFeed(obj,1);

    warning(warnState);
end





function[viaEdges,via_order,viamap_toOrig,viamap_toOrder]=makeSplitEdgeArray(obj,vias,psplit,esplit,feedviaCenters,feedviaMap,isEdgeFed)
    feedCenters=feedviaCenters{1};
    viaCenters=feedviaCenters{2};
    Nlayers=numel(obj.MetalLayers);




    if isempty(feedviaMap{2})
        viamap_toOrig=feedviaMap{1};
    else
        viamap_toOrig=[feedviaMap{2};feedviaMap{1}+max(feedviaMap{2})];
    end
    viaEdges=[psplit{2};psplit{1}];


    feeds=obj.modifiedFeedLocations;
    feedInfoLength=size(feeds,2);
    edgeFeeds=feeds(isEdgeFed,:);
    isFalseVia=false(size(vias,1),1);
    if isempty(viaEdges)
        viamap_toOrig=[];
    else
        for j=1:size(vias,1)
            isFalseVia(j)=any(all(edgeFeeds==vias(j,1:feedInfoLength),2));
            if isFalseVia(j)
                falseVias=viamap_toOrig==j;
                viamap_toOrig(falseVias,:)=[];
                falseVias_2=false(2*length(falseVias),1);falseVias_2(1:2:end)=falseVias;falseVias_2(2:2:end)=falseVias;
                viaEdges(falseVias_2,:)=[];
            end
        end

    end




















    via_order=[];







    viaCounter=1;
    viamap_toOrder=viamap_toOrig;
    if(~isempty(vias))
        for i=1:Nlayers
            activeViaIdx=find(vias(:,4)==i);
            stopVias=vias(activeViaIdx,[1:2,5]);
            via_order=[via_order;vias(activeViaIdx,3:4)];

            for j=1:length(activeViaIdx)
                viamap_toOrder(activeViaIdx(j)==viamap_toOrig)=viaCounter;
                viaCounter=viaCounter+1;
            end
        end
    end



    numfeeds=size(obj.FeedLocation,1);
    numEdgesPerFeed=size(feedCenters,1)/(numfeeds);
    if~isempty(obj.ViaLocations)
        numvias=size(obj.ViaLocations,1);
        numEdgesPerVia=size(viaCenters,1)/numvias;
    end

    setNumFeedEdgesForSolidFeed(obj,numEdgesPerFeed);

    feedCenters=feedCenters';
    feedCenters=reshape(feedCenters,[2*numEdgesPerFeed,numfeeds]);
    feedCenters=num2cell(feedCenters,1);
    feedCenters=cellfun(@(x)reshape(x',[2,numEdgesPerFeed])',feedCenters,'UniformOutput',false);
    f=obj.FeedLocation;
    for i=1:numfeeds
        tempf=feedCenters{i};
        tempf(:,3)=f(i,3);
        feedCenters{i}=tempf;
    end
    obj.FeedEdgeCenters=feedCenters;



end

































































