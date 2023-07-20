




classdef MdlStartWriter<coder.internal.modelreference.FunctionInterfaceWriter
    properties(Access=private)
        IsVariableStepSolver=false
        AbsTolControl=[]
        NumContStates=0
        NonContArrayNeeded=false
        Outports={}
        NumberOfOutports=0
ConfigSetUtils
        SolverResetInfo=[]
TunableParameters
    end

    methods(Access=public)
        function this=MdlStartWriter(functionInterfaces,modelInterfaceUtils,codeInfoUtils,configSetUtils,writer,tunableParams)
            this@coder.internal.modelreference.FunctionInterfaceWriter(functionInterfaces,modelInterfaceUtils,codeInfoUtils,writer);
            this.ConfigSetUtils=configSetUtils;
            this.init;
            this.TunableParameters=tunableParams;
        end


        function write(this)
            this.writeFunctionHeader;
            this.writeFunctionBody;
            this.writeCoverageNotify('covrtModelStart');
            this.writeFunctionTrailer;
        end
    end



    methods(Access=protected)
        function p=getFunctionPrototype(~,~)
            p='void mdlStart(SimStruct *S)';
        end

        function writeFunctionHeader(this,~)
            this.Writer.writeLine('\n#define MDL_START\n');
            writeFunctionHeader@coder.internal.modelreference.FunctionInterfaceWriter(...
            this);
        end

        function writeFunctionBody(this)
            startFunctionExits=(length(this.FunctionInterfaces)>1);
            if(startFunctionExits)


                actualArguments=this.FunctionInterfaceUtils.getActualArguments(this.FunctionInterfaces(2));
                this.declareMultiInstanceVariables;
                parameterIndices=this.declareFunctionArguments(actualArguments);
                this.writeModelArguments(actualArguments,parameterIndices);
            end

            this.writeCallProcessParamFunction;
            if(startFunctionExits)
                this.writeStartFunctionCall;
            end
        end


        function writeFunctionTrailer(this)
            this.Writer.writeLine('}');
        end
    end


    methods(Access=protected)
        function writeStartFunctionCall(this)



            if(length(this.FunctionInterfaces)>1)
                this.Writer.writeLine('%s;',this.FunctionInterfaces(2).getFunctionCall);
            end
        end
    end



    methods(Access=private)
        function init(this)
            this.IsVariableStepSolver=strcmp(this.ConfigSetUtils.getParam('SolverType'),'Variable-step');
            this.NumContStates=this.ModelInterface.NumContStates;

            if this.IsVariableStepSolver
                this.SolverResetInfo=this.ModelInterface.SolverResetInfo;
            end

            if isfield(this.ModelInterface,'VariableStepOpts')
                this.AbsTolControl=this.ModelInterface.VariableStepOpts.AbsTolControl;
            end

            this.Outports=coder.internal.modelreference.Utilities.getFieldData(this.ModelInterface,'Outports');
            this.NumberOfOutports=length(this.Outports);
        end


        function writeCallProcessParamFunction(this)
            if this.TunableParameters.hasParameter
                this.Writer.writeString('mdlProcessParameters(S);');
            end
        end
    end
end


