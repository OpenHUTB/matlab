




classdef MdlZeroCrossingWriter<coder.internal.modelreference.FunctionInterfaceWriter
    methods(Access=public)
        function this=MdlZeroCrossingWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer)
            this@coder.internal.modelreference.FunctionInterfaceWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer);
        end
    end



    methods(Access=protected)
        function p=getFunctionPrototype(~,~)
            p='void mdlZeroCrossings(SimStruct *S)';
        end

        function writeFunctionHeader(this,functionInterface)
            this.Writer.writeLine('\n#define MDL_ZERO_CROSSINGS\n');
            writeFunctionHeader@coder.internal.modelreference.FunctionInterfaceWriter(...
            this,functionInterface);
        end

        function writeFunctionTrailer(this)
            this.Writer.writeLine('}');
        end
    end
end
