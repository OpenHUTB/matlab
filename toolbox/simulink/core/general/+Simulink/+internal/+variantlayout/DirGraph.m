classdef(Hidden)DirGraph<handle


















    properties

        Nodes(1,:)Simulink.internal.variantlayout.Node;


        Edges(1,:)Simulink.internal.variantlayout.Edge;



        AdjacencyListPorts(:,2)double;




        Layers(1,:)Simulink.internal.variantlayout.Layer;


        SysName(1,:)char;




        HierarchyIdx(1,1)Simulink.internal.variantlayout.Hierarchy=...
        Simulink.internal.variantlayout.Hierarchy.HORIZONTAL;


        Areas(1,:)Simulink.internal.variantlayout.AnnotationArea;
    end

    properties(Hidden,Access=protected)



        Margin(1,1)double=50;


        DebugFlag(1,1)logical=false;
    end

    methods









        function obj=DirGraph(sys,blkPaths,annotations,hierarchyidx)
            if nargin>0



                n=length(blkPaths);






                listIndex=1;


                if~isempty(blkPaths)
                    obj.Nodes(1,n)=Simulink.internal.variantlayout.Node;
                end

                for nodeIdx=1:n
                    obj.Nodes(nodeIdx)=Simulink.internal.variantlayout.Node(blkPaths{nodeIdx},nodeIdx);





                    outPorts=obj.Nodes(nodeIdx).OutPorts;


                    pConnStructvec=get_param(blkPaths{nodeIdx},'PortConnectivity');

                    portHandles=get_param(blkPaths{nodeIdx},'PortHandles');


                    portConnidSum=numel(portHandles.Inport)+numel(portHandles.Enable)...
                    +numel(portHandles.Trigger)+numel(portHandles.Ifaction)...
                    +numel(portHandles.Reset)+numel(portHandles.Outport)+...
                    numel(portHandles.State);

                    for portIdx=1:numel(outPorts)


                        if~strcmp(outPorts(portIdx).PortType,'connection')
                            tmpLh=get(outPorts(portIdx).PortHandle,'Line');


                            if(tmpLh==-1)
                                continue;
                            end

                            tmpDstports=get(tmpLh,'DstPortHandle');

                        else






                            if outPorts(portIdx).PortSide==Simulink.internal.variantlayout.Direction.LEFT

                                portConnidx=portConnidSum+outPorts(portIdx).PortNumber;
                            else

                                portConnidx=portConnidSum+numel(portHandles.LConn)...
                                +outPorts(portIdx).PortNumber;
                            end
                            tmpDstports=pConnStructvec(portConnidx).DstPort;
                        end

                        tmpDstports=Simulink.variant.utils.i_cell2mat(tmpDstports);

                        for dstportid=1:numel(tmpDstports)



                            if outPorts(portIdx).PortHandle==tmpDstports(dstportid)
                                continue
                            end


                            if tmpDstports(dstportid)==-1
                                continue
                            end

                            obj.AdjacencyListPorts(listIndex,1)=outPorts(portIdx).PortHandle;
                            obj.AdjacencyListPorts(listIndex,2)=tmpDstports(dstportid);
                            listIndex=listIndex+1;
                        end
                    end
                end

                adjacencyListNew=obj.AdjacencyListPorts;



                numEdges=size(adjacencyListNew,1);
                edgIdx=1;


                if numEdges~=0
                    obj.Edges(1,numEdges)=Simulink.internal.variantlayout.Edge;
                end



                for itPorts=1:numEdges
                    srcportHandle=adjacencyListNew(itPorts,1);
                    dstportHandle=adjacencyListNew(itPorts,2);
                    srcportobj=Simulink.internal.variantlayout.Port(srcportHandle);
                    dstportobj=Simulink.internal.variantlayout.Port(dstportHandle);
                    obj.Edges(edgIdx)=Simulink.internal.variantlayout.Edge(srcportobj,dstportobj);
                    edgIdx=edgIdx+1;
                end

                obj.SysName=sys;
                obj.HierarchyIdx=hierarchyidx;



                areaId=1;
                noteId=1;
                for anotId=1:numel(annotations)
                    annotationObject=get(annotations(anotId),'Object');
                    if strcmp(annotationObject.AnnotationType,'area_annotation')
                        obj.Areas(areaId)=...
                        Simulink.internal.variantlayout.AnnotationArea(annotationObject,blkPaths);
                        areaId=areaId+1;
                    else
                        obj.Nodes(n+noteId)=...
                        Simulink.internal.variantlayout.Node(annotations(anotId));
                        noteId=noteId+1;
                    end
                end
            end
        end


        function nodeObj=findNode(obj,blk_handle)
            for nodeIdx=1:numel(obj.Nodes)
                if(obj.Nodes(nodeIdx).NodeHandle==blk_handle)
                    nodeObj=obj.Nodes(nodeIdx);
                    return;
                end
            end
        end


        function labelNodes(obj)
            positionLabel=zeros(numel(obj.Nodes),1);
            for nodeIdx1=1:numel(obj.Nodes)
                pos=obj.Nodes(nodeIdx1).Position;
                positionLabel(nodeIdx1)=pos(obj.HierarchyIdx);
            end
            [~,indexSorted]=sort(positionLabel);
            for nodeIdx2=1:numel(obj.Nodes)
                obj.Nodes(indexSorted(nodeIdx2)).NodeLabel=nodeIdx2;
            end
        end


        function sortNodes(obj)
            nodeLabels=[obj.Nodes.NodeLabel];
            [~,indexSorted]=sort(nodeLabels);
            tmpNodes=obj.Nodes(indexSorted);
            obj.Nodes=tmpNodes;
        end


        function displayNodes(obj)
            for nodeIdx=1:numel(obj.Nodes)
                fprintf([obj.Nodes(nodeIdx).NodeName,...
                ' \t ','%d',' \t','%d','\n'],...
                obj.Nodes(nodeIdx).NodeLabel,obj.Nodes(nodeIdx).NodeLayer);
            end
        end


        function displayPorts(obj)
            for nodeIdx=1:numel(obj.Nodes)
                fprintf([obj.Nodes(nodeIdx).NodeName,' \n']);
                fprintf('PortNumber \t PortHandle \t  PortType \t PortRotation \n');

                for inp=1:obj.Nodes(nodeIdx).Indegree
                    fprintf('%d \t \t',obj.Nodes(nodeIdx).InPorts(inp).PortNumber);
                    fprintf('%f \t',obj.Nodes(nodeIdx).InPorts(inp).PortHandle);
                    fprintf([obj.Nodes(nodeIdx).InPorts(inp).PortType,' \t']);
                    disp(obj.Nodes(nodeIdx).InPorts(inp).PortOrientation);
                    fprintf('\n');
                end

                for outp=1:obj.Nodes(nodeIdx).Outdegree
                    fprintf('%d \t \t',obj.Nodes(nodeIdx).OutPorts(outp).PortNumber);
                    fprintf('%f \t',obj.Nodes(nodeIdx).OutPorts(outp).PortHandle);
                    fprintf([obj.Nodes(nodeIdx).OutPorts(outp).PortType,' \t']);
                    disp(obj.Nodes(nodeIdx).OutPorts(outp).PortOrientation);
                    fprintf('\n');
                end

                fprintf('----------------------------------- \n');
            end
        end


        function Layer=findLayer(obj,blkPath)
            nodeHandle=get_param(blkPath,'Handle');
            nodeobj=obj.findNode(nodeHandle);
            Layer=nodeobj.NodeLayer;
        end


        function layerAssignment(obj)
            layerId=1;
            obj.Layers(1)=Simulink.internal.variantlayout.Layer(layerId,obj.Nodes(1).Position);
            obj.Nodes(1).NodeLayer=layerId;
            obj.Layers(1).appendNode(obj.Nodes(1));
            pos1Size=obj.Nodes(1).Size;
            pos1=obj.Nodes(1).Position;


            obj.Layers(1).LayerWidthMin=pos1(obj.HierarchyIdx)+pos1Size(obj.HierarchyIdx);


            for nodeId=1:numel(obj.Nodes)-1

                pos1=obj.Nodes(nodeId).Position;

                pos2=obj.Nodes(nodeId+1).Position;
                pos2Size=obj.Nodes(nodeId+1).Size;



                obj.Layers(layerId).LayerWidthMin=min(obj.Layers(layerId).LayerWidthMin,...
                pos2(obj.HierarchyIdx)+pos2Size(obj.HierarchyIdx));


                if(pos1(obj.HierarchyIdx)<=pos2(obj.HierarchyIdx))&&...
                    (pos2(obj.HierarchyIdx)<=obj.Layers(layerId).LayerWidthMin)
                    obj.Layers(layerId).appendNode(obj.Nodes(nodeId+1));
                    obj.Nodes(nodeId+1).NodeLayer=layerId;
                else
                    layerId=layerId+1;
                    obj.Layers(layerId)=Simulink.internal.variantlayout.Layer(layerId,obj.Nodes(nodeId+1).Position);
                    obj.Layers(layerId).appendNode(obj.Nodes(nodeId+1));



                    obj.Layers(layerId).LayerWidthMin=pos2(obj.HierarchyIdx)+pos2Size(obj.HierarchyIdx);
                    obj.Nodes(nodeId+1).NodeLayer=layerId;
                end
            end
        end


        function assignMaxLayerWidth(obj)
            for layerId=1:numel(obj.Layers)
                for nodeId=1:numel(obj.Layers(layerId).Nodes)
                    size=obj.Layers(layerId).Nodes(nodeId).Size;
                    pos=obj.Layers(layerId).Nodes(nodeId).Position;
                    obj.Layers(layerId).LayerWidthMax=max(obj.Layers(layerId).LayerWidthMax,...
                    size(obj.HierarchyIdx)+pos(obj.HierarchyIdx));
                end
            end
        end


        function LayerIdref=findReferenceLayer(obj)
            layersize=zeros(numel(obj.Layers),1);
            for LayerIdx=1:numel(obj.Layers)
                layersize(LayerIdx)=obj.Layers(LayerIdx).LayerSize;
            end
            [~,LayerIdref]=max(layersize);
        end




        function addDummyNodes(obj)
            allEdges=obj.Edges;
            layerIdRef=findReferenceLayer(obj);

            for edgId=1:numel(allEdges)
                srcNode=allEdges(edgId).SourceBlock;
                dstNode=allEdges(edgId).DstBlock;

                srcPort=allEdges(edgId).SourcePort;
                dstPort=allEdges(edgId).DstPort;

                srcLayer=obj.findLayer(srcNode);
                dstLayer=obj.findLayer(dstNode);


                dumNodenum=1;
                if(dstLayer>srcLayer)
                    while(dstLayer-srcLayer>1)
                        layerId=srcLayer+1;
                        isForward=true;
                        addDummyHere(isForward);
                    end
                else
                    while(srcLayer-dstLayer>1)
                        layerId=srcLayer-1;
                        isForward=false;
                        addDummyHere(isForward);
                    end
                end
            end

            function addDummyHere(isForward)

                posFactor=0.999;
                if isForward

                    if layerId>layerIdRef






                        if((srcPort.PortOrientation==Simulink.internal.variantlayout.Direction.LEFT)&&...
                            (dstPort.PortOrientation==Simulink.internal.variantlayout.Direction.LEFT))||...
                            ((srcPort.PortOrientation==Simulink.internal.variantlayout.Direction.DOWN)&&...
                            (dstPort.PortOrientation==Simulink.internal.variantlayout.Direction.DOWN))
                            posFactor=1-posFactor;
                        end
                    end
                else

                    if layerId<layerIdRef
                        if((srcPort.PortOrientation==Simulink.internal.variantlayout.Direction.RIGHT)&&...
                            (dstPort.PortOrientation==Simulink.internal.variantlayout.Direction.RIGHT))||...
                            ((srcPort.PortOrientation==Simulink.internal.variantlayout.Direction.UP)&&...
                            (dstPort.PortOrientation==Simulink.internal.variantlayout.Direction.UP))
                            posFactor=1-posFactor;
                        end
                    end
                end


                obj.Layers(layerId).appendDummyNode(dumNodenum,srcPort,srcNode,dstPort,obj.HierarchyIdx,posFactor);


                tmpIdx=(obj.AdjacencyListPorts(:,1)==srcPort.PortHandle);
                if sum(tmpIdx)>1

                    tmpIdx=tmpIdx&(obj.AdjacencyListPorts(:,2)==dstPort.PortHandle);
                end


                tmpPortHandle=obj.AdjacencyListPorts(tmpIdx,2);


                dummyHandleDst=max(obj.AdjacencyListPorts(:))+1;


                obj.Layers(layerId).Nodes(end).InPorts(1).PortHandle=dummyHandleDst;


                obj.AdjacencyListPorts(tmpIdx,2)=dummyHandleDst;


                dummyHandleSrc=dummyHandleDst+1;
                obj.Layers(layerId).Nodes(end).OutPorts(1).PortHandle=dummyHandleSrc;


                obj.AdjacencyListPorts(end+1,1)=dummyHandleSrc;


                obj.AdjacencyListPorts(end,2)=tmpPortHandle;

                dumNodenum=dumNodenum+1;
                srcLayer=layerId;

                srcPort=obj.Layers(layerId).Nodes(end).OutPorts(1);

            end
        end


        function orderNodes(obj,way)


            for LayerId=1:numel(obj.Layers)

                nodes=obj.Layers(LayerId).Nodes;
                pos_t=zeros(numel(nodes),1);
                for nodeId=1:numel(nodes)
                    position=nodes(nodeId).Position+(nodes(nodeId).Size)/2;
                    tidx=mod(obj.HierarchyIdx,2)+1;

                    pos_t(nodeId)=position(tidx);
                end
                if~way
                    [~,index_sorted]=sort(pos_t);
                else
                    [~,index_sorted]=sort(pos_t,'descend');
                end
                for nodeIdy=1:numel(nodes)

                    nodes(index_sorted(nodeIdy)).NodeRank=nodeIdy;
                    obj.Layers(LayerId).Nodes(nodeIdy)=nodes(index_sorted(nodeIdy));
                end
            end
        end


        function sizeLayers(obj)
            for LayerId=1:numel(obj.Layers)
                nodes=obj.Layers(LayerId).Nodes;
                size=0;

                for nodeId=1:numel(nodes)



                    if(obj.Layers(LayerId).Nodes(nodeId).Indegree==0)&&(obj.Layers(LayerId).Nodes(nodeId).Outdegree==0)
                        continue
                    end
                    size_tmp=nodes(nodeId).Size;
                    tidx=mod(obj.HierarchyIdx,2)+1;
                    size=size+size_tmp(tidx);
                end

                obj.Layers(LayerId).LayerSize=size;
            end
        end


        function displayLayers(obj,layerId)
            if nargin==1
                for layerId=1:numel(obj.Layers)
                    printLayer(layerId);
                end
            else
                printLayer(layerId);
            end

            function printLayer(layerIdx)
                fprintf(['Layer ','%d',':',' \n'],obj.Layers(layerIdx).LayerID);
                fprintf(['Layer Size ','=','%d','\n'],obj.Layers(layerIdx).LayerSize);
                fprintf(['Max Layer Width ','=','%d','\n'],obj.Layers(layerIdx).LayerWidthMax);
                fprintf(['Layer Position ','=','%d  %d','\n'],obj.Layers(layerIdx).LayerPosition);
                fprintf(['Node Size ','\t','  Node rank','\t','    Deltav','\n',]);
                nodes=obj.Layers(layerIdx).Nodes;
                for nodeId=1:numel(nodes)
                    fprintf(nodes(nodeId).NodeName);
                    fprintf(' \n');
                    fprintf(['%d',' \t'],nodes(nodeId).Size);
                    fprintf(' \t');
                    fprintf(['%d',' \t'],nodes(nodeId).NodeRank);
                    fprintf(' \t');
                    fprintf(['%d',' \t'],nodes(nodeId).Deltav);
                    fprintf(' \n');
                end
                fprintf('-------------------------------------- \n');
            end
        end



        function deltasvec=findDeltavec(obj,layerId)
            deltasvec=zeros(numel(obj.Layers(layerId).Nodes));
            for nodeId=1:numel(obj.Layers(layerId).Nodes)
                deltasvec(nodeId)=obj.Layers(layerId).Nodes(nodeId).Deltav;
            end
        end



        function dobalancedPlacementForward(obj,isHorizontalPlacement,rankType)



            LayerIdref=obj.findReferenceLayer;


            for nodeRefId=1:numel(obj.Layers(LayerIdref).Nodes)
                obj.Layers(LayerIdref).Nodes(nodeRefId).Deltav=0;
            end

            for LayerIdRight=LayerIdref+1:numel(obj.Layers)
                obj.createDeltas(LayerIdRight,LayerIdref);















                obj.validateDelta(LayerIdRight,isHorizontalPlacement,rankType);
            end


            for LayerIdLeft=LayerIdref-1:-1:1
                obj.createDeltas(LayerIdLeft,LayerIdref);
                obj.validateDelta(LayerIdLeft,isHorizontalPlacement,rankType);
            end
        end

        function dobalancedPlacementFeedback(obj,isHorizontalPlacement,rankType)

            layersize=zeros(numel(obj.Layers),1);
            for LayerIdx=1:numel(obj.Layers)
                layersize(LayerIdx)=obj.Layers(LayerIdx).LayerSize;
            end
            [~,LayerIdref]=max(layersize);


            for nodeRefId=1:numel(obj.Layers(LayerIdref).Nodes)
                obj.Layers(LayerIdref).Nodes(nodeRefId).Deltav=0;
            end

            for LayerIdRight=LayerIdref+1:numel(obj.Layers)
                obj.createDeltasfeedback(LayerIdRight,LayerIdref);
                obj.validateDelta(LayerIdRight,isHorizontalPlacement,rankType);
            end


            for LayerIdLeft=LayerIdref-1:-1:1
                obj.createDeltasfeedback(LayerIdLeft,LayerIdref);
                obj.validateDelta(LayerIdLeft,isHorizontalPlacement,rankType);
            end

        end



        function[portObj,nodeObj]=findPortobj(obj,PortHandle,LayerId)
            portObj=-1;
            nodeObj=-1;

            for nodeId=1:numel(obj.Layers(LayerId).Nodes)
                InPorts=obj.Layers(LayerId).Nodes(nodeId).InPorts;
                OutPorts=obj.Layers(LayerId).Nodes(nodeId).OutPorts;
                for inportId=1:numel(InPorts)
                    if InPorts(inportId).PortHandle==PortHandle
                        portObj=InPorts(inportId);
                        nodeObj=obj.Layers(LayerId).Nodes(nodeId);
                        return;
                    end
                end

                for outportId=1:numel(OutPorts)
                    if OutPorts(outportId).PortHandle==PortHandle
                        portObj=OutPorts(outportId);
                        nodeObj=obj.Layers(LayerId).Nodes(nodeId);
                        return;
                    end
                end
            end
        end


        function validateDelta(obj,LayerId,isHorizontallyPlaced,rankType)
            tidx=mod(obj.HierarchyIdx,2)+1;

            for nodeId=1:numel(obj.Layers(LayerId).Nodes)-1

                tmpNode=obj.Layers(LayerId).Nodes(nodeId);


                if~isfinite(obj.Layers(LayerId).Nodes(nodeId).Deltav)
                    obj.Layers(LayerId).Nodes(nodeId).Deltav=0;
                end

                if(isHorizontallyPlaced&&tidx==1)



                    if abs(obj.Layers(LayerId).Nodes(nodeId).Deltav)>obj.Margin
                        obj.Layers(LayerId).Nodes(nodeId).Deltav=...
                        sign(obj.Layers(LayerId).Nodes(nodeId).Deltav)*obj.Margin;
                    end
                elseif(~isHorizontallyPlaced&&tidx==2)



                    if abs(obj.Layers(LayerId).Nodes(nodeId).Deltav)>obj.Margin
                        obj.Layers(LayerId).Nodes(nodeId).Deltav=...
                        sign(obj.Layers(LayerId).Nodes(nodeId).Deltav)*obj.Margin;
                    end
                end

                if rankType





















                    modifyDelta(tmpNode,obj.Layers(LayerId).Nodes(nodeId+1));
                else



















                    modifyDelta(obj.Layers(LayerId).Nodes(nodeId+1),tmpNode);
                end
            end

            for nodeId=numel(obj.Layers(LayerId).Nodes):-1:2

                tmpNode=obj.Layers(LayerId).Nodes(nodeId);



                if nodeId==numel(obj.Layers(LayerId).Nodes)

                    if~isfinite(obj.Layers(LayerId).Nodes(nodeId).Deltav)
                        obj.Layers(LayerId).Nodes(nodeId).Deltav=0;
                    end

                    if(isHorizontallyPlaced&&tidx==1)



                        if abs(obj.Layers(LayerId).Nodes(nodeId).Deltav)>obj.Margin
                            obj.Layers(LayerId).Nodes(nodeId).Deltav=...
                            sign(obj.Layers(LayerId).Nodes(nodeId).Deltav)*obj.Margin;
                        end
                    elseif(~isHorizontallyPlaced&&tidx==2)



                        if abs(obj.Layers(LayerId).Nodes(nodeId).Deltav)>obj.Margin
                            obj.Layers(LayerId).Nodes(nodeId).Deltav=...
                            sign(obj.Layers(LayerId).Nodes(nodeId).Deltav)*obj.Margin;
                        end
                    end
                end
                if rankType


















                    modifyDelta(obj.Layers(LayerId).Nodes(nodeId-1),tmpNode)
                else


















                    modifyDelta(tmpNode,obj.Layers(LayerId).Nodes(nodeId-1));
                end
            end




            function modifyDelta(currNode,adjacentNode)
                currNodePos=currNode.Position;
                currNodeDelta=currNode.Deltav;

                adjacentNodePos=adjacentNode.Position;
                adjacentNodeDelta=adjacentNode.Deltav;
                adjacentNodeSize=adjacentNode.Size;
                adjacentNodeMaxPos=adjacentNodePos(tidx)+adjacentNodeSize(tidx);

                loopId=1;




                while(loopId<=2)&&...
                    (round(currNodePos(tidx)+currNodeDelta)<=round(adjacentNodeMaxPos+adjacentNodeDelta))
                    loopId=loopId+1;

                    if adjacentNodeDelta>0
                        adjacentNode.Deltav=0;
                        adjacentNodeDelta=0;
                    else


                        currNode.Deltav=0;
                        currNodeDelta=0;
                    end
                end
            end
        end


        function setNodePositions(obj)
            tidx=mod(obj.HierarchyIdx,2)+1;
            for layId=1:numel(obj.Layers)
                for nodeId=1:numel(obj.Layers(layId).Nodes)
                    deltavec=[0,0];

                    deltavec(tidx)=obj.Layers(layId).Nodes(nodeId).Deltav;

                    if~obj.Layers(layId).Nodes(nodeId).IsDummy

                        oldPos=get(obj.Layers(layId).Nodes(nodeId).NodeHandle,'Position');


                        posNew=oldPos+[deltavec,deltavec];
                        try
                            set(obj.Layers(layId).Nodes(nodeId).NodeHandle,'Position',posNew);
                        catch ex
                            if obj.DebugFlag
                                fprintf(['Node: ',obj.Layers(layId).Nodes(nodeId).NodeName,' \n']);
                                fprintf('DeltaV = %d \n',obj.Nodes(nodeId).Deltav);
                                disp(ex.message);
                            end
                        end

                        obj.Layers(layId).Nodes(nodeId).Position=posNew(1:2);



                        for inportId=1:numel(obj.Layers(layId).Nodes(nodeId).InPorts)
                            tmpPortHandle=obj.Layers(layId).Nodes(nodeId).InPorts(inportId).PortHandle;
                            newPortPos=get(tmpPortHandle,'Position');
                            obj.Layers(layId).Nodes(nodeId).InPorts(inportId).PortPosition=newPortPos;
                        end

                        for outportId=1:numel(obj.Layers(layId).Nodes(nodeId).OutPorts)
                            tmpPortHandle=obj.Layers(layId).Nodes(nodeId).OutPorts(outportId).PortHandle;
                            newPortPos=get(tmpPortHandle,'Position');
                            obj.Layers(layId).Nodes(nodeId).OutPorts(outportId).PortPosition=newPortPos;
                        end
                    else


                        oldPos=obj.Layers(layId).Nodes(nodeId).Position;

                        obj.Layers(layId).Nodes(nodeId).Position=oldPos+deltavec;

                        oldportPos=obj.Layers(layId).Nodes(nodeId).InPorts(1).PortPosition;
                        obj.Layers(layId).Nodes(nodeId).InPorts(1).PortPosition=oldportPos+deltavec;
                        obj.Layers(layId).Nodes(nodeId).OutPorts(1).PortPosition=oldportPos+deltavec;
                    end
                end
            end


            for areaId=1:numel(obj.Areas)
                obj.Areas(areaId).setAreaPosition;
            end
        end


        function reRoute(obj)


            tagMap=containers.Map('KeyType','double','ValueType','any');
            for edgId=1:numel(obj.Edges)
                try
                    lineHandle=get(obj.Edges(edgId).SourcePort.PortHandle,'Line');






                    key=obj.Edges(edgId).SourcePort.PortHandle;
                    if lineHandle==-1
                        continue;
                    end


                    value=get(lineHandle,'Tag');
                    if~isempty(value)
                        tagMap(key)=value;
                    end
                    delete_line(lineHandle);
                catch ex
                    if obj.DebugFlag
                        fprintf('Error deleting line between \n');
                        fprintf(['Source block: ',get(obj.Edges(edgId).SourcePort.PortHandle,'Parent'),...
                        '\t Destination block: ',get(obj.Edges(edgId).DstPort.PortHandle,'Parent'),'\n']);
                        disp(ex.message);
                    end
                end
            end

            for edgId=1:numel(obj.Edges)
                try



                    if~obj.Edges(edgId).SourcePort.getIfConnected(obj.Edges(edgId).DstPort)
                        lineHandle=add_line(obj.SysName,obj.Edges(edgId).SourcePort.PortHandle,...
                        obj.Edges(edgId).DstPort.PortHandle,'autorouting','smart');

                        if isKey(tagMap,obj.Edges(edgId).SourcePort.PortHandle)
                            set(lineHandle,'Tag',tagMap(obj.Edges(edgId).SourcePort.PortHandle));
                        end
                    end
                catch ex
                    if obj.DebugFlag
                        fprintf('Error adding line between \n');
                        fprintf(['Source block: ',get(obj.Edges(edgId).SourcePort.PortHandle,'Parent'),...
                        '\t Destination block: ',get(obj.Edges(edgId).DstPort.PortHandle,'Parent'),'\n']);
                        disp(ex.message);
                    end
                end
            end

        end


        function setDbFlag(obj,dbFlag)
            obj.DebugFlag=dbFlag;
        end

    end

    methods(Abstract)
        placeLayers(obj);
        createDeltas(obj);
        createDeltasfeedback(obj);
        autoLayoutPlace(obj);
        autoLayoutWithoutPlace(obj);
        autoLayoutWithPlace(obj);

    end

end



