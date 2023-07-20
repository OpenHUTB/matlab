function[tempMetalLayers,startLayer,stopLayer,gndLayers,viapolys]=prepareLayersForInterConnections(obj,localConnModel,isProbeFed,isEdgeFed,isEdgeVia)






    gndLayers=[];
    numVias=size(obj.ViaLocations,1);
    numFeeds=size(obj.FeedLocations,1);
    viapolys=cell(numel(obj.MetalLayers),1);
    stopLayer=[];

    tempMetalLayers=cellfun(@(x)copy(x),obj.MetalLayers,'UniformOutput',false);

    if strcmpi(localConnModel,'strip')
        for i=1:numVias
            startLayer=obj.modifiedViaLocations(i,3);
            stopLayer=obj.modifiedViaLocations(i,4);
            Wv=cylinder2strip(obj.ViaDiameter/2);
            if obj.IsRefiningPolygon

                v=em.PCBStructures.pickRefiningPolygon(Wv,tempMetalLayers{startLayer},obj.modifiedViaLocations(i,1:2));

                if~isEdgeVia
                    featureOnStartLayer=tempMetalLayers{startLayer}-v;
                    isOverLap=isEdgeOverlapOnBoundaryPoints(featureOnStartLayer);
                    tf=applyRefiningPolygon(obj,tempMetalLayers{startLayer},i,Wv,'via');
                    if~isOverLap&&tf

                        tempHoleOnStartLayer=[tempMetalLayers{startLayer}.FeaturePolygons,{v}];

                        tempMetalLayers{startLayer}=featureOnStartLayer;

                        setFeaturePolygons(tempMetalLayers{startLayer},tempHoleOnStartLayer);
                    end

                    featureOnStopLayer=tempMetalLayers{stopLayer}-v;
                    isOverLap=isEdgeOverlapOnBoundaryPoints(featureOnStopLayer);
                    tf=applyRefiningPolygon(obj,tempMetalLayers{stopLayer},i,Wv,'via');
                    if~isOverLap&&tf
                        tempHoleOnStopLayer=[tempMetalLayers{stopLayer}.FeaturePolygons,{v}];
                        tempMetalLayers{stopLayer}=featureOnStopLayer;
                        setFeaturePolygons(tempMetalLayers{stopLayer},tempHoleOnStopLayer);
                    end
                else

                    featureOnStartLayerM=tempMetalLayers{startLayer}-v;
                    featureOnStartLayerP=tempMetalLayers{startLayer}+v;
                    if~hasFeatureVerticesOnLayer(featureOnStartLayerM,v)


                        if~isempty(tempMetalLayers{startLayer}.FeaturePolygons)
                            tempFeatureOnStartLayer=tempMetalLayers{startLayer}.FeaturePolygons;
                        else
                            tempFeatureOnStartLayer=[];
                        end
                        tempMetalLayers{startLayer}=featureOnStartLayerP;
                        setFeaturePolygons(tempMetalLayers{startLayer},tempFeatureOnStartLayer);
                    else
                        tempHoleOnStartLayer=[tempMetalLayers{startLayer}.FeaturePolygons,{v}];
                        tempMetalLayers{startLayer}=featureOnStartLayerM;
                        setFeaturePolygons(tempMetalLayers{startLayer},tempHoleOnStartLayer);
                    end

                    featureOnStopLayerM=tempMetalLayers{stopLayer}-v;
                    featureOnStopLayerP=tempMetalLayers{stopLayer}+v;
                    if~hasFeatureVerticesOnLayer(featureOnStopLayerM,v)
                        if~isempty(tempMetalLayers{stopLayer}.FeaturePolygons)
                            tempFeatureOnStopLayer=tempMetalLayers{stopLayer}.FeaturePolygons;
                        else
                            tempFeatureOnStopLayer=[];
                        end
                        tempMetalLayers{stopLayer}=featureOnStopLayerP;
                        setFeaturePolygons(tempMetalLayers{stopLayer},tempFeatureOnStopLayer);
                    else
                        tempHoleOnStopLayer=[tempMetalLayers{stopLayer}.FeaturePolygons,{v}];
                        tempMetalLayers{stopLayer}=featureOnStopLayerM;
                        setFeaturePolygons(tempMetalLayers{stopLayer},tempHoleOnStopLayer);
                    end
                end

                viapolys{startLayer}=[viapolys{startLayer},{v}];
                viapolys{stopLayer}=[viapolys{stopLayer},{v}];
            else
                tempMetalLayers{startLayer}=tempMetalLayers{startLayer};
                tempMetalLayers{stopLayer}=tempMetalLayers{stopLayer};
                viapolys{startLayer}=[viapolys{startLayer}];
            end
        end

        for i=1:numFeeds
            startLayer=obj.modifiedFeedLocations(i,3);
            if~isempty(obj.ViaLocations)
                feedViaXY=find(obj.modifiedFeedLocations(i,1)==obj.modifiedViaLocations(:,1)&...
                obj.modifiedFeedLocations(i,2)==obj.modifiedViaLocations(:,2));
                layerid3=any(obj.modifiedFeedLocations(i,3)==obj.modifiedViaLocations(feedViaXY,3:4));
                if numel(obj.modifiedFeedLocations(i,:))>3
                    layerid4=any(obj.modifiedFeedLocations(i,4)==obj.modifiedViaLocations(feedViaXY,3:4));
                else
                    layerid4=false;
                end
                if layerid3
                    commonlayerid=obj.modifiedFeedLocations(i,3);
                elseif layerid4
                    commonlayerid=obj.modifiedFeedLocations(i,4);
                end
            else
                feedViaXY=[];
            end
            Wf=cylinder2strip(obj.FeedDiameter/2);
            if obj.IsRefiningPolygon



                if~isempty(feedViaXY)
                    f=viapolys{commonlayerid}{feedViaXY};
                else
                    f=obj.pickRefiningPolygon(Wf,tempMetalLayers{startLayer},obj.modifiedFeedLocations(i,1:2));
                end
                if~isEdgeFed

                    featureOnStartLayer=tempMetalLayers{startLayer}-f;
                    isOverLap=isEdgeOverlapOnBoundaryPoints(featureOnStartLayer);
                    tf=applyRefiningPolygon(obj,tempMetalLayers{startLayer},i,Wf,'feed');
                    if~isOverLap&&tf
                        tempHoleOnStartLayer=[tempMetalLayers{startLayer}.FeaturePolygons,{f}];
                        tempMetalLayers{startLayer}=featureOnStartLayer;
                        setFeaturePolygons(tempMetalLayers{startLayer},tempHoleOnStartLayer);
                    end
                    if isProbeFed
                        stopLayer=obj.modifiedFeedLocations(i,4);

                        featureOnStopLayer=tempMetalLayers{stopLayer}-f;
                        isOverLap=isEdgeOverlapOnBoundaryPoints(featureOnStopLayer);
                        tf=applyRefiningPolygon(obj,tempMetalLayers{stopLayer},i,Wf,'feed');
                        if~isOverLap&&tf
                            tempHoleOnStopLayer=[tempMetalLayers{stopLayer}.FeaturePolygons,{f}];
                            tempMetalLayers{stopLayer}=featureOnStopLayer;
                            setFeaturePolygons(tempMetalLayers{stopLayer},tempHoleOnStopLayer);
                        end
                        saveGroundConnection(obj.MetalLayers{stopLayer},{f.ShapeVertices'},2);
                        gndLayers=[gndLayers,stopLayer];
                        viapolys{stopLayer}=[viapolys{stopLayer},{f}];
                    end
                else














                    if~isa(obj.BoardShape,'antenna.Rectangle')&&isDielectricSubstrate(obj)
                        f=alignRefiningPolyWithBoardEdge(obj,f,obj.modifiedFeedLocations(i,1:2));
                    end


                    featureOnStartLayerM=tempMetalLayers{startLayer}-f;
                    featureOnStartLayerP=tempMetalLayers{startLayer}+f;
                    if~hasFeatureVerticesOnLayer(featureOnStartLayerM,f)


                        if~isempty(tempMetalLayers{startLayer}.FeaturePolygons)
                            tempFeatureOnStartLayer=tempMetalLayers{startLayer}.FeaturePolygons;
                        else
                            tempFeatureOnStartLayer=[];
                        end
                        tempMetalLayers{startLayer}=featureOnStartLayerP;
                        setFeaturePolygons(tempMetalLayers{startLayer},tempFeatureOnStartLayer);
                    else
                        tempHoleOnStartLayer=[tempMetalLayers{startLayer}.FeaturePolygons,{f}];
                        tempMetalLayers{startLayer}=featureOnStartLayerM;
                        setFeaturePolygons(tempMetalLayers{startLayer},tempHoleOnStartLayer);
                    end
                    if isProbeFed
                        stopLayer=obj.modifiedFeedLocations(i,4);

                        featureOnStopLayerM=tempMetalLayers{stopLayer}-f;
                        featureOnStopLayerP=tempMetalLayers{stopLayer}+f;
                        if~hasFeatureVerticesOnLayer(featureOnStopLayerM,f)


                            if~isempty(tempMetalLayers{stopLayer}.FeaturePolygons)
                                tempFeatureOnStopLayer=tempMetalLayers{stopLayer}.FeaturePolygons;
                            else
                                tempFeatureOnStopLayer=[];
                            end
                            tempMetalLayers{stopLayer}=featureOnStopLayerP;
                            setFeaturePolygons(tempMetalLayers{stopLayer},tempFeatureOnStopLayer);
                        else
                            tempHoleOnStopLayer=[tempMetalLayers{stopLayer}.FeaturePolygons,{f}];
                            tempMetalLayers{stopLayer}=featureOnStopLayerM;
                            setFeaturePolygons(tempMetalLayers{stopLayer},tempHoleOnStopLayer);
                        end
                        saveGroundConnection(obj.MetalLayers{stopLayer},{f.ShapeVertices'},2);
                        gndLayers=[gndLayers,stopLayer];
                        viapolys{stopLayer}=[viapolys{stopLayer},{f}];
                    end
                end
                viapolys{startLayer}=[viapolys{startLayer},{f}];
            else
                if isProbeFed
                    stopLayer=obj.modifiedFeedLocations(i,4);
                    tempMetalLayers{stopLayer}=tempMetalLayers{stopLayer};
                    gndLayers=[gndLayers,stopLayer];
                end
                viapolys{startLayer}=[viapolys{startLayer}];
            end
        end

    else

        for i=1:numVias
            startLayer=obj.modifiedViaLocations(i,3);
            stopLayer=obj.modifiedViaLocations(i,4);
            Wv=(obj.ViaDiameter/2);


            if~isEdgeVia(i)
                f=antenna.Shape.refiningpolygon(Wv,obj.modifiedViaLocations(i,1:2),[],'Poly',obj.NumFeedViaModelSides);
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
                    f=obj.pickRefiningPolygon(Wf,tempMetalLayers{startLayer},obj.modifiedFeedLocations(i,1:2));
                    tempMetalLayers{startLayer}=tempMetalLayers{startLayer}+f;
                    tempMetalLayers{stopLayer}=tempMetalLayers{stopLayer}+f;
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
            viapolys{startLayer}=[viapolys{startLayer},{f}];
        end

    end
