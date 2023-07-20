


classdef RightClickBuildExportFunction<Simulink.ModelReference.Conversion.SubsystemConversion
    methods(Static,Access=public)
        function conversionObj=exec(varargin)
            conversionObj=Simulink.ModelReference.Conversion.RightClickBuildExportFunction(varargin{:});
            conversionObj.convert;
        end
    end


    methods(Access=public)
        function this=RightClickBuildExportFunction(subsys,varargin)
            subsys=Simulink.ModelReference.Conversion.Utilities.getHandles(subsys);
            this@Simulink.ModelReference.Conversion.SubsystemConversion(subsys,varargin{:});
            this.SubsystemConversionCheck=Simulink.ModelReference.Conversion.RightClickBuildExportFunctionCheck(this.ConversionData);
        end

        function convert(this)
            convert@Simulink.ModelReference.Conversion.SubsystemConversion(this);


            if this.ConversionParameters.CopySubsystem
                arrayfun(@(aModel)this.updateTriggerSubsystem(aModel),this.ModelReferenceHandles);
            end
            arrayfun(@(aModel)this.updateExportFunctionModel(aModel),this.ModelReferenceHandles);
            arrayfun(@(aModel)save_system(aModel),this.ModelReferenceHandles);
            arrayfun(@(aModel)this.customizedInitAndStepFunctionNames(this.ConversionParameters,aModel),this.ModelReferenceHandles);
            arrayfun(@(aModel)Simulink.ModelReference.Conversion.UpdateDescriptionAndRequirements.update(aModel),...
            this.ModelReferenceHandles);


            arrayfun(@(aModel)this.SubsystemConversionCheck.CheckModelForConversion.checkModelSettingsForExportedFunction(get_param(aModel,'Name')),...
            this.ModelReferenceHandles,'UniformOutput',false);
            this.ConversionData.runNewModelFixes;

            arrayfun(@(aModel)save_system(aModel),this.ModelReferenceHandles);
        end
    end


    properties(Constant,Access=private)
        SearchOptions={'SearchDepth',1,'IncludeCommented','off'};
    end


    methods(Access=protected)
        function isCopyContent=copySubsystemToModel(this,subsysIdx)
            modelRefHandle=this.ModelReferenceHandles(subsysIdx);
            currentSubsystem=this.Systems(subsysIdx);
            isCopyContent=Simulink.ModelReference.Conversion.Utilities.canCopyContent(currentSubsystem)&&...
            ~this.ConversionData.MustCopySubsystem;
            isSampleTimeIndependent=this.getOrigModelIsSampleTimeIndependent;

            if isCopyContent
                Simulink.SubSystem.copyContentsToBlockDiagram(currentSubsystem,modelRefHandle);
                subsystemBlockCopied=false;
            else
                Simulink.ModelReference.Conversion.CopySubsystemToNewModel.copy(currentSubsystem,modelRefHandle,this.ConversionParameters.CreateBusObjectsForAllBuses,containers.Map,this.ConversionParameters.RightClickBuild,isSampleTimeIndependent);
                subsystemBlockCopied=true;
            end


            this.resetBlockPriorities(subsysIdx,subsystemBlockCopied);
        end

        function sti=getOrigModelIsSampleTimeIndependent(this)
            sti=Simulink.ModelReference.Conversion.SampleTimeUtils.isSampleTimeIndependent(this.Model,true);
        end

        function inheritSampleTimeForInportOfExportModels(this,portInfoDataType,ioPortBlockInNewModel)



            isInportBlock=strcmp(get_param(ioPortBlockInNewModel,'BlockType'),'Inport');
            if isInportBlock&&~strcmpi(portInfoDataType,'fcn_call')

                set_param(ioPortBlockInNewModel,'SampleTime','-1');
            end
        end

        function setupCppClassGen(this,subsysIdx)%#ok
        end

        function setupModelStepSize(this,subsysIdx)%#ok
        end

        function copyFunctionPrototypeControl(this,subsysIdx)%#ok
        end

        function setupSampleTimeForGeneralPorts(this,compiledIOInfo,ioPortBlkInNewMdl,isSampleTimeIndependent,isTriggeredModel)
            if isSampleTimeIndependent
                this.inheritSampleTimeForInportOfExportModels(compiledIOInfo.portAttributes.DataType,ioPortBlkInNewMdl);
            else
                if~compiledIOInfo.isExpanded
                    Simulink.ModelReference.Conversion.SampleTimeUtils.setSampleTime(compiledIOInfo.portAttributes,compiledIOInfo.block,ioPortBlkInNewMdl,isTriggeredModel,true);
                end
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

        function runCustomizedCompileTimeCheck(this)
            arrayfun(@(aSystem)Simulink.ModelReference.Conversion.TriggeredSubsystemCheck.exec(this.ConversionData,aSystem),this.Systems);
        end

        function copyCodeMappings(this)
            numberOfSubsystems=numel(this.Systems);
            for subsysIdx=1:numberOfSubsystems
                this.copyCodeMappingsImpl(subsysIdx);
            end
        end

        function setupConfigurationParameters(this,subsysIdx,isCopyContent)
            modelRefHandle=this.ModelReferenceHandles(subsysIdx);
            currentSubsystem=this.Systems(subsysIdx);

            configSetter=Simulink.ModelReference.Conversion.ConfigurationParametersRightClickBuildExportFunction(this.ActiveConfigSet,this.ConversionData,...
            currentSubsystem,modelRefHandle,isCopyContent);
            configSetter.setupConfigurationParameters;
        end

        function resetBlockPriorities(this,subsysIdx,subsystemBlockCopied)

        end

        function setupPortBlockAttributes(this,ioPortBlkInNewMdl,compiledIOInfo,useNewTemporaryModel,fcnCallInportIndices,ioPortBlkIdx)
            this.setupPortBlockAttributes@Simulink.ModelReference.Conversion.SubsystemConversion(ioPortBlkInNewMdl,compiledIOInfo,useNewTemporaryModel,fcnCallInportIndices,ioPortBlkIdx);

            assert(useNewTemporaryModel==false);


            if any(ismember(fcnCallInportIndices,ioPortBlkIdx))&&strcmp(get_param(ioPortBlkInNewMdl,'BlockType'),'Inport')
                set_param(ioPortBlkInNewMdl,'OutputFunctionCall','on');
            end
        end

        function compIOInfo=updateCompIOInfoCanExpandField(this,createBusObjectsForAllBuses,compIOInfo)
            numberOfCompIOInfos=length(compIOInfo);
            for idx=1:numberOfCompIOInfos
                compIOInfo(idx).portAttributes=Simulink.CompiledPortInfo(compIOInfo(idx).port);
                if~createBusObjectsForAllBuses
                    compIOInfo(idx).canExpand=false;
                end
            end
        end

        function setupConfigSet(this,modelRefHandle,currentSubsystem,isCopyContent)
            configSet=Simulink.ModelReference.Conversion.ConfigSetExportFunction(currentSubsystem);
            configSet.setup(this.ActiveConfigSet,this.Model,modelRefHandle,this.Logger,isCopyContent);
        end

        function createNewTopModelAndModelBlock(this)
            if this.shouldCreateNewTopModelAndModelBlock

                this.createNewTopModel;

                this.createModelBlock;
            end
        end

        function shouldCreate=shouldCreateNewTopModelAndModelBlock(this)
            shouldCreate=~(strcmp(this.CreateSILPILBlock,'None'))||this.ConversionParameters.ReplaceSubsystem;
        end
    end


    methods(Access=private)
        function updateConfigset(this)
            if strcmp(get_param(this.ActiveConfigSet,'IsERTTarget'),'off')
                arrayfun(@(aModel)this.updateTarget(getActiveConfigSet(aModel)),this.ModelReferenceHandles);
            end
        end

        function updateTarget(this,cs)
            cs.switchTarget('ert.tlc',[]);
            cs.assignFrom(this.ActiveConfigSet,true);
        end


        function updateExportFunctionModel(~,modelH)
            cs=getActiveConfigSet(modelH);

            if~isa(cs,'Simulink.ConfigSetRef')
                set_param(modelH,'SolverMode','Auto');
                set_param(modelH,'CombineOutputUpdateFcns','on');

                if~strcmpi(get_param(modelH,'CodeInterfacePackaging'),'Nonreusable function')
                    set_param(modelH,'CodeInterfacePackaging','Nonreusable function');
                    warning(message('RTW:buildProcess:MultiInstanceERTCodeNotSupportedFcnCallErr'));
                end

                if~strcmpi(get_param(modelH,'GRTInterface'),'off')
                    set_param(modelH,'GRTInterface','off');
                    warning(message('RTW:buildProcess:GRTInterfaceNotSupportedFcnCallErr'));
                end

                if~strcmpi(get_param(modelH,'MatFileLogging'),'off')
                    set_param(modelH,'MatFileLogging','off');
                    warning(message('RTW:buildProcess:MatFileLoggingNotSupportedFcnCallErr'));
                end


                if~strcmp(get_param(modelH,'CreateSILPILBlock'),'None')
                    set_param(modelH,'CreateSILPILBlock','None');
                end


                set_param(modelH,'EnableRefExpFcnMdlSchedulingChecks','off');
            end
        end
    end

    methods(Static,Access=public)
        function customizedInitAndStepFunctionNames(params,aModel)
            if~isempty(params.ExpFcnInitFcnName)
                obj=RTW.ModelSpecificCPrototype;
                obj.attachToModel(aModel);
                obj.setFunctionName(params.ExpFcnInitFcnName,'init');
                obj.runValidation;
            end
        end
    end

    methods(Access=private)
        function updateTriggerSubsystem(this,aModel)
            blks=find_system(aModel,this.SearchOptions{:},'BlockType','SubSystem');
            for idx=1:numel(blks)
                subsys=blks(idx);
                ssType=Simulink.SubsystemType(subsys);
                if ssType.isTriggeredSubsystem||ssType.isFunctionCallSubsystem||...
                    ssType.isEnabledAndTriggeredSubsystem
                    triggerPort=find_system(subsys,this.SearchOptions{:},'LookUnderMasks','all','BlockType','TriggerPort');
                    ph=get_param(subsys,'PortHandles');
                    aLine=get_param(ph.Trigger,'Line');
                    srcBlk=get_param(aLine,'SrcBlockHandle');


                    if~ishandle(srcBlk)
                        return;
                    end


                    Simulink.ModelReference.Conversion.TriggeredSubsystemFix.convertTriggerToFunctionCall(subsys,triggerPort,srcBlk);
                end
            end
        end
    end
end
