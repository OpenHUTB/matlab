classdef AUTOSARComponentToImplConverter<systemcomposer.internal.arch.internal.SoftwareComponentToImplConverter








    properties(Access=protected)
        M3IComp;
        M3IModel;
        IsUIMode;
    end

    methods(Access=public)
        function obj=AUTOSARComponentToImplConverter(blkH,mdlName,dirPath,behaviorType,template,isUIMode)
            obj@systemcomposer.internal.arch.internal.SoftwareComponentToImplConverter(blkH,mdlName,dirPath,template);
            obj.IsUIMode=isUIMode;

            obj.ImplementComponentAs=behaviorType;
            if isUIMode
                obj.setErrorReporter(systemcomposer.internal.GraphicalErrorReporter)
            end
        end
    end

    methods(Access=protected)

        function runValidationChecksHook(obj)
            import autosar.composition.studio.CompBlockUtils
            import autosar.composition.studio.CompBlockCreateModel
            import autosar.composition.studio.AUTOSARComponentToImplConverter


            fileExists=~isempty(dir(fullfile(obj.DirPath,[obj.ModelName,'.slx'])));

            if(fileExists)
                if obj.IsUIMode
                    answer=questdlg(...
                    message('SystemArchitecture:SaveAndLink:SaveNameExistsWarning',obj.ModelName).string,...
                    message('SystemArchitecture:SaveAndLink:ReplaceWarning').string,...
                    message('SystemArchitecture:SaveAndLink:Yes').string,...
                    message('SystemArchitecture:SaveAndLink:No').string,...
                    message('SystemArchitecture:SaveAndLink:No').string);

                    if isempty(answer)||answer==message('SystemArchitecture:SaveAndLink:No').string
                        obj.ValidationPassed=false;
                        return;
                    end
                else
                    DAStudio.error('autosarstandard:editor:ModelFileAlreadyExists',...
                    getfullname(obj.BlockHandle),obj.ModelName);
                end
            end


            if(fileExists)
                assert(strcmp(answer,message('SystemArchitecture:SaveAndLink:Yes').string),...
                'Should only get here if user selected yes');
                delete(fullfile(obj.DirPath,[obj.ModelName,'.slx']));
            end


            obj.M3IComp=CompBlockUtils.getM3IComp(obj.BlockHandle);
            obj.M3IModel=obj.M3IComp.rootModel;




            if(slfeature('SaveAUTOSARCompositionAsArchModel')==0)
                assert(isa(obj.M3IComp,'Simulink.metamodel.arplatform.component.AtomicComponent')||...
                isa(obj.M3IComp,'Simulink.metamodel.arplatform.component.AdaptiveApplication'),...
                'Cannot create a model for non-atomic component %s',getfullname(obj.BlockHandle));
            end


            mdlAlreadyLoaded=~isempty(find_system('type','block_diagram','Name',obj.ModelName));
            if mdlAlreadyLoaded
                msgId='autosarstandard:editor:ModelAlreadyLoaded';
                obj.ValidationPassed=false;
                DAStudio.error(msgId,getfullname(obj.BlockHandle),obj.ModelName);
            end



            rootArchModel=bdroot(obj.BlockHandle);
            if Simulink.interface.dictionary.internal.DictionaryClosureUtils.isModelLinkedToInterfaceDict(...
                rootArchModel)
                AUTOSARComponentToImplConverter.validateAllPortsHaveAssignedInterface(obj.BlockHandle);
            end

            if isSoftwareArchEnabled()

                obj.validateFunctionPeriods();
                runValidationChecksHook@systemcomposer.internal.arch.internal.SoftwareComponentToImplConverter(obj);
            end


            autosarcore.unregisterListenerCB(obj.M3IModel);
        end

        function createImplModelHook(obj)

            if isa(obj.M3IComp,'Simulink.metamodel.arplatform.component.AtomicComponent')||...
                isa(obj.M3IComp,'Simulink.metamodel.arplatform.component.AdaptiveApplication')
                autosar.mm.mm2sl.ModelBuilder.getOrCreateSimulinkModel(obj.M3IComp,'error',obj.ModelName,obj.Template);
            else
                autosar.arch.createModel(obj.ModelName);
            end
            obj.ModelHandle=get_param(obj.ModelName,'Handle');
        end

        function postCreateImplModelHook(obj)
            if isSoftwareArchEnabled()
                postCreateImplModelHook@systemcomposer.internal.arch.internal.SoftwareComponentToImplConverter(obj);
            end

            obj.migrateInterfaceToDictionary();

            import autosar.composition.studio.BEPInterfacePropagationUtils;


            compositionModel=bdroot(obj.BlockHandle);
            schemaVer=get_param(compositionModel,'AutosarSchemaVersion');
            set_param(obj.ModelName,'AutosarSchemaVersion',schemaVer);
            set_param(obj.ModelName,'EnableMultiTasking','on');
            set_param(obj.ModelName,'SaveFormat','Dataset');
            set_param(obj.ModelName,'ReturnWorkspaceOutputs','on');






            BEPInterfacePropagationUtils.propagateInterfacesFromConnections(obj.BlockHandle);
        end

        function postCopyContentsToModelHook(obj)
            import autosar.composition.studio.BEPInterfacePropagationUtils

            if isSoftwareArchEnabled()
                postCopyContentsToModelHook@systemcomposer.internal.arch.internal.SoftwareComponentToImplConverter(obj);
            end

            compositionModel=bdroot(obj.BlockHandle);

            if slfeature('ScheduleEditorPrototypeModeling')>0
                assert(slfeature('SoftwareModelingAutosar')==0);
                obj.createInternalBehaviorRunnables();
            end



            BEPInterfacePropagationUtils.populateInterfaceInformationInModel(...
            compositionModel,obj.ModelName);

            if~autosar.composition.Utils.isModelInCompositionDomain(obj.ModelName)


                autosar.mm.mm2sl.layout.SkeletonModelBeautifier.beautifyModel(obj.ModelName);


                dictFile=get_param(compositionModel,'DataDictionary');
                if~isempty(dictFile)
                    set_param(obj.ModelName,'DataDictionary',dictFile);
                end


                origWarnState=warning('off','Simulink:Engine:NoBlocksInModel');
                autosar.api.create(obj.ModelName);
                warning(origWarnState);
            end

            m3iNewComp=autosar.api.Utils.m3iMappedComponent(obj.ModelName);
            tran=M3I.Transaction(m3iNewComp.rootModel);
            isAdaptive=Simulink.CodeMapping.isAutosarAdaptiveSTF(obj.ModelName);
            if~autosar.composition.Utils.isModelInCompositionDomain(obj.ModelName)
                if~isAdaptive

                    m3iNewComp.Kind=obj.M3IComp.Kind;
                end
                origCompPackage=autosar.mm.util.XmlOptionsAdapter.get(...
                obj.M3IComp.rootModel.RootPackage.front,'ComponentPackage');
                origCompQName=[origCompPackage,'/',obj.M3IComp.Name];
                defaultCompQName=autosar.api.Utils.getQualifiedName(m3iNewComp);
                if~strcmp(origCompQName,defaultCompQName)




                    arProps=autosar.api.getAUTOSARProperties(obj.ModelName);
                    arProps.set('XmlOptions','ComponentQualifiedName',origCompQName);

                    defaultCompPackage=autosar.mm.util.XmlOptionsDefaultPackages.ComponentsPackage;
                    curIntBehQName=arProps.get('XmlOptions','InternalBehaviorQualifiedName');
                    newIntBehQName=regexprep(curIntBehQName,defaultCompPackage,origCompPackage);
                    arProps.set('XmlOptions','InternalBehaviorQualifiedName',newIntBehQName);

                    curImpQName=arProps.get('XmlOptions','ImplementationQualifiedName');
                    newImpQName=regexprep(curImpQName,defaultCompPackage,origCompPackage);
                    arProps.set('XmlOptions','ImplementationQualifiedName',newImpQName);
                end
            end



            srcM3IModel=obj.M3IComp.rootModel;
            dstM3IModel=m3iNewComp.rootModel;
            autosar.composition.utils.XmlOptionsCopier.copyXmlOptionsAndSetToInherit(...
            srcM3IModel,dstM3IModel);

            tran.commit;

            if isAdaptive

                mapping=autosar.api.Utils.modelMapping(obj.ModelName);
                ports={mapping.Inports.Block,mapping.Outports.Block};
                autosar.validation.fixits.connectPortToEventRouting(ports{:});

                set_param(obj.ModelName,'EnableMultiTasking','off');
            end
        end

        function linkComponentToModelHook(obj)

            isUIMode=false;
            compToModelLinker=autosar.composition.studio.AUTOSARComponentToModelLinker(obj.BlockHandle,obj.ModelName,isUIMode);
            obj.BlockHandle=compToModelLinker.linkComponentToModel();
        end

        function postLinkComponentToModelHook(obj)


            if isSoftwareArchEnabled()
                postLinkComponentToModelHook@systemcomposer.internal.arch.internal.SoftwareComponentToImplConverter(obj);
            end

            dictFile=get_param(bdroot(obj.BlockHandle),'DataDictionary');
            if~isempty(dictFile)
                set_param(obj.ModelName,'DataDictionary',dictFile);
            end



            set_param(obj.BlockHandle,'CodeInterface','Top model');


            autosar.ui.utils.registerListenerCB(obj.M3IModel);
        end
    end

    methods(Static,Access=private)
        function validateAllPortsHaveAssignedInterface(blockOrModelName)
            blockOrModelName=getfullname(blockOrModelName);

            inportBlocks=find_system(blockOrModelName,'SearchDepth',1,...
            'BlockType','Inport','IsBusElementPort','on');
            outportBlocks=find_system(blockOrModelName,'SearchDepth',1,...
            'BlockType','Outport','IsBusElementPort','on');
            compositePorts=[inportBlocks;outportBlocks];
            if any(strcmp(get_param(compositePorts,'OutDataTypeStr'),'Inherit: auto'))
                portNames=autosar.api.Utils.cell2str(get_param(compositePorts,'PortName'));
                DAStudio.error('autosarstandard:editor:PortsHaveNoAssignedInterface',...
                portNames)
            end
        end
    end

    methods(Access=private)
        function createInternalBehaviorRunnables(obj)



            compositionModel=bdroot(obj.BlockHandle);
            tcg=sltp.TaskConnectivityGraph(compositionModel);
            partitions=tcg.getSortedChildTasks('');

            layoutManager=autosar.mm.mm2sl.layout.LayoutManagerFactory.getLayoutManager(...
            compositionModel,'TopModel',false,'SubSystem',...
            'LayoutStrategy','Matrix','DestinationSystem',obj.ModelName);

            for i=1:length(partitions)
                partitionQualifiedName=partitions{i};
                [partitionCompName,partitionName]=strtok(partitionQualifiedName,'.');
                partitionName=partitionName(2:end);
                if strcmp(partitionCompName,obj.M3IComp.Name)
                    partitionSampleTime=tcg.getRateSpecifiedSampleTime(partitionQualifiedName);

                    blkHandle=add_block('built-in/SubSystem',...
                    [obj.ModelName,'/',partitionName],...
                    'MakeNameUnique','on',...
                    'TreatAsAtomicUnit','on',...
                    'SystemSampleTime',partitionSampleTime);

                    set_param(blkHandle,...
                    'ScheduleAs','Periodic partition',...
                    'PartitionName',partitionName);

                    layoutManager.addBlock(getfullname(blkHandle),'isCentral',true);
                end
            end
            layoutManager.refresh();
        end

        function validateFunctionPeriods(obj)



            componentFcns=obj.getComponentFunctions();

            rootMdl=bdroot(obj.BlockHandle);
            for idx=1:numel(componentFcns)
                currFcn=componentFcns(idx);


                if isvarname(currFcn.period)&&~Simulink.data.existsInGlobal(rootMdl,currFcn.period)
                    DAStudio.error('SystemArchitecture:SaveAndLink:ErrorUndefinedVariableAsPeriod',...
                    currFcn.period,currFcn.getName());
                end


                period=Simulink.data.evalinGlobal(rootMdl,currFcn.period);
                if any(~isnumeric(period))||period(1)==0
                    DAStudio.error('SystemArchitecture:SaveAndLink:ErrorUnsupportedPeriod',...
                    period,currFcn.getName());
                end
            end
        end
    end
end

function tf=isSoftwareArchEnabled()
    tf=slfeature('SoftwareModelingAutosar')>0;
end



