classdef(Abstract)FilterEdgeType<fxptopo.internal.transformation.TransformInterface




    properties
        EdgeType fxptopo.internal.EdgeType=fxptopo.internal.EdgeType.Contain
    end

    methods
        function this=FilterEdgeType(edgeType)
            if nargin==1
                this.EdgeType=edgeType;
            end
        end
    end
end
