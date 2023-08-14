



classdef MdlInitializeSizesWriter<coder.internal.modelreference.FunctionInterfaceWriter
    properties(SetAccess='private',GetAccess='protected')
StateInfoWriter
    end


    properties(Constant)
        JacobianDataFileSuffix='_Jpattern.mat';
    end


    properties(Access=protected)
ConfigSetUtils
TimingInterfaceUtils


ZeroCrossingInfoWriter


SampleTimes
SolverType


        DisallowSampleTimeInheritance=false
        IsAPeriodicTriggered=false
        IsFixedStepSolver=false;
        IsConstantBlock=false


Outports
Inports
NumberOfInputPorts
NumberOfOutputPorts
    end



    methods(Access=public)
        function this=MdlInitializeSizesWriter(modelInterfaceUtils,codeInfoUtils,configSetUtils,timingInterfaceUtils,writer)
            this@coder.internal.modelreference.FunctionInterfaceWriter([],modelInterfaceUtils,codeInfoUtils,writer);
            this.ConfigSetUtils=configSetUtils;
            this.TimingInterfaceUtils=timingInterfaceUtils;
            this.init;
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
        function p=getFunctionPrototype(~,~)
            p='void mdlInitializeSizes(SimStruct *S)';
        end

        function writeSchedulingDiagramInfo(this)
            this.Writer.writeString('ssSetAcceptsFcnCallInputs(S);');
        end

        function writeFunctionCallInfo(this)
            lineBuf=coder.internal.modelreference.FunctionCallUtils.getFunctionCallInputBuffer(this.ModelInterface);
            this.Writer.writeLine(lineBuf);
        end

        function writeModelRefInheritanceRule(this)
            this.Writer.writeLine('ssSetModelReferenceSampleTimeInheritanceRule(S, %s);',...
            this.ModelInterface.ModelRefTsInheritance);
        end

        function writeModelRefMultiThreadingSupport(this)

            if this.ModelInterface.SupportsMultiThreading
                this.Writer.writeLine('ssSetRuntimeThreadSafetyCompliance(S, RUNTIME_THREAD_SAFETY_COMPLIANCE_TRUE);');
            end
        end

        function writeNumberOfSampleTimes(this)
            if this.TimingInterfaceUtils.UsePortBasedSampleTimes
                this.Writer.writeLine('/* All sample times are available through ports. Use port based sample times. */');
                this.Writer.writeLine('ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);');
            else
                if this.IsConstantBlock
                    numberOfSampleTimes=1;
                elseif(~this.ModelInterfaceUtils.disallowSampleTimeInheritance||...
                    this.ModelInterfaceUtils.isAPeriodicTriggered)
                    modelWideEvents=this.TimingInterfaceUtils.getModelWideEvents;
                    numberOfSampleTimes=1+length(modelWideEvents);
                elseif this.ModelInterface.IsExportFcnDiagram
                    modelWideEvents=this.TimingInterfaceUtils.getModelWideEvents;
                    numberOfSampleTimes=this.ModelInterface.NumPortlessSimulinkFunctionPortGroups+...
                    length(modelWideEvents);
                else
                    numberOfSampleTimes=this.TimingInterfaceUtils.getNumberOfSampleTimes;
                end
                numberOfSampleTimes=numberOfSampleTimes+this.TimingInterfaceUtils.HasConstantOutput;
                this.Writer.writeLine('ssSetNumSampleTimes(S, %d);',numberOfSampleTimes);
            end
            this.Writer.writeLine('ssSetParameterTuningCompliance(S, true);');
        end

        function writeSimulinkFunctionReg(this)
            if this.ModelInterface.NumSimulinkFunctions>0
                this.Writer.writeLine('mdlRegisterSimulinkFunctions(S);');
            end
        end

        function writeSolverStatusFlags(this)
            if(isfield(this.ModelInterface,'SolverStatusFlags'))
                solverStatusFlags=this.ModelInterface.SolverStatusFlags;
                this.Writer.writeLine(['slmrSetModelRefSolverStatusFlags(S, ',num2str(solverStatusFlags),');']);
            end
        end

        function writeMessageQueuesInfo(this)

            if~isfield(this.ModelInterface,'LocalMessageQueueInfo')
                return;
            end

            qInfo=this.ModelInterface.LocalMessageQueueInfo;

            numQueues=length(qInfo);
            this.Writer.writeLine(['slmsg_ssSetNumLocalMessageQueues(S, ',num2str(numQueues),');']);


            if numQueues==1
                qInfo={qInfo};
            end

            for idx=1:numQueues
                qSpec=qInfo{idx};


                dimsStr='int_T qDims[] = {';
                for d=1:length(qSpec.DataDims)
                    dimsStr=[dimsStr,num2str(qSpec.DataDims(d)),', '];%#ok<AGROW>
                end
                dimsStr=[dimsStr(1:end-2),'};'];


                this.Writer.writeLine('{');
                this.Writer.writeLine(dimsStr);
                this.Writer.writeLine(['slmsg_ssSetMessageQueueType(S, SS_LOCAL_MESSAGE_QUEUE, ',num2str(idx-1),', ',qSpec.QueueType,');']);
                this.Writer.writeLine(['slmsg_ssSetMessageQueueCapacity(S, SS_LOCAL_MESSAGE_QUEUE, ',num2str(idx-1),', ',num2str(qSpec.QueueLength),');']);
                if~isempty(strfind(qSpec.QueueType,'PRIORITY'))
                    this.Writer.writeLine(['slmsg_ssSetMessageQueuePriorityOrder(S, SS_LOCAL_MESSAGE_QUEUE, ',num2str(idx-1),', ',qSpec.PriorityOrder,');']);
                end
                this.Writer.writeLine(['slmsg_ssMessageQueueSetDataProperties(S, SS_LOCAL_MESSAGE_QUEUE, ',num2str(idx-1),', '...
                ,num2str(length(qSpec.DataDims)),', qDims, ',num2str(qSpec.DataType),', ',qSpec.DataComplexity,');']);
                if qSpec.ExternalInputIdx>=0
                    qExInportIdx=qSpec.ExternalInputIdx;
                    this.Writer.writeLine(['slmsg_ssSetMsgQueueSpecExternalInportIdx(S, ',num2str(idx-1),', ',num2str(qExInportIdx),');']);
                    this.Writer.writeLine(['slmsg_ssSetInputPortMessageCompiledID(S, ',num2str(qSpec.ExternalInputIdx),', ',num2str(idx-1),');']);
                end
                this.Writer.writeLine('}');
            end
        end

        function writeModelRefSystemInitializeMethodReg(this)
            if~isempty(this.CodeInfo.SystemInitializeFunction)
                this.Writer.writeLine('slmrRegisterSystemInitializeMethod(S, mdlInitializeConditions);');
            end
        end

        function writeModelRefSystemResetMethodReg(this)
            if~isempty(this.CodeInfo.SystemResetFunction)
                this.Writer.writeLine('slmrRegisterSystemResetMethod(S, mdlReset);');
            end
        end

        function writeModelRefPeriodicOutputUpdateMethodReg(this)
            if~isempty(this.CodeInfo.OutputFunctions)&&...
                ~isempty(this.CodeInfo.OutputFunctions(1).Timing)&&...
                (strcmp(this.CodeInfo.OutputFunctions(1).Timing.TimingMode,'PERIODIC')||...
                strcmp(this.CodeInfo.OutputFunctions(1).Timing.TimingMode,'APERIODIC'))...
                this.Writer.writeLine('slmrRegisterPeriodicOutputUpdateMethod(S, mdlPeriodicOutputUpdate);');
            end
        end

        function writeSimulinkVersion(this)
            slVer=coder.make.internal.cachedVer('Simulink');
            this.Writer.writeLine(['ssSetSimulinkVersionGeneratedIn(S, "',slVer.Version,'");']);
        end

        function result=allRootInportFcnCallPortGroupInheritSampleTime(this)
            result=true;
            extPortGroups=coder.internal.modelreference.Utilities.getFieldData(this.ModelInterface,'ExternalPortGroups');
            for pgIdx=1:length(extPortGroups)
                portGroup=extPortGroups{pgIdx};
                period=portGroup.SpecifiedTsPeriodAndOffset(1);
                offset=portGroup.SpecifiedTsPeriodAndOffset(2);



                if(~eval(portGroup.IsSimulinkFunction)&&...
                    ~(period==-1&&offset==0))
                    result=false;
                    break;
                end
            end
        end

        function optionStr=getCommonSfunctionOptionsString(this)
            optionStr='';

            if(this.TimingInterfaceUtils.HasConstantOutput||...
                this.IsConstantBlock||...
                this.ModelInterface.HasParameterRateOutput||...
                this.ModelInterface.HasInternalParameterRate||...
                (isfield(this.ModelInterface,'NumSimulinkFunctions')&&...
                this.ModelInterface.NumSimulinkFunctions>0))
                optionStr=[optionStr,'SS_OPTION_ALLOW_CONSTANT_PORT_SAMPLE_TIME | '];
            end


            if~this.TimingInterfaceUtils.UsePortBasedSampleTimes
                if(this.ModelInterfaceUtils.NumberOfPorts>0||...
                    (~this.IsConstantBlock&&...
                    this.ModelInterface.NumPortlessSimulinkFunctionPortGroups))













                    optionStr=[optionStr,'SS_OPTION_PORT_SAMPLE_TIMES_ASSIGNED | '];
                end
            end

            if(~this.DisallowSampleTimeInheritance||...
                this.IsAPeriodicTriggered||...
                this.IsConstantBlock||...
                (slfeature('AllowExportFcnInTriggeredSS')>0&&...
                this.ModelInterface.IsExportFcnDiagram&&...
                this.allRootInportFcnCallPortGroupInheritSampleTime()))
                optionStr=[optionStr,'SS_OPTION_ALLOW_PORT_SAMPLE_TIME_IN_TRIGSS | '];
            end

            optionStr=[optionStr,'SS_OPTION_SUPPORTS_ALIAS_DATA_TYPES | '];
        end

        function writeSetModelOptions(this)

            optionStr=this.getCommonSfunctionOptionsString;


            if((~this.IsConstantBlock||(this.ModelInterface.DWorks.NumSFcnWrapperDWorks>0))&&...
                (this.TimingInterfaceUtils.UsePortBasedSampleTimes||...
                this.ModelInterfaceUtils.disallowSampleTimeInheritance||...
                (~this.ModelInterfaceUtils.disallowSampleTimeInheritance&&...
                this.ModelInterface.HasInternalParameterRate)))
                optionStr=[optionStr,'SS_OPTION_DISALLOW_CONSTANT_SAMPLE_TIME | '];
            end



            optionStr=[optionStr,'SS_OPTION_EXCEPTION_FREE_CODE | '];
            optionStr=[optionStr,'SS_OPTION_WORKS_WITH_CODE_REUSE'];

            this.Writer.writeLine('ssSetOptions(S, %s);',optionStr);
        end

        function writeSimStateComplianceDeclaration(this)
            this.Writer.writeLine('ssSetSimStateCompliance(S, USE_CUSTOM_SIM_STATE);\n');
        end

        function writeSetSimStateChecksum(this)
            this.Writer.writeLine([...
            this.ModelInterface.ModelRegisterSimStateChecksumFcnName,'(S);'...
            ]);
        end

        function writeModelSupportSymbolicDimensions(this)
            if(strcmp(this.ConfigSetUtils.getParam('AllowSymbolicDim'),'on'))
                this.Writer.writeLine('ssSetSymbolicDimsSupport(S, true);');
            end
        end

        function writeFunctionBody(this,~)
            this.writeBodyHeader;
            this.writeParameters;

            this.writeModelSupportSymbolicDimensions;

            inportWriter=...
            coder.internal.modelreference.PortInfoWriter.createInputPortInfoWriter(...
            this.ModelInterface,this.CodeInfo,this.Writer);

            outportWriter=...
            coder.internal.modelreference.PortInfoWriter.createOutputPortInfoWriter(...
            this.ModelInterface,this.CodeInfo,this.Writer);




            this.Writer.writeLine(...
            'slmrInitializeIOPortDataVectors(S, %d, %d);',...
            inportWriter.getNumberOfPorts,outportWriter.getNumberOfPorts);

            inportWriter.write;
            outportWriter.write;

            this.writeFunctionCallInfo;

            this.writeMessageQueuesInfo;

            this.writeSimStateComplianceDeclaration;
            this.writeSetSimStateChecksum;

            this.writeNumberOfSampleTimes;
            this.writeSFuntionWorkVectors;
            this.writeZeroCrossSignalInfos;
            this.writeSchedulingDiagramInfo;
            this.writeSetModelRefInlineVariables;
            this.writeSupportMultipleExecInstancesFlag;
            this.writeForEachInfo;
            this.writeSetModelOptions;
            this.writeMdlrefExportedMdlInfo;
            this.writeMdlrefDWorkType;
            this.writeSimulinkFunctionReg;
            this.writeModelRefSystemInitializeMethodReg;
            this.writeModelRefSystemResetMethodReg;
            this.writeModelRefPeriodicOutputUpdateMethodReg;
            this.writeSimulinkVersion;
            this.writeBodyTrailer;
        end


        function writeFunctionTrailer(this)
            this.Writer.writeLine('}');
        end

        function checkForModelBlock(this)


            this.Writer.writeLine([...
            ' if ((S->mdlInfo->genericFcn != %s) ',...
' && (!(S->mdlInfo->genericFcn)(S, GEN_FCN_CHK_MODELREF_SFUN_HAS_MODEL_BLOCK, -1, %s))) { return; }'...
            ],...
            coder.internal.modelreference.DataTypeUtils.getNullDefinition,...
            coder.internal.modelreference.DataTypeUtils.getNullDefinition);
        end

        function writeZeroCrossSignalInfos(this)
            this.ZeroCrossingInfoWriter.write;

            if strcmp(this.SolverType,'Variable-step')
                if this.ModelInterface.SolverResetInfo.ZCCacheNeedsReset
                    this.Writer.writeLine('ssSetZCCacheNeedsReset(S, 1);');
                end
                if this.ModelInterface.SolverResetInfo.DerivCacheNeedsReset
                    this.Writer.writeLine('ssSetDerivCacheNeedsReset(S, 1);');
                end
            end

            numberOfOutputPorts=length(this.ModelInterfaceUtils.Outports);
            for portIdx=1:numberOfOutputPorts
                this.Writer.writeLine('ssSetOutputPortIsNonContinuous(S, %d, %d);',...
                portIdx-1,this.ModelInterfaceUtils.Outports{portIdx}.NonContinuous);
                this.Writer.writeLine('ssSetOutputPortIsFedByBlockWithModesNoZCs(S, %d, %d);',...
                portIdx-1,this.ModelInterfaceUtils.Outports{portIdx}.FedByBlockWithModesNoZCs);
            end

            numberOfInputPorts=length(this.ModelInterfaceUtils.Inports);
            for portIdx=1:numberOfInputPorts
                this.Writer.writeLine('ssSetInputPortIsNotDerivPort(S, %d, %d);',...
                portIdx-1,~this.ModelInterfaceUtils.Inports{portIdx}.FeedsDerivPort);
            end

            this.writeModelRefInheritanceRule;
            this.writeModelRefMultiThreadingSupport;
        end

        function writeSupportMultipleExecInstancesFlag(this)
            if(isfield(this.ModelInterface,'ModelSupportsMultipleExecInstances')&&...
                this.ModelInterface.ModelSupportsMultipleExecInstances)
                this.Writer.writeLine('ssSupportsMultipleExecInstances(S, true);');
            else
                this.Writer.writeLine('ssSupportsMultipleExecInstances(S, false);');
                this.Writer.writeLine('ssRegisterMsgForNotSupportingMultiExecInst(S,"%s");',...
                this.ModelInterface.ModelMultipleExecInstancesNoSupportMsg);
            end
        end
    end



    methods(Access=protected)
        function writeBodyHeader(this)
            this.checkForModelBlock;

            this.Writer.writeLine('ssSetNumSFcnParams(S, 0);');





            this.Writer.writeLine('ssFxpSetU32BitRegionCompliant(S, 1);');


            this.initializeInfAndNaN;

            this.declareVariables;
            this.writeModelSettings;
        end


        function writeParameters(this)
            this.Writer.writeLine('ssSetRTWGeneratedSFcn(S, 2);');
            this.Writer.writeLine('ssSetNumContStates(S, %d);',this.ModelInterface.NumContStates);
            this.Writer.writeLine('ssSetNumDiscStates(S, 0);');
            if(this.ModelInterface.NumContStates>0)
                this.Writer.writeLine('ssSetNumPeriodicContStates(S, %d);',this.ModelInterface.NumPeriodicContStates);
            end
            if this.ModelInterface.ModelIsLinearlyImplicit
                this.Writer.writeLine('ssSetMassMatrixType( S, %s);',...
                this.ModelInterfaceUtils.getssMatrixType(this.ModelInterface.ModelMassMatrixType));
                this.Writer.writeLine('ssSetMassMatrixNzMax( S, %d);',this.ModelInterface.ModelMassMatrixNzMax);
            end
        end


        function writeMdlrefDWorkType(this)
            this.Writer.writeLine('/* DWork */');
            if this.ModelInterface.HasDWork
                this.Writer.writeLine('\n#if SS_SFCN_FOR_SIM\n');



                this.Writer.writeLine('if (ssSetNumDWork(S, 1)) {');
                this.Writer.writeLine('  int mdlrefDWTypeId;');
                this.Writer.writeLine('  ssRegMdlRefDWorkType(S, &mdlrefDWTypeId);');
                this.Writer.writeLine('  if (mdlrefDWTypeId == INVALID_DTYPE_ID ) return;');
                this.Writer.writeLine('  if (!ssSetDataTypeSize(S, mdlrefDWTypeId, sizeof(%s))) return;',...
                this.ModelInterface.DWorkType);
                this.Writer.writeLine('  ssSetDWorkDataType(S, 0, mdlrefDWTypeId);');
                this.Writer.writeLine('  ssSetDWorkWidth(S, 0, 1);');
                this.Writer.writeLine('}');
                this.Writer.writeLine('\n#else\n');
                this.Writer.writeLine('if ( !ssSetNumDWork(S, 1)) {return;}');
                this.Writer.writeLine('\n#endif\n');
            else
                this.Writer.writeLine('ssSetNumDWork(S, 0);');
            end
        end


        function writeMdlrefExportedMdlInfo(this)
            this.Writer.writeLine('\n#if SS_SFCN_FOR_SIM\n');
            this.Writer.writeLine('if (S->mdlInfo->genericFcn != %s && \n ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY) {',...
            coder.internal.modelreference.DataTypeUtils.getNullDefinition);
            this.Writer.writeLine('int_T retVal = 1;');
            this.Writer.writeLine('%s(S, %s, &retVal);',...
            this.getRegistrationFunctionName(this.CodeInfo.Name),...
            this.ModelInterfaceUtils.getStringLiteralCast(this.CodeInfo.Name));
            this.Writer.writeLine('if (!retVal) return;');
            this.Writer.writeLine('}');
            this.Writer.writeLine('\n#endif\n');
        end


        function writeBodyTrailer(this)

            if this.ModelInterfaceUtils.needAbsoluteTime
                this.Writer.writeLine('ssSetNeedAbsoluteTime(S, 1);');
            end

        end

        function init(this)
            this.SolverType=this.ConfigSetUtils.getParam('SolverType');

            this.IsAPeriodicTriggered=this.ModelInterface.IsAPeriodicTriggered;
            this.DisallowSampleTimeInheritance=this.ModelInterface.DisallowSampleTimeInheritance;

            this.IsFixedStepSolver=this.isFixedStepSolver;

            this.IsConstantBlock=this.ModelInterfaceUtils.isConstantBlock;

            this.SampleTimes=this.TimingInterfaceUtils.getSampleTimes;

            this.Inports=this.CodeInfo.Inports;
            this.NumberOfInputPorts=length(this.Inports);

            this.Outports=this.CodeInfo.Outports;
            this.NumberOfOutputPorts=length(this.Outports);

            this.ZeroCrossingInfoWriter=coder.internal.modelreference.ZeroCrossingInfoWriter(this.ModelInterfaceUtils,this.Writer);
        end


        function declareVariables(this)
            this.Writer.writeLine('if (S->mdlInfo->genericFcn != %s){',...
            coder.internal.modelreference.DataTypeUtils.getNullDefinition);
            this.Writer.writeLine('_GenericFcn fcn = S->mdlInfo->genericFcn;');

        end

        function status=isFixedStepSolver(this)
            status=strcmp(this.ConfigSetUtils.getParam('SolverType'),'Fixed-step');
        end

        function writeModelSettings(this)

            this.Writer.writeLine('}');
        end

        function initializeInfAndNaN(this)
            langStd=this.ConfigSetUtils.getParam('TargetLangStandard');
            if~slfeature('SupportNonfiniteLiterals')||...
                strcmp(langStd,'C89/C90 (ANSI)')||...
                strcmp(langStd,'C++03 (ISO)')
                this.Writer.writeLine('rt_InitInfAndNaN(sizeof(real_T));');
            end
        end


        function writeSetModelRefInlineVariables(this)
            this.Writer.writeLine('ssSetModelReferenceNormalModeSupport(S, MDL_START_AND_MDL_PROCESS_PARAMS_OK);');
        end


        function writeForEachInfo(this)
            if(isfield(this.ModelInterface,'ModelHasStateInsideForEachSS')&&...
                this.ModelInterface.ModelHasStateInsideForEachSS)
                this.Writer.writeLine('ssHasStateInsideForEachSS(S, true);');
            else
                this.Writer.writeLine('ssHasStateInsideForEachSS(S, false);');
            end
        end

        function writeSFuntionWorkVectors(this)
            this.Writer.writeLine('ssSetNumRWork(S, 0);');
            this.Writer.writeLine('ssSetNumIWork(S, 0);');
            this.Writer.writeLine('ssSetNumPWork(S, 0);');
            this.Writer.writeLine('ssSetNumModes(S, 0);');
        end


        function writeOriginalPortBusTypes(this,types,funcname)
            if(isempty(types))
                return;
            end

            if(~iscell(types))
                types={types};
            end

            for i=1:length(types)
                port=types{i}.Port;
                type=types{i}.BusType;

                this.Writer.writeLine([funcname,'(S, ',num2str(port),', "',type,'");']);
            end
        end
    end


    methods(Static,Access=private)
        function regFcnName=getRegistrationFunctionName(modelName)
            regFcnName=sprintf('mr_%s_MdlInfoRegFcn',modelName);
        end
    end
end





