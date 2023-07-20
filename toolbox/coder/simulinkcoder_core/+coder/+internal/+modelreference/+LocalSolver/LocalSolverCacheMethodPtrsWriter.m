



classdef LocalSolverCacheMethodPtrsWriter<coder.internal.modelreference.FunctionInterfaceWriter
    methods
        function this=LocalSolverCacheMethodPtrsWriter(modelInterfaceUtils,codeInfoUtils,writer,headerWriter)
            this@coder.internal.modelreference.FunctionInterfaceWriter([],modelInterfaceUtils,codeInfoUtils,writer);
            this.Linkage=coder.internal.modelreference.FunctionLinkage.External;
            this.HeaderWriter=headerWriter;
            this.NumberOfFunctionInterfaces=1;
        end

        function write(this)
            this.writeFunctionHeader;
            this.writeFunctionBody;
            this.writeFunctionTrailer;
            if~isempty(this.HeaderWriter)
                assert(this.Linkage==coder.internal.modelreference.FunctionLinkage.External)
                this.declareInHeader(this.FunctionInterfaces);
            end
        end
    end


    methods(Access=protected)
        function p=getFunctionPrototype(this,~)
            p=['void localSolverCacheMethodPtrs_',this.ModelInterface.Name,'(SimStruct *S)'];
        end

        function writeFunctionBody(this,~)
            this.writeModelMethodsSetup;
        end


        function writeModelMethodsSetup(this)


            if~isempty(this.CodeInfo.OutputFunctions)
                this.Writer.writeLine(['ssSetmdlOutputs(S, mdlOutputs_',this.ModelInterface.Name,');']);
            end

            if~isempty(this.CodeInfo.DerivativeFunction)
                this.Writer.writeLine(['ssSetmdlDerivatives(S, mdlDerivatives_',this.ModelInterface.Name,');']);
            end

            if~isempty(this.CodeInfo.ForcingFunctionFunction)
                this.Writer.writeLine(['ssSetmdlForcingFunction(S, mdlForcingFunction_',this.ModelInterface.Name,');']);
            end

            if~isempty(this.CodeInfo.MassMatrixFunction)
                this.Writer.writeLine(['ssSetmdlMassMatrix(S, mdlMassMatrix_',this.ModelInterface.Name,');']);
            end

            if~isempty(this.CodeInfo.ProjectionFunction)
                this.Writer.writeLine(['ssSetmdlProjection(S, mdlProjection_',this.ModelInterface.Name,');']);
            end

            if~isempty(this.CodeInfo.MassMatrixFunction)
                this.Writer.writeLine(['ssSetmdlInitSystemMatrices(S, mdlInitSystemMatrices_',this.ModelInterface.Name,');']);
            end

        end

    end
end





