classdef CostTopoUtilityContainer<handle











    properties(SetAccess=private)
        Model char
        Graph digraph=digraph()
    end

    methods



        function obj=buildGraph(obj,aModel)
            obj.Model=aModel;
            obj.Graph=digraph();
            obj.buildModelRefCostTopo();
        end


        function addUtilitiesToTopo(obj,aCostResult)
            obj.addUtilities(aCostResult);
        end
    end

    methods(Hidden)


        function buildModelRefCostTopo(obj)
            aContainer=designcostestimation.internal.graphutil.CostTopoModelRefContainer();
            obj.Graph=aContainer.buildGraph(obj.Model).Graph;
        end


        function addUtilities(obj,aResult)
            BlocksCostTable=aResult.BlockwiseCost;

            func=@(BlockName,BlockCost)obj.addUtility(BlockName);
            rowfun(func,BlocksCostTable,'NumOutputs',0);

            utilNodes=obj.Graph.Nodes.Type=="Utility";
            utilNames=obj.Graph.Nodes(utilNodes,:).FullName;
            aWrapper=@(currUtilName)obj.processUtil(currUtilName,aResult);
            arrayfun(aWrapper,utilNames);
        end



        function addUtility(obj,currUtility)
            NodeNames=obj.Graph.Nodes.FullName;
            if(ismember(currUtility,NodeNames))
                return;
            end
            nodeToAdd=designcostestimation.internal.graphutil.CostTopoContainer.createNodeToAdd(0,...
            "Utility",string(obj.Model),string(currUtility),"",false,string(currUtility));
            obj.Graph=obj.Graph.addnode(nodeToAdd);
        end


        function processUtil(obj,currUtilName,aResult)
            opcount=aResult.OpCount;

            strToFind=[char(currUtilName),'(call)'];

            callSiteSrcLocs=opcount(strcmp(opcount(:,3),strToFind),1);
            callSiteSrcLocs=callSiteSrcLocs(~cellfun('isempty',callSiteSrcLocs));
            if(isempty(callSiteSrcLocs))
                return;
            end
            callSiteSrcLocs=unique(callSiteSrcLocs);
            aWrapper=@(currCallSite)obj.addEdge(currCallSite,currUtilName);
            cellfun(aWrapper,callSiteSrcLocs);
        end



        function addEdge(obj,aParentNode,aChildNode)
            obj.Graph=designcostestimation.internal.graphutil.CostTopoContainer.addEdge(obj.Graph,aParentNode,aChildNode);
        end

    end
end


