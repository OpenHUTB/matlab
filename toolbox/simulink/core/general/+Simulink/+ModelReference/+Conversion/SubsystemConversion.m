


classdef SubsystemConversion<handle
    properties(Transient,SetAccess=protected,GetAccess=protected)
Model
Systems

ReplaceSubsystem
CreateSILPILBlock
BuildTarget

SubsystemConversionCheck

ActiveConfigSet
NewActiveConfigSet

PortUtils
        Sandbox=[];
DataDictionary
        IsSuccess=false;
SubsystemChecksumToModelMap
System2Model
CommandMap
CheckMap
        CompiledIOInfo={}
        CachedGraphicalInfo={}
        CanRunNewModelFixes=false;
        HaveCreatedWrapperSystems=false;
    end

    properties(Transient,Hidden,SetAccess=protected,GetAccess=public)
ModelReferenceHandles
ConversionData
ConversionParameters
DataAccessor
Logger
ParentSystems
SystemZoomFactors
ParentZoomFactors
        NewTopModel=[]
        temporaryModelForVirtualBusExpansion_Handle=-1;
        expansionTable;
        CopyStrategies;
        CodeMappingCopier={};
        CompileTimeIOAttributes={}
    end

    properties(Constant,Access=private)
        SupportedCheckIds={
        DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorModelConfigurationsId')
        DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorSubsystemInterfaceId')
        DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorSubsystemContentId')
        DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorCompleteConversionId')
        DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorTerminateId')};
    end


    methods(Static,Access=public)
        function conversionObj=exec(varargin)
            conversionObj=Simulink.ModelReference.Conversion.SubsystemConversion(varargin{:});
            conversionObj.convert;


            if conversionObj.ConversionParameters.UseConversionDialog
                logger=conversionObj.Logger;
                aStage=Simulink.output.Stage('Diagnostics','ModelName',getfullname(conversionObj.Model),'UIMode',true);%#ok
                cellfun(@(aMsg)MSLDiagnostic(aMsg.Identifier,...
                'CATEGORY',DAStudio.message('Simulink:modelReferenceAdvisor:Category')).reportAsWarning,logger.getWarning);
                logger.clearWarning;


                cellfun(@(aMsg)Simulink.output.info(aMsg.getString,'MessageId',aMsg.Identifier,...
                'Category',DAStudio.message('Simulink:modelReferenceAdvisor:Category')),logger.getInfo);
                logger.clearInfo;
            end
        end
    end



    methods(Access=public)
        function this=SubsystemConversion(varargin)
            this.ConversionData=Simulink.ModelReference.Conversion.ConversionData(varargin{:});
            this.SubsystemConversionCheck=Simulink.ModelReference.Conversion.SubsystemConversionCheck(this.ConversionData);


            this.ConversionParameters=this.ConversionData.ConversionParameters;
            this.BuildTarget=this.ConversionParameters.BuildTarget;
            this.ReplaceSubsystem=this.ConversionParameters.ReplaceSubsystem;


            this.Model=this.ConversionParameters.Model;
            this.Systems=this.ConversionParameters.Systems;


            this.CreateSILPILBlock=get_param(this.Model,'CreateSILPILBlock');


            this.ActiveConfigSet=getActiveConfigSet(this.Model);


            this.PortUtils=Simulink.ModelReference.Conversion.PortUtils;
            this.Logger=this.ConversionData.Logger;
            this.DataAccessor=this.ConversionData.DataAccessor;
            this.DataDictionary=get_param(this.Model,'DataDictionary');


            this.SubsystemChecksumToModelMap=containers.Map;
            this.System2Model=containers.Map('KeyType','double','ValueType','char');
            this.expansionTable=containers.Map;


            if this.ConversionParameters.CheckSimulationResults
                params={this.Model,...
                {Simulink.ModelReference.Conversion.DefaultModificationObject('Baseline')},...
                'StopTime',this.ConversionParameters.StopTime,...
                'RelativeTolerance',this.ConversionParameters.RelativeTolerance,...
                'AbsoluteTolerance',this.ConversionParameters.AbsoluteTolerance,...
                'Logger',this.Logger};
                if this.ConversionParameters.TimeOut>0
                    params=horzcat(params,'TimeOut',this.ConversionParameters.TimeOut);
                end
                this.Sandbox=Simulink.Sandbox(params{:});
            end


            this.CommandMap={@()this.checkModelSettings
            @()this.runBeforeCompilationChecks
            @()this.runAfterCompilationChecks
            @()this.completeConversion
            @()this.ConversionData.ModelActions.terminate};




            if all(arrayfun(@(ss)slInternal('isSubsystem',ss)&&~Simulink.SubsystemType.hasLinkToADirtyLibrary(ss),...
                this.Systems))

                this.SystemZoomFactors=arrayfun(@(aBlk)get_param(aBlk,'ZoomFactor'),this.Systems,'UniformOutput',false);
                this.ParentZoomFactors=arrayfun(@(aBlk)get_param(get_param(aBlk,'Parent'),'ZoomFactor'),...
                this.Systems,'UniformOutput',false);
            end
        end

        function this=createWrapperSystems(this)
            if this.ConversionParameters.CreateWrapperSubsystem
                if~this.HaveCreatedWrapperSystems
                    wrapperCreater=Simulink.ModelReference.Conversion.WrapSubsystemCreater(this.ConversionData.ModelBlocks);
                    this.ParentSystems=wrapperCreater.create;
                    this.HaveCreatedWrapperSystems=true;
                end
            else
                this.ParentSystems=this.ConversionData.ModelBlocks;
            end
        end

        function delete(this)
            if~isempty(this.ConversionData)
                this.ConversionData.ModelActions.terminate;
            end

            if~this.IsSuccess

            end
        end

        function convert(this)
            counter=1;
            N=4;
            useAutoFix=this.ConversionParameters.UseAutoFix;
            while(counter<=N)
                numTopModelFixes=numel(this.ConversionData.TopModelFixes);
                numSystemFixes=numel(this.ConversionData.SystemFixes);
                try

                    checkObj=this.CommandMap{counter};
                    checkObj();

                    counter=counter+1;
                catch me
                    hasTopModelFixes=numel(this.ConversionData.TopModelFixes)~=numTopModelFixes;
                    hasSystemFixes=numel(this.ConversionData.SystemFixes)~=numSystemFixes;
                    if(hasTopModelFixes||hasSystemFixes)
                        runNow=useAutoFix;
                        if(runNow)

                            this.ConversionData.ModelActions.terminate;


                            this.runFixes;



                            counter=1;
                            this.ConversionData.Logger.clearWarning;
                            this.ConversionData.clearFixQueues;
                        else
                            throw(me);
                        end
                    else
                        throw(me);
                    end
                end
            end
        end
    end



    methods(Hidden,Access=public)
        function result=getIsSuccess(this)
            result=this.IsSuccess;
        end

        function checkModelSettings(this)
            this.SubsystemConversionCheck.checkModelSettings;
        end

        function runBeforeCompilationChecks(this)
            this.SubsystemConversionCheck.runBeforeCompilationChecks;
        end

        function runAfterCompilationChecks(this)
            this.SubsystemConversionCheck.runAfterCompilationChecks;
            this.runCustomizedCompileTimeCheck;
        end

        function runCheck(this,checkId)
            currentCheckIdx=find(strcmp(this.SupportedCheckIds,checkId),1);
            assert(~isempty(currentCheckIdx),'Unsupported check ID: %s',checkId);
            this.CommandMap{currentCheckIdx}();
        end


        function reset(this)
            this.SubsystemConversionCheck.reset;
        end

        function status=hasFix(this)
            status=~isempty(this.ConversionData.TopModelFixes)||...
            ~isempty(this.ConversionData.SystemFixes);
        end

        function runFixes(this)
            this.ConversionData.runTopModelFixes;
            this.ConversionData.runSystemFixes;
        end
    end


    methods(Access=protected)
        function createSubsystemWrapperAndCopyProperties(this)
            if this.shouldCreateNewTopModelAndModelBlock

                if this.ConversionParameters.CreateWrapperSubsystem
                    this.createWrapperSystems;
                    arrayfun(@(idx)this.CompileTimeIOAttributes{idx}.copy(this.ParentSystems(idx)),1:numel(this.Systems));
                end
                arrayfun(@(idx)this.CompileTimeIOAttributes{idx}.copy(this.ConversionData.ModelBlocks(idx)),1:numel(this.Systems));
            end
        end

        function isCopyContent=copySubsystemToModel(this,subsysIdx)
            modelRefHandle=this.ModelReferenceHandles(subsysIdx);
            currentSubsystem=this.Systems(subsysIdx);
            isCopyContent=Simulink.ModelReference.Conversion.Utilities.canCopyContent(currentSubsystem)&&...
            ~this.ConversionData.MustCopySubsystem;
            isSampleTimeIndependent=this.getOrigModelIsSampleTimeIndependent;

            if~this.ConversionParameters.CreateBusObjectsForAllBuses&&(this.temporaryModelForVirtualBusExpansion_Handle~=-1)
                wrapperSubsystem=get_param(get_param(this.temporaryModelForVirtualBusExpansion_Handle,'Name'),'Handle');



                subsystemBlks=find_system(wrapperSubsystem,'SearchDepth',1,'BlockType','SubSystem');
                assert(numel(subsystemBlks)==1,'At present, there is only one subsystem at the root level');
                subsysBlk=subsystemBlks(1);
                this.adjustRTWSystemCodeFromNonreusableToInline(subsysBlk);
                subsystemBlockCopied=true;
            else
                if isCopyContent
                    Simulink.SubSystem.copyContentsToBlockDiagram(currentSubsystem,modelRefHandle);
                    subsystemBlockCopied=false;
                else
                    Simulink.ModelReference.Conversion.CopySubsystemToNewModel.copy(currentSubsystem,modelRefHandle,this.ConversionParameters.CreateBusObjectsForAllBuses,containers.Map,this.ConversionParameters.RightClickBuild,isSampleTimeIndependent);
                    subsystemBlockCopied=true;
                end
            end


            this.resetBlockPriorities(subsysIdx,subsystemBlockCopied);
        end
        function setupPortBlockAttributes(this,ioPortBlkInNewMdl,compiledIOInfo,useNewTemporaryModel,fcnCallInportIndices,ioPortBlkIdx)%#ok
            if compiledIOInfo.isPureVirtualBus&&useNewTemporaryModel&&compiledIOInfo.isExpanded
                Simulink.ModelReference.Conversion.PortUtils.setBEPsExpandedFromPureVirtualBus(ioPortBlkInNewMdl,compiledIOInfo,this.ConversionParameters.RightClickBuild);
            else
                Simulink.ModelReference.Conversion.PortUtils.setIOAttributesForPortBlock(ioPortBlkInNewMdl,...
                compiledIOInfo.portAttributes,compiledIOInfo.busName,this.DataAccessor,this.ConversionParameters.RightClickBuild);
            end
        end

        function sti=getOrigModelIsSampleTimeIndependent(this)
            sti=Simulink.ModelReference.Conversion.SampleTimeUtils.isSampleTimeIndependent(this.Model,this.ConversionParameters.ExportedFcn);
        end
        function inheritSampleTimeForInportOfExportModels(this,portInfoDataType,ioPortBlockInNewModel)%#ok
        end

        function setupSampleTimeForGeneralPorts(this,compiledIOInfo,ioPortBlkInNewMdl,isSampleTimeIndependent,isTriggeredModel)%#ok
            if~isSampleTimeIndependent&&~compiledIOInfo.isExpanded
                Simulink.ModelReference.Conversion.SampleTimeUtils.setSampleTime(compiledIOInfo.portAttributes,compiledIOInfo.block,ioPortBlkInNewMdl,isTriggeredModel,false);
            end
        end

        function createModelMaskForNewModel(~,maskParams,newModel)


            if~isempty(maskParams)
                N=numel(maskParams);
                modelArgs={};
                for idx=1:N
                    aParam=maskParams{idx};
                    if strcmp(aParam.Tunable,'on')
                        modelArgs{end+1}=maskParams{idx}.Name;%#ok


                    end
                end

                if~isempty(modelArgs)
                    strbuf=modelArgs{1};
                    if(numel(modelArgs)>1)
                        numberOfModelArgs=numel(modelArgs);
                        for idx=2:numberOfModelArgs
                            strbuf=[strbuf,',',modelArgs{idx}];%#ok
                        end
                    end
                    set_param(newModel,'ParameterArgumentNames',strbuf);
                end



                modelMask=Simulink.Mask.create(newModel);


                paramNames=cellfun(@(aParam)aParam.Name,maskParams,'UniformOutput',false);
                N=numel(modelMask.Parameters);
                for idx=1:N
                    currentMaskParam=modelMask.Parameters(idx);
                    currentIndex=strcmp(currentMaskParam.Name,paramNames);
                    currentMaskParam.Value=maskParams{currentIndex}.Value;
                    currentMaskParam.Prompt=maskParams{currentIndex}.Prompt;
                end
            end
        end

        function cloneHarnessForSSConversion(this)
            assert(class(this)=="Simulink.ModelReference.Conversion.SubsystemConversion"&&~this.ConversionParameters.RightClickBuild,'harness clone only happens when general subsystem conversion happens');
            Simulink.harness.cloneHarnessForSSConversion(this,this.Logger);
        end

        function changeSimulationModesToSIL(~,parentModel,mdlRef,mdlRefBlkH)%#ok

        end

        function createModelBlock(this)
            numberOfSubsystems=numel(this.Systems);

            for subsysIdx=1:numberOfSubsystems
                subsysH=this.Systems(subsysIdx);
                mdlRef=this.System2Model(subsysH);
                mdlRefH=get_param(mdlRef,'Handle');


                parentModel=get_param(this.ConversionData.getScratchModel(subsysH),'Name');

                ssName=strrep(get_param(subsysH,'Name'),'/','//');
                mdlRefBlkH=add_block('built-in/ModelReference',[parentModel,'/',ssName],'makenameunique','on');
                set_param(mdlRefBlkH,'modelName',mdlRef,...
                'SimulationMode',this.ConversionParameters.SimulationModes{1});


                aModelBlockObj=get_param(mdlRefBlkH,'Object');
                aModelBlockObj.refreshModelBlock;

                this.CachedGraphicalInfo{end+1}=Simulink.ModelReference.Conversion.CopyGraphicalInfo.create(subsysH);
                this.CachedGraphicalInfo{end}.copy(mdlRefBlkH);



                Simulink.ModelReference.Conversion.Utilities.copyRMItoModelBlock(mdlRefH,mdlRefBlkH);


                this.changeSimulationModesToSIL(parentModel,mdlRef,mdlRefBlkH);

                this.ConversionData.ModelBlocks(subsysIdx)=mdlRefBlkH;


                modelBlockName=[parentModel,'/',ssName];
                Simulink.ModelReference.Conversion.ModelWorkspaceUtils.setupInstanceParameterValuesOnModelBlocks(mdlRef,modelBlockName);
            end

            this.CanRunNewModelFixes=true;
        end

        function runCustomizedCompileTimeCheck(this)%#ok
        end

        function copyCodeMappingsImpl(this,subsysIdx)
            modelRefHandle=this.ModelReferenceHandles(subsysIdx);
            copyContentStrategy=this.CopyStrategies{subsysIdx};
            if~isempty(this.CodeMappingCopier{subsysIdx})
                this.CodeMappingCopier{subsysIdx}.CopyCodeMappings(modelRefHandle,copyContentStrategy);
            end
        end

        function createERTCodeMappingsImpl(this,subsysIdx)
            modelRefHandle=this.ModelReferenceHandles(subsysIdx);
            if~isempty(this.CodeMappingCopier{subsysIdx})
                this.CodeMappingCopier{subsysIdx}.ConstructERTCodeMappings(modelRefHandle);
            end
        end

        function copyCodeMappings(this)
            ertModelMapping=Simulink.CodeMapping.get(this.Model,'CoderDictionary');
            isServiceInterfaceMapping=~isempty(ertModelMapping)&&...
            ertModelMapping.isFunctionPlatform;
            if this.ConversionParameters.CopyCodeMappings




                arrayfun(@(subsysIdx)this.copyCodeMappingsImpl(subsysIdx),1:numel(this.Systems));
            elseif isServiceInterfaceMapping
                arrayfun(@(subsysIdx)this.createERTCodeMappingsImpl(subsysIdx),1:numel(this.Systems));
            end
        end

        function setupModelStepSize(this,subsysIdx)%#ok
        end

        function setupModelInfo(this,subsysIdx,copyStrategy)
            modelRefHandle=this.ModelReferenceHandles(subsysIdx);
            currentSubsystem=this.Systems(subsysIdx);

            this.copyUsedModelWorkspaceVariables(modelRefHandle,this.SubsystemConversionCheck.UsedVariablesInModelWorkspace{subsysIdx});
            this.copyUsedModelWorkspaceVariables(modelRefHandle,this.SubsystemConversionCheck.UsedVariablesByConfigsetInMWS{subsysIdx});

            this.copyUsedMaskVariables(currentSubsystem,modelRefHandle,this.SubsystemConversionCheck.UsedVariablesInMaskWorkspace{subsysIdx});
            this.copyUsedMaskVariables(currentSubsystem,modelRefHandle,this.SubsystemConversionCheck.UsedVariablesByConfigsetInMSK{subsysIdx});


            set_param(modelRefHandle,'SetExecutionDomain',get_param(currentSubsystem,'SetExecutionDomain'));
            set_param(modelRefHandle,'ExecutionDomainType',get_param(currentSubsystem,'ExecutionDomainType'));


            set_param(modelRefHandle,'Location',get_param(currentSubsystem,'Location'));


            set_param(modelRefHandle,'ZoomFactor',get_param(currentSubsystem,'ZoomFactor'));


            if isempty(this.BuildTarget)&&...
                all(strcmp(this.ConversionParameters.SimulationModes,'Normal'))&&...
                ~isa(this.ActiveConfigSet,'Simulink.ConfigSetRef')
                set_param(modelRefHandle,'ArrayBoundsChecking','None');
            end


            Simulink.ModelReference.Conversion.Utilities.copyRMItoModel(currentSubsystem,modelRefHandle);


            simulinkSpec=Simulink.ModelReference.Conversion.SimulinkFunctionBlockSpecification(this.Model,this.Logger,copyStrategy);
            simulinkSpec.setupSpecifications(modelRefHandle,currentSubsystem);

            this.setTotalNumberOfInstanceToSingle(modelRefHandle,currentSubsystem);
            this.setupCppClassGen(subsysIdx);
            this.copyFunctionPrototypeControl(subsysIdx);
        end

        function setupConfigurationParameters(this,subsysIdx,isCopyContent)
            modelRefHandle=this.ModelReferenceHandles(subsysIdx);
            currentSubsystem=this.Systems(subsysIdx);
            configSetter=Simulink.ModelReference.Conversion.ConfigurationParameters(this.ActiveConfigSet,this.ConversionData,...
            currentSubsystem,modelRefHandle,isCopyContent);
            configSetter.setupConfigurationParameters;
        end

        function setupInstanceParameters(this,subsysIdx,isCopyContent,useNewTemporaryModel)
            currentSubsystem=this.Systems(subsysIdx);
            modelRefName=this.System2Model(currentSubsystem);
            Simulink.ModelReference.Conversion.ModelWorkspaceUtils.setupInstanceParameters(currentSubsystem,modelRefName,isCopyContent,...
            ~this.ConversionParameters.CreateBusObjectsForAllBuses&&useNewTemporaryModel);
        end

        function resetBlockPriorities(this,subsysIdx,subsystemBlockCopied)

        end

        function setupCppClassGen(this,subsysIdx)%#ok
        end

        function copyFunctionPrototypeControl(this,subsysIdx)%#ok
        end

        function compIOInfo=updateCompIOInfoCanExpandField(this,createBusObjectsForAllBuses,compIOInfo)%#ok
            numberOfCompIOInfos=length(compIOInfo);
            for idx=1:numberOfCompIOInfos
                compIOInfo(idx).portAttributes=Simulink.CompiledPortInfo(compIOInfo(idx).port);
            end
        end

        function setupConfigSet(this,modelRefHandle,currentSubsystem,isCopyContent)
            configSet=Simulink.ModelReference.Conversion.ConfigSet(currentSubsystem);
            configSet.setup(this.ActiveConfigSet,this.Model,modelRefHandle,this.Logger,isCopyContent);
        end

        function shouldCreate=shouldCreateNewTopModelAndModelBlock(this)
            shouldCreate=true;
        end

    end



    methods(Access=private)
        function ssPortBlks=removefield(~,ssPortBlks,field)

            if isfield(ssPortBlks,field)
                ssPortBlks=rmfield(ssPortBlks,field);
            end
        end

        function ssPortBlks=getSubsystemPortBlocksWithoutGotoFromLabels(this,subsysIdx)
            ssPortBlks=this.SubsystemConversionCheck.SubsystemPortBlocks{subsysIdx};
            this.removefield(ssPortBlks,'fromBlksH');
            this.removefield(ssPortBlks,'gotoBlksH');
        end

        function compIOInfo=genBusObjectAndCacheCompIOInfo(this,subsysIdx)
            currentSubsystem=this.Systems(subsysIdx);
            ssPortBlks=this.getSubsystemPortBlocksWithoutGotoFromLabels(subsysIdx);

            createBusObjectsForAllBuses=this.SubsystemConversionCheck.ConversionParameters.CreateBusObjectsForAllBuses;
            useTempModelAndNotCreateBusObjects=(this.temporaryModelForVirtualBusExpansion_Handle~=-1)&&~createBusObjectsForAllBuses;

            compIOInfo=Simulink.ModelReference.Conversion.PortUtils.getCompiledIOInfo(ssPortBlks,currentSubsystem,useTempModelAndNotCreateBusObjects);




            bclist=get_param(this.Model,'BackPropagatedBusObjects');
            displayWarningAboutBusName=false;

            isConvertingSubsystemToModelButNotExportFunctionModel=useTempModelAndNotCreateBusObjects&&~this.SubsystemConversionCheck.ConversionParameters.ExportedFcn;

            calculateSampleTimeForEachComponentOfVirtualBus=useTempModelAndNotCreateBusObjects;
            compIOInfo=sl('slbus_gen_object',compIOInfo,calculateSampleTimeForEachComponentOfVirtualBus,isConvertingSubsystemToModelButNotExportFunctionModel,...
            bclist,0,this.DataAccessor,displayWarningAboutBusName);


            compIOInfo=this.updateCompIOInfoCanExpandField(createBusObjectsForAllBuses,compIOInfo);


            numberOfCompIOInfos=length(compIOInfo);
            for idx=1:numberOfCompIOInfos
                this.SubsystemConversionCheck.throwErrorWhenBusObjectContainsMultiRates(compIOInfo(idx));
                this.SubsystemConversionCheck.checkMultiRateCollapsion(compIOInfo(idx),currentSubsystem);
            end
        end


        function finalizeConversionProcess(this)
            this.cloneHarnessForSSConversion;




            if any(cellfun(@(fixObj)fixObj.IsModifiedSystemInterface,this.ConversionData.ReferencedModelFixes))


                if~this.ConversionParameters.CreateWrapperSubsystem
                    this.ConversionParameters.CreateWrapperSubsystem=true;
                end
            end

            this.createSubsystemWrapperAndCopyProperties;


            this.ConversionData.runNewModelFixes;
            this.copyCodeMappings();

            if this.ConversionParameters.ReplaceSubsystem

                subsystemReplacer=Simulink.ModelReference.Conversion.SubsystemReplacer(...
                this.Model,this.ConversionData,this.ParentSystems,this.CachedGraphicalInfo,...
                this.temporaryModelForVirtualBusExpansion_Handle,this.expansionTable,this.CopyStrategies);
                subsystemReplacer.replace();
            end
        end

        function cacheBeforeCreateModel(this)
        end

        function cleanupReferencedModels(this)
            if~isempty(this.SubsystemChecksumToModelMap)


                newModelNames=Simulink.ModelReference.Conversion.Utilities.cellify(this.SubsystemChecksumToModelMap.values);
                cellfun(@(aModel)Simulink.ModelReference.Conversion.Utilities.cleanupModel(aModel),newModelNames);
            end
        end

        function completeConversion(this)
            this.IsSuccess=false;


            slreq.utils.onHierarchyChange('preChange',this.Model);

            collectVariableInfo=Simulink.ModelReference.Conversion.CollectVariableInformation(this.ConversionData,this.DataAccessor);
            collectVariableInfo.collectBeforeConversion;


            this.createModelFromSubsystem;

            collectVariableInfo.collectAfterConversion;


            this.CompileTimeIOAttributes=Simulink.ModelReference.Conversion.Utilities.cellify(...
            arrayfun(@(ss)Simulink.ModelReference.Conversion.CopyIOAttributes(ss),...
            this.Systems,'UniformOutput',false));

            this.ConversionData.ModelActions.terminate


            if this.ConversionParameters.ReplaceSubsystem
                this.ConversionData.runTopModelFixes;
            end


            this.SubsystemConversionCheck.VirtualBusCheck.updateNewModels(this.System2Model);
            this.SubsystemConversionCheck.VirtualBusCheck.insertSignalConversionBlocks;

            if this.shouldCreateNewTopModelAndModelBlock

                this.createNewTopModel;


                this.createModelBlock;
            end

            collectVariableInfo.collectData(this.CompiledIOInfo);


            this.finalizeConversionProcess;


            if this.ConversionParameters.UseConversionAdvisor
                arrayfun(@(subsys)this.Logger.addInfo(...
                message('Simulink:modelReferenceAdvisor:CompleteConversionMessage',...
                this.ConversionData.beautifySubsystemName(subsys),...
                Simulink.ModelReference.Conversion.MessageBeautifier.createRestoreHyperLink(...
                DAStudio.message('Simulink:modelReferenceAdvisor:RestoreOriginalModel')))),this.Systems);
            end

            if this.ConversionParameters.UseConversionAdvisor
                open_system(this.Model);
            end


            for idx=1:numel(this.ConversionParameters.ModelReferenceNames)
                aModel=this.ConversionParameters.ModelReferenceNames{idx};
                if strcmp(get_param(aModel,'Dirty'),'on')
                    save_system(aModel);
                end
            end


            if~isempty(this.BuildTarget)
                buildObj=Simulink.ModelReference.Conversion.BuildUtils(this.ConversionParameters.ModelReferenceNames,this.BuildTarget);
                buildObj.build;
            end


            this.ConversionData.saveData;


            slreq.utils.onHierarchyChange('postChange',this.Model);




            this.IsSuccess=true;




            if this.ConversionParameters.CheckSimulationResults&&this.ConversionParameters.ReplaceSubsystem
                modificationObjects=cellfun(@(simMode)Simulink.ModelReference.Conversion.ChangeModelBlockSimulationMode(...
                this.ConversionData.ModelBlocks,simMode),this.ConversionParameters.SimulationModes,'UniformOutput',false);
                this.Sandbox.check(modificationObjects);
                this.Sandbox.restoreOriginaryConfigSet;
            end
        end

        function cacheCodeMappings(this,codeMappingOfOriginalModel,currentSubsystem)
            if~isempty(codeMappingOfOriginalModel)&&~(this.ConversionParameters.SS2mdlForPLC)&&...
                (isa(codeMappingOfOriginalModel,'Simulink.CoderDictionary.ModelMapping')||...
                isa(codeMappingOfOriginalModel,'Simulink.CoderDictionary.ModelMappingSLC'))



                this.CodeMappingCopier{end+1}=coder.mapping.internal.createCodeMappingCopier(currentSubsystem,true);
                this.CodeMappingCopier{end}.CacheRootInportCodeMappings();
            else
                this.CodeMappingCopier{end+1}=[];
            end
        end

        function createModelFromSubsystem(this)
            numberOfSubsystems=numel(this.Systems);
            codeMappingOfOriginalModel=Simulink.CodeMapping.getCurrentMapping(this.Model);
            for subsysIdx=1:numberOfSubsystems
                currentSubsystem=this.Systems(subsysIdx);
                assert(ishandle(currentSubsystem)==true,'the variable currentSubsystem is not a handle');

                modelRefName=this.ConversionParameters.ModelReferenceNames{subsysIdx};




                subsysChecksum=Simulink.ModelReference.Conversion.Utilities.getSubsystemChecksum(currentSubsystem);
                if this.SubsystemChecksumToModelMap.isKey(subsysChecksum)
                    modelRefName=this.SubsystemChecksumToModelMap(subsysChecksum);
                else
                    modelRefHandle=new_system(modelRefName,'Model');


                    this.ModelReferenceHandles(end+1)=modelRefHandle;
                    this.SubsystemChecksumToModelMap(subsysChecksum)=modelRefName;
                    this.System2Model(currentSubsystem)=modelRefName;


                    this.cacheCodeMappings(codeMappingOfOriginalModel,currentSubsystem);


                    tempModelForVirtualBusCross=Simulink.ModelReference.Conversion.TemporaryModelForVirtualBusCrossing(this.ConversionParameters);
                    [this.temporaryModelForVirtualBusExpansion_Handle,useNewTemporaryModel,this.expansionTable]=tempModelForVirtualBusCross.generateTemporaryModel(currentSubsystem,modelRefHandle);



                    this.setupDataManagement(subsysIdx);


                    isCopyContent=this.copySubsystemToModel(subsysIdx);


                    this.setupConfigSet(modelRefHandle,currentSubsystem,isCopyContent);



                    metaData=get_param(modelRefHandle,'MetaData');
                    metaData.IsConvertedViaModelReference=true;
                    set_param(modelRefHandle,'Metadata',metaData);



                    copyContentStrategy=Simulink.ModelReference.Conversion.SubsystemCopyStrategy.copyStrategy(useNewTemporaryModel,isCopyContent);
                    this.CopyStrategies{end+1}=copyContentStrategy;
                    this.setupModelInfo(subsysIdx,copyContentStrategy);


                    this.setIOAttributes(subsysIdx,isCopyContent);
                    this.setupInstanceParameters(subsysIdx,isCopyContent,useNewTemporaryModel);
                    this.setupModelStepSize(subsysIdx);


                    if slfeature('ExecutionDomainExportFunction')==1



                        set_param(modelRefHandle,'TempMdlNeedsGraphSearch','on');
                    end
                    if slfeature('ExecutionDomainExportFunction')>0&&...
                        this.ConversionParameters.ExportedFcn
                        if~strcmpi(get_param(modelRefHandle,'SetExecutionDomain'),'on')
                            set_param(modelRefHandle,'SetExecutionDomain','on');
                        end
                        if~strcmpi(get_param(modelRefHandle,'ExecutionDomainType'),'ExportFunction')
                            set_param(modelRefHandle,'ExecutionDomainType','ExportFunction');
                        end
                    end

                    if this.ConversionParameters.UseConversionAdvisor
                        open_system(modelRefName);
                    end
                end


                this.System2Model(currentSubsystem)=modelRefName;
            end
        end

        function setupDataManagement(this,subsysIdx)
            modelRefHandle=this.ModelReferenceHandles(subsysIdx);

            if~isempty(this.DataDictionary)
                set_param(modelRefHandle,'DataDictionary',this.DataDictionary);
            end
            if slfeature('SLModelAllowedBaseWorkspaceAccess')>0
                set_param(modelRefHandle,'EnableAccessToBaseWorkspace',...
                get_param(this.Model,'EnableAccessToBaseWorkspace'));
            end
        end

        function setTotalNumberOfInstanceToSingle(~,modelRefHandle,currentSubsystem)



            toFileBlocks=find_system(currentSubsystem,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'BlockType','ToFile');
            if~isempty(toFileBlocks)&&strcmp(get_param(modelRefHandle,'ModelReferenceNumInstancesAllowed'),'Multi')
                set_param(modelRefHandle,'ModelReferenceNumInstancesAllowed','Single');
            end
        end

        function adjustRTWSystemCodeFromNonreusableToInline(~,subsysBlk)
            if strcmp(get_param(subsysBlk,'RTWSystemCode'),'Nonreusable function')
                set_param(subsysBlk,'RTWSystemCode','Inline');
            end
        end

        function copyUsedModelWorkspaceVariables(this,newModel,variables)
            modelWorkspaceUtils=Simulink.ModelReference.Conversion.ModelWorkspaceUtilsForSubsystemConversion(...
            this.Model,newModel,variables);
            modelWorkspaceUtils.setLogger(this.Logger);
            modelWorkspaceUtils.copy;
        end

        function copyUsedMaskVariables(this,subsys,newModel,variables)
            N=numel(variables);
            modelWorkspace=get_param(newModel,'ModelWorkspace');
            maskParams={};
            for idx=1:N
                aVariable=variables(idx);
                varName=aVariable.Name;
                blkName=aVariable.Source;


                if~Simulink.ModelReference.Conversion.Utilities.isChildBlock(subsys,blkName)
                    aMask=Simulink.Mask.get(aVariable.Source);
                    varList=aMask.getWorkspaceVariables;
                    index=arrayfun(@(item)strcmp(item.Name,varName),varList);
                    param=varList(index);
                    modelWorkspace.assignin(param.Name,param.Value);


                    maskParamIndex=arrayfun(@(item)strcmp(item.Name,varName),aMask.Parameters);
                    if any(maskParamIndex)
                        maskParams{end+1}=aMask.Parameters(maskParamIndex);%#ok
                    end
                end
            end

            this.createModelMaskForNewModel(maskParams,newModel);
        end

        function setupOneNewTopModel(this,aNewModel)

            if~isempty(this.DataDictionary)
                set_param(aNewModel,'DataDictionary',this.DataDictionary);
            end

            set_param(aNewModel,'ZoomFactor',this.ParentZoomFactors{1});
        end
        function createNewTopModel(this)
            this.ConversionData.createScratchModel;
            arrayfun(@(aNewModel)this.setupOneNewTopModel(aNewModel),this.ConversionData.ScratchModel);
        end



        function fcnCallInportIndices=getFunctionCallPortsIndices(~,subsys)

            fcnCallInports=getCompiledFunctionCallInports(subsys);
            fcnCallInports=fcnCallInports.Inports;
            fcnCallInportIndices=[];
            if~isempty(fcnCallInports)
                fcnCallInportIndices=-ones(numel(fcnCallInports),1);
                for ii=1:numel(fcnCallInports)
                    fcnCallInportIndices(ii)=fcnCallInports(ii).PortIdx+1;
                end
            end
        end





        function setExtraInportBlocksTransferedFromFunctionCallInports(this,...
            mdlRefPortBlkHs,...
            numberOfOriginalInports,...
            compIOInfo,...
            isTriggeredModel)

            if(numel(mdlRefPortBlkHs.inportBlksH.blocks)>numberOfOriginalInports)



                newInportBlks=mdlRefPortBlkHs.inportBlksH.blocks((numberOfOriginalInports+1):end);

                newInportCompIOInfo=compIOInfo((numberOfOriginalInports+1+numel(mdlRefPortBlkHs.outportBlksH.blocks)):end);
                for idx=1:numel(newInportBlks)
                    newInportBlk=newInportBlks(idx);
                    portInfo=newInportCompIOInfo(idx).portAttributes;

                    assert(strcmp(get_param(newInportBlk,'BlockType'),'Inport'));
                    Simulink.ModelReference.Conversion.PortUtils.setIOAttributesForPortBlock(newInportBlk,portInfo,newInportCompIOInfo(idx).busName,this.DataAccessor,this.ConversionParameters.RightClickBuild);
                    if strcmp(get_param(newInportBlk,'OutputFunctionCall'),'on')
                        set_param(bdroot(newInportBlk),'SampleTimeConstraint','Unconstrained');
                    end
                    if~this.getOrigModelIsSampleTimeIndependent
                        Simulink.ModelReference.Conversion.SampleTimeUtils.setSampleTime(portInfo,newInportCompIOInfo(idx).block,newInportBlk,isTriggeredModel,this.ConversionParameters.RightClickBuild);
                    end
                end
            end
        end


        function setupOneControlPortBlockAttributes(this,ctrlPorts,compIOInfosForCtrlPorts,isTriggeredModel,ctrlIdx)
            ctrlBlk=ctrlPorts(ctrlIdx);
            portInfo=compIOInfosForCtrlPorts(ctrlIdx).portAttributes;
            Simulink.ModelReference.Conversion.PortUtils.setIOAttributesForPortBlock(ctrlBlk,portInfo,compIOInfosForCtrlPorts(ctrlIdx).busName,this.DataAccessor,this.ConversionParameters.RightClickBuild);
            Simulink.ModelReference.Conversion.SampleTimeUtils.setSampleTime(portInfo,compIOInfosForCtrlPorts(ctrlIdx).block,ctrlBlk,isTriggeredModel,this.ConversionParameters.RightClickBuild);
        end
        function setupControlPortBlockAttributes(this,mdlRefPortBlkHs,compIOInfosForCtrlPorts,isTriggeredModel)



            ctrlPorts=[mdlRefPortBlkHs.enableBlksH.blocks;mdlRefPortBlkHs.triggerBlksH.blocks;mdlRefPortBlkHs.resetBlksH.blocks];
            arrayfun(@(ctrlIdx)this.setupOneControlPortBlockAttributes(ctrlPorts,compIOInfosForCtrlPorts,isTriggeredModel,ctrlIdx),1:numel(ctrlPorts));
        end

        function setupPortBlockStorageClass(this,ioPortBlkInNewMdl,compiledIOInfo)
            if this.ConversionParameters.PropagateSignalStorageClass
                isInportBlock=strcmp(get_param(ioPortBlkInNewMdl,'BlockType'),'Inport');
                if isInportBlock
                    tmpPortHs=get_param(ioPortBlkInNewMdl,'PortHandles');
                    tmpSrcPortH=tmpPortHs.Outport;
                else

                    tmpSrcPortH=Simulink.ModelReference.Conversion.PortUtils.getOutportBlockGraphicalSrc(ioPortBlkInNewMdl);
                end
                Simulink.ModelReference.Conversion.PortUtils.setOutportRTWStorageClass(tmpSrcPortH,compiledIOInfo.portAttributes);
            end
        end

        function setupPortBlockLabels(this,ioPortBlkInNewMdl,compiledIOInfo,subsys,isCopyContent)


            isInportBlock=strcmp(get_param(ioPortBlkInNewMdl,'BlockType'),'Inport');
            useNewTemporaryModel=(this.temporaryModelForVirtualBusExpansion_Handle~=-1);
            if isInportBlock
                if~Simulink.ModelReference.Conversion.isBusElementPort(ioPortBlkInNewMdl)
                    Simulink.ModelReference.Conversion.PortUtils.setupInportBlockLabel(subsys,...
                    compiledIOInfo.block,ioPortBlkInNewMdl,isCopyContent,useNewTemporaryModel,this.ConversionParameters.CreateBusObjectsForAllBuses);
                end
            else
                this.PortUtils.setupOutportBlockLabel(compiledIOInfo.block,ioPortBlkInNewMdl,compiledIOInfo.isExpanded);
            end
        end





        function setupPortBlockSampleTime(this,ioPortBlkInNewMdl,compiledIOInfo,useNewTemporaryModel,isTriggeredModel,subsystemType)
            isSampleTimeIndependent=this.getOrigModelIsSampleTimeIndependent;
            if compiledIOInfo.isPureVirtualBus&&useNewTemporaryModel&&compiledIOInfo.isExpanded








                useOriginalPortSampleTimeInfo=subsystemType.isIteratorSubsystem||subsystemType.isForIteratorSubsystem||subsystemType.isWhileIteratorSubsystem;
                if numel(compiledIOInfo.block)==1&&~Simulink.ModelReference.Conversion.isBusElementPort(compiledIOInfo.block)
                    sampTimeSettingOnOrigBlock=get_param(compiledIOInfo.block,'SampleTime');
                    isSampleTimeSetOnOrigBlock=~strcmp(strtrim(sampTimeSettingOnOrigBlock),'-1');
                    useOriginalPortSampleTimeInfo=isSampleTimeSetOnOrigBlock||useOriginalPortSampleTimeInfo;

                    if~isSampleTimeSetOnOrigBlock&&compiledIOInfo.isFromMultiRate

                        warningPortBlockType=get_param(compiledIOInfo.block,'BlockType');
                        warningPortIndex=get_param(compiledIOInfo.block,'Port');

                        if strcmp(warningPortBlockType,'Inport')
                            msg=message('Simulink:modelReference:convertToModelReference_multiRatesMaybeInvalidForBEPsIn',warningPortIndex);
                        else
                            msg=message('Simulink:modelReference:convertToModelReference_multiRatesMaybeInvalidForBEPsOut',warningPortIndex);
                        end

                        this.Logger.addWarning(msg);
                    end
                end

                if~compiledIOInfo.portAttributes.IsTriggered&&~strcmpi(mat2str(compiledIOInfo.Attribute.SampleTime),'Inf')&&...
                    ~isTriggeredModel
                    if~isSampleTimeIndependent
                        if useOriginalPortSampleTimeInfo
                            set_param(ioPortBlkInNewMdl,'SampleTime',compiledIOInfo.portAttributes.SampleTimeStr);
                        else
                            set_param(ioPortBlkInNewMdl,'SampleTime',mat2str(compiledIOInfo.Attribute.SampleTime));
                        end
                    end
                end
            else
                this.setupSampleTimeForGeneralPorts(compiledIOInfo,ioPortBlkInNewMdl,isSampleTimeIndependent,isTriggeredModel);
            end
        end

        function setIOAttributes(this,subsysIdx,isCopyContent)
            useNewTemporaryModel=(this.temporaryModelForVirtualBusExpansion_Handle~=-1);
            compIOInfo=this.genBusObjectAndCacheCompIOInfo(subsysIdx);




            this.CompiledIOInfo{subsysIdx}=...
            compIOInfo(arrayfun(@(x)~(strcmp(get_param(x.block(1),'BlockType'),'From')||strcmp(get_param(x.block(1),'BlockType'),'Goto')),compIOInfo));

            expandedCompIOInfos=Simulink.ModelReference.Conversion.PortUtils.expandCompIOInfo(compIOInfo,useNewTemporaryModel,this.ConversionParameters.CreateBusObjectsForAllBuses);

            subsys=this.Systems(subsysIdx);
            subsystemType=Simulink.SubsystemType(subsys);
            modelRefName=this.System2Model(subsys);
            mdlRefH=get_param(modelRefName,'Handle');

            isTriggeredModel=~isempty(find_system(mdlRefH,'SearchDepth','1','BlockType','TriggerPort'));

            mdlRefPortBlkHs=Simulink.ModelReference.Conversion.Utilities.getSystemPortBlocks(mdlRefH);





            if useNewTemporaryModel



                tempMdlName=get_param(this.temporaryModelForVirtualBusExpansion_Handle,'Name');
                portBlksInTempSubsys=Simulink.ModelReference.Conversion.Utilities.getSystemPortBlocks(tempMdlName);
                numberOfOriginalInports=numel(portBlksInTempSubsys.inportBlksH.blocks);
            else
                numberOfOriginalInports=numel(this.SubsystemConversionCheck.SubsystemPortBlocks{subsysIdx}.inportBlksH.blocks);
            end



































            if~isCopyContent
                this.setExtraInportBlocksTransferedFromFunctionCallInports(mdlRefPortBlkHs,numberOfOriginalInports,expandedCompIOInfos,isTriggeredModel);
            end



            nonSynthesizedIOPortInNewMdl=[mdlRefPortBlkHs.inportBlksH.blocks(1:numberOfOriginalInports);...
            mdlRefPortBlkHs.outportBlksH.blocks];



            if~isempty(expandedCompIOInfos)


                fcnCallInportIndices=this.getFunctionCallPortsIndices(subsys);

                for ioPortBlkIdx=1:numel(nonSynthesizedIOPortInNewMdl)
                    ioPortBlkInNewMdl=nonSynthesizedIOPortInNewMdl(ioPortBlkIdx);


                    compiledIOInfo=expandedCompIOInfos(ioPortBlkIdx);

                    isInportBlock=(ioPortBlkIdx<=numberOfOriginalInports);
                    assert(xor(strcmp(get_param(ioPortBlkInNewMdl,'BlockType'),'Inport'),isInportBlock)==false);
                    this.setupPortBlockAttributes(ioPortBlkInNewMdl,compiledIOInfo,useNewTemporaryModel,fcnCallInportIndices,ioPortBlkIdx);
                    this.setupPortBlockSampleTime(ioPortBlkInNewMdl,compiledIOInfo,useNewTemporaryModel,isTriggeredModel,subsystemType);
                    this.setupPortBlockLabels(ioPortBlkInNewMdl,compiledIOInfo,subsys,isCopyContent);
                    this.setupPortBlockStorageClass(ioPortBlkInNewMdl,compiledIOInfo)
                end


                if isempty(ioPortBlkIdx)
                    ioPortBlkIdx=0;
                end
                compIOInfosForCtrlPorts=expandedCompIOInfos(ioPortBlkIdx+1:end);
                this.setupControlPortBlockAttributes(mdlRefPortBlkHs,compIOInfosForCtrlPorts,isTriggeredModel);
            end
        end
    end
end




