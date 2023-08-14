




classdef ConstantParameter<internal.mtree.mlfb.ChartData
    properties
Value
    end

    methods
        function this=ConstantParameter(name,type,value)
            this=this@internal.mtree.mlfb.ChartData(name,type,'parameter');
            this.Value=value;
        end
    end
end
