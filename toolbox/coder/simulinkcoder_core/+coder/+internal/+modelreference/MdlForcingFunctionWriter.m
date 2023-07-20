




classdef MdlForcingFunctionWriter<coder.internal.modelreference.FunctionInterfaceWriter
    methods(Access=public)
        function this=MdlForcingFunctionWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer)
            this@coder.internal.modelreference.FunctionInterfaceWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer);
        end
    end



    methods(Access=protected)
        function p=getFunctionPrototype(~,~)
            p='void mdlForcingFunction(SimStruct *S)';
        end

        function writeFunctionHeader(this,functionInterface)
            this.Writer.writeLine('\n#define MDL_FORCINGFUNCTION\n');
            writeFunctionHeader@coder.internal.modelreference.FunctionInterfaceWriter(...
            this,functionInterface);
        end

        function writeFunctionTrailer(this)
            this.Writer.writeLine('}');
        end
    end
end


