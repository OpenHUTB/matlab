




classdef MdlDisableWriter<coder.internal.modelreference.FunctionInterfaceWriter
    methods
        function this=MdlDisableWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer)
            this@coder.internal.modelreference.FunctionInterfaceWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer);
        end
    end



    methods(Access=protected)
        function p=getFunctionPrototype(~,~)
            p='void mdlDisable(SimStruct *S)';
        end

        function writeFunctionHeader(this,functionInterface)
            this.Writer.writeLine('\n#define RTW_GENERATED_DISABLE\n');
            writeFunctionHeader@coder.internal.modelreference.FunctionInterfaceWriter(...
            this,functionInterface);
        end
    end
end
