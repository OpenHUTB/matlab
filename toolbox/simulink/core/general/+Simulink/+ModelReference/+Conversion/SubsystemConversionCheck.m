


classdef SubsystemConversionCheck<handle
    properties(Hidden,Access=public)
Systems
        ModelReferenceHandles=[]
        ModelBlocks=[]
        SubsystemPortBlocks={}
        UsedVariablesInModelWorkspace={}
        UsedVariablesInMaskWorkspace={}
        UsedVariablesByConfigsetInMWS={}
        UsedVariablesByConfigsetInMSK={}

        CheckModelForConversion=[]
        VirtualBusCheck=[]
ConversionParameters
    end
    properties(GetAccess=public,SetAccess=private)
DataAccessor
    end
    properties(GetAccess=protected,SetAccess=protected)





        IsVirtualSubsystem;
        Model;
        ConversionData;
        Logger;
    end

    properties(GetAccess=private,SetAccess=private)
ParameterMap
    end

    properties(Constant,Access=private)
        FindVarOptions={'SearchMethod','cached','FindUsedVars',true}
    end



    methods(Access=public)
        function checkExportedFunctionSubsystemImpl(this,currentSubsystem)



            exportFunctionChecks=coder.internal.RightClickBuild.create(this.Model,currentSubsystem,'ExportFunctions',true);
            exportFunctionChecks.checkExportFcnsCondition(currentSubsystem);


            this.ConversionParameters.ExportedFcn=true;
            if hIsEmptySubsystem(currentSubsystem)
                this.ConversionParameters.ExportedFcn=false;
            end









            results=this.CheckModelForConversion.checkModelSettingsForExportedFunction(get_param(this.Model,'Name'));
            numberOfErrors=length(results);
            if~isempty(results)
                me=MException(message('Simulink:modelReferenceAdvisor:invalidExportedFunctionSS',...
                this.ConversionData.beautifySubsystemName(currentSubsystem)));


                for idx=1:numberOfErrors
                    me=me.addCause(MException(results{idx}));
                end
                throw(me);
            end
        end

        function this=SubsystemConversionCheck(params)
            this.ConversionData=params;
            this.ConversionParameters=params.ConversionParameters;
            this.Logger=this.ConversionData.Logger;
            this.DataAccessor=this.ConversionData.DataAccessor;
            this.ParameterMap=this.ConversionData.ParameterMap;
            this.CheckModelForConversion=Simulink.ModelReference.Conversion.CheckModelForConversion(this.ConversionData);


            this.Model=this.ConversionParameters.Model;
            this.Systems=this.ConversionParameters.Systems;
            numberOfSubsystems=numel(this.Systems);
            this.IsVirtualSubsystem=zeros(numberOfSubsystems,1);
            this.ModelReferenceHandles=zeros(numberOfSubsystems,1);
            this.ModelBlocks=zeros(numberOfSubsystems,1);
        end

        function checkModelSettings(this)
            this.checkModelSettingsImpl;
        end

        function reset(this)
            this.IsVirtualSubsystem=zeros(numel(this.Systems),1);
        end

        function runBeforeCompilationChecks(this)
            arrayfun(@(currentSubsystem)this.checkSubsystemBeforeCompilation(currentSubsystem),this.Systems);
            this.checkStateflow;
            this.checkMaskedSubsystem;
            Simulink.ModelReference.Conversion.CheckStateRWBlocks.check(this.ConversionData);
            arrayfun(@(currentSubsystem)this.checkModelBeforeBuild(currentSubsystem),this.Systems);
        end

        function runAfterCompilationChecks(this)
            this.compile;

            Simulink.ModelReference.Conversion.GotoFromCheck.check(this.Systems,this.ConversionData,this);
            if(slfeature('scopeddsm')>0)
                Simulink.ModelReference.Conversion.ScopedDataStoreMemoryCheck.check(this.Systems,this.ConversionData);
            else
                Simulink.ModelReference.Conversion.DataStoreMemoryCheck.check(this.Systems,this.ConversionData);
            end
            Simulink.ModelReference.Conversion.PartitionsCheck.check(this.Systems,this.ConversionData);
            if isempty(this.ConversionData.BlockPriority)
                this.ConversionData.BlockPriority=Simulink.ModelReference.Conversion.BlockPrioritySort(this.Systems,this.ConversionParameters.ExportedFcn,this.ConversionParameters.SS2mdlForPLC);
                this.ConversionData.BlockPriority.sort;
            end
            this.VirtualBusCheck=Simulink.ModelReference.Conversion.VirtualBusCheck(this.ConversionData);
            this.VirtualBusCheck.check;

            arrayfun(@(currentSubsystem)this.checkSubsystemAfterCompilation(currentSubsystem),this.Systems);
        end


        function compile(this)
            this.ConversionData.ModelActions.compile;
            this.configureSubsystemPorts;
        end

        function throwErrorWhenBusObjectContainsMultiRates(this,compIOInfo)


            busName=compIOInfo.busName;
            if~isempty(busName)
                [mixed,busSampleTime]=Simulink.ModelReference.Conversion.SampleTimeUtils.getSampleTimeFromBus(this.DataAccessor,busName,-1);
                arrayfun(@(blk)this.throwErrorForBusObjContainsMultiRates(compIOInfo,mixed,busSampleTime,blk),compIOInfo.block);
            end
        end

        function checkMultiRateCollapsion(this,compiledIOInfo,currentSubsystem)



            if~this.ConversionParameters.CreateBusObjectsForAllBuses&&...
                iscell(compiledIOInfo.portAttributes.SampleTime)&&numel(compiledIOInfo.portAttributes.SampleTime)>1&&~compiledIOInfo.canExpand
                blockType=get_param(compiledIOInfo.block(1),'BlockType');
                if~(strcmp(blockType,'From')||strcmp(blockType,'Goto'))
                    portName=get_param(compiledIOInfo.block,'PortName');
                    if iscell(portName)
                        portName=portName{1};
                    end
                    this.Logger.addWarning(message('Simulink:modelReferenceAdvisor:MultiRatesLose',portName,...
                    get_param(currentSubsystem,'Name')));
                    return;
                end
            end
        end
    end



    methods(Hidden,Access=public)
        function checkSubsystemBeforeCompilation(this,currentSubsystem)
            this.checkSubsystemType(currentSubsystem);
            this.checkLinkToADirtyLibrary(currentSubsystem);
            this.checkRootOutportAsStateOwner(currentSubsystem);
            this.checkUnappliedConfigSetChanges(currentSubsystem);
        end

        function checkSubsystemAfterCompilation(this,currentSubsystem)
            this.getListOfParametersUsedBySubsystem(currentSubsystem);
            this.checkExportedFunctionSubsystem(currentSubsystem);
            this.checkVariantSubsystem(currentSubsystem);
            this.checkForLocalDworkCrossingSubsys(currentSubsystem);
            this.checkFcnCallSubsystem(currentSubsystem);
            this.checkForConstInputs(currentSubsystem);
            this.checkIfInportsAreMerged(currentSubsystem);
            this.checkNonBusSignalPassingMultiRates(currentSubsystem);
            this.checkForActualSrcDstSampleTimes(currentSubsystem);
            this.checkForVariableDimensionPorts(currentSubsystem);
            this.correctMustCopySubsystemSetting(currentSubsystem);
        end
    end



    methods(Access=private)

        function throwErrorForBusObjContainsMultiRates(this,compIOInfo,mixed,busSampleTime,blk)
            busName=compIOInfo.busName;
            blkType=get_param(blk,'BlockType');
            if~(strcmp(blkType,'From')||strcmp(blkType,'Goto'))
                portNumber=get_param(blk,'Port');
                if mixed
                    throw(MException(message('Simulink:modelReference:convertToModelReference_BusWithMixedSampleTimes',...
                    busName,blkType,portNumber)));
                else
                    if compIOInfo.portAttributes.IsTriggered&&...
                        ~isequal(busSampleTime,-1)
                        throw(MException(message('Simulink:modelReference:convertToModelReference_BusWithKnownTsInTriggerSS',...
                        busName,blkType,portNumber)));
                    end
                end
            end
        end

        function configureSubsystemPorts(this)
            subsys=this.ConversionParameters.Systems;
            N=numel(subsys);
            for idx=1:N
                this.SubsystemPortBlocks{idx}=Simulink.ModelReference.Conversion.Utilities.getSystemPortBlocks(subsys(idx));
                this.setCacheCompiledBus(idx);
            end
        end

        function getListOfParametersUsedBySubsystem(this,currentSubsystem)
            index=(this.Systems==currentSubsystem);
            varList=Simulink.findVars(this.ConversionParameters.getSystemName(currentSubsystem),this.FindVarOptions{:});
            N=numel(varList);
            mwIndexes=false(N,1);
            maskIndexes=false(N,1);
            for idx=1:N
                aVariable=varList(idx);
                if strcmpi(aVariable.SourceType,'model workspace')
                    mwIndexes(idx)=true;
                elseif strcmpi(aVariable.SourceType,'mask workspace')
                    maskIndexes(idx)=true;
                else


                end
            end
            this.UsedVariablesInModelWorkspace{index}=varList(mwIndexes);
            this.UsedVariablesInMaskWorkspace{index}=varList(maskIndexes);



            origModel=get_param(bdroot(currentSubsystem),'Name');
            variableUsedByConfigSet=Simulink.findVars(origModel,this.FindVarOptions{:});
            copyThisVariableToModelWorkspace=false(numel(variableUsedByConfigSet),1);
            copyThisVariableToMaskWorkspace=false(numel(variableUsedByConfigSet),1);
            for ii=1:numel(variableUsedByConfigSet)
                var=variableUsedByConfigSet(ii);
                if strcmpi(var.SourceType,'model workspace')
                    for uidx=1:numel(var.Users)
                        oneUser=var.Users{uidx};

                        if(strcmp(oneUser,origModel))
                            copyThisVariableToModelWorkspace(ii,1)=true;
                        end
                    end
                elseif strcmpi(var.SourceType,'mask workspace')
                    for uidx=numel(var.Users)
                        oneUser=var.Users{uidx};
                        if(strcmp(oneUser,origModel))
                            copyThisVariableToMaskWorkspace(ii,1)=true;
                        end
                    end
                end
            end
            this.UsedVariablesByConfigsetInMWS{index}=variableUsedByConfigSet(copyThisVariableToModelWorkspace);
            this.UsedVariablesByConfigsetInMSK{index}=variableUsedByConfigSet(copyThisVariableToMaskWorkspace);

        end

        function setCacheCompiledBus(obj,subsysIdx)
            subsysH=obj.ConversionParameters.Systems(subsysIdx);
            subsysPH=get_param(subsysH,'PortHandles');





            if Simulink.ModelReference.Conversion.Utilities.canCopyContent(subsysH)&&...
                ~obj.ConversionData.MustCopySubsystem
                inportBlocks=obj.SubsystemPortBlocks{subsysIdx}.inportBlksH.blocks;
                obj.SubsystemPortBlocks{subsysIdx}.inportBlksH.portHs=...
                arrayfun(@(portBlock)Simulink.ModelReference.Conversion.Utilities.getInportBlock(portBlock),inportBlocks)';

                outportBlocks=obj.SubsystemPortBlocks{subsysIdx}.outportBlksH.blocks;
                obj.SubsystemPortBlocks{subsysIdx}.outportBlksH.portHs=...
                arrayfun(@(portBlock)Simulink.ModelReference.Conversion.Utilities.getOutportBlock(portBlock),outportBlocks)';
            else
                obj.SubsystemPortBlocks{subsysIdx}.inportBlksH.portHs=subsysPH.Inport;
                obj.SubsystemPortBlocks{subsysIdx}.outportBlksH.portHs=subsysPH.Outport;
                obj.SubsystemPortBlocks{subsysIdx}.resetBlksH.portHs=subsysPH.Reset;
            end




            obj.SubsystemPortBlocks{subsysIdx}.enableBlksH.portHs=[];
            if~isempty(obj.SubsystemPortBlocks{subsysIdx}.enableBlksH.blocks)
                obj.SubsystemPortBlocks{subsysIdx}.enableBlksH.portHs=subsysPH.Enable;
            end

            obj.SubsystemPortBlocks{subsysIdx}.triggerBlksH.portHs=[];
            if~isempty(obj.SubsystemPortBlocks{subsysIdx}.triggerBlksH.blocks)
                if isempty(subsysPH.Trigger)
                    obj.SubsystemPortBlocks{subsysIdx}.triggerBlksH.blocks=[];
                    obj.SubsystemPortBlocks{subsysIdx}.triggerBlksH.portHs=[];
                else
                    obj.SubsystemPortBlocks{subsysIdx}.triggerBlksH.portHs=subsysPH.Trigger;


                    assert(numel(obj.SubsystemPortBlocks{subsysIdx}.triggerBlksH.blocks)==numel(subsysPH.Trigger));
                end
            end

            if~isempty(obj.SubsystemPortBlocks{subsysIdx}.resetBlksH.blocks)
                if isempty(subsysPH.Reset)
                    obj.SubsystemPortBlocks{subsysIdx}.resetBlksH.blocks=[];
                    obj.SubsystemPortBlocks{subsysIdx}.resetBlksH.portHs=[];
                else
                    obj.SubsystemPortBlocks{subsysIdx}.resetBlksH.portHs=subsysPH.Reset;


                    assert(numel(obj.SubsystemPortBlocks{subsysIdx}.resetBlksH.blocks)==numel(subsysPH.Reset));
                end
            else
                obj.SubsystemPortBlocks{subsysIdx}.resetBlksH.blocks=[];
                obj.SubsystemPortBlocks{subsysIdx}.resetBlksH.portHs=[];
            end

            if isfield(obj.SubsystemPortBlocks{subsysIdx},'fromBlksH')
                fromBlocks=obj.SubsystemPortBlocks{subsysIdx}.fromBlksH.blocks;
                obj.SubsystemPortBlocks{subsysIdx}.fromBlksH.portHs=...
                arrayfun(@(portBlock)Simulink.ModelReference.Conversion.Utilities.getInportBlock(portBlock),fromBlocks)';
            end
            if isfield(obj.SubsystemPortBlocks{subsysIdx},'gotoBlksH')
                gotoBlocks=obj.SubsystemPortBlocks{subsysIdx}.gotoBlksH.blocks;
                obj.SubsystemPortBlocks{subsysIdx}.gotoBlksH.portHs=...
                arrayfun(@(portBlock)Simulink.ModelReference.Conversion.Utilities.getOutportBlock(portBlock),gotoBlocks)';
            end
        end

        function checkForLocalDworkCrossingSubsys(this,currentSubsystem)
            localDworkCrossingChecker=Simulink.ModelReference.Conversion.LocalDworkCrossingChecker(this.ConversionData,currentSubsystem);
            localDworkCrossingChecker.check();
        end

        function handleDiagnostic(this,msg)
            if(this.ConversionParameters.Force)
                this.Logger.addWarning(msg);
            else
                throw(MSLException(msg));
            end
        end

        function checkIfInportsAreMerged(this,currentSubsystem)
            inportsMergedChecker=Simulink.ModelReference.Conversion.InportMergedChecker(this.ConversionData,this.SubsystemPortBlocks,currentSubsystem);
            inportsMergedChecker.check;
        end

        function checkForVariableDimensionPorts(this,currentSubsystem)
            vardimChecker=Simulink.ModelReference.Conversion.VariableDimensionPortsChecker(this.ConversionData,this.SubsystemPortBlocks,currentSubsystem);
            vardimChecker.check;
        end

        function checkFcnCallSubsystem(this,currentSubsystem)
            fcnCallSubsysChecker=Simulink.ModelReference.Conversion.FunctionCallSubsystemChecker(this.ConversionData,this.SubsystemPortBlocks,currentSubsystem);
            fcnCallSubsysChecker.check;
        end

        function checkVariantSubsystem(this,subsysH)

            if~isempty(get_param(subsysH,'CompiledLocalVVCE'))
                this.ConversionParameters.CreateBusObjectsForAllBuses=true;
            else
                subsysIdx=this.Systems==subsysH;
                portblks=this.SubsystemPortBlocks{subsysIdx};
                portBlks=[portblks.inportBlksH.blocks;portblks.outportBlksH.blocks;portblks.triggerBlksH.blocks;portblks.enableBlksH.blocks;portblks.resetBlksH.blocks];
                for ii=1:numel(portBlks)
                    if~isempty(get_param(portBlks(ii),'CompiledLocalVVCE'))
                        this.ConversionParameters.CreateBusObjectsForAllBuses=true;
                        break;
                    end
                end

                portHdls=get_param(subsysH,'PortHandles');
                portHdls=[portHdls.Inport,portHdls.Outport];
                for ii=1:numel(portHdls)
                    if slInternal('doesPortHaveVariantConditionsInCompileTime',portHdls(ii))
                        this.ConversionParameters.CreateBusObjectsForAllBuses=true;
                        break;
                    end
                end
            end
            if~strcmp(get_param(subsysH,'Commented'),'off')
                throw(MException(message('Simulink:modelReferenceAdvisor:CommentedSubsystem',...
                this.ConversionData.beautifySubsystemName(subsysH))));
            end

            if isequal(get_param(subsysH,'NotInCompiledModel'),'on')
                throw(MException(message('Simulink:modelReferenceAdvisor:SubsystemInInactiveVariant',...
                this.ConversionData.beautifySubsystemName(subsysH))));
            end
        end

        function checkLinkToADirtyLibrary(this,subsysH)
            subsysObj=get_param(subsysH,'object');
            if subsysObj.hasLinkToADirtyLibrary
                throw(MException(message('Simulink:modelReference:convertToModelReference_SubsystemHasLinkToADirtyLibrary',...
                this.ConversionData.beautifySubsystemName(subsysH))));
            end
            subsysObj.updateReference;
        end

        function checkRootOutportAsStateOwner(this,subsysH)
            subsysObj=get_param(subsysH,'object');
            child_blocks=find_system(subsysH,'LookUnderMasks','on','SearchDepth',1,'MatchFilter',@Simulink.match.allVariants);
            for ii=1:length(child_blocks)
                block_type=get_param(child_blocks(ii),'BlockType');
                if strcmp(block_type,'Outport')
                    if(strcmpi(get_param(child_blocks(ii),'IsStateOwnerBlock'),'on'))
                        stateAccessorMap=get_param(bdroot(child_blocks(ii)),'StateAccessorInfoMap');
                        for i=1:length(stateAccessorMap)
                            if(stateAccessorMap(i).StateOwnerBlock==child_blocks(ii))
                                throw(MException(message('Simulink:SubsystemReference:UnsupportedOutportBlockAsStateOwnerAtTopLevel',...
                                this.ConversionData.beautifySubsystemName(subsysH),...
                                getfullname(child_blocks(ii)))));
                            end
                        end
                    end
                end
            end
            subsysObj.updateReference;
        end

    end

    methods(Access=protected)
        function checkNonBusSignalPassingMultiRates(this,currentSubsystem)
            nonbusSignalMultiRatesChecker=Simulink.ModelReference.Conversion.NonBusSignalPassingMultiRatesChecker(this.ConversionData,currentSubsystem);
            nonbusSignalMultiRatesChecker.check;
        end
        function checkStateflow(this)
            Simulink.ModelReference.Conversion.StateflowCheck.check(this.ConversionData);
        end
        function checkMaskedSubsystem(this)
            Simulink.ModelReference.Conversion.MaskedSubsystemCheck.check(this.ConversionData);
        end

        function checkModelSettingsImplRCB(this)
            results=this.CheckModelForConversion.checkModelSettings;
            if~isempty(results)
                numberOfMessages=length(results);
                if this.ConversionParameters.Force
                    for errIdx=1:numberOfMessages
                        this.handleDiagnostic(results{errIdx});
                    end
                end
            end
        end

        function checkModelSettingsImpl(this)
            results=this.CheckModelForConversion.checkModelSettings;
            if~isempty(results)
                numberOfMessages=length(results);
                if~this.ConversionParameters.Force
                    me=MException(message('Simulink:modelReferenceAdvisor:invalidModelSettings'));
                    for errIdx=1:numberOfMessages
                        me=me.addCause(MException(results{errIdx}));
                    end
                    throw(me);
                else
                    for errIdx=1:numberOfMessages
                        this.handleDiagnostic(results{errIdx});
                    end
                end
            end
        end
        function checkUnappliedConfigSetChangesImpl(~,subsysH)
            origModel=bdroot(subsysH);
            origModelObj=get_param(origModel,'Object');
            origConfigSet=origModelObj.getActiveConfigSet();
            if~slprivate('checkSimPrm',origConfigSet)
                DAStudio.error('RTW:buildProcess:StopAtUserRequest');
            end
        end
        function checkUnappliedConfigSetChanges(~,~)

        end

        function checkForConstInputs(this,currentSubsystem)
            constInputChecker=Simulink.ModelReference.Conversion.ConstInputChecker(this.ConversionData,this.SubsystemPortBlocks,currentSubsystem);
            constInputChecker.check;
        end

        function checkModelBeforeBuild(~,~)

        end

        function checkExportedFunctionSubsystem(this,currentSubsystem)
            subsysIdx=find(this.Systems==currentSubsystem);

            if(this.IsVirtualSubsystem(subsysIdx)&&...
                (this.isFunctionCallInportsCrossingVirtualBoundary(currentSubsystem)||...
                this.ConversionData.FcnCallCrossBoundaryWithGotoFrom))
                this.checkExportedFunctionSubsystemImpl(currentSubsystem);
            else
                if this.IsVirtualSubsystem(subsysIdx)&&~this.ConversionData.SkipVirtualSubsystemCheck

                    this.ConversionData.addSystemFixObj(Simulink.ModelReference.Conversion.FixParameters(...
                    currentSubsystem,'TreatAsAtomicUnit','on',this.ConversionData));
                    throw(MException(message('Simulink:modelReferenceAdvisor:invalidSSTypeVirtual',...
                    this.ConversionData.beautifySubsystemName(currentSubsystem))));
                end
            end
        end

        function checkSubsystemType(this,currentSubsystem)
            checker=Simulink.ModelReference.Conversion.SubsystemTypeChecker(currentSubsystem,this.ConversionData);
            this.IsVirtualSubsystem(this.Systems==currentSubsystem)=checker.check();
        end

        function correctMustCopySubsystemSetting(~,~)

        end

        function checkForActualSrcDstSampleTimes(this,currentSubsystem)
            checker=Simulink.ModelReference.Conversion.ActualSrcDstSampleTimesChecker(this.Systems,this.SubsystemPortBlocks,this.ConversionParameters,this.Logger,currentSubsystem);
            checker.checkForActualSrcDstSampleTimes;
        end
    end

    methods(Static,Access=private)
        function status=isFunctionCallInportsCrossingVirtualBoundary(subsys)
            fcnCallInports=getCompiledFunctionCallInports(subsys);
            status=isfield(fcnCallInports,'Inports')&&~isempty(fcnCallInports.Inports);
        end
    end

    methods(Static,Access=public)
        function checkModelBeforeBuildStatic(block_hdl)
            origMdlHdl=bdroot(block_hdl);

            if~strcmp(get_param(origMdlHdl,'CheckMdlBeforeBuild'),'Off')
                msg=[];
                origMdlName=get_param(origMdlHdl,'Name');
                if isempty(get_param(origMdlHdl,'ObjectivePriorities'))

                    msg=message('RTW:configSet:objUnspecifiedWarning',origMdlName);
                elseif~coder.advisor.internal.runBuildAdvisor(block_hdl,false,true)

                    msg=message('Simulink:slbuild:advisorWarning');
                end
                if~isempty(msg)
                    if get_param(origMdlHdl,'CheckMdlBeforeBuild')=="Warning"
                        sldiagviewer.reportWarning(MSLException([],msg));
                    else
                        throw(MSLException([],msg));
                    end
                end
            end
        end
    end
end


function isEmpty=hIsEmptySubsystem(ssBlkH)
    blockList=find_system(ssBlkH,'SearchDepth',1,'LookUnderMasks','all',...
    'FollowLinks','on');
    for i=1:length(blockList)
        blkH=blockList(i);
        if isequal(blkH,ssBlkH)
            continue;
        end
        blockType=get_param(blkH,'BlockType');
        if strcmp(get_param(blkH,'virtual'),'on')&&...
            strcmpi(blockType,'Subsystem')
            if isEmptySubsystem(blkH)
                continue;
            else
                isEmpty=false;
                return;
            end
        end
        isEmpty=false;
        return;
    end
    isEmpty=true;
    return;
end


