




classdef MdlDerivativeWriter<coder.internal.modelreference.FunctionInterfaceWriter
    methods(Access=public)
        function this=MdlDerivativeWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer)
            this@coder.internal.modelreference.FunctionInterfaceWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer);
        end
    end



    methods(Access=protected)
        function p=getFunctionPrototype(~,~)
            p='void mdlDerivatives(SimStruct *S)';
        end

        function writeFunctionHeader(this,functionInterace)
            this.Writer.writeLine('\n#define MDL_DERIVATIVES\n');
            writeFunctionHeader@coder.internal.modelreference.FunctionInterfaceWriter(...
            this,functionInterace);
        end

        function writeFunctionTrailer(this)
            this.Writer.writeLine('}');
        end
    end
end
