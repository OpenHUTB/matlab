classdef CostTopoModelRefContainer<handle









    properties(SetAccess=private)
        Model char
        Graph digraph=digraph()
    end

    methods



        function obj=buildGraph(obj,aModel)
            obj.Model=aModel;
            obj.Graph=digraph();


            [mdlrefs,refblks]=find_mdlrefs(obj.Model,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
            fGraphs=cellfun(@obj.buildCostTopoGraph,mdlrefs,'UniformOutput',false);
            cellfun(@obj.updateEdges,fGraphs);
            obj.addModelRefEdges(refblks);
        end
    end

    methods(Hidden)


        function retGraph=buildCostTopoGraph(~,aModel)
            aContainer=designcostestimation.internal.graphutil.CostTopoContainer();
            retGraph=aContainer.buildGraph(aModel).Graph;
        end


        function addModelRefEdges(obj,refblks)
            for c=1:size(refblks)
                mdlName=get_param(refblks(c),'ModelName');
                obj.addEdge(refblks(c),mdlName);
            end
        end



        function addEdge(obj,aParentNode,aChildNode)
            obj.Graph=designcostestimation.internal.graphutil.CostTopoContainer.addEdge(obj.Graph,aParentNode,aChildNode);
        end



        function updateEdges(obj,aGraph)
            newEndNodes=aGraph.Edges.EndNodes(:,:)+obj.Graph.numnodes;
            numElem=size(newEndNodes);
            typeCell=cell(numElem(1),1);
            typeCell(:)={'Contain'};
            newEdges=table(newEndNodes,typeCell,'VariableNames',{'EndNodes','Type'});
            obj.Graph=obj.Graph.addnode(aGraph.Nodes);
            obj.Graph=obj.Graph.addedge(newEdges);
        end
    end
end


