classdef RightClickBuild<Simulink.ModelReference.Conversion.SubsystemConversion



    properties(SetAccess=private,GetAccess=public)
CompiledSampleTimes
FundStepSize
    end

    methods(Static,Access=public)
        function conversionObj=exec(varargin)
            conversionObj=Simulink.ModelReference.Conversion.RightClickBuildExportFunction(varargin{:});
            conversionObj.convert;
        end

        function busObjectName=getBusObjectNameFromDTOPrefixDecorationName(dtoBusObjectName)
            busObjectName=dtoBusObjectName;
            if~isempty(busObjectName)

                busObjectName=regexprep(busObjectName,'^dto(Dbl|Sgl|Scl)(Flt|Fxp)?_','');
            end
        end
    end

    methods(Access=public)
        function this=RightClickBuild(subsys,varargin)
            subsys=Simulink.ModelReference.Conversion.Utilities.getHandles(subsys);
            this@Simulink.ModelReference.Conversion.SubsystemConversion(subsys,varargin{:});
            this.SubsystemConversionCheck=Simulink.ModelReference.Conversion.RightClickBuildCheck(this.ConversionData);
        end

        function convert(this)
            convert@Simulink.ModelReference.Conversion.SubsystemConversion(this);

            arrayfun(@(aModel)this.trySetupNewModelSTIndependent(aModel),this.ModelReferenceHandles);
            this.checkModelContainsCustomCode;
        end

    end

    methods(Access=protected)
        function splitModifiedConfigSet(this,activeConfigSet,modelRefHandle,logger)
            newActiveConfigSet=[];
            if isa(activeConfigSet,'Simulink.ConfigSetRef')
                newActiveConfigSet=getRefConfigSet(activeConfigSet);
            end
            if~isempty(newActiveConfigSet)
                [configSetEqual,~]=isequal(getActiveConfigSet(get_param(modelRefHandle,'Name')),getRefConfigSet(activeConfigSet));
                if configSetEqual
                    attachConfigSetCopy(get_param(modelRefHandle,'Name'),activeConfigSet,true)
                    setActiveConfigSet(modelRefHandle,activeConfigSet.Name);
                    detachConfigSet(modelRefHandle,configSet.DefaultConfigSetName);
                end
            end
        end

        function setupConfigSet(this,modelRefHandle,currentSubsystem,isCopyContent)
            configSet=Simulink.ModelReference.Conversion.ConfigSetRightClickBuild(currentSubsystem);
            configSet.setup(this.ActiveConfigSet,this.Model,modelRefHandle,this.Logger,isCopyContent);
        end
        function setupCppClassGen(this,subsysIdx)
            newModel=this.ModelReferenceHandles(subsysIdx);
            subsys=this.Systems(subsysIdx);
            if rtwprivate('isCPPClassGenEnabled',this.ActiveConfigSet)&&...
                strcmpi(get_param(this.ActiveConfigSet,'IsCPPClassGenMode'),'on')
                interfaceConf=get_param(subsys,'SSRTWCPPFcnClass');
                if isempty(interfaceConf)
                    interfaceConf=RTW.ModelCPPDefaultClass('',newModel);
                end
                set_param(newModel,'RTWCPPFcnClass',interfaceConf);
            end
        end








        function setupModelStepSize(this,subsysIdx)
            newModel=this.ModelReferenceHandles(subsysIdx);
            subsys=this.Systems(subsysIdx);
            blkSampleTime=this.CompiledSampleTimes{subsysIdx};

            bSetFixedStepAuto=true;
            fixedStepPrm=get_param(this.Model,'FixedStep');

            bUseFundStepSize=false;
            bFundStepSize=str2double(get_param(this.Model,'CompiledStepSize'));
            if(strcmp(get_param(this.Model,'SolverType'),'Variable-step'))
                bFundStepSize=0;
            end

            if~strcmpi(fixedStepPrm,'auto')
                bSetFixedStepAuto=coder.internal.SampleTimeChecks.loc_shouldUseAutoFixedStep(subsys,bFundStepSize,blkSampleTime);
            else




                bUseFundStepSize=~coder.internal.SampleTimeChecks.loc_shouldUseAutoFixedStep(subsys,bFundStepSize,blkSampleTime);
            end
            bIsVariableStepSolver=strcmp(get_param(this.Model,'SolverType'),'Variable-step');

            if iscell(blkSampleTime)
                if((length(blkSampleTime)==2)&&...
                    (isequal(blkSampleTime{2},[inf,0])))
                    blkSampleTime=blkSampleTime{1};
                end
            end

            cs=getActiveConfigSet(newModel);
            if strcmp(get_param(cs,'AutosarCompliant'),'on')&&...
                ~iscell(blkSampleTime)&&...
                (blkSampleTime(1)~=-1)&&...
                (blkSampleTime(1)~=Inf)
                set_param(newModel,'FixedStep',num2str(blkSampleTime(1)));
            elseif(bUseFundStepSize&&~bIsVariableStepSolver)
                tsStr=sprintf('%.17g',bFundStepSize);
                set_param(newModel,'FixedStep',tsStr);
            elseif bSetFixedStepAuto
                set_param(newModel,'FixedStep','auto');
            end
            set_param(newModel,'SolverPrmCheckMsg','none');
        end
        function copyFunctionPrototypeControl(this,subsysIdx)
            newModel=this.ModelReferenceHandles(subsysIdx);
            subsys=this.Systems(subsysIdx);
            if ishandle(subsys)
                fcnprotoConf=get_param(subsys,'SSRTWFcnClass');
                if~isempty(fcnprotoConf)
                    if isa(fcnprotoConf,'RTW.ModelSpecificCPrototype')
                        if isempty(fcnprotoConf.InitFunctionName)
                            fcnprotoConf.InitFunctionName=[get_param(newModel,'name'),'_initialize'];
                        end
                    end
                    if~ishandle(fcnprotoConf.ModelHandle)
                        fcnprotoConf.ModelHandle=newModel;
                    end
                    set_param(newModel,'RTWFcnClass',fcnprotoConf);
                end
            end
        end
        function setupSampleTimeForGeneralPorts(this,compiledIOInfo,ioPortBlkInNewMdl,isSampleTimeIndependent,isTriggeredModel)
            this.inheritSampleTimeForInportOfExportModels(compiledIOInfo.portAttributes.DataType,ioPortBlkInNewMdl);
            if(~this.ConversionParameters.ExportedFcn)&&~isSampleTimeIndependent&&~compiledIOInfo.isExpanded
                Simulink.ModelReference.Conversion.SampleTimeUtils.setSampleTime(compiledIOInfo.portAttributes,compiledIOInfo.block,ioPortBlkInNewMdl,isTriggeredModel,true);
            end
        end
        function createModelMaskForNewModel(~,maskParams,newModel)%#ok
        end
        function cloneHarnessForSSConversion(this)%#ok

        end
        function changeSimulationModesToSIL(this,parentModel,mdlRef,mdlRefBlkH)
            isSilModelBlock=strcmp(get_param(this.Model,'CreateSILPILBlock'),'SIL');
            isPILModelBlock=strcmp(get_param(this.Model,'CreateSILPILBlock'),'PIL');
            set_param(parentModel,'SystemTargetFile',get_param(mdlRef,'SystemTargetFile'));
            set_param(parentModel,'UseDivisionForNetSlopeComputation',get_param(mdlRef,'UseDivisionForNetSlopeComputation'));
            if isSilModelBlock
                set_param(mdlRefBlkH,'SimulationMode','Software-in-the-loop');

                Simulink.ModelReference.Conversion.ChangeModelBlockSimulationMode.updateSILModelForRCB(mdlRef);
            end
            if isPILModelBlock
                set_param(mdlRefBlkH,'SimulationMode','Processor-in-the-loop');
            end
            set_param(mdlRefBlkH,'CodeInterface','Top model');
            set_param(mdlRef,'CreateSILPILBlock','None');
        end
        function copyCodeMappings(this)
            numberOfSubsystems=numel(this.Systems);
            for subsysIdx=1:numberOfSubsystems
                this.copyCodeMappingsImpl(subsysIdx);
            end
        end

        function runCustomizedCompileTimeCheck(this)
            this.CompiledSampleTimes=Simulink.ModelReference.Conversion.Utilities.cellify(...
            arrayfun(@(aSystem)get_param(aSystem,'CompiledSampleTime'),this.Systems,...
            'UniformOutput',false));
            this.FundStepSize=str2double(get_param(this.Model,'CompiledStepSize'));
        end

        function setupModelInfo(this,subsysIdx,isCopyContent)
            modelRefHandle=this.ModelReferenceHandles(subsysIdx);

            assert(this.ConversionParameters.RightClickBuild==true);
            setupModelInfo@Simulink.ModelReference.Conversion.SubsystemConversion(this,subsysIdx,isCopyContent);


            hasStateflow=true;
            if hasStateflow
                TLCOptions=get_param(modelRefHandle,'TLCOptions');
                TLCOptions=strcat(TLCOptions,' -aAlwaysIncludeCustomSrc=1');
                try
                    set_param(modelRefHandle,'TLCOptions',TLCOptions);
                catch ME

                end
            end
        end
        function setupConfigurationParameters(this,subsysIdx,isCopyContent)
            modelRefHandle=this.ModelReferenceHandles(subsysIdx);
            currentSubsystem=this.Systems(subsysIdx);

            configSetter=Simulink.ModelReference.Conversion.ConfigurationParametersRightClickBuild(this.ActiveConfigSet,this.ConversionData,...
            currentSubsystem,modelRefHandle,isCopyContent);
            configSetter.setupConfigurationParameters;
        end
        function resetBlockPriorities(this,subsysIdx,subsystemBlockCopied)
            modelRefHandle=this.ModelReferenceHandles(subsysIdx);
            currentSubsystem=this.Systems(subsysIdx);
            isCopyContent=~subsystemBlockCopied;
            this.ConversionData.BlockPriority.resetBlockPriority(currentSubsystem,modelRefHandle,isCopyContent);
        end

        function shouldCreate=shouldCreateNewTopModelAndModelBlock(this)
            shouldCreate=~(strcmp(this.CreateSILPILBlock,'None'))||this.ConversionParameters.ReplaceSubsystem;
        end
    end

    methods(Access=private)
        function trySetupNewModelSTIndependent(this,convertedModel)
            origModelCreateSILPIL=get_param(this.Model,'CreateSILPILBlock');
            if strcmp(origModelCreateSILPIL,'SIL')||strcmp(origModelCreateSILPIL,'PIL')

                origSampleTimeConstraintSetting=get_param(convertedModel,'SampleTimeConstraint');
                set_param(convertedModel,'SampleTimeConstraint','STIndependent');
                try
                    newModelAction=Simulink.ModelActions(convertedModel);
                    newModelAction.compile;
                    newModelAction.terminate;
                catch MME %#ok

                    set_param(convertedModel,'SampleTimeConstraint',origSampleTimeConstraintSetting);
                end
            end
            if strcmp(get_param(convertedModel,'Dirty'),'on')
                save_system(convertedModel);
            end
        end

        function checkModelContainsCustomCode(this)
            originalModelPath=fileparts(which(get_param(this.Model,'Name')));
            for idx=1:numel(this.Systems)
                aModel=this.ModelReferenceHandles(idx);
                convertModelPath=fileparts(which(get_param(aModel,'Name')));
                if~strcmp(originalModelPath,convertModelPath)&&this.containsCustomeCodeSettings
                    this.Logger.addWarning(message('Simulink:modelReference:convertToModelReference_DiffRefLocation',get_param(aModel,'Name'),convertModelPath,get_param(this.Model,'Name')));
                end
            end
        end

        function var=containsCustomeCodeSettings(this)
            model=this.Model;
            var=false;
            if strcmp(get_param(model,'RTWUseSimCustomCode'),'on')
                var=var|~isempty(get_param(model,'SimCustomSourceCode'));
                var=var|~isempty(get_param(model,'SimCustomHeaderCode'));
                var=var|~isempty(get_param(model,'SimCustomInitializer'));
                var=var|~isempty(get_param(model,'SimCustomTerminator'));
                var=var|~isempty(get_param(model,'SimUserIncludeDirs'));
                var=var|~isempty(get_param(model,'SimUserSources'));
                var=var|~isempty(get_param(model,'SimUserLibraries'));
                var=var|~isempty(get_param(model,'SimUserDefines'));
            else
                var=var|~isempty(get_param(model,'CustomSourceCode'));
                var=var|~isempty(get_param(model,'CustomHeaderCode'));
                var=var|~isempty(get_param(model,'CustomInitializer'));
                var=var|~isempty(get_param(model,'CustomTerminator'));
                var=var|~isempty(get_param(model,'CustomInclude'));
                var=var|~isempty(get_param(model,'CustomSource'));
                var=var|~isempty(get_param(model,'CustomLibrary'));
                var=var|~isempty(get_param(model,'CustomDefine'));
            end
        end
    end
end
