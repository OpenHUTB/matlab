




classdef MdlOutputsWriter<coder.internal.modelreference.FunctionInterfaceWriter
    properties(Access=private)
TimingInterfaceUtils
SampleTimes
ResetTids
ResetOffsets
TermTid
TermOffset
    end


    methods
        function this=MdlOutputsWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,timingInterfaceUtils,writer)
            this@coder.internal.modelreference.FunctionInterfaceWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer);
            this.TimingInterfaceUtils=timingInterfaceUtils;
            this.SampleTimes=this.TimingInterfaceUtils.getSampleTimes;
            this.ResetTids=int32.empty;
            this.ResetOffsets=int32.empty;
            this.TermTid=int32.empty;
            this.TermOffset=int32.empty;
            for sampIdx=1:length(this.SampleTimes)
                timingInterface=this.SampleTimes(sampIdx);
                if this.TimingInterfaceUtils.isModelWideEvent(timingInterface)
                    offset=timingInterface.SampleOffset;
                    if offset>2
                        [tidInSubMdl,id]=this.TimingInterfaceUtils.getModelWideEventsInfo(offset);
                        this.ResetOffsets(end+1)=offset;
                        this.ResetTids(end+1)=tidInSubMdl;
                    elseif offset==2
                        [tidInSubMdl,id]=this.TimingInterfaceUtils.getModelWideEventsInfo(offset);
                        this.TermOffset(end+1)=offset;
                        this.TermTid(end+1)=tidInSubMdl;
                    end
                end
            end
        end
    end



    methods(Access=public)
        function write(this)
            this.writeFunctionHeader;
            this.writeFunctionBody(this.FunctionInterfaces);
            this.writeFunctionTrailer;
            if~isempty(this.HeaderWriter)
                assert(this.Linkage==coder.internal.modelreference.FunctionLinkage.External)
                this.declareInHeader(this.FunctionInterfaces);
            end
        end
    end



    methods(Access=protected)
        function p=getFunctionPrototype(this,~)
            p=sprintf('void mdlOutputs(SimStruct *S, int_T %s)',...
            this.ModelInterfaceUtils.getGlobalTidString);
        end

        function writeSetDenormalBehavior(this)



            ftzFeature=slfeature('SetDenormalBehavior');
            ftzEnabled=strcmp(this.ModelInterface.DenormalBehavior,'FlushToZero');
            if ftzFeature&&ftzEnabled

                this.Writer.writeLine('int denormalBackup = _MM_GET_FLUSH_ZERO_MODE();');

                this.Writer.writeLine(['_MM_SET_FLUSH_ZERO_MODE',...
                '(_MM_FLUSH_ZERO_ON);']);
            end

        end

        function writeRestoreDenormalBehavior(this)



            ftzFeature=slfeature('SetDenormalBehavior');
            ftzEnabled=strcmp(this.ModelInterface.DenormalBehavior,'FlushToZero');
            if ftzFeature&&ftzEnabled
                this.Writer.writeLine('_MM_SET_FLUSH_ZERO_MODE(denormalBackup);');
            end

        end

        function writeFunctionBody(this,functionInterfaces)
            if~isempty(functionInterfaces)
                this.writeSetDenormalBehavior();
                actualArguments=this.FunctionInterfaceUtils.getActualArguments(functionInterfaces);
                this.declareMultiInstanceVariables;
                parameterIndices=this.declareFunctionArguments(actualArguments);


                if this.ModelInterface.ParameterChangeEventTID==-1
                    calledFromSetupRTR=false;
                    this.declareTestpointedParameters(calledFromSetupRTR);
                    this.writeTestpointedParameters(calledFromSetupRTR);
                end
                this.writeModelArguments(actualArguments,parameterIndices);

                for idx=1:length(functionInterfaces)
                    this.initializePorts(functionInterfaces(idx).ActualArgs);
                end

                if this.ModelInterface.ParameterChangeEventTID~=-1
                    this.writeTunableParameterOutput;
                end

                this.writeResetSubsysOutput;
                this.writeTermSubsysOutput;
                this.writeFunctionCall;
                this.updateOutports(actualArguments);
                this.writeRestoreDenormalBehavior();
            end
        end


        function writeFunctionTrailer(this)
            this.Writer.writeLine('}');
        end


        function declareInportVariable(this,dataInterface)
            portIdx=this.InputPortIndexMap(this.CodeInfoUtils.getInportIndex(dataInterface));
            if this.ModelInterfaceUtils.isDirectFeedThroughPort(portIdx)
                if(isa(dataInterface.Type,"coder.types.Matrix")&&any(isinf(dataInterface.Type.Dimensions)))
                    functionCallString=sprintf('ssGetInputPortDynamicArrayData(S, %d)',portIdx-1);
                else
                    functionCallString=sprintf('ssGetInputPortSignal(S, %d)',portIdx-1);
                end
            else
                MSLDiagnostic('Simulink:modelReference:DirectFeedThrough',portIdx).reportAsWarning;
                functionCallString='(NULL)';
            end

            constString='const';
            dataType=this.DataTypeUtils.getBaseType(dataInterface.Implementation.Type);
            this.declareVariable(constString,dataType.Identifier,dataInterface.Implementation.Identifier,functionCallString);
        end


        function initializePorts(this,actualArguments)
            flag=this.ModelInterface.HasConstantOutput&&...
            (~isempty(this.CodeInfo.Inports)>0||~isempty(this.CodeInfo.Outports)>0);

            if this.HasVarDimsInport||this.HasVarDimsOutport
                if flag
                    this.Writer.writeLine('if (%s != CONSTANT_TID && %s != PARAMETER_TUNING_TID){',...
                    this.ModelInterfaceUtils.getGlobalTidString,...
                    this.ModelInterfaceUtils.getGlobalTidString);
                end

                if this.HasVarDimsInport
                    this.writeInitializeVarDimsPorts(actualArguments,'In','ssGetCurrentInputPortDimensions');
                end

                if this.HasVarDimsOutport
                    this.writeInitializeVarDimsPorts(actualArguments,'Out','ssGetCurrentOutputPortDimensions');
                end

                if flag
                    this.Writer.writeLine('}');
                end
            end
        end


        function writeFunctionCall(this,~)

            if isempty(this.ResetTids)&&isempty(this.TermTid)&&...
                this.NumberOfFunctionInterfaces==1&&...
                this.FunctionInterfaces.Timing.SamplePeriod==Inf
                return;
            end

            tidStr=this.ModelInterfaceUtils.getGlobalTidString;
            this.Writer.writeLine('if (%s != CONSTANT_TID &&',tidStr);
            for idx=1:length(this.ResetTids)
                this.Writer.writeLine('    %s != %d &&',tidStr,this.ResetTids(idx));
            end
            for idx=1:length(this.TermTid)
                this.Writer.writeLine('    %s != %d &&',tidStr,this.TermTid(idx));
            end
            this.Writer.writeLine('    %s != PARAMETER_TUNING_TID)',tidStr);
            this.Writer.writeLine('{');
            this.writeOutputOrUpdateFunctionCall;
            this.Writer.writeLine('}');
        end
    end


    methods(Access=private)
        function writeTunableParameterOutput(this)

            assert(this.ModelInterface.ParameterChangeEventTID~=-1,'The referenced model has no tunable parameter sample time.');
            this.Writer.writeLine('if (%s == PARAMETER_TUNING_TID){',this.ModelInterfaceUtils.getGlobalTidString);
            calledFromSetupRTR=false;
            this.declareTestpointedParameters(calledFromSetupRTR);
            this.writeTestpointedParameters(calledFromSetupRTR);

            this.writeFunctionForSampleTime(Inf,0);
            this.Writer.writeLine('}');
        end

        function writeResetSubsysOutput(this)
            assert(length(this.ResetTids)==length(this.ResetOffsets));
            for idx=1:length(this.ResetTids)
                this.Writer.writeLine('if (%s == %d ) {',this.ModelInterfaceUtils.getGlobalTidString,this.ResetTids(idx));
                this.writeFunctionForSampleTime(Inf,this.ResetOffsets(idx));
                this.Writer.writeLine('}');
            end
        end

        function writeTermSubsysOutput(this)
            assert(length(this.TermTid)==length(this.TermOffset));
            assert(length(this.TermTid)<=1);
            for idx=1:length(this.TermTid)
                this.Writer.writeLine('if (%s == %d ) {',this.ModelInterfaceUtils.getGlobalTidString,this.TermTid(idx));
                this.writeFunctionForSampleTime(Inf,this.TermOffset(idx));
                this.Writer.writeLine('}');
            end
        end

        function writeFunctionForSampleTime(this,samplePeriod,sampleOffset)
            for fcnIdx=this.NumberOfFunctionInterfaces:-1:1
                functionInterface=this.FunctionInterfaces(fcnIdx);
                if functionInterface.Timing.SamplePeriod==samplePeriod&&...
                    functionInterface.Timing.SampleOffset==sampleOffset
                    this.Writer.writeLine([functionInterface.getFunctionCall,';']);
                    break;
                end
            end
        end
    end
end


