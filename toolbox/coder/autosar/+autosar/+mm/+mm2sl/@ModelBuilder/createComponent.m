




function sysHandle=createComponent(self,m3iComp,...
    createSimulinkObject,nameConflictAction,...
    createTypes,createCalPrms,...
    modelPeriodicRunnablesAs,initializationRunnable,resetRunnables,...
    terminateRunnable,dataDictionary,...
    updateMode,autoDelete,modelName,openModel,useBusElementPorts,...
    forceLegacyWorkspaceBehavior,predefinedVariant)





    self.IsCompositionComponent=autosar.composition.Utils.isM3IComposition(m3iComp);

    self.slTypeBuilder.keepSLObj=createSimulinkObject;


    self.UpdateMode=updateMode;
    self.AutoDelete=autoDelete;
    self.UseBusElementPorts=useBusElementPorts;

    self.slModelName=modelName;


    assert(m3iComp.rootModel==self.m3iModel,'Expected root of component to be m3iModel');


    self.m3iComponent=m3iComp.asDeviant(self.m3iModel.asImmutable.getRootDeviant());


    if~self.IsCompositionComponent
        initRunnableFinder=autosar.mm.mm2sl.InitRunnableFinder();
        self.InitRunnable=initRunnableFinder.find(initializationRunnable,self.m3iComponent);

        resetRunnableFinder=autosar.mm.mm2sl.ResetRunnableFinder();
        self.ResetRunnables=resetRunnableFinder.find(resetRunnables,self.m3iComponent);

        terminateRunnableFinder=autosar.mm.mm2sl.TerminateRunnableFinder();
        self.TerminateRunnable=terminateRunnableFinder.find(terminateRunnable,self.m3iComponent);


        modelingStyleDeterminer=autosar.mm.mm2sl.PeriodicRunnablesModelingStyleDeterminer(...
        self.m3iComponent,self.InitRunnable,self.ResetRunnables,self.TerminateRunnable,self.m3iSwcTiming);
        [isStyleSupported,self.ModelPeriodicRunnablesAs,limitationMsgObj]=...
        modelingStyleDeterminer.isStyleSupported(modelPeriodicRunnablesAs);
        if~isStyleSupported
            arguments=[limitationMsgObj.Arguments...
            ,{DAStudio.message('autosarstandard:importer:ModelPeriodicRunnablesSuggestionMsg')}];
            DAStudio.error(limitationMsgObj.Identifier,arguments{:});
        end



        if strcmp(self.ModelPeriodicRunnablesAs,'FunctionCallSubsystem')&&...
            ~isempty(self.m3iComponent.Behavior)&&...
            self.m3iComponent.Behavior.isvalid()&&...
            self.m3iComponent.Behavior.isMultiInstantiable
            DAStudio.error('autosarstandard:importer:MultiInstanceMultipleRunnablesImport',...
            autosar.api.Utils.getQualifiedName(self.m3iComponent),...
            autosar.api.Utils.getQualifiedName(self.m3iComponent));
        end
    end



    trans=M3I.Transaction(self.m3iModel);
    if self.ShareAUTOSARProperties
        sharedM3IModel=autosar.dictionary.Utils.getUniqueReferencedModel(self.m3iModel);
        transShared=M3I.Transaction(sharedM3IModel);
    end

    if~self.IsCompositionComponent&&~self.m3iComponent.instanceMapping.isvalid()
        self.m3iComponent.instanceMapping=Simulink.metamodel.arplatform.instance.ComponentInstanceRef(self.m3iModel);
    end

    if~self.UpdateMode
        self.slModelName=autosar.mm.mm2sl.ModelBuilder.getOrCreateSimulinkModel(...
        self.m3iComponent,nameConflictAction,modelName);


        if~isempty(self.ResetRunnables)||~isempty(self.TerminateRunnable)


            set_param(self.slModelName,'IncludeMdlTerminateFcn','on');
        end
    end

    self.slPort2RefBiMap=autosar.mm.util.BiMap(...
    'InitCapacity',40,...
    'KeyType1','double',...
    'KeyType2','char',...
    'HashFcn2',@autosar.mm.util.InstanceRefHelper.getOrSetId);

    self.slPort2AccessMap=autosar.mm.util.Map(...
    'InitCapacity',40,...
    'KeyType','double');

    self.slIrvRef2RunnableMap=autosar.mm.util.Map(...
    'InitCapacity',10,...
    'KeyType','char',...
    'HashFcn',@autosar.mm.util.InstanceRefHelper.getOrSetId);

    self.ManualIRVAdditionsMap=containers.Map();


    ddName=dataDictionary;
    if~isempty(ddName)
        set_param(self.slModelName,'DataDictionary',ddName);
        workSpace=Simulink.dd.open(ddName);
    else
        workSpace='base';
    end
    modelWorkSpace=get_param(self.slModelName,'ModelWorkspace');


    if~self.IsCompositionComponent
        if~isvalid(self.m3iComponent.Behavior)
            self.createDefaultBehavior(self.m3iComponent);
        end
    end







    self.apply('mmVisit',self.m3iComponent);




    if~self.UpdateMode
        functionCallInports=find_system(self.slModelName,'SearchDepth',1,...
        'blocktype','Inport','OutputFunctionCall','on');
        if~isempty(functionCallInports)&&~self.m3iComponent.Behavior.isMultiInstantiable
            set_param(self.slModelName,'ModelReferenceNumInstancesAllowed','Single');
        end
    end


    m3iIrvRefs=self.slIrvRef2RunnableMap.getKeys();
    for ii=1:numel(m3iIrvRefs)
        data=self.slIrvRef2RunnableMap(m3iIrvRefs{ii});



        numSrc=numel(data.src);
        numDst=numel(data.dst);

        if numSrc<=1
            if numDst<1

                self.createSourceIrvPort(m3iIrvRefs{ii},data.src);
            else
                for jj=1:numDst
                    self.connectIrvPorts(m3iIrvRefs{ii},data.src,data.dst(jj));
                end
            end
        elseif numDst<=1
            if numSrc<1

                self.createDestinationIrvPort(m3iIrvRefs{ii},data.dst)
            else
                for jj=1:numSrc
                    self.connectIrvPorts(m3iIrvRefs{ii},data.src(jj),data.dst);
                end
            end
        else

            for jj=1:numSrc
                self.connectIrvPorts(m3iIrvRefs{ii},data.src(jj),data.dst(1));
            end


            for jj=2:numDst
                self.connectIrvPorts(m3iIrvRefs{ii},data.src(1),data.dst(jj));
            end
        end
    end





    m3iIrvRefs=self.slIrvRef2RunnableMap.getKeys();
    for ii=1:numel(m3iIrvRefs)
        m3iIrvRef=m3iIrvRefs{ii};
        data=self.slIrvRef2RunnableMap(m3iIrvRef);
        if~isempty(data)
            numSrc=numel(data.src);
            numDst=numel(data.dst);

            if(numSrc==1)&&(numDst==1)&&isequal(data.src,data.dst)

                autosar.mm.util.MessageReporter.createWarning(...
                'autosarstandard:importer:RunnableWithSelfFeedbackIRV',...
                m3iIrvRef.DataElements.Name,getfullname(data.src));


                self.slIrvRef2RunnableMap.remove(m3iIrvRef);
                m3iIrvRef.DataElements.destroy();
                m3iIrvRef.destroy();


                m3iAccess=data.m3iAccess;
                for accIdx=1:length(m3iAccess)
                    if m3iAccess(accIdx).isvalid()
                        m3iAccess(accIdx).destroy();
                    end
                end
            end
        end
    end


    if self.UpdateMode
        irvNames=self.ManualIRVAdditionsMap.keys();
        for ii=1:numel(irvNames)
            irvName=irvNames{ii};
            if strcmp(self.ModelPeriodicRunnablesAs,'AtomicSubsystem')
                modelText=sprintf('<a href="matlab:open_system(''%s'')">%s</a>',self.slModelName,self.slModelName);
                self.ChangeLogger.logAddition('Manual','RateTransition',...
                'block',modelText,['InterRunnableVariable ',irvName]);
            else
                data=self.ManualIRVAdditionsMap(irvName);
                srcSubsys=sprintf('<a href="matlab:hilite_system(''%s'')">%s</a>',data.src,data.src);
                dstSubsys=sprintf('<a href="matlab:hilite_system(''%s'')">%s</a>',data.dst,data.dst);
                self.ChangeLogger.logAddition('Manual','Signal line',...
                ['from ',srcSubsys,' to ',dstSubsys],self.slModelName,['InterRunnableVariable ',irvName]);
            end
        end
    end

    shouldRunMemSecBuilder=false;



    initValueParamSet=autosar.mm.util.Set(...
    'InitCapacity',20,...
    'KeyType','char',...
    'HashFcn',@(x)x);
    if~self.IsCompositionComponent
        if m3iComp.Behavior.isvalid()
            slSignalBuilder=autosar.mm.mm2sl.SignalBuilder(self.m3iModel,self.slTypeBuilder,...
            self.slConstBuilder,self.ChangeLogger,...
            self.SLModelBuilder.getSLMatcher(),...
            initValueParamSet,...
            self.NVServiceNeedsPIMSet);
            slSignalBuilder.buildComponentSignals(workSpace,modelWorkSpace,m3iComp,forceLegacyWorkspaceBehavior);
            shouldRunMemSecBuilder=slSignalBuilder.RequiresLegacyMemorySectionDefinitions;
        end
    end


    if createCalPrms

        slParams=self.slParameterBuilder.buildComponentParameter(workSpace,modelWorkSpace,m3iComp,true,self.SLModelBuilder.getSLMatcher(),initValueParamSet,forceLegacyWorkspaceBehavior);
        self.slParameterBuilder.buildVariantConfigurations(workSpace,...
        self.slModelName,predefinedVariant);

        if~isempty(slParams)
            modelArgParams={};
            slParams=[slParams{:}];
            for paramIdx=1:length(slParams)
                param=slParams(paramIdx);
                if~isempty(param.slObj)&&~isempty(param.codeProperties.paramType)


                    assert(~isempty(param.name),'Parameter name cannot be empty');
                    if any(strcmp(param.codeProperties.paramType,{'PerInstanceParameter','PortParameter'}))
                        modelArgParams=[modelArgParams,param.name];%#ok<AGROW>
                    end
                    self.SlParamMap(param.name)=param.codeProperties;
                end
            end





            modelArgsStr=get_param(self.slModelName,'ParameterArgumentNames');
            if~isempty(modelArgsStr)
                modelArgs=strsplit(modelArgsStr,',');
            else
                modelArgs={};
            end
            updatedModelArgs=unique([modelArgs,modelArgParams]);
            updatedParamArgStr=join(updatedModelArgs,',');
            set_param(self.slModelName,'ParameterArgumentNames',updatedParamArgStr{1});
        end
        shouldRunMemSecBuilder=shouldRunMemSecBuilder||self.slParameterBuilder.RequiresLegacyMemorySectionDefinitions;
    end

    if~self.IsCompositionComponent


        self.SLModelBuilder.refreshModelLayout();
        self.SLModelBuilder.reportDeletions();
        self.SLModelBuilder.markupAdditions();
    end



    if createTypes
        self.slTypeBuilder.createAll(workSpace);

        if isempty(ddName)

            enumFileName=[self.slModelName,'_defineIntEnumTypes'];
            enumFileName=autosar.mm.mm2sl.ModelBuilder.checkEnumFileName(nameConflictAction,enumFileName);
            enumFileName=[enumFileName,'.m'];
            self.slTypeBuilder.createEnumsFile(enumFileName);
        end
    end



    sigNames=self.DsmBlockMap.keys;
    dsmContext=self.DsmBlockMap.values;
    for ii=1:numel(dsmContext)
        blkHandle=dsmContext{ii}.blkH;
        [sigExists,sigObj]=autosar.utils.Workspace.objectExistsInModelScope(self.slModelName,sigNames{ii});
        if sigExists
            autosar.mm.mm2sl.ModelBuilder.set_param(self.ChangeLogger,...
            blkHandle,'StateMustResolveToSignalObject','on');
            if isa(sigObj,'Simulink.Signal')
                if~isempty(sigObj.InitialValue)&&~strcmp(sigObj.InitialValue,'[]')
                    autosar.mm.mm2sl.ModelBuilder.set_param(self.ChangeLogger,...
                    blkHandle,'InitialValue',sigObj.InitialValue);
                end
                autosar.mm.mm2sl.ModelBuilder.set_param(self.ChangeLogger,...
                blkHandle,'SignalType',sigObj.Complexity);
            end
        end
    end
    self.SLLookupTableBuilder.addLookupTableBlocks();
    self.SLLookupTableBuilder.connectLookupTableBlocks(self.slPort2RefBiMap,...
    self.ModelPeriodicRunnablesAs,self.UpdateMode);




    clientBlks=arblk.findAUTOSARClientBlks(self.slModelName);
    for ii=1:length(clientBlks)
        showErrorStatus=get_param(clientBlks{ii},'showErrorStatus');
        set_param(clientBlks{ii},'showErrorStatus',showErrorStatus);
    end



    if~self.IsCompositionComponent
        self.SLModelBuilder.addterms();
        self.SLModelBuilder.addEventRoutingBlocks();
    end



    isAdaptiveCompExpFcnStyle=false;
    if isa(m3iComp,'Simulink.metamodel.arplatform.component.AdaptiveApplication')
        isAdaptiveCompExpFcnStyle=self.SLModelBuilder.convertToExportFunctionStyle();
    end

    if self.slTypeBuilder.needsLongLong()

        autosar.mm.mm2sl.SLModelBuilder.set_param(self.ChangeLogger,...
        self.slModelName,'ProdLongLongMode','on');
    end

    if slfeature('ExecutionDomainExportFunction')>0
        if(~isa(m3iComp,'Simulink.metamodel.arplatform.component.AdaptiveApplication')&&...
            strcmp(self.ModelPeriodicRunnablesAs,'FunctionCallSubsystem'))||...
