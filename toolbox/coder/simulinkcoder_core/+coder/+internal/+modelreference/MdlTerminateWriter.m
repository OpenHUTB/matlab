




classdef MdlTerminateWriter<coder.internal.modelreference.FunctionInterfaceWriter
    methods
        function this=MdlTerminateWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer)
            this@coder.internal.modelreference.FunctionInterfaceWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer);
        end
    end



    methods(Access=public)
        function write(this)
            this.writeFunctionHeader;
            if~isempty(this.FunctionInterfaces)
                assert(length(this.FunctionInterfaces)<2);
                this.writeFunctionBody(this.FunctionInterfaces);
            end
            if slfeature('ModelRefAccelSupportsOPForSimscapeBlocks')>=4
                this.Writer.writeLine('simTgtFreeOPModelData(S);');
            end
            this.writeFunctionTrailer;
        end
    end



    methods(Access=protected)
        function p=getFunctionPrototype(~,~)
            p='void mdlTerminate(SimStruct *S)';
        end

    end
end
