




classdef MdlOutputsWriter<coder.internal.modelreference.MdlOutputsWriter



    methods
        function this=MdlOutputsWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,timingInterfaceUtils,writer,headerWriter)
            this@coder.internal.modelreference.MdlOutputsWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,timingInterfaceUtils,writer);
            this.Linkage=coder.internal.modelreference.FunctionLinkage.External;
            this.HeaderWriter=headerWriter;
        end
    end

    methods(Access=protected)

        function p=getFunctionPrototype(this,~)
            p=sprintf('void mdlOutputs_%s(SimStruct *S, int_T %s)',...
            this.ModelInterface.Name,...
            this.ModelInterfaceUtils.getGlobalTidString);
        end





        function writeSetDenormalBehavior(~)
        end

        function writeRestoreDenormalBehavior(~)
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


