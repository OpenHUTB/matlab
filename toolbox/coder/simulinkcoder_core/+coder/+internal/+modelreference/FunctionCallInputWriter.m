


classdef FunctionCallInputWriter<coder.internal.modelreference.FunctionCallWriter
    methods(Access=public)
        function this=FunctionCallInputWriter(functionInterfaces,modelInterfaceUtils,codeInfoUtils,writer)
            this@coder.internal.modelreference.FunctionCallWriter(functionInterfaces,modelInterfaceUtils,codeInfoUtils,writer);
        end
    end



    methods(Access=protected)
        function updateOutports(this,actualArguments)
            this.writeUpdateVarDimsOutPorts(actualArguments);
        end
    end
end
