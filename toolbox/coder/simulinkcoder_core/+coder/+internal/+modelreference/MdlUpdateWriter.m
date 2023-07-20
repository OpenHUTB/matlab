




classdef MdlUpdateWriter<coder.internal.modelreference.FunctionInterfaceWriter
    methods(Access=public)
        function this=MdlUpdateWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer)
            this@coder.internal.modelreference.FunctionInterfaceWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer);
        end
    end



    methods(Access=public)
        function write(this)
            if~isempty(this.FunctionInterfaces)
                this.writeFunctionHeader;
                this.writeFunctionBody(this.FunctionInterfaces);
                this.writeFunctionTrailer;
                if~isempty(this.HeaderWriter)
                    assert(this.Linkage==coder.internal.modelreference.FunctionLinkage.External)
                    this.declareInHeader(this.FunctionInterfaces);
                end
            end
        end
    end



    methods(Access=protected)
        function p=getFunctionPrototype(this,~)
            p=sprintf('void mdlUpdate(SimStruct *S, int_T %s)',...
            this.ModelInterfaceUtils.getGlobalTidString);
        end

        function writeFunctionHeader(this,~)
            this.Writer.writeLine('\n#define MDL_UPDATE\n');
            writeFunctionHeader@coder.internal.modelreference.FunctionInterfaceWriter(...
            this);
        end

        function writeFunctionBody(this,functionInterfaces)
            actualArguments=this.FunctionInterfaceUtils.getActualArguments(functionInterfaces);
            this.declareMultiInstanceVariables;
            parameterIndices=this.declareFunctionArguments(actualArguments);
            this.writeModelArguments(actualArguments,parameterIndices);
            this.initializePorts(actualArguments);
            this.writeOutputOrUpdateFunctionCall;
            this.updateOutports(actualArguments);
        end


        function writeContinuousSampleTimeCondition(this,taskIdx)
            this.Writer.writeLine('if (ssIsSampleHit(S, %d, %s)) {',...
            taskIdx-1,this.ModelInterfaceUtils.getGlobalTidString);
        end
    end
end
