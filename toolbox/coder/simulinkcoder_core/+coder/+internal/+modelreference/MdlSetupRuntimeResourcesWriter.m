




classdef MdlSetupRuntimeResourcesWriter<coder.internal.modelreference.FunctionInterfaceWriter
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
SetupRTRFunctionInterfaces
        IsEmitingService=false
ServiceWriter
    end

    methods(Access=public)
        function this=MdlSetupRuntimeResourcesWriter(setupRTRfunctionInterface,...
            startFunctionInterfaces,modelInterfaceUtils,codeInfoUtils,...
            configSetUtils,writer,tunableParams)
            this@coder.internal.modelreference.FunctionInterfaceWriter(...
            startFunctionInterfaces,modelInterfaceUtils,codeInfoUtils,writer);
            this.ConfigSetUtils=configSetUtils;
            this.init;
            this.TunableParameters=tunableParams;
            this.SetupRTRFunctionInterfaces=setupRTRfunctionInterface;
            this.ServiceWriter=coder.internal.modelreference.SimulinkServicesWriter(...
            this.ModelInterfaceUtils,this.CodeInfoUtils,this.Writer);
            if slfeature('SLMessageService')>=2&&...
                slfeature('ServiceFunctions')>=1
                this.IsEmitingService=true;
            end
        end
        function write(this)
            this.writeFunctionHeader;
            this.writeFunctionBody;
            this.writeFunctionTrailer;
        end
    end



    methods(Access=protected)
        function p=getFunctionPrototype(~,~)
            p='void mdlSetupRuntimeResources(SimStruct *S)';
        end

        function writeFunctionHeader(this,~)
            this.Writer.writeLine('\n#define MDL_SETUP_RUNTIME_RESOURCES\n');
            writeFunctionHeader@coder.internal.modelreference.FunctionInterfaceWriter(...
            this);
        end

        function writeFunctionBody(this)
            handleSetupRTR=~isempty(this.SetupRTRFunctionInterfaces);
            if~handleSetupRTR
                actualArguments=this.FunctionInterfaceUtils.getActualArguments(...
                this.FunctionInterfaces);
            else
                actualArguments=this.FunctionInterfaceUtils.getActualArguments(...
                [this.FunctionInterfaces,this.SetupRTRFunctionInterfaces(1)]);
            end
            this.declareMultiInstanceVariables;
            parameterIndices=this.declareFunctionArguments(actualArguments);
            calledFromSetupRTR=true;
            this.declareTestpointedParameters(calledFromSetupRTR);
            this.writeDeclareRegistrationFunctionArguments;
            this.initializePorts(actualArguments);
            this.writeSampleTimeInfo;
            this.writeAbsTolControl;
            this.writeInitNonContOutputArray;
            this.writeStringOutputInitialization;


            if(this.IsEmitingService)
                this.ServiceWriter.write(false);
            end

            this.writeDeepLearningConstruction;
            this.writeInitializeFunctionCall;


            if(this.IsEmitingService)
                this.ServiceWriter.write(true);
            end

            this.writeTestpointedParameters(calledFromSetupRTR);
            this.writeModelArguments(actualArguments,parameterIndices);
            this.writeModelMappingInfo;
            this.writeNonContOutputSignals;
            this.writeCoverageNotify('covrtModelInit');

            if handleSetupRTR
                this.Writer.writeLine('%s;',this.SetupRTRFunctionInterfaces(1).getFunctionCall);
            end
        end

        function writeFunctionTrailer(this)
            this.Writer.writeLine('}');
        end
        function writeInitializeFunctionCall(this)
            if slfeature('ModelRefAccelSupportsOPForSimscapeBlocks')>=4
                this.Writer.writeLine('simTgtAllocOPModelData(S);');
            end
            this.Writer.writeLine('%s;',this.FunctionInterfaces(1).getFunctionCall);
        end
        function writeStringOutputInitialization(this)
            for outportIdx=1:this.NumberOfOutports
                anOutport=this.Outports{outportIdx};
                if(anOutport.IsString)
                    this.Writer.writeLine('{');
                    outportDataInterface=this.CodeInfo.Outports(outportIdx);
                    outportIdentifier=outportDataInterface.Implementation.Identifier;
                    this.declareOutputVariable(outportDataInterface);
                    this.Writer.writeLine('suInitializeSILStringOutput(%s);',outportIdentifier);
                    this.Writer.writeLine('}');
                end
            end
        end
        function init(this)
            this.IsVariableStepSolver=strcmp(this.ConfigSetUtils.getParam('SolverType'),'Variable-step');
            this.NumContStates=this.ModelInterface.NumContStates;

            this.SolverResetInfo=this.ModelInterface.SolverResetInfo;

            if isfield(this.ModelInterface,'VariableStepOpts')
                this.AbsTolControl=this.ModelInterface.VariableStepOpts.AbsTolControl;
            end

            this.Outports=coder.internal.modelreference.Utilities.getFieldData(this.ModelInterface,'Outports');
            this.NumberOfOutports=length(this.Outports);
        end

        function writeDeclareRegistrationFunctionArguments(this)
            this.writeDeclareNonContOutputArray;
            this.Writer.writeLine('void *sysRanPtr = (NULL);');
            this.Writer.writeLine('int  sysTid = 0;');
            if isequal(this.ModelInterface.NeedsGlobalTimerIndices,'yes')
                this.Writer.writeLine('uint32_T* globalTimerIndices = (NULL);');
            end
            if isequal(this.ModelInterface.NeedsGlobalRuntimeEventIndices,'yes')
                this.Writer.writeLine('uint32_T* globalRuntimeEventIndices = (NULL);');
            end
            if(isfield(this.ModelInterface,'NumDataTransfers')&&this.ModelInterface.NumDataTransfers>0)
                this.Writer.writeLine('uint32_T* gblDataTransferIds = (NULL);');
            end
            this.writeDeclareAbsTolControl;
        end


        function writeDeclareNonContOutputArray(this)
            if isfield(this.SolverResetInfo,'NumNonContOutputSignals')
                if isfield(this.ModelInterface,'Outports')
                    for portIdx=1:this.NumberOfOutports
                        numNonContOutputSignals=this.SolverResetInfo.NumNonContOutputSignals;
                        if(numNonContOutputSignals(portIdx)>0)
                            this.Writer.writeLine('ssNonContDerivSigFeedingOutports mr_nonContOutput%d[%d];',...
                            portIdx-1,numNonContOutputSignals(portIdx));
                            this.NonContArrayNeeded=true;
                        end
                    end
                end

                if this.NonContArrayNeeded
                    this.Writer.writeLine('ssNonContDerivSigFeedingOutports *mr_nonContOutputArray[%d];',this.NumberOfOutports);
                end
            end
        end


        function writeDeclareAbsTolControl(this)
            if this.IsVariableStepSolver&&(this.NumContStates>0)
                genAbsTolControl=any(this.AbsTolControl==1);
                if genAbsTolControl
                    this.Writer.writeLine('uint8_T* absTolControl = ssGetAbsTolControlVector(S);');
                end
            end
        end


        function writeSampleTimeInfo(this)
            this.Writer.writeString('ssGetContextSysRanBCPtr(S, &sysRanPtr);');
            this.Writer.writeString('ssGetContextSysTid(S, &sysTid);');
            if isequal(this.ModelInterface.NeedsGlobalTimerIndices,'yes')
                this.Writer.writeString(...
                'globalTimerIndices = _ssGetGlobalTimerIndices(S);');
            end
            if isequal(this.ModelInterface.NeedsGlobalRuntimeEventIndices,'yes')
                this.Writer.writeString(...
                'globalRuntimeEventIndices = _ssGetGlobalRuntimeEventIndices(S);');
            end
            if(isfield(this.ModelInterface,'NumDataTransfers')&&...
                this.ModelInterface.NumDataTransfers>0)
                this.Writer.writeString('_ssGetGlobalDataTransferIndices(S, &gblDataTransferIds);');
            end
            this.Writer.writeString('if (sysTid == CONSTANT_TID) {');
            this.Writer.writeString('sysTid = 0;');
            this.Writer.writeString('}')
        end


        function writeAbsTolControl(this)
            if this.IsVariableStepSolver&&(this.NumContStates>0)
                for stateIdx=1:this.NumContStates
                    if(this.AbsTolControl(stateIdx)==1)
                        this.Writer.writeLine('absTolControl[%d] = %d;',stateIdx-1,this.AbsTolControl(stateIdx));
                    end
                end
            end
        end


        function writeInitNonContOutputArray(this)
            if isfield(this.SolverResetInfo,'NumNonContOutputSignals')&&this.NonContArrayNeeded
                numNonContOutputSignals=this.SolverResetInfo.NumNonContOutputSignals;
                for idx=1:this.NumberOfOutports
                    portIdx=idx-1;
                    if(numNonContOutputSignals(idx)>0)
                        this.Writer.writeLine('mr_nonContOutputArray[%d] = mr_nonContOutput%d;',portIdx,portIdx);
                    else
                        this.Writer.writeLine('mr_nonContOutputArray[%d] = (NULL);',portIdx);
                    end
                end
            end
        end


        function writeCallProcessParamFunction(this)
            if this.TunableParameters.hasParameter
                this.Writer.writeString('mdlProcessParameters(S);');
            end
        end


        function writeModelMappingInfo(this)
            if this.ModelInterface.IsModelRefScalableBuild
                dworkIdentifier=this.ModelInterface.SFcnDWorkIdentifier;
                this.Writer.writeLine('ssSetModelMappingInfoPtr(S, &(%s.rtm.DataMapInfo.mmi));',dworkIdentifier);
            else
                this.Writer.writeLine('ssSetModelMappingInfoPtr(S, &(dw->rtm.DataMapInfo.mmi));');
            end
        end

        function writeDeepLearningConstruction(this)
            if isfield(this.ModelInterface,'CoderDataGroups')
                coderDataGroups=this.ModelInterface.CoderDataGroups;
                numCoderDataGroups=numel(coderDataGroups.CoderDataGroup);
                for i=1:numCoderDataGroups
                    if numCoderDataGroups==1
                        coderDataGroup=coderDataGroups.CoderDataGroup;
                    else
                        coderDataGroup=coderDataGroups.CoderDataGroup{i};
                    end



                    if strcmp(coderDataGroup.SynthesizedNamePrefix,'_DeepLearning')&&...
                        coderDataGroup.Depth==0

                        this.Writer.writeLine(' dw->%s = new %s;',coderDataGroup.SelfPath,coderDataGroup.Type);
                    end
                end
            end
        end

        function writeNonContOutputSignals(this)
            this.Writer.writeLine('if (S->mdlInfo->genericFcn != (NULL)) {');
            this.Writer.writeLine('_GenericFcn fcn = S->mdlInfo->genericFcn;');
            if isfield(this.SolverResetInfo,'NumNonContOutputSignals')
                numNonContOutputSignals=this.SolverResetInfo.NumNonContOutputSignals;
                for idx=1:this.NumberOfOutports
                    if numNonContOutputSignals(idx)>0
                        portIdx=idx-1;
                        this.Writer.writeLine('if (!(fcn)(S, GEN_FCN_REG_MODELREF_NONCONTSIGS, %d, mr_nonContOutput%d)) return;',portIdx,portIdx);
                    end
                end
            end
            this.Writer.writeLine('}');
        end
    end
end



