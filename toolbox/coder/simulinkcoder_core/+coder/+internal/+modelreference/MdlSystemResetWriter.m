




classdef MdlSystemResetWriter<coder.internal.modelreference.FunctionInterfaceWriter
    methods
        function this=MdlSystemResetWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer)
            this@coder.internal.modelreference.FunctionInterfaceWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer);
        end
    end



    methods(Access=protected)
        function p=getFunctionPrototype(~,~)
            p='void mdlReset(SimStruct *S)';
        end


        function writeFunctionTrailer(this)
            this.Writer.writeLine('}');
        end
    end
end
