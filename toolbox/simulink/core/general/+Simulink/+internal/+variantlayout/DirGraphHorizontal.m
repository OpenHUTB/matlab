classdef(Hidden)DirGraphHorizontal<Simulink.internal.variantlayout.DirGraph


















    properties
    end

    methods

        function obj=DirGraphHorizontal(mdlName,blkPaths,annotations)


            if nargin==1



                allBlocks=find_system(mdlName,'SearchDepth','1','LookUnderMasks','on',...
                'MatchFilter',@Simulink.match.allVariants,'IncludeCommented','on');


                if numel(allBlocks)>1
                    blkPaths=allBlocks(2:end);
                else
                    blkPaths={};
                end
                annotations=find_system(mdlName,'SearchDepth','1',...
                'FindAll','on','Type','annotation');
            end

            obj@Simulink.internal.variantlayout.DirGraph(mdlName,blkPaths,annotations,1);
        end


        function createDeltas(obj,LayerId,layerIdref)

            delta_prev=0;



            refNodeIsRightOfCurNode=(LayerId<layerIdref);

            for nodeId=1:numel(obj.Layers(LayerId).Nodes)


                if(obj.Layers(LayerId).Nodes(nodeId).Indegree==0)&&(obj.Layers(LayerId).Nodes(nodeId).Outdegree==0)
                    obj.Layers(LayerId).Nodes(nodeId).Deltav=delta_prev;
                else

                    if refNodeIsRightOfCurNode

                        tmpPorts=obj.Layers(LayerId).Nodes(nodeId).OutPorts;
                    else

                        tmpPorts=obj.Layers(LayerId).Nodes(nodeId).InPorts;
                    end

                    if isempty(tmpPorts)


                        obj.Layers(LayerId).Nodes(nodeId).Deltav=delta_prev;

                    else
                        tmpDelta=delta_prev;
                        balancePlaceNumber=0;
                        for portId=1:numel(tmpPorts)

                            if refNodeIsRightOfCurNode
                                tmpEqual=obj.AdjacencyListPorts(:,1)==tmpPorts(portId).PortHandle;



                                if~any(tmpEqual)
                                    continue
                                end
                                tmp2PortHandle=obj.AdjacencyListPorts(tmpEqual,2);
                                layertmp2=LayerId+1;
                            else
                                tmpEqual=obj.AdjacencyListPorts(:,2)==tmpPorts(portId).PortHandle;
                                if~any(tmpEqual)
                                    continue
                                end
                                tmp2PortHandle=obj.AdjacencyListPorts(tmpEqual,1);
                                layertmp2=LayerId-1;
                            end







                            posV=tmpPorts(portId).PortPosition;


                            balancePlacetmp2Port=0;
                            for tmp2PortId=1:numel(tmp2PortHandle)


                                [tmp2Port,UnodeObj]=obj.findPortobj(tmp2PortHandle(tmp2PortId),layertmp2);


                                if(tmp2Port==-1)||(UnodeObj==-1)
                                    continue;
                                end
                                posU=tmp2Port.PortPosition;











                                if(tmp2Port.PortOrientation==Simulink.internal.variantlayout.Direction.LEFT)
                                    tmpDelta=tmpDelta+posU(2)+UnodeObj.Deltav-(posV(2)+delta_prev);
                                    balancePlacetmp2Port=balancePlacetmp2Port+1;

















                                end






                                if(tmp2Port.PortOrientation==Simulink.internal.variantlayout.Direction.DOWN)




                                    if refNodeIsRightOfCurNode
                                        tmpDelta=tmpDelta+posU(2)+UnodeObj.Deltav-(posV(2)+delta_prev)-20;
                                    else
                                        tmpDelta=tmpDelta+posU(2)+UnodeObj.Deltav-(posV(2)+delta_prev)+20;
                                    end
                                    balancePlacetmp2Port=balancePlacetmp2Port+1;

                                end






                                if(tmp2Port.PortOrientation==Simulink.internal.variantlayout.Direction.UP)







                                end







                                if(tmp2Port.PortOrientation==Simulink.internal.variantlayout.Direction.RIGHT)




                                end
                            end

                            if balancePlacetmp2Port~=0
                                tmpDelta=tmpDelta/balancePlacetmp2Port;




                                if tmpPorts(portId).PortOrientation==Simulink.internal.variantlayout.Direction.LEFT
                                    balancePlaceNumber=balancePlaceNumber+1;
                                else
                                    tmpDelta=0;
                                end
                            end
                        end

                        balancePlaceNumber=max(1,balancePlaceNumber);
                        delta_prev=tmpDelta/balancePlaceNumber;

                        obj.Layers(LayerId).Nodes(nodeId).Deltav=delta_prev;
                    end
                end
            end
        end


        function createDeltasfeedback(obj,LayerId,layerIdref)

            delta_prev=0;

            for nodeId=1:numel(obj.Layers(LayerId).Nodes)


                if(obj.Layers(LayerId).Nodes(nodeId).Indegree==0)&&(obj.Layers(LayerId).Nodes(nodeId).Outdegree==0)
                    obj.Layers(LayerId).Nodes(nodeId).Deltav=delta_prev;
                else


                    refNodeIsRightOfCurNode=(LayerId<layerIdref);
                    if refNodeIsRightOfCurNode

                        tmpPorts=obj.Layers(LayerId).Nodes(nodeId).InPorts;
                    else

                        tmpPorts=obj.Layers(LayerId).Nodes(nodeId).OutPorts;
                    end

                    if isempty(tmpPorts)


                        obj.Layers(LayerId).Nodes(nodeId).Deltav=delta_prev;
                    else
                        tmpDelta=delta_prev;
                        balancePlaceNumber=0;
                        for portId=1:numel(tmpPorts)

                            if refNodeIsRightOfCurNode
                                tmpEqual=obj.AdjacencyListPorts(:,2)==tmpPorts(portId).PortHandle;



                                if~any(tmpEqual)
                                    continue
                                end
                                tmp2PortHandle=obj.AdjacencyListPorts(tmpEqual,1);
                                layertmp2=LayerId+1;
                            else
                                tmpEqual=obj.AdjacencyListPorts(:,1)==tmpPorts(portId).PortHandle;

                                if~any(tmpEqual)
                                    continue
                                end
                                tmp2PortHandle=obj.AdjacencyListPorts(tmpEqual,2);
                                layertmp2=LayerId-1;
                            end








                            posV=tmpPorts(portId).PortPosition;
                            balancePlacetmp2Port=0;
                            for tmp2PortId=1:numel(tmp2PortHandle)


                                [tmp2Port,UnodeObj]=obj.findPortobj(tmp2PortHandle(tmp2PortId),layertmp2);

                                if(tmp2Port==-1)||(UnodeObj==-1)
                                    continue;
                                end
                                posU=tmp2Port.PortPosition;




                                if(tmp2Port.PortOrientation==Simulink.internal.variantlayout.Direction.RIGHT)
                                    tmpDelta=tmpDelta+posU(2)+UnodeObj.Deltav-(posV(2)+delta_prev);
                                    balancePlacetmp2Port=balancePlacetmp2Port+1;

















                                end







                                if(tmp2Port.PortOrientation==Simulink.internal.variantlayout.Direction.DOWN)

                                    if refNodeIsRightOfCurNode
                                        tmpDelta=tmpDelta+posU(2)+UnodeObj.Deltav-(posV(2)+delta_prev)-20;
                                    else
                                        tmpDelta=tmpDelta+posU(2)+UnodeObj.Deltav-(posV(2)+delta_prev)+20;
                                    end
                                    balancePlacetmp2Port=balancePlacetmp2Port+1;
                                end






                                if(tmp2Port.PortOrientation==Simulink.internal.variantlayout.Direction.UP)







                                end






                                if(tmp2Port.PortOrientation==Simulink.internal.variantlayout.Direction.LEFT)



                                end

                            end

                            if balancePlacetmp2Port~=0
                                tmpDelta=tmpDelta/balancePlacetmp2Port;

                                if tmpPorts(portId).PortOrientation==Simulink.internal.variantlayout.Direction.RIGHT
                                    balancePlaceNumber=balancePlaceNumber+1;
                                else
                                    tmpDelta=0;
                                end
                            end
                        end

                        balancePlaceNumber=max(1,balancePlaceNumber);
                        delta_prev=tmpDelta/balancePlaceNumber;

                        obj.Layers(LayerId).Nodes(nodeId).Deltav=delta_prev;
                    end
                end
            end
        end


        function placeLayers(obj)
            for layerId=2:numel(obj.Layers)
                desiredPosition=obj.Layers(layerId-1).LayerWidthMax+obj.Margin;
                currentPosition=obj.Layers(layerId).LayerPosition;
                deltaX=desiredPosition-currentPosition(1);
                obj.Layers(layerId).LayerPosition=[desiredPosition,currentPosition(2)];
                obj.Layers(layerId).LayerWidthMax=obj.Layers(layerId).LayerWidthMax+deltaX;

                for nodeId=1:numel(obj.Layers(layerId).Nodes)

                    tmpPos=obj.Layers(layerId).Nodes(nodeId).Position;
                    newXPos=tmpPos(1)+deltaX;

                    posOld=get(obj.Layers(layerId).Nodes(nodeId).NodeHandle,'Position');
                    posNew=[newXPos,posOld(2),posOld(3)+deltaX,posOld(4)];
                    try
                        set(obj.Layers(layerId).Nodes(nodeId).NodeHandle,'Position',posNew);
                        obj.Layers(layerId).Nodes(nodeId).Position=[newXPos,posOld(2)];
                    catch ex
                        if obj.DebugFlag
                            fprintf(['Node: ',obj.Layers(layerId).Nodes(nodeId).NodeName,' \n']);
                            fprintf('DeltaX = %d \n',deltaX);
                            disp(ex.message);
                        end
                    end



                    for inportId=1:numel(obj.Layers(layerId).Nodes(nodeId).InPorts)
                        tmpPortHandle=obj.Layers(layerId).Nodes(nodeId).InPorts(inportId).PortHandle;
                        newPortPos=get(tmpPortHandle,'Position');
                        obj.Layers(layerId).Nodes(nodeId).InPorts(inportId).PortPosition=newPortPos;
                    end

                    for outportId=1:numel(obj.Layers(layerId).Nodes(nodeId).OutPorts)
                        tmpPortHandle=obj.Layers(layerId).Nodes(nodeId).OutPorts(outportId).PortHandle;
                        newPortPos=get(tmpPortHandle,'Position');
                        obj.Layers(layerId).Nodes(nodeId).OutPorts(outportId).PortPosition=newPortPos;
                    end
                end
            end
        end


        function autoLayoutPlace(obj)
            if~isempty(obj.Nodes)
                obj.labelNodes;
                obj.sortNodes;
                obj.layerAssignment;
                obj.sizeLayers;
                obj.assignMaxLayerWidth;
                obj.placeLayers;
            end
        end


        function autoLayoutWithoutPlace(obj,isHorizontallyPlaced,hasRight,hasLeft)

            if nargin==2
                hasLeft=true;
                hasRight=true;
            end
            if~isempty(obj.Nodes)
                obj.labelNodes;
                obj.sortNodes;
                obj.layerAssignment;
                obj.sizeLayers;
                obj.assignMaxLayerWidth;
                obj.addDummyNodes;
                for nodeOrdering=0:1
                    obj.orderNodes(nodeOrdering);
                    if hasRight
                        obj.dobalancedPlacementForward(isHorizontallyPlaced,nodeOrdering);
                        obj.setNodePositions;
                    end
                    if hasLeft
                        obj.dobalancedPlacementFeedback(isHorizontallyPlaced,nodeOrdering);
                        obj.setNodePositions;
                    end
                end
                obj.reRoute;
            end
        end


        function autoLayoutWithPlace(obj,hasRight,hasLeft)

            if nargin==1
                hasLeft=true;
                hasRight=true;
            end
            if~isempty(obj.Nodes)
                obj.labelNodes;
                obj.sortNodes;
                obj.layerAssignment;
                obj.sizeLayers;
                obj.assignMaxLayerWidth;
                obj.placeLayers;
                obj.addDummyNodes;
                for nodeOrdering=0:1
                    obj.orderNodes(nodeOrdering);
                    if hasRight
                        obj.dobalancedPlacementForward(1,nodeOrdering);
                        obj.setNodePositions;
                    end
                    if hasLeft
                        obj.dobalancedPlacementFeedback(1,nodeOrdering);
                        obj.setNodePositions;
                    end
                end
                obj.reRoute;
            end
        end

    end
end



