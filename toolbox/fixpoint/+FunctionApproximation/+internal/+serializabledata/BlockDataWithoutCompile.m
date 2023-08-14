classdef BlockDataWithoutCompile<FunctionApproximation.internal.serializabledata.BlockData





    methods(Access=protected)
        function this=setInterfaceTypes(this)
            ports=get_param(this.FullName,'Ports');
            this.InputTypes=repmat(numerictype('double'),1,ports(1));
            this.OutputType=repmat(numerictype('double'),1,this.NumOutputs);
        end
    end
end
