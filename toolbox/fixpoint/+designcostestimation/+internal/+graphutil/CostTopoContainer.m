classdef CostTopoContainer<handle












    properties(SetAccess=private)
        Model char
    end

    properties(SetAccess={...
        ?designcostestimation.internal.graphutil.CostTopoContainer})
        Graph digraph=digraph()
    end

    methods

        function obj=buildGraph(obj,aModel)
            obj.Model=aModel;
            obj.buildTopoGraph();
            obj.addFullNameToNodes();
        end
    end

    methods(Hidden)

        function addFullNameToNodes(obj)
            aNodes=obj.Graph.Nodes;
            FullName=getfullname(aNodes.Handle);
            obj.Graph.Nodes.FullName=string(FullName);
        end



        function buildTopoGraph(obj)
            aSlTopoGraphContainer=fxptopo.internal.SLTopoContainer();
            aSlTopoGraphContainer.setRemoveTopNode(false);
            aSlTopoGraph=aSlTopoGraphContainer.buildGraph(obj.Model);
            obj.Graph=aSlTopoGraph.ModelGraph;
            obj.pruneGraph();
        end


        function pruneGraph(obj)
            edgesToDelete=obj.Graph.Edges.Type~="Contain";
            edgesToRetain=obj.Graph.Edges.Type=="Contain";
            nodesToDelete=obj.Graph.Edges.EndNodes(edgesToDelete,:);
            nodesToDelete=unique(nodesToDelete(:));
            nodesToRetain=obj.Graph.Edges.EndNodes(edgesToRetain,:);
            nodesToRetain=unique(nodesToRetain(:));
            n=setdiff(nodesToDelete,nodesToRetain);
            obj.Graph=obj.Graph.rmnode(n);
        end
    end

    methods(Static)

        function returnEdge=createEdgeToAdd(fromNode,toNode,Edgetype)
            returnEdge=table([fromNode,toNode],Edgetype,...
            'VariableNames',{'EndNodes','Type'});
        end


        function returnNode=createNodeToAdd(aHandle,aType,aSID,aNodeLabel,aMaskType,aLink,aFullName)
            returnNode=table(aHandle,aType,aSID,aNodeLabel,aMaskType,aLink,aFullName,...
            'VariableNames',{'Handle','Type','SID','NodeLabel','MaskType','IsLink','FullName'});
        end



        function retGraph=addEdge(aGraph,parentNode,childNode)
            fromNode=aGraph.Nodes.FullName==string(parentNode);
            toNode=aGraph.Nodes.FullName==string(childNode);
            fromIdx=find(fromNode);
            toIdx=find(toNode);


            if(isempty(fromIdx)||isempty(toIdx))
                retGraph=aGraph;
                return;
            end
            anEdge=designcostestimation.internal.graphutil.CostTopoContainer.createEdgeToAdd(fromIdx,...
            toIdx,cellstr("Contain"));%#ok<*FNDSB>
            edgeExists=ismember(anEdge,aGraph.Edges);
            if(~edgeExists)
                retGraph=aGraph.addedge(anEdge);
            else
                retGraph=aGraph;
            end
        end


        function successorNames=findAllSuccessors(aGraph,aPathStr)
            successorNodes=aGraph.successors(find(aGraph.Nodes.FullName==aPathStr));%#ok<*FNDSB>
            successorGraph=aGraph.subgraph(successorNodes);
            successorNames=successorGraph.Nodes.FullName;
            wrapper=@(current)designcostestimation.internal.graphutil.CostTopoContainer.findAllSuccessors(aGraph,current);
            sofs=cellfun(wrapper,successorNames,'UniformOutput',false);
            successorNames=[successorNames;vertcat(sofs{:})];
            successorNames=unique(successorNames);
        end
    end
end


