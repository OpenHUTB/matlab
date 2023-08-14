




classdef MdlEnableWriter<coder.internal.modelreference.FunctionInterfaceWriter
    methods
        function this=MdlEnableWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer)
            this@coder.internal.modelreference.FunctionInterfaceWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer);
        end
    end



    methods(Access=protected)
        function p=getFunctionPrototype(~,~)
            p='void mdlEnable(SimStruct *S)';
        end

        function writeFunctionHeader(this,functionInterface)
            this.Writer.writeLine('\n#define RTW_GENERATED_ENABLE\n');
            writeFunctionHeader@coder.internal.modelreference.FunctionInterfaceWriter(...
            this,functionInterface);
        end
    end
end
