




classdef MdlProjectionWriter<coder.internal.modelreference.MdlProjectionWriter
    methods(Access=public)
        function this=MdlProjectionWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer,headerWriter)
            this@coder.internal.modelreference.MdlProjectionWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer);
            this.Linkage=coder.internal.modelreference.FunctionLinkage.External;
            this.HeaderWriter=headerWriter;
        end
    end



    methods(Access=protected)
        function p=getFunctionPrototype(this,~)
            p=['void mdlProjection_',this.ModelInterface.Name,'(SimStruct *S)'];
        end







        function declareInportVariable(this,dataInterface)
            dataType=this.DataTypeUtils.getBaseType(dataInterface.Implementation.Type);
            portIdx=this.InputPortIndexMap(this.CodeInfoUtils.getInportIndex(dataInterface))-1;
            functionCallString=sprintf('ssGetInputPortSignalForLocalSolver(%d)',portIdx);
            constString='const';
            this.declareVariable(constString,dataType.Identifier,dataInterface.Implementation.Identifier,functionCallString);
        end
    end
end
