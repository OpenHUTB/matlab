classdef Graph<handle

    properties
TargetViewId

Nodes

Edges
StartingNodeIds
StartingEdgeIds
        Constraint slreq.internal.tracediagram.data.Constraint
Filter



GraphType




        ColorId;
ArtifactList
DomainList




LayerInfo
UpstreamMapping
DownstreamMapping
MidstreamMapping








ColorCode
ColorClass
    end

    properties(Access=private)


        FIRST_ARTIFACT_COLOR=204;
        DEFAULT_SATURATION_LEVEL='100%';
        DEFAULT_LIGHTNESS_LEVEL='37%';


VisitedNodes
NodesToBeVisited
        STANDARD_COLOR_LAYER=getStandardColorLayer();
    end

    methods(Abstract)
        node=createNode(this,itemInfo);
        edge=createEdge(this,link);
        out=getStreamDepthOffset(this,link,isTracedFromSrc);
        src=getLinkSource(this,link);
        dst=getLinkDestination(this,link);

    end

    methods
        function this=Graph(targetViewId)
            this.TargetViewId=targetViewId;
            this.reset();
        end

        function reset(this)
            this.Constraint=slreq.internal.tracediagram.data.Constraint;
            this.Nodes=containers.Map('KeyType','char','ValueType','any');
            this.Edges=containers.Map('KeyType','char','ValueType','any');

            this.ColorCode=containers.Map('KeyType','char','ValueType','any');
            this.ColorCode('ArtifactUri')=containers.Map('KeyType','char','ValueType','char');

            this.ColorClass=containers.Map('KeyType','char','ValueType','any');
            this.ColorClass('ArtifactUri')=containers.Map('KeyType','char','ValueType','char');

            [this.ColorCode('Domain'),this.ColorClass('Domain')]=getDomainColorMap();

            this.LayerInfo=containers.Map('KeyType','char','ValueType','any');
            this.VisitedNodes=containers.Map('KeyType','char','ValueType','any');
            this.ArtifactList=containers.Map('KeyType','char','ValueType','logical');
            this.DomainList=containers.Map('KeyType','char','ValueType','any');
        end

        function setStartingNodes(this,nodeList)

            this.StartingNodeIds=unique(this.createNodeList(nodeList),'stable');

            if~iscell(nodeList)
                nodeList=num2cell(nodeList);
            end

            for index=1:length(nodeList)
                this.setRootNodeInfo(nodeList{index});
            end
        end

        function setStartingEdge(this,linkList)

            this.StartingEdgeIds=unique(this.createEdgeList(linkList),'stable');

            for index=1:length(linkList)
                cLink=linkList(index);
                source=this.getLinkSource(cLink);
                this.setRootNodeInfo(source);
                destStruct=this.getLinkDestination(cLink);
                this.setRootNodeInfo(destStruct);
            end
        end

        function setRootNodeInfo(this,itemInfo)
            nodeId=this.createNodeIfNotCreated(itemInfo);
            nodeObj=this.Nodes(nodeId);
            this.setDepthForNode(nodeObj);
        end

        function out=exportToDigraph(this)
            allEdges=this.Edges.values;
            starts=cell(size(allEdges));
            ends=cell(size(allEdges));
            types=cell(size(allEdges));

            allNodeIds={};
            for index=1:length(allEdges)
                cEdge=allEdges{index};
                srcNodeId=cEdge.SourceNodeId;
                allNodeIds{end+1}=srcNodeId;%#ok<AGROW>
                starts{index}=srcNodeId;
                dstNodeId=cEdge.DestinationNodeId;
                ends{index}=dstNodeId;
                allNodeIds{end+1}=dstNodeId;%#ok<AGROW>
                types{index}=cEdge.LinkType;
            end

            allNodeIds=unique(allNodeIds,'stable');

            names=cell(size(allNodeIds));
            streamDepth=cell(size(allNodeIds));
            layerDepth=cell(size(allNodeIds));
            traceDepth=cell(size(allNodeIds));
            streamType=cell(size(allNodeIds));
            labels=cell(size(allNodeIds));
            for index=1:length(allNodeIds)
                cNodeId=allNodeIds{index};
                cNode=this.Nodes(cNodeId);
                names{index}=cNode.Summary;
                streamDepth{index}=cNode.StreamDepth;
                layerDepth{index}=cNode.LayerDepth;
                traceDepth{index}=cNode.TraceDepth;
                streamType{index}=cNode.StreamType;
                labels{index}=sprintf('<%s>S %d L %d T %d:%s',streamType{index},streamDepth{index},layerDepth{index},traceDepth{index},names{index});
            end

            out=digraph(starts,ends);
            out.Nodes.Names=names';
            out.Nodes.SteamDepth=streamDepth';
            out.Nodes.LayerDepth=layerDepth';
            out.Nodes.TraceDepth=traceDepth';
            out.Nodes.StreamTypye=streamType';
            out.Nodes.Labels=labels';
            out.Edges.Types=types';


        end


        function preprocess(this)%#ok<MANU>

        end
        function out=export(this)
            this.preprocess();
            this.traverse();
            this.setArtifactColor();
            out=jsonencode(this);
        end

        function out=createNodeList(this,listOfItemInfo)
            if~iscell(listOfItemInfo)
                listOfItemInfo=num2cell(listOfItemInfo);
            end

            out=cell(size(listOfItemInfo));
            for index=1:length(listOfItemInfo)
                out{index}=this.createNodeIfNotCreated(listOfItemInfo{index});
            end
            out=out';
        end

        function out=createEdgeList(this,listOfLinks)
            if~iscell(listOfLinks)
                listOfLinks=num2cell(listOfLinks);
            end
            out=cell(size(listOfLinks));
            for index=1:length(listOfLinks)
                out{index}=this.createEdgeIfNotCreated(listOfLinks{index});
            end

            out=out';
        end

        function out=isNodeCreated(this,itemInfo)
            itemKey=slreq.internal.tracediagram.data.Node.getNodeKey(itemInfo);
            out=isKey(this.Nodes,itemKey);
        end

        function out=isLinkFiltered(~,~)




            out=false;
        end

        function out=isEdgeCreated(this,dataLink)
            itemKey=slreq.internal.tracediagram.data.Edge.getEdgeKey(dataLink);
            out=isKey(this.Nodes,itemKey);
        end

        function[nodeId,isCreated]=createNodeIfNotCreated(this,itemInfo)
            isCreated=this.isNodeCreated(itemInfo);
            isFiltered=this.isNodeFiltered(itemInfo);
            if isFiltered
                nodeId='';
                return;
            end

            if isCreated
                nodeId=slreq.internal.tracediagram.data.Node.getNodeKey(itemInfo);
            else
                newNode=this.createNode(itemInfo);
                this.Nodes(newNode.Id)=newNode;
                nodeId=newNode.Id;
            end
        end

        function[edgeId,isCreated]=createEdgeIfNotCreated(this,dataLink)
            isCreated=this.isEdgeCreated(dataLink);
            isFiltered=this.isLinkFiltered(dataLink);
            if isFiltered
                edgeId='';
                return;
            end
            if isCreated
                edgeId=slreq.internal.tracediagram.data.Edge.getEdgeKey(dataLink);
            else
                newEdge=this.createEdge(dataLink);
                this.Edges(newEdge.Id)=newEdge;
                edgeId=newEdge.Id;
            end
        end

        function traverse(this)
            this.traverseForLinkableItem();
        end

        function out=getRootNodeIds(this)
            out=this.StartingNodeIds;

            allEdges=this.StartingEdgeIds;
            for index=1:length(allEdges)
                cEdgeId=allEdges{index};
                edgeObj=this.Edges(cEdgeId);
                out{end+1}=edgeObj.SourceNodeId;%#ok<AGROW>
            end

            out=unique(out,'stable');
        end

        function traverseForLinkableItem(this)
            allRootItems=this.getRootNodeIds();
            this.NodesToBeVisited=allRootItems;
            this.VisitedNodes=containers.Map('keytype','char','valuetype','logical');

            while~isempty(this.NodesToBeVisited)
                this.traverseNodes(this.NodesToBeVisited{1});




                this.NodesToBeVisited(1)=[];
            end

        end

        function out=isNodeFiltered(this,nodeId)%#ok<INUSD>

            out=false;
        end

        function out=isNodeVisisted(this,nodeId)
            out=isKey(this.VisitedNodes,nodeId);
        end

        function traverseNodes(this,nodeId)




            if this.isNodeVisisted(nodeId)
                return;
            end

            this.VisitedNodes(nodeId)=true;


            this.refreshEdgesFromNodes(nodeId);

            cNode=this.Nodes(nodeId);

            allOutgoingNodeIds=cNode.getOutgoingNodeIds();
            allIncomingNodeIds=cNode.getIncomingNodeIds();

            this.NodesToBeVisited=[this.NodesToBeVisited,allOutgoingNodeIds,allIncomingNodeIds];
        end

        function refreshEdgesFromNodes(this,nodeId)
            [inLinks,outLinks]=this.getLinksFromId(nodeId);

            nodeObj=this.Nodes(nodeId);
            for index=1:length(outLinks)
                cLink=outLinks(index);
                if this.isLinkFiltered(cLink)
                    continue;
                end

                depthOffset=this.getStreamDepthOffset(cLink,true);


                if~this.Constraint.ShouldGetExpandedGraph&&~this.isSameStreamType(nodeObj,depthOffset)
                    continue;
                end

                this.createEdgeIfNotCreated(cLink);
                cDst=this.getLinkDestination(cLink);

                [dstId,wasCreated]=this.createNodeIfNotCreated(cDst);

                dstNode=this.Nodes(dstId);



                nodeObj.addOutgoingNodeIds(dstId);

                if~wasCreated
                    this.setDepthForNode(dstNode,nodeObj,depthOffset);
                end

            end

            for index=1:length(inLinks)
                cLink=inLinks(index);
                if this.isLinkFiltered(cLink)
                    continue;
                end

                depthOffset=this.getStreamDepthOffset(cLink,false);

                if~this.Constraint.ShouldGetExpandedGraph&&~this.isSameStreamType(nodeObj,depthOffset)
                    continue;
                end

                this.createEdgeIfNotCreated(cLink);
                cSrc=this.getLinkSource(cLink);
                [srcId,wasCreated]=this.createNodeIfNotCreated(cSrc);
                srcNode=this.Nodes(srcId);
                nodeObj.addIncomingNodeIds(srcId)



                if~wasCreated
                    this.setDepthForNode(srcNode,nodeObj,depthOffset);
                end
            end
        end

        function out=isSameStreamType(~,nodeObj,depthOffset)
            out=(nodeObj.StreamType.isUpstream&&depthOffset==1)...
            ||(nodeObj.StreamType.isDownstream&&depthOffset==-1);
        end

        function addNodeToLayer(this,node,layerNumber)
            if isKey(this.LayerInfo,num2str(layerNumber))
                idList=this.LayerInfo(num2str(layerNumber));
            else
                idList={};
            end

            idList{end+1}=node.Id;
            this.LayerInfo(num2str(layerNumber))=idList;
        end


        function setDepthForNode(this,node,sourceNode,depthOffset)
            if nargin==2
                node.setStreamType('Midstream');
                node.setStreamDepth(0);
                node.setLayerDepth(0);
                node.setTraceDepth(0);
                this.addNodeToLayer(node,0);
                return;
            end

            if~node.isStreamDepthSet
                node.setStreamDepth(sourceNode.StreamDepth+depthOffset);
            end

            if~node.isStreamTypeSet
                if sourceNode.StreamType.isUpstream&&depthOffset==1
                    node.setStreamType('Upstream');
                elseif sourceNode.StreamType.isDownstream&&depthOffset==-1
                    node.setStreamType('Downstream');
                end
            end

            if~node.isLayerDepthSet
                node.setLayerDepth(sourceNode.LayerDepth+depthOffset);
                this.addNodeToLayer(node,sourceNode.LayerDepth+depthOffset);
            end

            if~node.isTraceDepthSet
                node.setTraceDepth(sourceNode.TraceDepth+1);


            end

            if~node.isAlreadyTraced
                node.setTraceFrom(sourceNode.Id);
            end
        end


        function out=getStreamType(this,typeName,isTracedFromSrc)
            if isKey(this.Constraint.LinkSourceToStreamTypeMap,typeName)
                kName=typeName;
            else


                kName='Relate';
            end
            out=this.Constraint.LinkSourceToStreamTypeMap(kName);
            if isTracedFromSrc
                out=-out;
            end
        end


        function[inLinks,outLinks]=getLinksFromId(this,nodeId)
            node=this.Nodes(nodeId);
            [inLinks,outLinks]=node.getLinks;
        end



        function setArtifactColor(this)
            artifactColorCodeMap=this.ColorCode('ArtifactUri');
            artifactColorClassMap=this.ColorClass('ArtifactUri');
            allArtifacts=this.ArtifactList.keys;

            colorNum=length(allArtifacts);

            if colorNum<length(this.STANDARD_COLOR_LAYER)
                for index=1:colorNum
                    artifactColorCodeMap(allArtifacts{index})=this.STANDARD_COLOR_LAYER{index};
                    artifactColorClassMap(allArtifacts{index})=sprintf('Color_%d',index);
                end
            else
                hueOffset=floor(360/colorNum);
                startHue=this.FIRST_ARTIFACT_COLOR;
                satNum=this.DEFAULT_SATURATION_LEVEL;
                lightNum=this.DEFAULT_LIGHTNESS_LEVEL;
                for index=1:colorNum
                    hueNum=mod((startHue+hueOffset*index),360);
                    artifactColorCodeMap(allArtifacts{index})=sprintf('hsl(%d, %s, %s)',hueNum,satNum,lightNum);
                    artifactColorClassMap(allArtifacts{index})=sprintf('Color_%d',index);
                end
            end
        end
    end
