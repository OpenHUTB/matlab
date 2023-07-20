classdef ObserverModelMapping<autosar.mm.observer.Observer





    properties(SetAccess=immutable,GetAccess=private)
        ModelName;
        ComponentId='';
        ComponentQName='';
        MappingRoot;
        IsAdaptive;
        IsComposition;
    end

    methods
        function this=ObserverModelMapping(modelName)
            this.ModelName=modelName;
            this.MappingRoot=autosar.api.Utils.modelMapping(modelName);
            try
                m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);
            catch



                return;
            end
            if~isempty(m3iComp)



                this.ComponentId=m3iComp.qualifiedName;
                this.ComponentQName=autosar.api.Utils.convertComponentIdToQName(this.ComponentId);
            end
            this.IsAdaptive=autosar.api.Utils.isMappedToAdaptiveApplication(modelName);
            this.IsComposition=autosar.api.Utils.isMappedToComposition(modelName);
        end

        function observeChanges(this,changesReport)


            if~Simulink.internal.isArchitectureModel(this.ModelName,'AUTOSARArchitecture')
                this.observeDeleted(changesReport);
                this.observeAdded(changesReport);
                this.observeChanged(changesReport);
            end
        end
    end

    methods(Access=private)
        function observeDeleted(this,changesReport)
            deleted=changesReport.getRemoved();
            for i=1:deleted.size
                cur=deleted.at(i);
                if autosar.ui.utils.isaValidUIObject(cur)
                    old=changesReport.getOldState(cur);
                    this.updateMappingForAddRemove(cur,old);
                end
            end
        end

        function observeAdded(this,changesReport)
            added=changesReport.getAdded();
            for i=1:added.size
                cur=added.at(i);
                if autosar.ui.utils.isaValidUIObject(cur)
                    this.updateMappingForAddRemove(cur,[]);
                end
            end
        end

        function observeChanged(this,changesReport)
            import autosar.mm.util.ExternalToolInfoAdapter;
            changed=changesReport.getChanged();
            metaPkgPort='Simulink.metamodel.arplatform.port';
            for i=1:changed.size
                cur=changed.at(i);
                if autosar.ui.utils.isaValidUIObject(cur)
                    curMutable=cur.asMutable;
                    if isa(curMutable,'Simulink.metamodel.types.CompuMethod')&&...
                        ~this.IsComposition
                        slTypeNamesAlreadySet=ExternalToolInfoAdapter.get(curMutable,...
                        autosar.ui.metamodel.PackageString.SlDataTypes);
                        isReferencedElement=autosar.mm.util.ExternalToolInfoAdapter.get(curMutable,'IsReference');
                        if~isempty(isReferencedElement)&&isReferencedElement
                            if~isempty(slTypeNamesAlreadySet)
                                autosar.mm.util.mapSLDataTypes(this.ModelName,curMutable,...
                                slTypeNamesAlreadySet,'OK',false,true);
                            end
                        end
                    else
                        old=changesReport.getOldState(cur);
                        this.updateMapping(cur,old);
                    end
                elseif isa(cur.asMutable,[metaPkgPort,'.DataReceiverNonqueuedPortComSpec'])||...
                    isa(cur.asMutable,[metaPkgPort,'.DataSenderNonqueuedPortComSpec'])||...
                    isa(cur.asMutable,[metaPkgPort,'.DataReceiverQueuedPortComSpec'])||...
                    isa(cur.asMutable,[metaPkgPort,'.DataSenderQueuedPortComSpec'])&&...
                    ~this.IsComposition

                    old=changesReport.getOldState(cur);
                    this.updateMapping(cur,old);
                elseif isa(cur.asMutable,'Simulink.metamodel.arplatform.interface.VariableData')&&...
                    ~this.IsComposition

                    old=changesReport.getOldState(cur);
                    this.updateMapping(cur,old);
                end
            end
        end


        function updateMapping(this,m3iObj,old)

            assert(~isempty(this.ModelName),'model %s is not loaded.',this.ModelName);
            isNamedElement=isprop(old,'Name');
            oldName=[];
            if isNamedElement
                oldName=old.Name;
            end

            m3iObj=m3iObj.asMutable;
            interfaceServiceChanged=(isa(m3iObj,autosar.ui.metamodel.PackageString.InterfaceClass)...
            &&(isprop(old,'IsService')&&~strcmp(old.IsService,m3iObj.IsService)));
            portInterfaceNameChanged=(isa(m3iObj,autosar.ui.metamodel.PackageString.PortClass)...
            &&(((isempty(old.Interface)||~isvalid(old.Interface))&&~isempty(m3iObj.Interface))||...
            (old.Interface.isvalid()&&m3iObj.Interface.isvalid()&&~strcmp(old.Interface.Name,m3iObj.Interface.Name))));
            isParameterElementChanged=...
            isa(m3iObj,'Simulink.metamodel.arplatform.interface.ParameterData');


            if isNamedElement
                if strcmp(old.qualifiedName,m3iObj.qualifiedName)&&...
                    ~(interfaceServiceChanged||portInterfaceNameChanged)&&...
                    ~isParameterElementChanged





                    return;
                end
            end

            if isa(m3iObj,autosar.ui.configuration.PackageString.Components{1})||...
                isa(m3iObj,autosar.ui.configuration.PackageString.Components{2})||...
                isa(m3iObj,'Simulink.metamodel.arplatform.component.AdaptiveApplication')
                modelNodeMObj=this.MappingRoot;
                compName=modelNodeMObj.MappedTo.Name;
                if strcmp(compName,oldName)

                    modelNodeMObj.MappedTo.Name=m3iObj.Name;
                    modelNodeMObj.MappedTo.UUID=m3iObj.qualifiedName;
                end
            elseif isa(m3iObj,autosar.ui.configuration.PackageString.Runnables)
                if~strcmp(m3iObj.containerM3I.containerM3I.qualifiedName,this.ComponentId)

                    return;
                end
                modelNodeMObj=this.MappingRoot;
                isServerRunnable=false;
                initRunnable=modelNodeMObj.InitializeFunctions.MappedTo.Runnable;
                if strcmp(initRunnable,oldName)
                    modelNodeMObj.InitializeFunctions.mapEntryPoint(m3iObj.Name,'');
                end
                if~isempty(modelNodeMObj.ResetFunctions)
                    for ii=1:length(modelNodeMObj.ResetFunctions)
                        resetRunnable=modelNodeMObj.ResetFunctions(ii).MappedTo.Runnable;
                        if strcmp(resetRunnable,oldName)
                            modelNodeMObj.ResetFunctions(ii).mapEntryPoint(m3iObj.Name,'');
                            break;
                        end
                    end
                end
                if~isempty(modelNodeMObj.TerminateFunctions)
                    assert(numel(modelNodeMObj.TerminateFunctions)==1,...
                    'More than one terminate function found.');
                    terminateRunnable=modelNodeMObj.TerminateFunctions(1).MappedTo.Runnable;
                    if strcmp(terminateRunnable,oldName)
                        modelNodeMObj.TerminateFunctions.mapEntryPoint(m3iObj.Name,'');
                    end
                end
                if~isempty(modelNodeMObj.StepFunctions)
                    for ii=1:length(modelNodeMObj.StepFunctions)
                        periodicRunnable=modelNodeMObj.StepFunctions(ii).MappedTo.Runnable;
                        if strcmp(periodicRunnable,oldName)
                            modelNodeMObj.StepFunctions(ii).mapEntryPoint(m3iObj.Name,'');
                            break;
                        end
                    end
                end
                for ii=1:m3iObj.Events.size()
                    if isa(m3iObj.Events.at(ii),autosar.ui.configuration.PackageString.Events{4})
                        isServerRunnable=true;
                        break;
                    end
                end
                if isServerRunnable
                    for index=1:length(modelNodeMObj.ServerFunctions)
                        slFunction=modelNodeMObj.ServerFunctions(index);
                        aRunnable=slFunction.MappedTo.Runnable;
                        if strcmp(aRunnable,oldName)
                            slFunction.mapEntryPoint(m3iObj.Name,'');
                            break;
                        end
                    end
                end
                if~isempty(modelNodeMObj.FcnCallInports)
                    for index=1:length(modelNodeMObj.FcnCallInports)
                        fncCallInport=modelNodeMObj.FcnCallInports(index);
                        aRunnable=fncCallInport.MappedTo.Runnable;
                        if strcmp(aRunnable,oldName)
                            fncCallInport.mapEntryPoint(m3iObj.Name,'');
                            break;
                        end
                    end
                end
            elseif isa(m3iObj,autosar.ui.configuration.PackageString.Events{1})

            elseif isa(m3iObj,autosar.ui.metamodel.PackageString.PortClass)
                if~strcmp(m3iObj.containerM3I.qualifiedName,this.ComponentId)

                    return;
                end
                if isa(m3iObj,autosar.ui.configuration.PackageString.Ports{1})
                    portNodes=this.MappingRoot.Inports;
                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{2})
                    portNodes=this.MappingRoot.Outports;
                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{3})
                    portNodes=this.MappingRoot.FunctionCallers;
                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{4})
                    portNodes=this.MappingRoot.Inports;
                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{5})

                    portNodes=[];
                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{6})
                    portNodes=[this.MappingRoot.Inports,this.MappingRoot.Outports];
                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{7})
                    portNodes=this.MappingRoot.Inports;
                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{8})
                    portNodes=this.MappingRoot.Outports;
                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{9})
                    portNodes=[this.MappingRoot.Inports,this.MappingRoot.Outports];
                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{10})
                    portNodes={this.MappingRoot.LookupTables,this.MappingRoot.ModelScopedParameters};
                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{11})
                    portNodes=this.MappingRoot.Outports;
                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{12})

                    portNodes=[];
                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{13})
                    portNodes=this.MappingRoot.Inports;



                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{14})
                    portNodes=this.MappingRoot.Outports;



                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{15})||...
                    isa(m3iObj,autosar.ui.configuration.PackageString.Ports{16})||...
                    isa(m3iObj,autosar.ui.configuration.PackageString.Ports{17})
                    portNodes=this.MappingRoot.DataStores;
                else
                    assert(false,'Invalid port type');
                end
                if~iscell(portNodes)
                    portNodes={portNodes};
                end
                if((isempty(old.Interface)||~isvalid(old.Interface))&&~isempty(m3iObj.Interface))||...
                    (old.Interface.isvalid()&&m3iObj.Interface.isvalid()&&...
                    ~strcmp(old.Interface.Name,m3iObj.Interface.Name))
                    autosar.mm.observer.ObserverModelMapping.handleInterfaceChange(m3iObj,portNodes,oldName,this.ModelName);
                else

                    for portTypeIdx=1:length(portNodes)
                        portNodeVec=portNodes{portTypeIdx};
                        for i=1:length(portNodeVec)
                            if~isvalid(portNodeVec(i))
                                continue;
                            end
                            portMObj=portNodeVec(i);
                            if isa(portMObj.MappedTo,autosar.ui.configuration.PackageString.PortElementClass)
                                if strcmp(portMObj.MappedTo.Port,oldName)
                                    portMObj.mapPortElement(m3iObj.Name,portMObj.MappedTo.Element,...
                                    portMObj.MappedTo.DataAccessMode);
                                end
                            elseif isa(portMObj.MappedTo,autosar.ui.configuration.PackageString.PortOperationClass)
                                if strcmp(portMObj.MappedTo.ClientPort,oldName)
                                    portMObj.mapPortOperation(m3iObj.Name,portMObj.MappedTo.Operation);
                                end
                            elseif isa(portMObj.MappedTo,autosar.ui.configuration.PackageString.ARParameterClass)
                                if strcmp(portMObj.MappedTo.Port,oldName)
                                    portMObj.mapLookupTable(m3iObj.Name,portMObj.MappedTo.Parameter,'');
                                end
                            elseif isa(portMObj.MappedTo,...
                                'Simulink.AutosarTarget.PortEvent')
                                portName=portMObj.MappedTo.Port;
                                if strcmp(portName,oldName)
                                    portMObj.mapPortEvent(m3iObj.Name,portMObj.MappedTo.Event,'');
                                end
                            elseif isa(portMObj.MappedTo,...
                                'Simulink.AutosarTarget.PortProvidedEvent')
                                portName=portMObj.MappedTo.Port;
                                if strcmp(portName,oldName)
                                    portMObj.mapPortProvidedEvent(m3iObj.Name,...
                                    portMObj.MappedTo.Event,...
                                    portMObj.MappedTo.AllocateMemory,'');
                                end
                            elseif isa(portMObj.MappedTo,...
                                'Simulink.AutosarTarget.PortMethod')
                                assert(false,'Adaptive Method mapping is automatic, no listening required');
                            elseif isa(portMObj.MappedTo,...
                                'Simulink.AutosarTarget.DictionaryReference')
                                portName=portMObj.MappedTo.getPerInstancePropertyValue('Port');
                                if strcmp(portName,oldName)
                                    Simulink.CodeMapping.setPerInstancePropertyValue(...
                                    this.ModelName,portMObj,'MappedTo','Port',m3iObj.Name);
                                end
                            end
                        end
                    end
                end
            elseif isa(m3iObj,'Simulink.metamodel.arplatform.interface.PersistencyData')

                if this.IsAdaptive
                    dataStoreNodes=this.MappingRoot.DataStores;
                    if~isempty(old)&&~isempty(dataStoreNodes)
                        for ii=1:numel(dataStoreNodes)
                            dataStoreNode=dataStoreNodes(ii);
                            if isa(dataStoreNode.MappedTo,'Simulink.AutosarTarget.DictionaryReference')
                                if strcmp(...
                                    dataStoreNode.MappedTo.getPerInstancePropertyValue('DataElement'),old.Name)
                                    Simulink.CodeMapping.setPerInstancePropertyValue(...
                                    this.ModelName,dataStoreNode,'MappedTo','DataElement',m3iObj.Name);
                                    break;
                                end
                            end
                        end
                    end
                end
            elseif isa(m3iObj,autosar.ui.configuration.PackageString.IRV)
                if~strcmp(m3iObj.containerM3I.containerM3I.qualifiedName,this.ComponentId)

                    return;
                end

                if~isempty(this.MappingRoot.DataTransfers)

                    funcNodes=this.MappingRoot.DataTransfers;


                    for index=1:length(funcNodes)
                        funcMObj=funcNodes(index);
                        if strcmp(funcMObj.MappedTo.IrvName,old.Name)


                            funcMObj.mapInterRunnableVariable(...
                            funcMObj.SignalName,m3iObj.Name,...
                            funcMObj.MappedTo.IrvAccessMode,'');
                            break;
                        end
                    end
                end
                if~isempty(this.MappingRoot.RateTransition)

                    funcNodes=this.MappingRoot.RateTransition;


                    for index=1:length(funcNodes)
                        funcMObj=funcNodes(index);
                        if strcmp(funcMObj.MappedTo.IrvName,old.Name)


                            funcMObj.mapInterRunnableVariable(...
                            m3iObj.Name,funcMObj.MappedTo.IrvAccessMode,'');
                            break;
                        end
                    end
                end
            elseif isa(m3iObj,autosar.ui.configuration.PackageString.ParameterData)...
                &&~isa(m3iObj.containerM3I,'Simulink.metamodel.arplatform.interface.ParameterInterface')&&...
                ~this.IsComposition
                if~startsWith(m3iObj.qualifiedName,[this.ComponentId,'.'])

                    return;
                end
                lutNodes=this.MappingRoot.LookupTables;


                for index=1:length(lutNodes)
                    lutMObj=lutNodes(index);
                    if strcmp(lutMObj.MappedTo.Parameter,old.Name)


                        lutMObj.mapLookupTable(...
                        lutMObj.LookupTableName,lutMObj.MappedTo.ParameterAccessMode,'',m3iObj.Name,'');
                        break;
                    end
                end
            elseif isa(m3iObj,autosar.ui.configuration.PackageString.ParameterData)...
                &&isa(m3iObj.containerM3I,'Simulink.metamodel.arplatform.interface.ParameterInterface')&&...
                ~this.IsComposition
                modelScopedParams=this.MappingRoot.ModelScopedParameters;


                for index=1:length(modelScopedParams)
                    paramMObj=modelScopedParams(index);
                    if strcmp(paramMObj.MappedTo.getPerInstancePropertyValue('DataElement'),old.Name)


                        Simulink.CodeMapping.setPerInstancePropertyValue(...
                        this.ModelName,paramMObj,'MappedTo','DataElement',m3iObj.Name);
                    end
                end
            elseif isa(m3iObj,autosar.ui.configuration.PackageString.DataElement)||...
                isa(m3iObj,autosar.ui.metamodel.PackageString.ModeDeclarationGroupElementClass)

                portNodes=[this.MappingRoot.Inports,this.MappingRoot.Outports];
                portBlockMappings={portNodes.MappedTo};



                dataElementPropertyName='Element';
                if this.IsAdaptive
                    dataElementPropertyName='Event';
                end
                portElementNames=cellfun(@(x)x.(dataElementPropertyName),portBlockMappings,'UniformOutput',false);

                portNodes=portNodes(ismember(portElementNames,old.Name));

                assert(m3iObj.containerM3I.isvalid(),'DataElement or ModeDeclarationGroup is unparented');
                interfaceName=m3iObj.containerM3I.Name;
                dataObj=autosar.api.getAUTOSARProperties(this.ModelName,true);
                for i=1:length(portNodes)
                    if~isvalid(portNodes(i))
                        continue;
                    end
                    portMObj=portNodes(i);
                    interfaceValue='';
                    if~isempty(portMObj.MappedTo.Port)
                        interfaceValue=dataObj.get(...
                        [this.ComponentQName,'/',portMObj.MappedTo.Port],'Interface');
                    end
                    if strcmp(interfaceValue,interfaceName)
                        portName=portMObj.MappedTo.Port;
                        if this.IsAdaptive
                            if isa(portMObj.MappedTo,'Simulink.AutosarTarget.PortProvidedEvent')
                                portMObj.mapPortProvidedEvent(portName,m3iObj.Name,...
                                portMObj.MappedTo.AllocateMemory,'');
                            else
                                portMObj.mapPortEvent(portName,m3iObj.Name,'');
                            end
                        else
                            portMObj.mapPortElement(portName,m3iObj.Name,...
                            portMObj.MappedTo.DataAccessMode);
                        end
                    end
                end
            elseif isa(m3iObj,'Simulink.metamodel.arplatform.composition.ComponentPrototype')&&...
                this.IsComposition

                modelBlockNodes=this.MappingRoot.ModelBlocks;
                assert(m3iObj.containerM3I.isvalid(),'ComponentPrototype is unparented');


                for index=1:length(modelBlockNodes)
                    modelBlockMObj=modelBlockNodes(index);
                    if strcmp(modelBlockMObj.MappedTo.PrototypeName,old.Name)


                        modelBlockMObj.mapComponentPrototype(m3iObj.Name,'');
                        break;
                    end
                end
            elseif isa(m3iObj,autosar.ui.configuration.PackageString.Operation)&&...
                ~this.IsComposition
                if this.IsAdaptive



                    return;
                end
                portNodes={this.MappingRoot.FunctionCallers};

                interfaceName=m3iObj.containerM3I.Name;
                dataObj=autosar.api.getAUTOSARProperties(this.ModelName,true);

                for i=1:length(portNodes)
                    for j=1:length(portNodes{i})
                        if~isvalid(portNodes{i}(j))
                            continue;
                        end
                        portMObj=portNodes{i}(j);
                        interfaceValue='';
                        if~isempty(portMObj.MappedTo.ClientPort)
                            interfaceValue=dataObj.get(...
                            [this.ComponentQName,'/',portMObj.MappedTo.ClientPort],'Interface');
                        end
                        if strcmp(interfaceValue,interfaceName)&&strcmp(portMObj.MappedTo.Operation,old.Name)
                            portMObj.mapPortOperation(portMObj.MappedTo.ClientPort,m3iObj.Name);
                        end
                    end
                end
            elseif isa(m3iObj,'Simulink.metamodel.arplatform.port.DataReceiverPortComSpec')&&...
                ~this.IsComposition
                if~strcmp(m3iObj.containerM3I.containerM3I.containerM3I.qualifiedName,this.ComponentId)

                    return;
                end
                portNodes=this.MappingRoot.Inports;
                autosar.mm.observer.ObserverModelMapping.fireAutosarMappingUpdatedEventForComSpecChange(m3iObj,portNodes);
            elseif isa(m3iObj,'Simulink.metamodel.arplatform.port.DataSenderPortComSpec')&&...
                ~this.IsComposition
                if~strcmp(m3iObj.containerM3I.containerM3I.containerM3I.qualifiedName,this.ComponentId)

                    return;
                end
                portNodes=this.MappingRoot.Outports;
                autosar.mm.observer.ObserverModelMapping.fireAutosarMappingUpdatedEventForComSpecChange(m3iObj,portNodes);
            elseif isa(m3iObj,autosar.ui.metamodel.PackageString.SwAddrMethodClass)&&...
                ~this.IsComposition




                runnableMappingCategoryNames=autosar.ui.configuration.PackageString.MappingObjWithRunnables;
                for categoryName=runnableMappingCategoryNames
                    mapObjList=this.MappingRoot.(categoryName{1});
                    for mapObj=mapObjList
                        if mapObj.isvalid()
                            if~isempty(mapObj.MappedTo)&&~isempty(mapObj.MappedTo.SwAddrMethod)...
                                &&strcmp(mapObj.MappedTo.SwAddrMethod,oldName)

                                mapObj.mapSwAddrMethod(m3iObj.Name);
                            end
                            if~isempty(mapObj.MappedTo)&&~isempty(mapObj.MappedTo.InternalDataSwAddrMethod)...
                                &&strcmp(mapObj.MappedTo.InternalDataSwAddrMethod,oldName)

                                mapObj.mapInternalDataSwAddrMethod(m3iObj.Name);
                            end
                        end
                    end
                end
                internalDataMappingCategoryNames=autosar.ui.configuration.PackageString.InternalDataObjWithSwAddrMethods;
                for categoryName=internalDataMappingCategoryNames
                    mapObjList=this.MappingRoot.(categoryName{1});
                    for mapObj=mapObjList
                        if mapObj.isvalid()
                            mappedSwAddrMethod=mapObj.MappedTo.getPerInstancePropertyValue('SwAddrMethod');
                            if~isempty(mapObj.MappedTo)&&~isempty(mappedSwAddrMethod)...
                                &&strcmp(mappedSwAddrMethod,oldName)

                                Simulink.CodeMapping.setPerInstancePropertyValue(this.ModelName,mapObj,'MappedTo','SwAddrMethod',m3iObj.Name);
                                notify(mapObj,'AutosarMappingEntityUpdated')
                            end
                        end
                    end
                end
            elseif isa(m3iObj,'Simulink.metamodel.arplatform.interface.VariableData')&&...
                ~this.IsComposition

                mappedTo=autosar.mm.util.getVariableRoleFromM3IData(m3iObj);
                if~isempty(mappedTo)
                    this.updatePIMMapping(m3iObj,mappedTo,oldName)
                end
            end
        end

        function updatePIMMapping(this,m3iObj,mappedTo,oldName)




            signalMappingUpdater=autosar.updater.modelMapping.Signal(this.ModelName);
            sigObj=signalMappingUpdater.findMappedSignals(mappedTo,oldName);
            if~isempty(sigObj)
                signalMappingUpdater.updateMapping(sigObj,m3iObj);
                return;
            end


            stateMappingUpdater=autosar.updater.modelMapping.State(this.ModelName);
            stateObj=stateMappingUpdater.findMappedStates(mappedTo,oldName);
            if~isempty(stateObj)
                stateMappingUpdater.updateMapping(stateObj,m3iObj);
                return;
            end


            dsmMappingUpdater=autosar.updater.modelMapping.DataStore(this.ModelName);
            dsmObj=dsmMappingUpdater.findMappedDSMBlocks(mappedTo,oldName);
            if~isempty(dsmObj)
                dsmMappingUpdater.updateMapping(dsmObj,m3iObj);
                return;
            end


            synthDsmMappingUpdater=autosar.updater.modelMapping.SynthesizedDataStore(this.ModelName);
            synthDsmObj=synthDsmMappingUpdater.findMappedSynthDSMs(mappedTo,oldName);
            if~isempty(synthDsmObj)
                synthDsmMappingUpdater.updateMapping(synthDsmObj,m3iObj);
                return;
            end
        end

        function updateMappingForAddRemove(this,cur,old)


            if cur.isvalid
                m3iObj=cur;
            else
                m3iObj=old;
            end
            m3iObj=m3iObj.asMutable;

            assert(~isempty(this.ModelName),'model %s is not loaded!',this.ModelName);

            if isa(m3iObj,autosar.ui.metamodel.PackageString.PortClass)
                if~strcmp(m3iObj.containerM3I.qualifiedName,this.ComponentId)

                    return;
                end
                if this.IsComposition&&...
                    (isa(m3iObj,autosar.ui.configuration.PackageString.Ports{3})||...
                    isa(m3iObj,autosar.ui.configuration.PackageString.Ports{5})||...
                    isa(m3iObj,autosar.ui.configuration.PackageString.Ports{10}))



                    return
                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{1})
                    portNodes=this.MappingRoot.Inports;
                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{2})
                    portNodes=this.MappingRoot.Outports;
                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{3})
                    portNodes=this.MappingRoot.FunctionCallers;

                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{4})
                    portNodes=this.MappingRoot.Inports;
                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{5})

                    return
                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{6})
                    portNodes=[this.MappingRoot.Inports,this.MappingRoot.Outports];
                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{7})
                    portNodes=this.MappingRoot.Inports;
                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{8})
                    portNodes=this.MappingRoot.Outports;
                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{9})
                    portNodes=[this.MappingRoot.Inports,this.MappingRoot.Outports];
                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{10})
                    portNodes={this.MappingRoot.LookupTables,this.MappingRoot.ModelScopedParameters};
                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{11})
                    portNodes=this.MappingRoot.Outports;
                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{12})

                    return
                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{13})
                    portNodes=this.MappingRoot.Inports;



                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{14})
                    portNodes=this.MappingRoot.Outports;



                elseif isa(m3iObj,autosar.ui.configuration.PackageString.Ports{15})||...
                    isa(m3iObj,autosar.ui.configuration.PackageString.Ports{16})||...
                    isa(m3iObj,autosar.ui.configuration.PackageString.Ports{17})

                    portNodes=this.MappingRoot.DataStores;
                else

                    assert(false,'Unknown port type in updateMappingForAddRemove');
                end
                if~iscell(portNodes)
                    portNodes={portNodes};
                end
                if~cur.isvalid

                    oldName=old.Name;
                    for portTypeIdx=1:length(portNodes)
                        portNodeVec=portNodes{portTypeIdx};
                        for i=1:length(portNodeVec)
                            if portNodeVec(i).isvalid
                                portMObj=portNodeVec(i);
                                if isa(portMObj.MappedTo,...
                                    autosar.ui.configuration.PackageString.PortElementClass)
                                    if strcmp(portMObj.MappedTo.Port,oldName)
                                        if~autosar.composition.Utils.isCompositePortBlock(portMObj.Block)
                                            portMObj.mapPortElement('','',...
                                            portMObj.MappedTo.DataAccessMode);
                                        end
                                    end
                                elseif isa(portMObj.MappedTo,...
                                    autosar.ui.configuration.PackageString.ARParameterClass)
                                    if strcmp(portMObj.MappedTo.Port,oldName)
                                        portMObj.mapLookupTable(portMObj.LookupTableName,...
                                        portMObj.MappedTo.ParameterAccessMode,'','','');
                                    end
                                elseif isa(portMObj.MappedTo,'Simulink.AutosarTarget.PortEvent')
                                    if strcmp(portMObj.MappedTo.Port,oldName)
                                        portMObj.mapPortEvent('','','');
                                    end
                                elseif isa(portMObj.MappedTo,'Simulink.AutosarTarget.PortProvidedEvent')
                                    if strcmp(portMObj.MappedTo.Port,oldName)
                                        portMObj.mapPortProvidedEvent('','',...
                                        portMObj.MappedTo.AllocateMemory,'');
                                    end
                                elseif isa(portMObj.MappedTo,'Simulink.AutosarTarget.PortMethod')
                                    assert(false,'Adaptive Method mapping is automatic, no listening required');
                                elseif isa(portMObj.MappedTo,'Simulink.AutosarTarget.DictionaryReference')
                                    if strcmp(...
                                        portMObj.MappedTo.getPerInstancePropertyValue('Port'),oldName)


                                        Simulink.CodeMapping.setPerInstancePropertyValue(...
                                        this.ModelName,portMObj,'MappedTo','Port','');
                                        Simulink.CodeMapping.setPerInstancePropertyValue(...
                                        this.ModelName,portMObj,'MappedTo','DataElement','');
                                    end
                                else
                                    if strcmp(portMObj.MappedTo.ClientPort,oldName)
                                        portMObj.mapPortOperation('','');
                                    end
                                end
                            end
                        end
                    end
                end
            elseif isa(m3iObj,autosar.ui.configuration.PackageString.IRV)
                if~strcmp(m3iObj.containerM3I.containerM3I.qualifiedName,this.ComponentId)

                    return;
                end

                if~isempty(this.MappingRoot.DataTransfers)

                    funcNodes=this.MappingRoot.DataTransfers;


                    if~cur.isvalid


                        for index=1:length(funcNodes)
                            funcMObj=funcNodes(index);
                            if strcmp(funcMObj.MappedTo.IrvName,m3iObj.Name)


                                funcMObj.mapInterRunnableVariable(...
                                funcMObj.SignalName,'',...
                                funcMObj.MappedTo.IrvAccessMode,'');
                            end
                        end
                    end
                end
                if~isempty(this.MappingRoot.RateTransition)

                    funcNodes=this.MappingRoot.RateTransition;


                    if~cur.isvalid


                        for index=1:length(funcNodes)
                            funcMObj=funcNodes(index);
                            if strcmp(funcMObj.MappedTo.IrvName,m3iObj.Name)


                                funcMObj.mapInterRunnableVariable(...
                                '',funcMObj.MappedTo.IrvAccessMode,'');
                            end
                        end
                    end
                end
            elseif isa(m3iObj,autosar.ui.configuration.PackageString.ParameterData)...
                &&~isa(m3iObj.containerM3I,'Simulink.metamodel.arplatform.interface.ParameterInterface')...
                &&~this.IsComposition
                if~startsWith(m3iObj.qualifiedName,[this.ComponentId,'.'])

                    return;
                end
                if~cur.isvalid
                    lutNodes=this.MappingRoot.LookupTables;


                    for index=1:length(lutNodes)
                        lutMObj=lutNodes(index);
                        if strcmp(lutMObj.MappedTo.Parameter,old.Name)


                            lutMObj.mapLookupTable(...
                            lutMObj.LookupTableName,lutMObj.MappedTo.ParameterAccessMode,'','','');
                            break;
                        end
                    end
                end
            elseif(isa(m3iObj,autosar.ui.configuration.PackageString.DataElement)||...
                isa(m3iObj,autosar.ui.configuration.PackageString.Operation)||...
                (isa(m3iObj,autosar.ui.configuration.PackageString.ParameterData)...
                &&isa(m3iObj.containerM3I,'Simulink.metamodel.arplatform.interface.ParameterInterface')))...
                &&~this.IsComposition
                if isa(m3iObj,autosar.ui.configuration.PackageString.DataElement)
                    portNodes={this.MappingRoot.Inports,this.MappingRoot.Outports};
                elseif isa(m3iObj,autosar.ui.configuration.PackageString.ParameterData)
                    portNodes={this.MappingRoot.LookupTables,this.MappingRoot.ModelScopedParameters};
                else
                    portNodes={this.MappingRoot.FunctionCallers};
                    if this.IsAdaptive
                        portNodes=[portNodes,{this.MappingRoot.ServerFunctions}];
                    end
                end
                interfaceName=m3iObj.containerM3I.Name;
                dataObj=autosar.api.getAUTOSARProperties(this.ModelName,true);
                if~cur.isvalid
                    oldName=old.Name;

                    for i=1:length(portNodes)
                        for j=1:length(portNodes{i})
                            if portNodes{i}(j).isvalid
                                portMObj=portNodes{i}(j);
                                if portMObj.isvalid
                                    interfaceValue='';
                                    if isa(portMObj,'Simulink.AutosarTarget.BlockMapping')
                                        if isa(m3iObj,autosar.ui.configuration.PackageString.DataElement)
                                            if this.IsAdaptive
                                                isEventOfInterest=~isempty(portMObj.MappedTo.Event)&&...
                                                strcmp(oldName,portMObj.MappedTo.Event);
                                                if isEventOfInterest
                                                    portName=portMObj.MappedTo.Port;
                                                    if isa(portMObj.MappedTo,'Simulink.AutosarTarget.PortProvidedEvent')
                                                        portMObj.mapPortProvidedEvent(portName,'',...
                                                        portMObj.MappedTo.AllocateMemory,'');
                                                    else
                                                        portMObj.mapPortEvent(portName,'','');
                                                    end
                                                end
                                            else
                                                isDataElementOfInterest=~isempty(portMObj.MappedTo.Element)...
                                                &&strcmp(oldName,portMObj.MappedTo.Element)...
                                                &&~autosar.composition.Utils.isCompositePortBlock(portMObj.Block);
                                                if isDataElementOfInterest
                                                    if~isempty(portMObj.MappedTo.Port)
                                                        interfaceValue=dataObj.get(...
                                                        [this.ComponentQName,'/',portMObj.MappedTo.Port],'Interface');
                                                    end
                                                    if strcmp(interfaceValue,interfaceName)||isempty(interfaceValue)
                                                        portMObj.mapPortElement(portMObj.MappedTo.Port,...
                                                        '',portMObj.MappedTo.DataAccessMode);
                                                    end
                                                end
                                            end
                                        else
                                            if this.IsAdaptive
                                                assert(false,'Adaptive Method mapping is automatic, no listening required');
                                            else
                                                isOperationOfInterest=~isempty(portMObj.MappedTo.Operation)&&...
                                                strcmp(oldName,portMObj.MappedTo.Operation);
                                                if isOperationOfInterest
                                                    if~isempty(portMObj.MappedTo.ClientPort)
                                                        interfaceValue=dataObj.get(...
                                                        [this.ComponentQName,'/',portMObj.MappedTo.ClientPort],...
                                                        'Interface');
                                                    end
                                                    if strcmp(interfaceValue,interfaceName)||isempty(interfaceValue)
                                                        portMObj.mapPortOperation(portMObj.MappedTo.ClientPort,...
                                                        '');
                                                    end
                                                end
                                            end
                                        end
                                    elseif isa(portMObj,autosar.ui.configuration.PackageString.LookupTableMapClass)
                                        if isa(m3iObj,autosar.ui.configuration.PackageString.ParameterData)
                                            isParameterOfInterest=~isempty(portMObj.MappedTo.Parameter)&&...
                                            strcmp(portMObj.MappedTo.Parameter,oldName);
                                            if isParameterOfInterest
                                                if~isempty(portMObj.MappedTo.Port)
                                                    interfaceValue=dataObj.get(...
                                                    [this.ComponentQName,'/',portMObj.MappedTo.Port],'Interface');
                                                    if strcmp(interfaceValue,interfaceName)||isempty(interfaceValue)
                                                        portMObj.mapLookupTable(portMObj.LookupTableName,...
                                                        portMObj.MappedTo.ParameterAccessMode,...
                                                        portMObj.MappedTo.Port,'','');
                                                    end
                                                end
                                            end
                                        end
                                    elseif isa(portMObj,'Simulink.AutosarTarget.ModelScopedParameterMapping')&&...
                                        strcmp(portMObj.MappedTo.ArDataRole,'PortParameter')



                                        mappingTarget=portMObj.MappedTo;
                                        if isa(m3iObj,autosar.ui.configuration.PackageString.ParameterData)
                                            isParameterOfInterest=strcmp(...
                                            mappingTarget.getPerInstancePropertyValue('DataElement'),oldName);
                                            if isParameterOfInterest
                                                paramPort=mappingTarget.getPerInstancePropertyValue('Port');
                                                if isempty(paramPort)


                                                    continue;
                                                end
                                                interfaceValue=dataObj.get(...
                                                [this.ComponentQName,'/',paramPort],'Interface');
                                                if strcmp(interfaceValue,interfaceName)||isempty(interfaceValue)
                                                    Simulink.CodeMapping.setPerInstancePropertyValue(...
                                                    this.ModelName,portMObj,'MappedTo','DataElement','');
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            elseif isa(m3iObj,'Simulink.metamodel.arplatform.interface.PersistencyData')

                dataStoreNodes=this.MappingRoot.DataStores;
                if~isempty(old)
                    for ii=1:numel(dataStoreNodes)
                        dataStoreNode=dataStoreNodes(ii);
                        if this.IsAdaptive
                            if~isempty(dataStoreNode)
                                if isa(dataStoreNode.MappedTo,'Simulink.AutosarTarget.DictionaryReference')
                                    if strcmp(...
                                        dataStoreNode.MappedTo.getPerInstancePropertyValue('DataElement'),old.Name)

                                        Simulink.CodeMapping.setPerInstancePropertyValue(...
                                        this.ModelName,dataStoreNode,'MappedTo','DataElement','');
                                    end
                                end
                            end
                        end
                    end
                end
            elseif isa(m3iObj,autosar.ui.configuration.PackageString.Events{4})...
                &&~this.IsComposition


                if cur.isvalid

                    opEventCount=0;
                    for ii=1:cur.StartOnEvent.Events.size()
                        if isa(cur.StartOnEvent.Events.at(ii),autosar.ui.configuration.PackageString.Events{4})
                            opEventCount=opEventCount+1;
                        end
                    end
                    if opEventCount>0

                        funcNodes=this.MappingRoot.FcnCallInports;
                        for index=1:length(funcNodes)
                            if funcNodes(index).isvalid
                                funcMObj=funcNodes(index);
                                if strcmp(funcMObj.MappedTo.Runnable,cur.StartOnEvent.Name)
                                    autosar.api.Utils.mapFunction(this.ModelName,funcMObj,'');
                                end
                            end
                        end
                        entryFuncNodes=[this.MappingRoot.StepFunctions,this.MappingRoot.InitializeFunctions];
                        for index=1:length(entryFuncNodes)
                            if entryFuncNodes(index).isvalid
                                funcMObj=entryFuncNodes(index);
                                if strcmp(funcMObj.MappedTo.Runnable,cur.StartOnEvent.Name)
                                    autosar.api.Utils.mapFunction(this.ModelName,funcMObj,'');
                                end
                            end
                        end
                    end
                end

            elseif isa(m3iObj,autosar.ui.configuration.PackageString.Runnables)
                if~strcmp(m3iObj.containerM3I.containerM3I.qualifiedName,this.ComponentId)

                    return;
                end
                if this.IsAdaptive

                    return
                end
                isMappedToSimulinkFunction=false;
                for ii=1:m3iObj.Events.size()
                    if isa(m3iObj.Events.at(ii),autosar.ui.configuration.PackageString.Events{4})||...
                        isa(m3iObj.Events.at(ii),'Simulink.metamodel.arplatform.behavior.InternalTriggerOccurredEvent')
                        isMappedToSimulinkFunction=true;
                        break;
                    end
                end
                if isMappedToSimulinkFunction
                    funcNodes=this.MappingRoot.ServerFunctions;
                elseif~isempty(this.MappingRoot.FcnCallInports)
                    funcNodes=this.MappingRoot.FcnCallInports;
                else
                    funcNodes=this.MappingRoot.StepFunctions;
                end

                if~cur.isvalid

                    for index=1:length(funcNodes)
                        if funcNodes(index).isvalid
                            funcMObj=funcNodes(index);
                            if strcmp(funcMObj.MappedTo.Runnable,m3iObj.Name)
                                autosar.api.Utils.mapFunction(this.ModelName,funcMObj,'');
                            end
                        end
                    end


                    for index=1:length(this.MappingRoot.InitializeFunctions)
                        if this.MappingRoot.InitializeFunctions(index).isvalid
                            initMObj=this.MappingRoot.InitializeFunctions(index);
                            if strcmp(initMObj.MappedTo.Runnable,m3iObj.Name)
                                autosar.api.Utils.mapFunction(this.ModelName,initMObj,'');
                            end
                        end
                    end
                end
            elseif isa(m3iObj,autosar.ui.metamodel.PackageString.SwAddrMethodClass)&&...
                ~(this.IsComposition||this.IsAdaptive)
                if~cur.isvalid()




                    mappingCategoryNames=autosar.ui.configuration.PackageString.MappingObjWithRunnables;
                    for categoryName=mappingCategoryNames
                        mapObjList=this.MappingRoot.(categoryName{1});
                        for mapObj=mapObjList
                            if mapObj.isvalid()
                                if~isempty(mapObj.MappedTo)&&~isempty(mapObj.MappedTo.SwAddrMethod)...
                                    &&strcmp(mapObj.MappedTo.SwAddrMethod,m3iObj.Name)

                                    mapObj.unmapSwAddrMethod()
                                end
                                if~isempty(mapObj.MappedTo)&&~isempty(mapObj.MappedTo.InternalDataSwAddrMethod)...
                                    &&strcmp(mapObj.MappedTo.InternalDataSwAddrMethod,m3iObj.Name)
                                    mapObj.unmapInternalDataSwAddrMethod();
                                end
                            end
                        end
                    end
                end
                internalDataMappingCategoryNames=autosar.ui.configuration.PackageString.InternalDataObjWithSwAddrMethods;
                for categoryName=internalDataMappingCategoryNames
                    mapObjList=this.MappingRoot.(categoryName{1});
                    for mapObj=mapObjList
                        if mapObj.isvalid()
                            mappedSwAddrMethod=mapObj.MappedTo.getPerInstancePropertyValue('SwAddrMethod');
                            if~isempty(mapObj.MappedTo)&&~isempty(mappedSwAddrMethod)...
                                &&strcmp(mappedSwAddrMethod,m3iObj.Name)

                                Simulink.CodeMapping.setPerInstancePropertyValue(this.ModelName,mapObj,'MappedTo','SwAddrMethod','');
                                notify(mapObj,'AutosarMappingEntityUpdated');
                            end
                        end
                    end
                end
            end

        end
    end

    methods(Static,Access=public)
        function handleInterfaceChange(m3iObj,portNodes,oldName,mdlName)

            for portTypeIdx=1:length(portNodes)
                portNodeVec=portNodes{portTypeIdx};
                for i=1:length(portNodeVec)
                    if~isvalid(portNodeVec(i))
                        continue;
                    end
                    portMObj=portNodeVec(i);
                    if isa(portMObj.MappedTo,...
                        autosar.ui.configuration.PackageString.PortElementClass)
                        if strcmp(portMObj.MappedTo.Port,oldName)
                            portMObj.mapPortElement(m3iObj.Name,'',...
                            portMObj.MappedTo.DataAccessMode);
                        end
                    elseif isa(portMObj.MappedTo,...
                        autosar.ui.configuration.PackageString.ARParameterClass)
                        if strcmp(portMObj.MappedTo.Port,oldName)&&...
                            strcmp(portMObj.MappedTo.ParameterAccessMode,...
                            autosar.ui.configuration.PackageString.ParameterAccessMode{1})
                            portMObj.mapLookupTable(portMObj.LookupTableName,...
                            portMObj.MappedTo.ParameterAccessMode,'','','');
                        end
                    elseif isa(portMObj.MappedTo,...
                        'Simulink.AutosarTarget.PortEvent')
                        portName=portMObj.MappedTo.Port;
                        if strcmp(portName,oldName)


                            portMObj.mapPortEvent(portName,'','');
                        end
                    elseif isa(portMObj.MappedTo,...
                        'Simulink.AutosarTarget.PortProvidedEvent')
                        portName=portMObj.MappedTo.Port;
                        if strcmp(portName,oldName)


                            portMObj.mapPortProvidedEvent(portName,'',...
                            portMObj.MappedTo.AllocateMemory,'');
                        end
                    elseif isa(portMObj.MappedTo,...
                        'Simulink.AutosarTarget.DictionaryReference')
                        portName=portMObj.MappedTo.getPerInstancePropertyValue('Port');
                        if strcmp(portName,oldName)


                            Simulink.CodeMapping.setPerInstancePropertyValue(...
                            mdlName,portMObj,'MappedTo','DataElement','');
                        end
                    else
                        if strcmp(portMObj.MappedTo.ClientPort,oldName)
                            portMObj.mapPortOperation(m3iObj.Name,'');
                        end
                    end
                end
            end
        end
    end

    methods(Static,Access=private)
        function fireAutosarMappingUpdatedEventForComSpecChange(m3iObj,portNodes)


            ARPortName=m3iObj.containerM3I.containerM3I.Name;
            ARDataElementName=m3iObj.containerM3I.DataElements.Name;

            for ii=1:length(portNodes)
                portObj=portNodes(ii);
                portElement=portObj.MappedTo;
                if isa(portElement,'Simulink.AutosarTarget.PortElement')&&...
                    strcmp(portElement.Port,ARPortName)&&...
                    strcmp(portElement.Element,ARDataElementName)

                    notify(portObj,'AutosarMappingEntityUpdated')

                    return;
                end
            end
        end
    end
end




