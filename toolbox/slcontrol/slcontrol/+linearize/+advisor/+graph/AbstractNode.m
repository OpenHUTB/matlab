classdef AbstractNode<matlab.mixin.Heterogeneous
    properties
        Type linearize.advisor.graph.NodeTypeEnum
    end
    methods(Sealed)
        function names=print(this)
            n=numel(this);
            names=cell(n,1);
            for i=1:n
                names{i,1}=scalarprint(this(i));
            end
        end
    end
    methods(Abstract)
        str=getDataTipStr(this)
    end
    methods(Abstract,Access=protected)
        name=scalarprint(this)
    end
end