end


function out=getStandardColorLayer()










    out{1}='hsl(204, 100%, 37%)';
    out{2}='hsl(18, 79%, 47%)';
    out{3}='hsl(42, 85%, 53%)';
    out{4}='hsl(290, 50%, 37%)';
    out{5}='hsl(86, 56%, 43%)';
    out{6}='hsl(198, 83%, 62%)';
    out{7}='hsl(349, 78%, 36%)';
    out{8}='hsl(0, 0%, 49%)';
end

function[colorCodeMap,colorClassMap]=getDomainColorMap()
    colorCodeMap=containers.Map('KeyType','char','ValueType','char');
    colorClassMap=containers.Map('KeyType','char','ValueType','char');

    colorCodeMap('linktype_rmi_matlab')='hsl(204, 100%, 37%)';
    colorClassMap('linktype_rmi_matlab')='Color_1';

    colorCodeMap('linktype_rmi_simulink')='hsl(18, 79%, 47%)';
    colorClassMap('linktype_rmi_simulink')='Color_2';

    colorCodeMap('linktype_rmi_data')='hsl(42, 85%, 53%)';
    colorClassMap('linktype_rmi_data')='Color_3';

    colorCodeMap('linktype_rmi_testmgr')='hsl(290, 50%, 37%)';
    colorClassMap('linktype_rmi_testmgr')='Color_4';

    colorCodeMap('linktype_rmi_slreq')='hsl(86, 56%, 43%)';
    colorClassMap('linktype_rmi_slreq')='Color_5';

    colorCodeMap('linktype_rmi_doors')='hsl(198, 83%, 62%)';
    colorClassMap('linktype_rmi_doors')='Color_6';

    colorCodeMap('linktype_rmi_excel')='hsl(349, 78%, 36%)';
    colorClassMap('linktype_rmi_excel')='Color_7';

    colorCodeMap('other')='hsl(0, 0%, 40%)';
    colorClassMap('other')='Color_8';
end


