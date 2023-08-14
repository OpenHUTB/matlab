classdef(Hidden)MappingUpdaterForSharedDictionary




    methods(Static,Access=public)

        function handleMappingForDeletedReferences(mdlH)








            origDirtyState=get_param(mdlH,'dirty');
            cleanUpObj=onCleanup(@()set_param(mdlH,'dirty',origDirtyState'));

            autosar.dictionary.MappingUpdaterForSharedDictionary.handleDeletedInterfaces(mdlH);

            autosar.dictionary.MappingUpdaterForSharedDictionary.handleSwAddrMethods(mdlH);
        end
    end

    methods(Static,Access=private)

        function handleDeletedInterfaces(mdlH)

            m3iComp=autosarcore.ModelUtils.m3iMappedComponent(mdlH);


            m3iPorts=autosarcore.MetaModelFinder.findChildByTypeName(m3iComp,...
            'Simulink.metamodel.arplatform.port.Port',true,true);
            idx=cellfun(@(x)isempty(x.Interface),m3iPorts);
            m3iPorts=m3iPorts(idx);

            if~isempty(m3iPorts)

                mapping=autosarcore.ModelUtils.modelMapping(mdlH);
                dataPortNodes=[mapping.Inports,mapping.Outports];
                portParameterNodes=[];
                csNodes=[];
                if autosarcore.ModelUtils.isMappedToComponent(mdlH)

                    csNodes=mapping.FunctionCallers;


                    modelParams=mapping.ModelScopedParameters;
                    portParameterNodes=modelParams(...
                    arrayfun(@(x)strcmp(x.MappedTo.ArDataRole,'PortParameter'),modelParams));
                end


                for portIdx=1:length(m3iPorts)
                    curM3IPort=m3iPorts{portIdx};
                    if isa(curM3IPort,'Simulink.metamodel.arplatform.port.ParameterReceiverPort')
                        relevantMappingNodes={portParameterNodes};
                    elseif isa(curM3IPort,'Simulink.metamodel.arplatform.port.ClientPort')||...
                        isa(curM3IPort,'Simulink.metamodel.arplatform.port.ServerPort')
                        relevantMappingNodes={csNodes};
                    else
                        relevantMappingNodes={dataPortNodes};
                    end

                    autosar.mm.observer.ObserverModelMapping.handleInterfaceChange(...
                    curM3IPort,relevantMappingNodes,m3iPorts{portIdx}.Name,mdlH);
                end
            end


            autosar.dictionary.MappingUpdaterForSharedDictionary.handleDeletedOrRenamedPortElements(mdlH);
        end

        function handleDeletedOrRenamedPortElements(mdlH)



            import autosar.dictionary.MappingUpdaterForSharedDictionary

            mapping=autosarcore.ModelUtils.modelMapping(mdlH);
            m3iComp=autosarcore.ModelUtils.m3iMappedComponent(mdlH);

            isAdaptive=autosarcore.ModelUtils.isMappedToAdaptiveApplication(mdlH);


            inports=mapping.Inports;
            for portIdx=1:length(inports)
                curPort=inports(portIdx);
                arPort=curPort.MappedTo.Port;
                if isAdaptive
                    elementPropName='Event';
                else
                    elementPropName='Element';
                end
                arElement=curPort.MappedTo.(elementPropName);
                if isempty(arElement)

                    continue;
                end

                if MappingUpdaterForSharedDictionary.isPortElementDeletedOrRenamed(m3iComp,arPort,arElement)
                    elementName=MappingUpdaterForSharedDictionary.getM3IObjectNameByMappingID(mdlH,curPort.MappedTo.UUID);
                    if~strcmp(arElement,elementName)
                        if isAdaptive
                            curPort.mapPortEvent(arPort,'','');
                        else
                            curPort.mapPortElement(arPort,elementName,curPort.MappedTo.DataAccessMode);
                        end
                    end
                end
            end


            outports=mapping.Outports;
            for portIdx=1:length(outports)
                curPort=outports(portIdx);
                arPort=curPort.MappedTo.Port;
                if isAdaptive
                    elementPropName='Event';
                else
                    elementPropName='Element';
                end
                arElement=curPort.MappedTo.(elementPropName);
                if isempty(arElement)

                    continue;
                end

                if MappingUpdaterForSharedDictionary.isPortElementDeletedOrRenamed(m3iComp,arPort,arElement)
                    elementName=MappingUpdaterForSharedDictionary.getM3IObjectNameByMappingID(mdlH,curPort.MappedTo.UUID);
                    if~strcmp(arElement,elementName)
                        if isAdaptive
                            curPort.mapPortProvidedEvent(arPort,'',curPort.MappedTo.AllocateMemory,'');
                        else
                            curPort.mapPortElement(arPort,elementName,curPort.MappedTo.DataAccessMode);
                        end
                    end
                end
            end

            if autosarcore.ModelUtils.isMappedToComponent(mdlH)



                fcnCallers=mapping.FunctionCallers;
                for portIdx=1:length(fcnCallers)
                    curFcnCaller=fcnCallers(portIdx);
                    arPort=curFcnCaller.MappedTo.ClientPort;
                    arOperation=curFcnCaller.MappedTo.Operation;
                    if isempty(arOperation)

                        continue;
                    end

                    if MappingUpdaterForSharedDictionary.isPortElementDeletedOrRenamed(m3iComp,arPort,arOperation)
                        opName=MappingUpdaterForSharedDictionary.getM3IObjectNameByMappingID(mdlH,curFcnCaller.MappedTo.UUID);
                        if~strcmp(arOperation,opName)
                            curFcnCaller.mapPortOperation(arPort,opName);
                        end
                    end
                end


                modelParams=mapping.ModelScopedParameters;
                portParameterNodes=modelParams(...
                arrayfun(@(x)strcmp(x.MappedTo.ArDataRole,'PortParameter'),modelParams));
                for portIdx=1:length(portParameterNodes)
                    curPortParam=portParameterNodes(portIdx);
                    arPort=curPortParam.MappedTo.getPerInstancePropertyValue('Port');
                    arElement=curPortParam.MappedTo.getPerInstancePropertyValue('DataElement');
                    if isempty(arElement)

                        continue;
                    end

                    if MappingUpdaterForSharedDictionary.isPortElementDeletedOrRenamed(m3iComp,arPort,arElement)
                        elemName=MappingUpdaterForSharedDictionary.getM3IObjectNameByMappingID(mdlH,curPortParam.MappedTo.UUID);
                        if~strcmp(arElement,elemName)
                            Simulink.CodeMapping.setPerInstancePropertyValue(...
                            mdlH,curPortParam,'MappedTo','DataElement',elemName);
                        end
                    end
                end
            end
        end

        function name=getM3IObjectNameByMappingID(mdlH,mappingID)
            name='';
            if~isempty(mappingID)
                m3iObj=autosar.dictionary.MappingUpdaterForSharedDictionary.getM3IObjectByMappingID(mdlH,mappingID);
                if m3iObj.isvalid()
                    name=m3iObj.Name;
                end
            end
        end

        function m3iObj=getM3IObjectByMappingID(mdlH,mappingID)
            elementID=jsondecode(mappingID).ElementID;
            serializedInterfaceDictUUID=jsondecode(mappingID).ArchitectureDictionaryUUID;
            sharedM3IModel=autosarcore.ModelUtils.getSharedElementsM3IModel(mdlH);
            currentDictUUID=autosar.dictionary.Utils.getDictionaryUUID(sharedM3IModel);
            assert(strcmp(currentDictUUID,serializedInterfaceDictUUID),'Unexpected dictionary UUID');
            m3iObj=M3I.getObjectById(elementID,sharedM3IModel);
        end

        function elementDeleted=isPortElementDeletedOrRenamed(m3iComp,arPortName,arItfElementName)
            elementDeleted=false;


            m3iPort=autosarcore.MetaModelFinder.findChildByName(m3iComp,arPortName);


            if m3iPort.isvalid()
                m3iItf=m3iPort.Interface;
                m3iItfElement=autosarcore.MetaModelFinder.findChildByName(m3iItf,arItfElementName);
                elementDeleted=isempty(m3iItfElement);
            end
        end

        function handleSwAddrMethods(mdlH)
            if autosarcore.ModelUtils.isMappedToComponent(mdlH)
                throwErrors=false;



                [invalidRunnables,invalidRunnableData,invalidInternalData]=...
                autosar.validation.ClassicSwAddrMethodValidator.verifySwAddrMethods(mdlH,throwErrors);

                for runnableIdx=1:length(invalidRunnables)
                    invalidRunnables{runnableIdx}.unmapSwAddrMethod();
                end
                for runnableIdx=1:length(invalidRunnableData)
                    invalidRunnableData{runnableIdx}.unmapInternalDataSwAddrMethod();
                end
                for internalDataIdx=1:length(invalidInternalData)
                    Simulink.CodeMapping.setPerInstancePropertyValue(mdlH,...
                    invalidInternalData{internalDataIdx},'MappedTo',...
                    'SwAddrMethod','');
                end
            else


            end
        end
    end
end


