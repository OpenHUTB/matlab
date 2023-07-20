classdef(Abstract)FilterNodeType<fxptopo.internal.transformation.TransformInterface





    properties
        NodeType char='port'
    end

    methods
        function this=FilterNodeType(nodeType)
            if nargin==1
                this.NodeType=nodeType;
            end
        end
    end
end
