




classdef MdlMassMatrixWriter<coder.internal.modelreference.FunctionInterfaceWriter
    methods(Access=public)
        function this=MdlMassMatrixWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer)
            this@coder.internal.modelreference.FunctionInterfaceWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer);
        end
    end



    methods(Access=protected)
        function p=getFunctionPrototype(~,~)
            p='void mdlMassMatrix(SimStruct *S)';
        end

        function writeFunctionHeader(this,~)
            this.Writer.writeLine('\n#define MDL_MASSMATRIX\n');
            writeFunctionHeader@coder.internal.modelreference.FunctionInterfaceWriter(...
            this,this.FunctionInterfaces);
        end


        function writeFunctionTrailer(this)
            this.Writer.writeLine('}');
        end
    end
end


