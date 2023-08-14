




classdef LocalSolverInterfaceBuilder<handle

    properties(Access=private)
CodeInfoUtils
ModelInterfaceUtils
ConfigSetUtils
TimingInterfaceUtils
FunctionCallUtils
Writer
HeaderWriter
ModelInterface
CodeInfo
TunableParameters
    end


    methods(Access=public)
        function this=LocalSolverInterfaceBuilder(codeInfo,modelInterface,configSet,writer,headerWriter)
            this.CodeInfoUtils=coder.internal.modelreference.CodeInfoUtils(codeInfo);
            this.ModelInterfaceUtils=coder.internal.modelreference.ModelInterfaceUtils(modelInterface);
            this.ConfigSetUtils=coder.internal.modelreference.ConfigSetUtils(configSet);
            this.TimingInterfaceUtils=coder.internal.modelreference.TimingInterfaceUtils(this.CodeInfoUtils,this.ModelInterfaceUtils);
            this.FunctionCallUtils=coder.internal.modelreference.FunctionCallUtils(codeInfo,modelInterface);
            this.Writer=writer;
            this.CodeInfo=this.CodeInfoUtils.getCodeInfo;
            this.ModelInterface=this.ModelInterfaceUtils.getModelInterface;
            this.TunableParameters=coder.internal.modelreference.TunableParameters(this.CodeInfo,this.ModelInterfaceUtils);
            this.HeaderWriter=headerWriter;

            this.updateCodeInfoForSimTarget;
        end

        function writerObjs=getWriterObjects(this)
            writerObjs={};


            writerObjs{end+1}=(coder.internal.modelreference.LocalSolver.MdlInitSystemMatricesWriter(...
            this.ModelInterface,this.Writer,this.HeaderWriter));












            writerObjs{end+1}=(coder.internal.modelreference.LocalSolver.LocalSolverCacheMethodPtrsWriter(...
            this.ModelInterfaceUtils,...
            this.CodeInfoUtils,...
            this.Writer,...
            this.HeaderWriter));


            functionInterfaces=this.FunctionCallUtils.getOutputFunctions;
            writerObjs{end+1}=(coder.internal.modelreference.LocalSolver.MdlOutputsWriter(...
            functionInterfaces,...
            this.ModelInterfaceUtils,...
            this.CodeInfoUtils,...
            this.TimingInterfaceUtils,...
            this.Writer,...
            this.HeaderWriter));










            writerObjs{end+1}=(coder.internal.modelreference.LocalSolver.MdlDerivativeWriter(...
            this.CodeInfo.DerivativeFunction,...
            this.ModelInterfaceUtils,...
            this.CodeInfoUtils,...
            this.Writer,...
            this.HeaderWriter));


            writerObjs{end+1}=(coder.internal.modelreference.LocalSolver.MdlProjectionWriter(...
            this.CodeInfo.ProjectionFunction,...
            this.ModelInterfaceUtils,...
            this.CodeInfoUtils,...
            this.Writer,...
            this.HeaderWriter));


            writerObjs{end+1}=(coder.internal.modelreference.LocalSolver.MdlForcingFunctionWriter(...
            this.CodeInfo.ForcingFunctionFunction,...
            this.ModelInterfaceUtils,...
            this.CodeInfoUtils,...
            this.Writer,...
            this.HeaderWriter));


            writerObjs{end+1}=(coder.internal.modelreference.LocalSolver.MdlMassMatrixWriter(...
            this.CodeInfo.MassMatrixFunction,...
            this.ModelInterfaceUtils,...
            this.CodeInfoUtils,...
            this.Writer,...
            this.HeaderWriter));
        end
    end

    methods(Access=private)
        function updateCodeInfoForSimTarget(this)
            this.updateOwner(this.CodeInfo.InternalData);
            this.updateOwner(this.CodeInfo.Inports);
            this.updateOwner(this.CodeInfo.Outports);
            this.updateOwner(this.CodeInfo.Parameters);
        end


        function updateOwner(this,dataInterfaces)
            numberOfDataInterface=length(dataInterfaces);
            for i=1:numberOfDataInterface
                implementation=dataInterfaces(i).Implementation;
                if~isempty(implementation)&&~implementation.isDefined
                    if class(implementation)=="RTW.PointerExpression"
                        implementation.TargetRegion.Owner=this.CodeInfo.Name;
                    else
                        implementation.Owner=this.CodeInfo.Name;
                    end
                end
            end
        end
    end


end


