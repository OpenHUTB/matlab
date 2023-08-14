


classdef FunctionCallUtils<handle
    properties(Access=private)
CodeInfo
ModelInterface

        FunctionCallInputs=[]
        NumberOfFunctionCallInputs=0

        NumberOfFcnCallOutputFunctions=0
        NumberOfFcnCallEnableFunctions=0
        NumberOfFcnCallDisableFunctions=0

        NumberOfEnableFunctions=0
        NumberOfDisableFunctions=0
        NumberOfOutputFunctions=0
    end


    methods(Access=public)
        function this=FunctionCallUtils(codeInfo,modelInterface)
            this.CodeInfo=codeInfo;
            this.ModelInterface=modelInterface;
            this.init;
        end


        function functionInterfaces=getFunctionCallEnableFunctions(this)
            if(this.NumberOfEnableFunctions==this.NumberOfFcnCallEnableFunctions)
                functionInterfaces=this.CodeInfo.EnableFunction;
            elseif(this.NumberOfEnableFunctions==(this.NumberOfFcnCallEnableFunctions+1))
                functionInterfaces=this.CodeInfo.EnableFunction(2:end);
            else
                assert(false,'Unexpected number of EnableFunction');
            end
        end


        function functionInterfaces=getFunctionCallDisableFunctions(this)
            if(this.NumberOfDisableFunctions==this.NumberOfFcnCallDisableFunctions)
                functionInterfaces=this.CodeInfo.DisableFunction;
            elseif(this.NumberOfDisableFunctions==(this.NumberOfFcnCallDisableFunctions+1))
                functionInterfaces=this.CodeInfo.DisableFunction(2:end);
            else
                assert(false,'Unexpected number of EnableFunction');
            end
        end


        function functionInterfaces=getFunctionCallOutputFunctions(this)
            start=this.NumberOfOutputFunctions-this.NumberOfFcnCallOutputFunctions+1;
            functionInterfaces=this.CodeInfo.OutputFunctions(start:this.NumberOfOutputFunctions);
        end


        function functionInterface=getEnableFunction(this)
            if(this.NumberOfEnableFunctions==(this.NumberOfFcnCallEnableFunctions+1))
                functionInterface=this.CodeInfo.EnableFunction(1);
            else
                functionInterface=[];
            end
        end


        function functionInterface=getDisableFunction(this)
            if(this.NumberOfDisableFunctions==(this.NumberOfFcnCallDisableFunctions+1))
                functionInterface=this.CodeInfo.DisableFunction(1);
            else
                functionInterface=[];
            end
        end


        function functionInterfaces=getOutputFunctions(this)
            stop=this.NumberOfOutputFunctions-this.NumberOfFcnCallOutputFunctions;
            functionInterfaces=this.CodeInfo.OutputFunctions(1:stop);
        end
    end


    methods(Access=private)
        function init(this)
            this.FunctionCallInputs=coder.internal.modelreference.Utilities.getFieldData(this.ModelInterface,'FcnCallInputs');
            this.NumberOfFunctionCallInputs=length(this.FunctionCallInputs);

            if~isempty(this.FunctionCallInputs)
                this.NumberOfFcnCallEnableFunctions=this.getNumberOfFunctionCallFunctions('Enable');
                this.NumberOfFcnCallDisableFunctions=this.getNumberOfFunctionCallFunctions('Disable');
                this.NumberOfFcnCallOutputFunctions=this.getNumberOfFunctionCallFunctions('Output');
            end

            this.NumberOfEnableFunctions=length(this.CodeInfo.EnableFunction);
            this.NumberOfDisableFunctions=length(this.CodeInfo.DisableFunction);
            this.NumberOfOutputFunctions=length(this.CodeInfo.OutputFunctions);
        end


        function num=getNumberOfFunctionCallFunctions(this,functionType)
            num=sum(cellfun(@(fcnInfo)strcmp(fcnInfo.FcnType,functionType),this.FunctionCallInputs));
        end
    end


    methods(Static,Access=public)
        function fcnName=getFcnCallWrapperFcnName(taskName)
            fcnName=[taskName,'_sf'];
        end

        function lineBuf=getFunctionCallInputBuffer(modelInterface)
            lineBuf='';
            if isfield(modelInterface,'FcnCallInputs')
                functionCallInputs=coder.internal.modelreference.Utilities.getFieldData(modelInterface,'FcnCallInputs');
                numberOfFunctionCallInputs=length(functionCallInputs);

                for idx=1:numberOfFunctionCallInputs
                    functionCallInput=functionCallInputs{idx};
                    switch functionCallInput.FcnType
                    case 'Output'
                        functionCallString='ssExportOutputFcn';
                    case 'Enable'
                        functionCallString='ssExportEnableFcn';
                    case 'Disable'
                        functionCallString='ssExportDisableFcn';
                    otherwise
                        assert(false,'Unexpected function type: %s',functionCallInput.FcnType);
                    end
                    fcnName=coder.internal.modelreference.FunctionCallUtils.getFcnCallWrapperFcnName(...
                    functionCallInput.TaskName);
                    lineBuf=[lineBuf,sprintf('%s(S, %d, %s);',...
                    functionCallString,...
                    functionCallInput.PortIdx,...
                    fcnName)];%#ok
                end
            end
        end
    end
end
