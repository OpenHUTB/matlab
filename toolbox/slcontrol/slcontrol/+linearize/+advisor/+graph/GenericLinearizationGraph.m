classdef GenericLinearizationGraph<linearize.advisor.graph.AbstractGraph


    methods
        function this=GenericLinearizationGraph
            this.Nodes=linearize.advisor.graph.LinNode.empty;
        end
        function srcIdx=getSrcIdx(this)
            srcIdx=this.Nodes.getInIOIdx;
        end
        function snkIdx=getSnkIdx(this)
            snkIdx=this.Nodes.getOutIOIdx;
        end
    end
end