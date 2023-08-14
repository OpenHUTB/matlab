


classdef SimulinkFunctionsWriter<handle
    properties(SetAccess=private,GetAccess=private)
ModelInterface
CodeInfo
Writer
    end


    methods(Access=public)
        function this=SimulinkFunctionsWriter(modelInterfaceUtils,codeInfoUtils,writer)
            this.ModelInterface=modelInterfaceUtils.getModelInterface;
            this.CodeInfo=codeInfoUtils.getCodeInfo;
            this.Writer=writer;
        end
    end



    methods(Access=public)
        function write(this)
            if this.ModelInterface.NumSimulinkFunctions>0
                writerObjects={coder.internal.modelreference.RequestFunctionCallWriter(this.ModelInterface,this.CodeInfo,this.Writer),...
                coder.internal.modelreference.ProvideFunctionWriter(this.ModelInterface,this.CodeInfo,this.Writer),...
                coder.internal.modelreference.MdlRegisterSimulinkFunctionWriter(this.ModelInterface,this.CodeInfo,this.Writer)};
                cellfun(@(obj)obj.write,writerObjects);
            end
        end
    end
end
