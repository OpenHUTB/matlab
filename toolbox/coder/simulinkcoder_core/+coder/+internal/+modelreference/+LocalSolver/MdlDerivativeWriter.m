




classdef MdlDerivativeWriter<coder.internal.modelreference.MdlDerivativeWriter
    methods(Access=public)
        function this=MdlDerivativeWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer,headerWriter)
            this@coder.internal.modelreference.MdlDerivativeWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer);
            this.Linkage=coder.internal.modelreference.FunctionLinkage.External;
            this.HeaderWriter=headerWriter;
        end
    end

    methods(Access=protected)
        function p=getFunctionPrototype(this,~)
            p=['void mdlDerivatives_',this.ModelInterface.Name,'(SimStruct *S)'];
        end









        function declareInportVariable(this,dataInterface)
            dataType=this.DataTypeUtils.getBaseType(dataInterface.Implementation.Type);
            portIdx=this.InputPortIndexMap(this.CodeInfoUtils.getInportIndex(dataInterface))-1;
            functionCallString=sprintf('(S)->portInfo.inputs[(%d)].signal.vect',portIdx);
            constString='const';
            this.declareVariable(constString,dataType.Identifier,dataInterface.Implementation.Identifier,functionCallString);
        end
    end
end


