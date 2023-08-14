classdef BlockDataWithCompile<FunctionApproximation.internal.serializabledata.BlockDataAssumeCompile



    methods(Access=protected)
        function this=setInterfaceTypes(this)
            blockPath=Simulink.ID.getFullName(this.SID);
            modelCompileHandler=fixed.internal.modelcompilehandler.ModelCompileHandler(blockPath);
            start(modelCompileHandler);
            this=setInterfaceTypes@FunctionApproximation.internal.serializabledata.BlockDataAssumeCompile(this);
            stop(modelCompileHandler);
        end
    end
end
