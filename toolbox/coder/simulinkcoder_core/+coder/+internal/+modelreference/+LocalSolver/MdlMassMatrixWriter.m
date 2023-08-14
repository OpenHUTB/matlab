




classdef MdlMassMatrixWriter<coder.internal.modelreference.MdlMassMatrixWriter
    methods(Access=public)
        function this=MdlMassMatrixWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer,headerWriter)
            this@coder.internal.modelreference.MdlMassMatrixWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer);
            this.Linkage=coder.internal.modelreference.FunctionLinkage.External;
            this.HeaderWriter=headerWriter;
        end
    end



    methods(Access=protected)
        function p=getFunctionPrototype(this,~)
            p=['void mdlMassMatrix_',this.ModelInterface.Name,'(SimStruct *S)'];
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