isAdaptiveCompExpFcnStyle


            set_param(self.slModelName,'SetExecutionDomain','on');
            set_param(self.slModelName,'ExecutionDomainType','ExportFunction');
        elseif strcmp(self.ModelPeriodicRunnablesAs,'Auto')

            functionCallInports=find_system(self.slModelName,'SearchDepth',1,...
            'blocktype','Inport','OutputFunctionCall','on');
            asyncTaskSpecs=find_system(self.slModelName,'SearchDepth',1,...
            'blocktype','AsynchronousTaskSpecification');
            if~isempty(functionCallInports)&&isempty(asyncTaskSpecs)
                set_param(self.slModelName,'SetExecutionDomain','on');
                set_param(self.slModelName,'ExecutionDomainType','ExportFunction');
            end
        end
    end


    if openModel
        open_system(self.slModelName);
    end


    if~isempty(ddName)
        if openModel
            workSpace.explore();
        end
        workSpace.close();
    end

    if shouldRunMemSecBuilder

        memSectionBuilder=autosar.mm.mm2sl.MemorySectionBuilder(self.m3iModel);
        self.CompatibleSwAddrMethods=memSectionBuilder.build();
    end


    sysHandle=get_param(self.slSystemName,'Handle');





    reRegisterListener=autosarcore.unregisterListenerCBTemporarily(self.m3iModel);%#ok<NASGU>
    if self.ShareAUTOSARProperties
        reRegisterListenerShared=autosarcore.unregisterListenerCBTemporarily(sharedM3IModel);%#ok<NASGU>
    end

    trans.commit();
    if self.ShareAUTOSARProperties
        transShared.commit();
    end

end




