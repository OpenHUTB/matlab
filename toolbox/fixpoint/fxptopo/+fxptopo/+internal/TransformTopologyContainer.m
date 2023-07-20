classdef(Sealed)TransformTopologyContainer<fxptopo.internal.CompositeTopologyContainer













    properties
        TransformationObjects(1,:)fxptopo.internal.transformation.TransformInterface
    end

    methods
        function this=TransformTopologyContainer()
            this.ChildContainer=fxptopo.internal.SLTopoWithMdlRefContainer();
            this.TransformationObjects=fxptopo.internal.TransformTopologyContainer.getDefaultTransformations();
        end
    end

    methods(Access=protected)
        function createGraph(this)
            this.ChildContainer.ModelName=this.ModelName;
            this.ChildContainer.CurrentSystem=this.CurrentSystem;
            this.ChildContainer.createGraph();
            this.ModelGraph=this.ChildContainer.ModelGraph;
            this.Graph=this.ChildContainer.Graph;

            for ii=1:numel(this.TransformationObjects)
                this=this.TransformationObjects(ii).transform(this);
            end
        end
    end

    methods(Static)
        function defaultTransformationObjects=getDefaultTransformations()
            defaultTransformationObjects=...
            [...
            fxptopo.internal.transformation.CollapseEdgeType("Signal"),...
            fxptopo.internal.transformation.DeleteEdgeType("Contain"),...
            fxptopo.internal.transformation.DeleteNodeType('port'),...
            fxptopo.internal.transformation.DeleteNonMaskedSubsytem(),...
            fxptopo.internal.transformation.DeleteNodeType('ModelReference'),...
            fxptopo.internal.transformation.DeleteNodesInLinkedMaskedBlocks(),...
            fxptopo.internal.transformation.DeleteNodeType('Scope'),...
            fxptopo.internal.transformation.DeleteNodeType('ForEach'),...
            fxptopo.internal.transformation.DeleteNodesUnderDashBoard(),...
            fxptopo.internal.transformation.DeleteSubsytemsWithNoPorts(),...
            ];
        end
    end
end
