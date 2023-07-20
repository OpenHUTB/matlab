classdef BlockDataAssumeCompile<FunctionApproximation.internal.serializabledata.BlockData



    methods(Access=protected)
        function this=setInterfaceTypes(this)
            blockInterfaceParser=FunctionApproximation.internal.BlockInterfaceParser();
            blockObject=get_param(Simulink.ID.getFullName(this.SID),'Object');
            this.InputTypes=getInputTypes(blockInterfaceParser,blockObject);
            this.OutputType=getOutputTypes(blockInterfaceParser,blockObject);
        end
    end
end
