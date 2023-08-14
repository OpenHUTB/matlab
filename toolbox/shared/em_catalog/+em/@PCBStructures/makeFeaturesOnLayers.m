function[tempMetalLayers,startLayer,stopLayer,gndLayers,viapolys]=makeFeaturesOnLayers(obj,isProbeFed,isEdgeFed,isEdgeVia)






    gndLayers=[];
    numVias=size(obj.ViaLocations,1);
    numFeeds=size(obj.FeedLocations,1);
    viapolys=cell(numel(obj.MetalLayers),1);
    stopLayer=[];

    tempMetalLayers=cellfun(@(x)copy(x),obj.MetalLayers,'UniformOutput',false);



    for i=1:numVias
        startLayer=obj.modifiedViaLocations(i,3);
        stopLayer=obj.modifiedViaLocations(i,4);
        Wv=(obj.ViaDiameter/2);


        if~isEdgeVia(i)
            f=antenna.Shape.refiningpolygon(Wv(i),obj.modifiedViaLocations(i,1:2),[],'Poly',obj.NumFeedViaModelSides);
            tempMetalLayers{startLayer}=tempMetalLayers{startLayer}-f;
            tempMetalLayers{stopLayer}=tempMetalLayers{stopLayer}-f;
        else

            f=em.PCBStructures.pickRefiningPolygon(Wv,tempMetalLayers{startLayer},obj.modifiedViaLocations(i,1:2));
            tempMetalLayers{startLayer}=tempMetalLayers{startLayer}+f;
            tempMetalLayers{stopLayer}=tempMetalLayers{stopLayer}+f;
        end
        viapolys{startLayer}=[viapolys{startLayer},{f}];
    end


    for i=1:numFeeds
        startLayer=obj.modifiedFeedLocations(i,3);
        Wf=(obj.FeedDiameter/2);
        if isProbeFed
            stopLayer=obj.modifiedFeedLocations(i,4);
            if~isEdgeFed(i)
                f=antenna.Shape.refiningpolygon(Wf,obj.modifiedFeedLocations(i,1:2),[],'Poly',obj.NumFeedViaModelSides);
                tempMetalLayers{startLayer}=tempMetalLayers{startLayer}-f;
                tempMetalLayers{stopLayer}=tempMetalLayers{stopLayer}-f;
            else



                f=[];
                [tempMetalLayers{startLayer}]=forceImprintEdgeFeed(obj.modifiedFeedLocations(i,1:2),Wf,tempMetalLayers{startLayer});
                [tempMetalLayers{stopLayer}]=forceImprintEdgeFeed(obj.modifiedFeedLocations(i,1:2),Wf,tempMetalLayers{stopLayer});


                if 0
                    plot_dbStack=dbstack;disp(['Debug plot active on line ',num2str((plot_dbStack(1).line)),' of ',plot_dbStack(1).file]);%#ok
                    plot_v=tempMetalLayers{startLayer}.InternalPolyShape.Vertices;
                    figure;plot(plot_v(:,1),plot_v(:,2),'-or');axis equal;
                    title(['After imprinting feed ',num2str(i)]);
                end
            end
            gndLayers=[gndLayers,stopLayer];
        else
            Wf=cylinder2strip(obj.FeedDiameter/2);
            f=obj.pickRefiningPolygon(Wf,tempMetalLayers{startLayer},obj.modifiedFeedLocations(i,1:2));


            featureOnStartLayer=tempMetalLayers{startLayer}-f;
            isOverLap=isEdgeOverlapOnBoundaryPoints(featureOnStartLayer);
            tf=applyRefiningPolygon(obj,tempMetalLayers{startLayer},i,Wf,'feed');
            if~isOverLap&&tf
                tempHoleOnStartLayer=[tempMetalLayers{startLayer}.FeaturePolygons,{f}];
                tempMetalLayers{startLayer}=featureOnStartLayer;
                setFeaturePolygons(tempMetalLayers{startLayer},tempHoleOnStartLayer);
            end
        end
        if~isempty(f)
            viapolys{startLayer}=[viapolys{startLayer},{f}];
        end
    end

    obj.MetalLayersCopy=tempMetalLayers;
end

function[newLayer]=forceImprintEdgeFeed(feedPos,feedRad,origLayer)

    P=origLayer.getShapeVertices;
    edges1=transpose(1:(size(P,1)-1));edges2=transpose(2:size(P,1));
    edges=[edges1,edges2];




    falseVerts=find(any(isnan(P),2));
    traceStarts=falseVerts+1;traceStarts=[1,traceStarts'];
    for j=1:length(falseVerts)
        edges(edges(:,2)==falseVerts(j),2)=traceStarts(j);
        edges(edges(:,1)==falseVerts(j),:)=[];
    end
    edges=[edges;edges(end,2),traceStarts(end)];


    [edgeDistances,flag]=em.internal.meshprinting.inter2_point_seg(P,edges,feedPos);

    validEdges=flag<0;
    if~any(validEdges)
        error('Error!!');
    end
    edges_temp=edges(validEdges,:);
    [minDist,nearestEdgeIdx]=min(edgeDistances(validEdges));
    chosenEdge=edges_temp(nearestEdgeIdx,:);

    P1=P(chosenEdge(1,1),:);
    P2=P(chosenEdge(1,2),:);
    Ptemp=[feedPos,0];


    if minDist>0
        crossFull=cross(cross(P1-Ptemp,P2-P1),P2-P1);
        translationVector=minDist*crossFull/norm(crossFull);translationVector(3)=[];
        Ptemp=Ptemp+translationVector;
    end

    edgeVec=(P2-P1)/norm(P2-P1);
    vertsNew=feedRad*[-1;1]*edgeVec+Ptemp;

    if chosenEdge(1)>chosenEdge(2)
        P=[P(1:max(chosenEdge),:);vertsNew;P((max(chosenEdge)+1):end,:)];
    else
        P=[P(1:min(chosenEdge),:);vertsNew;P(max(chosenEdge):end,:)];
    end

    if~isa(origLayer,'antenna.Polygon')
        newLayer=antenna.Polygon;
    else
        newLayer=origLayer;
    end
    newLayer.Vertices=P;
end
