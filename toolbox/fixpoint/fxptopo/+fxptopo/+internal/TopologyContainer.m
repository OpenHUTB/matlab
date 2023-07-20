classdef(Abstract)TopologyContainer<handle&matlab.mixin.Heterogeneous










    properties(SetAccess=protected)
        CurrentSystem char
        ModelName char
        ModelGraph digraph=digraph
    end

    properties(SetAccess={...
        ?fxptopo.internal.TopologyContainer,...
        ?fxptopo.internal.transformation.TransformInterface})
        Graph digraph=digraph
    end

    properties(Access=protected)
        ModelRefs cell
    end

    methods(Sealed)
        function validateSystem(~,currentSystem)
            try
                Simulink.ID.getSID(currentSystem);
            catch err
                err.cause{1}.throwAsCaller;
            end
        end

        function this=buildGraph(this,currentSystem)
            validateSystem(this,currentSystem);
            this.CurrentSystem=currentSystem;
            this.ModelName=Simulink.ID.getModel(currentSystem);
            createGraph(this);
            endNodeNames=this.Graph.Nodes.NodeLabel(this.Graph.Edges.EndNodes);
            if(numel(endNodeNames)==2)
                endNodeNames=endNodeNames(:)';
            end
            this.Graph.Edges.EndNodeNames=endNodeNames;
        end

        function subGraphs=getCyclicSubGraphs(this)
            nodeSetExtractor=fxptopo.internal.CyclicSubGraphSetExtractor().extract(this.Graph);
            subGraphs=nodeSetExtractor.SubGraphs;
        end
    end

    methods
        function varargout=plot(this)
            h=fxptopo.internal.plotTopo(this.Graph);

            if nargout>0
                varargout{1}=h;
            end
        end
    end

    methods(Abstract,Access=protected)
        createGraph(this)
    end
end


