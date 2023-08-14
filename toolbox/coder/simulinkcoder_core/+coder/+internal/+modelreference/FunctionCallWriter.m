







classdef FunctionCallWriter<coder.internal.modelreference.FunctionInterfaceWriter
    methods(Access=public)
        function this=FunctionCallWriter(functionInterfaces,modelInterfaceUtils,codeInfoUtils,writer)
            this@coder.internal.modelreference.FunctionInterfaceWriter(functionInterfaces,modelInterfaceUtils,codeInfoUtils,writer);
            this.Linkage=coder.internal.modelreference.FunctionLinkage.External;
        end
    end



    methods(Access=protected)
        function p=getFunctionPrototype(~,functionInterface)
            p=sprintf('ssFcnCallErr_T %s%s(SimStruct *S, int_T el, int_T idx)',...
            functionInterface.Prototype.Name,'_sf');
        end

        function writeReturnStatement(this)
            this.Writer.writeLine('return SS_FCNCALL_NO_ERR;');
        end
    end
end


