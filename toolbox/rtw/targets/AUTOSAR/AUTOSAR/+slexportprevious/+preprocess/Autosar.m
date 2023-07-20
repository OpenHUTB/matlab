function Autosar(obj)




















    if isR2017bOrEarlier(obj.ver)

        obj.appendRule('<Block<BlockType|SignalInvalidation><InitialOutput:remove>>');
        obj.appendRule('<Block<BlockType|SignalInvalidation><InvalidationPolicy:remove>>');
    end

    if isR2020aOrEarlier(obj.ver)

        obj.appendRule('<Block<BlockType|SignalInvalidation><SimulateInvalidationFlag:remove>>');
    end



    if~autosarcore.ModelUtils.isMapped(obj.modelName)
        return
    end


    if isR2021aOrEarlier(obj.ver)&&obj.ver.isMDL



        DAStudio.warning('RTW:autosar:saveSlxAsMdl',obj.modelName);
    end

    if isR2022aOrEarlier(obj.ver)





        mappingManager=get_param(obj.modelName,'MappingManager');
        mapping=mappingManager.getActiveMappingFor('AutosarTarget');
        if~isempty(mapping)&&strcmp(mapping.DataDefaultsMapping.InternalData.Memory,'CTypedPerInstanceMemory')
            mapping.DataDefaultsMapping.InternalData.Memory='Default';
        end


        if Simulink.CodeMapping.isAutosarAdaptiveSTF(get_param(obj.modelName,'handle'))
            currAraVer=get_param(obj.modelName,'AutosarSchemaVersion');
            if strcmp(currAraVer,'R20-11')

                set_param(obj.modelName,'AutosarSchemaVersion','R19-11');

                m3iModel=autosarcore.M3IModelLoader.loadM3IModel(obj.modelName);
                dataObj=autosar.api.getAUTOSARProperties(obj.modelName,true);

                processPath=dataObj.find('/','Process','PathType','FullyQualified','Name','DefaultInstance');
                machinePath=dataObj.find('/','Machine','PathType','FullyQualified','Name','Host');
                modePath=dataObj.find('/','ModeDeclarationGroup','PathType','FullyQualified','Name','DefaultMachineStates');

                t=M3I.Transaction(m3iModel);

                if~isempty(machinePath)

                    if isempty(modePath)
                        dataObj.add(machinePath{1},'FunctionGroup','Host_ModeDeclarationGroupElement');
                    else
                        dataObj.add(machinePath{1},'FunctionGroup','Host_ModeDeclarationGroupElement','ModeGroup',modePath{1});
                    end
                end

                mdgePath=dataObj.find('/','ModeDeclarationGroupElement','PathType','FullyQualified','Name','Host_ModeDeclarationGroupElement');

                if~isempty(processPath)
                    pSeq=autosarcore.MetaModelFinder.findObjectByName(m3iModel,processPath{1});
                    applicationDesc=['Log messages for adaptive application ',obj.modelName];

                    if(pSeq.size()>0)
                        pObj=pSeq.at(1);


                        if isempty(pObj.LogTraceProcessDesc)
                            pObj.LogTraceProcessDesc=applicationDesc;
                        end

                        if~isempty(mdgePath)
                            mdgePathObj=autosarcore.MetaModelFinder.findObjectByName(m3iModel,mdgePath{1});

                            scObj=pObj.StateDependentStartupConfig;
                            if(scObj.size()>0)
                                scElem=scObj.at(1);
                                fgStateObjs=scElem.FunctionGroupState;
                                for jj=1:fgStateObjs.size()
                                    fgStateObjs.at(jj).('groupElement')=mdgePathObj.at(1);
                                end
                            end
                        end
                    end
                end
                t.commit();
            end
        end
    end


    if isR2021bOrEarlier(obj.ver)




        mappingManager=get_param(obj.modelName,'MappingManager');
        mapping=mappingManager.getActiveMappingFor('AutosarTargetCPP');
        if~isempty(mapping)
            delimiter='::';
            if contains(mapping.CppClassReference.ClassNamespace,delimiter)
                mapping.CppClassReference.ClassNamespace='';
            end
        end
    end


    if~autosarinstalled()
        MSLDiagnostic('RTW:autosar:AUTOSARBlocksetRequiredMsg').reportAsWarning;
        return
    end


    if isempty(autosar.api.Utils.m3iModel(obj.modelName))
        if isR2016aOrEarlier(obj.ver)
            loc_deleteLookupTableMapping(obj.modelName);
        end
        return
    end


    if isR2020aOrEarlier(obj.ver)
        mappingManager=get_param(obj.modelName,'MappingManager');
        modelMapping=mappingManager.getActiveMappingFor('AutosarTarget');

        if~isempty(modelMapping)
            for parameter=modelMapping.ModelScopedParameters
                if isequal(parameter.MappedTo.ArDataRole,'PortParameter')
                    parameter.MappedTo.ArDataRole='Auto';
                end
            end
        end


        if Simulink.CodeMapping.isAutosarAdaptiveSTF(get_param(obj.modelName,'handle'))

            m3iModel=autosarcore.M3IModelLoader.loadM3IModel(obj.modelName);
            t=M3I.Transaction(m3iModel);
            autosar.internal.adaptive.manifest.ManifestUtilities.removeAllAdaptiveManifestArtifacts(m3iModel);
            t.commit();



            loc_removeAdaptiveMethodsMapping(obj);
        end
    end

    if isR2019aOrEarlier(obj.ver)
        mappingManager=get_param(obj.modelName,'MappingManager');
        modelMapping=mappingManager.getActiveMappingFor('AutosarTargetCPP');
        if isa(modelMapping,'Simulink.AutosarTarget.AdaptiveModelMapping')
            loc_remapAdaptiveOutports(modelMapping);
        end
    end

    if isR2018bOrEarlier(obj.ver)
        loc_removeMappingToPartitions(obj);

        modelMapping=mappingManager.getActiveMappingFor('AutosarTargetCPP');
        if isa(modelMapping,'Simulink.AutosarTarget.AdaptiveModelMapping')
            loc_deleteAdaptiveConfiguration(obj.modelName)

            return;
        end
    end

    if isR2018aOrEarlier(obj.ver)
        loc_MigrateComponentXmlOptionsToArRoot(obj.modelName);
        loc_deleteInternalTriggers(obj.modelName);
    end

    if isR2016aOrEarlier(obj.ver)
        loc_deleteSwRecordLayoutGroups(obj.modelName);
        loc_deleteLookupTableMapping(obj.modelName);
        loc_replaceExplicitReceiveByVal(obj.modelName);


        loc_replaceModeSenderDataAccess(obj.modelName);
        loc_deleteClassObjects(obj.modelName,'ModeSenderPort');
        if Simulink.CodeMapping.isMappedToAutosarComponent(obj.modelName)
            loc_deleteTriggerReceivers(obj.modelName);
        end
        set_param(obj.modelName,'IncludeMdlTerminateFcn','off');
    end

    if isR2015aOrEarlier(obj.ver)

        loc_unmapNvPorts(obj.modelName);


        loc_deleteClassObjects(obj.modelName,'NvDataSenderReceiverPort');
        loc_deleteClassObjects(obj.modelName,'NvDataSenderPort');
        loc_deleteClassObjects(obj.modelName,'NvDataReceiverPort');


        loc_deleteClassObjects(obj.modelName,'SwBaseType');


        loc_deleteClassObjects(obj.modelName,'CompuMethod');
    end

    if isR2014bOrEarlier(obj.ver)

        loc_deleteIntegerValueVariationPoint(obj.modelName);
    end

    if isR2014aOrEarlier(obj.ver)

        loc_unmapPRPorts(obj.modelName);


        loc_deleteClassObjects(obj.modelName,'InitEvent');


        loc_deleteClassObjects(obj.modelName,'DataConstr');
    end

    if isR2013bOrEarlier(obj.ver)
        loc_deleteClassObjects(obj.modelName,'SwAddrMethod');
    end

    if isR2017aOrEarlier(obj.ver)
        loc_removeQueuedExplicitSend(obj.modelName);

        loc_deleteCompositionMappingIfAny(obj.modelName);
    end

    function loc_deleteClassObjects(modelName,metaClassName)


        dataObj=autosar.api.getAUTOSARProperties(modelName,true);
        paths=dataObj.find([],metaClassName,'PathType','FullyQualified');
        for ii=1:length(paths)
            dataObj.delete(paths{ii});
        end

        function loc_deleteIntegerValueVariationPoint(modelName)


            metaClass=Simulink.metamodel.arplatform.variant.IntegerValueVariationPoint.MetaClass;
            m3iModel=autosarcore.M3IModelLoader.loadM3IModel(modelName);
            seq=autosarcore.MetaModelFinder.findObjectByMetaClass(m3iModel,metaClass);
            t=M3I.Transaction(m3iModel);
            for ii=seq.size():-1:1
                seq.at(ii).destroy();
            end
            t.commit();

            function loc_deleteSwRecordLayoutGroup(m3iObj)
                seqV=m3iObj.SwRecordLayoutV;
                for ii=seqV.size():-1:1
                    seqV.at(ii).destroy();
                end
                seq=m3iObj.SwRecordLayoutGroup;
                for ii=seq.size():-1:1
                    loc_deleteSwRecordLayoutGroup(seq.at(ii));
                end
                m3iObj.destroy();

                function loc_deleteSwRecordLayoutGroups(modelName)

                    metaClass=Simulink.metamodel.types.SwRecordLayout.MetaClass;
                    m3iModel=autosarcore.M3IModelLoader.loadM3IModel(modelName);
                    seq=autosarcore.MetaModelFinder.findObjectByMetaClass(m3iModel,metaClass);

                    t=M3I.Transaction(m3iModel);
                    for ii=1:seq.size()
                        if seq.at(ii).SwRecordLayoutGroup.isvalid()
                            loc_deleteSwRecordLayoutGroup(seq.at(ii).SwRecordLayoutGroup);
                        end
                    end
                    t.commit();

                    function loc_unmapNvPorts(modelName)


                        dataObj=autosar.api.getAUTOSARProperties(modelName,true);
                        compQName=dataObj.get('XmlOptions','ComponentQualifiedName');
                        nvReceiverPorts=dataObj.get(compQName,'NvReceiverPorts',...
                        'PathType','FullyQualified');
                        nvSenderPorts=dataObj.get(compQName,'NvSenderPorts',...
                        'PathType','FullyQualified');
                        nvSenderReceiverPorts=dataObj.get(compQName,'NvSenderReceiverPorts',...
                        'PathType','FullyQualified');

                        arPorts=[nvReceiverPorts,nvSenderPorts,nvSenderReceiverPorts];


                        for ii=1:length(arPorts)
                            arPorts{ii}=dataObj.get(arPorts{ii},'Name');
                        end

                        loc_unmapArPorts(modelName,arPorts);


                        function loc_unmapPRPorts(modelName)


                            dataObj=autosar.api.getAUTOSARProperties(modelName,true);
                            compQName=dataObj.get('XmlOptions','ComponentQualifiedName');
                            senderReceiverPorts=dataObj.get(compQName,'SenderReceiverPorts',...
                            'PathType','FullyQualified');
                            nvSenderReceiverPorts=dataObj.get(compQName,'NvSenderReceiverPorts',...
                            'PathType','FullyQualified');

                            arPorts=[senderReceiverPorts,nvSenderReceiverPorts];


                            for ii=1:length(arPorts)
                                arPorts{ii}=dataObj.get(arPorts{ii},'Name');
                            end

                            loc_unmapArPorts(modelName,arPorts);

                            function loc_removeQueuedExplicitSend(modelName)





                                mapping=autosarcore.ModelUtils.modelMapping(modelName);
                                if isempty(mapping)||isempty(mapping.Outports)
                                    return;
                                end

                                emptyIndexes=arrayfun(@(x)isempty(x.MappedTo),mapping.Outports);
                                outports=mapping.Outports(~emptyIndexes);
                                if isempty(outports)
                                    return;
                                end

                                mappedTos=[outports.MappedTo];
                                queuedIndexes=strcmp({mappedTos.DataAccessMode},'QueuedExplicitSend');
                                queuedOutports=outports(queuedIndexes);
                                for idx=1:length(queuedOutports)
                                    blkMap=queuedOutports(idx);
                                    blkMap.mapPortElement(blkMap.MappedTo.Port,blkMap.MappedTo.Element,'ExplicitSend');
                                end

                                function loc_unmapArPorts(modelName,arPortNames)

                                    mapping=autosarcore.ModelUtils.modelMapping(modelName);
                                    for dataIdx=1:length(mapping.Inports)
                                        blkMap=mapping.Inports(dataIdx);
                                        if~isempty(blkMap.MappedTo)
                                            arPortName=blkMap.MappedTo.Port;
                                            if any(strcmp(arPortName,arPortNames))
                                                dataAccessModeStr=blkMap.MappedTo.DataAccessMode;
                                                blkMap.mapPortElement('','',dataAccessModeStr);
                                            end
                                        end
                                    end
                                    for dataIdx=1:length(mapping.Outports)
                                        blkMap=mapping.Outports(dataIdx);
                                        if~isempty(blkMap.MappedTo)
                                            arPortName=blkMap.MappedTo.Port;
                                            if any(strcmp(arPortName,arPortNames))
                                                dataAccessModeStr=blkMap.MappedTo.DataAccessMode;
                                                blkMap.mapPortElement('','',dataAccessModeStr);
                                            end
                                        end
                                    end

                                    function loc_replaceExplicitReceiveByVal(modelName)

                                        modelMapping=autosarcore.ModelUtils.modelMapping(modelName);


                                        for i=1:length(modelMapping.Inports)
                                            inportBlockMapping=modelMapping.Inports(i);

                                            if strcmp(inportBlockMapping.MappedTo.DataAccessMode,...
                                                'ExplicitReceiveByVal')

                                                [~,inportName]=fileparts(inportBlockMapping.Block);
                                                port=inportBlockMapping.MappedTo.Port;
                                                element=inportBlockMapping.MappedTo.Element;
                                                mappingObj=autosar.api.getSimulinkMapping(modelName);
                                                mappingObj.mapInport(inportName,port,element,...
                                                'ExplicitReceive');
                                            end

                                        end

                                        function loc_replaceModeSenderDataAccess(modelName)

                                            modelMapping=autosarcore.ModelUtils.modelMapping(modelName);

                                            for dataIdx=1:length(modelMapping.Outports)
                                                blkMap=modelMapping.Outports(dataIdx);
                                                if~isempty(blkMap.MappedTo)
                                                    if strcmp(blkMap.MappedTo.DataAccessMode,'ModeSend')
                                                        blkMap.mapPortElement('','','ImplicitSend');
                                                    end
                                                end
                                            end


                                            function loc_MigrateComponentXmlOptionsToArRoot(modelName)



                                                m3iModel=autosarcore.M3IModelLoader.loadM3IModel(modelName);
                                                t=M3I.Transaction(m3iModel);
                                                arRoot=m3iModel.RootPackage.front();
                                                m3iComp=autosarcore.ModelUtils.m3iMappedComponent(modelName);

                                                arRoot.ComponentQualifiedName=autosar.api.Utils.getQualifiedName(m3iComp);
                                                arRoot.InternalBehaviorQualifiedName=autosar.mm.util.XmlOptionsAdapter.get(...
                                                m3iComp,'InternalBehaviorQualifiedName');
                                                arRoot.ImplementationQualifiedName=autosar.mm.util.XmlOptionsAdapter.get(...
                                                m3iComp,'ImplementationQualifiedName');
                                                t.commit();

                                                function loc_deleteCompositionMappingIfAny(modelName)
                                                    mmgr=get_param(modelName,'MappingManager');
                                                    mapping=mmgr.getActiveMappingFor('AutosarComposition');
                                                    if~isempty(mapping)
                                                        mapping.unmap();
                                                        mmgr.deleteMapping(mapping);
                                                    end

                                                    function loc_deleteLookupTableMapping(modelName)
                                                        if Simulink.CodeMapping.isMappedToAutosarComponent(modelName)
                                                            mapping=autosar.api.Utils.modelMapping(modelName);
                                                            mapping.unmapLookupTables();
                                                        end

                                                        function loc_deleteTriggerReceivers(modelName)



                                                            dataObj=autosar.api.getAUTOSARProperties(modelName,true);
                                                            m3iModel=autosar.api.Utils.m3iModel(modelName);

                                                            compQName=dataObj.get('XmlOptions','ComponentQualifiedName');
                                                            m3iCompSeq=autosarcore.MetaModelFinder.findObjectByName(m3iModel,compQName);
                                                            assert(m3iCompSeq.size()==1)
                                                            m3iComp=m3iCompSeq.at(1);


                                                            events=m3iComp.Behavior.Events;
                                                            t=M3I.Transaction(m3iModel);
                                                            for ii=events.size():-1:1
                                                                if isa(events.at(ii),...
                                                                    'Simulink.metamodel.arplatform.behavior.ExternalTriggerOccurredEvent')
                                                                    events.at(ii).destroy();
                                                                end
                                                            end


                                                            triggerPorts=m3iComp.TriggerReceiverPorts;
                                                            for ii=triggerPorts.size():-1:1
                                                                triggerPorts.at(ii).destroy();
                                                            end


                                                            instanceMapping=m3iComp.instanceMapping;
                                                            if~isempty(instanceMapping)
                                                                instanceRefs=instanceMapping.instance;
                                                                for ii=instanceRefs.size():-1:1
                                                                    if isa(instanceRefs.at(ii),...
                                                                        'Simulink.metamodel.arplatform.instance.TriggerInstanceRef')
                                                                        instanceRefs.at(ii).destroy();
                                                                    end
                                                                end
                                                            end
                                                            t.commit();


                                                            loc_deleteClassObjects(modelName,'TriggerInterface');


                                                            function loc_deleteInternalTriggers(modelName)


                                                                loc_deleteClassObjects(modelName,'InternalTriggerOccurredEvent');
                                                                loc_deleteClassObjects(modelName,'InternalTrigger');

                                                                function loc_deleteAdaptiveConfiguration(modelName)
                                                                    mappingManager=get_param(modelName,'MappingManager');
                                                                    modelMapping=mappingManager.getActiveMappingFor('AutosarTargetCPP');
                                                                    if isa(modelMapping,'Simulink.AutosarTarget.AdaptiveModelMapping')
                                                                        autosar.api.delete(modelName);
                                                                        set_param(modelName,'SystemTargetFile','autosar.tlc');
                                                                    end

                                                                    function loc_remapAdaptiveOutports(mapping)


                                                                        outports=mapping.Outports;
                                                                        for ii=1:length(outports)
                                                                            curPort=outports(ii);
                                                                            portName=curPort.MappedTo.Port;
                                                                            eventName=curPort.MappedTo.Event;
                                                                            curPort.mapPortEvent(portName,eventName,'');
                                                                        end

                                                                        function loc_removeAdaptiveMethodsMapping(obj)



                                                                            mappingManager=get_param(obj.modelName,'MappingManager');
                                                                            mapping=mappingManager.getActiveMappingFor('AutosarTargetCPP');
                                                                            if~isa(mapping,'Simulink.AutosarTarget.AdaptiveModelMapping')
                                                                                return;
                                                                            end
                                                                            methodMappings=[mapping.ServerFunctions,mapping.FunctionCallers];
                                                                            for ii=1:length(methodMappings)
                                                                                curMapping=methodMappings(ii);
                                                                                blockPath=curMapping.Block;
                                                                                blockHandle=get_param(blockPath,'Handle');
                                                                                mapping.unmapBlock(blockHandle);
                                                                            end

                                                                            function loc_removeMappingToPartitions(obj)
                                                                                mappingManager=get_param(obj.modelName,'MappingManager');
                                                                                modelMapping=mappingManager.getActiveMappingFor('AutosarTarget');
                                                                                if isempty(modelMapping)
                                                                                    return
                                                                                end


                                                                                for stepMap=modelMapping.StepFunctions
                                                                                    partitionName=stepMap.PartitionName;
                                                                                    if isempty(partitionName)
                                                                                        continue
                                                                                    end

                                                                                    obj.appendRule(['<Simulink.AutosarTarget.EntryPointMapping<PartitionName|"',partitionName,'">:remove>']);
                                                                                end



