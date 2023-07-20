classdef(Hidden)TabCompletionUtils





    properties(Constant)
        SupportedInportPortTypes={'DataReceiverPort',...
        'DataSenderReceiverPort',...
        'ModeReceiverPort',...
        'ServiceRequiredPort',...
        'NvDataReceiverPort',...
        'NvDataSenderReceiverPort'};
        SupportedOutportPortTypes={'DataSenderPort',...
        'DataSenderReceiverPort',...
        'ModeSenderPort',...
        'ServiceProvidedPort',...
        'NvDataSenderPort',...
        'NvDataSenderReceiverPort'};
    end

    methods(Static)
        function pathStruct=getAUTOSARPathCompletion(dataObj,path)




            pathStruct=struct('name',{},'separator',{},'isleaf',{});

            needsSlashPrefix=false;
            if isempty(path)||(length(path)==1&&strcmp(path,'/'))

                m3iModel=dataObj.getM3IModel(ForXmlOptions=true);
                m3iObj=m3iModel.RootPackage.front();
                needsSlashPrefix=~(length(path)==1&&strcmp(path,'/'));
                if isempty(path)

                    pathStruct=struct('name','XmlOptions','separator','/',...
                    'isleaf',true);
                end
            else

                m3iModel=dataObj.getM3IModel();
                m3iObj=autosar.api.getAUTOSARProperties.findObjByPartialOrFullPath(m3iModel,path);
            end

            if isempty(m3iObj)


                return;
            end
            m3iChildren=m3iObj.containeeM3I;

            for childIdx=1:m3iChildren.size()
                if needsSlashPrefix

                    elementName=['/',m3iChildren.at(childIdx).Name];
                elseif~isempty(m3iChildren.at(childIdx))&&m3iChildren.at(childIdx).has('Name')
                    elementName=m3iChildren.at(childIdx).Name;
                else

                    continue;
                end


                isLeaf=isempty(m3iChildren.at(childIdx).containeeM3I);
                pathStruct(end+1)=struct('name',elementName,'separator','/',...
                'isleaf',isLeaf);%#ok<AGROW>
            end
        end

        function pathStruct=getAUTOSARPathCompletionForFind(dataObj,path)


            pathStruct=autosar.api.TabCompletionUtils.getAUTOSARPathCompletion(dataObj,path);
            pathStruct(strcmp({pathStruct(:).name},'XmlOptions'))=[];
        end

        function propertyNameCell=getValidPropertyNamesForGet(dataObj,elementPath)



            isGetMode=true;
            propertyNameCell=...
            autosar.api.TabCompletionUtils.getValidPropertyNames(...
            dataObj,elementPath,isGetMode);
        end

        function propertyNameCellPackage=getValidPackagePropertyNamesForSet(dataObj,elementPath)
            propertyNameCell=autosar.api.TabCompletionUtils.getValidPropertyNamesForSet(dataObj,elementPath);
            packages=autosar.mm.util.XmlOptionsAdapter.getXmlOptionNamesForPackages(dataObj.getM3IModelContext());
            propertyNameCellPackage=intersect(propertyNameCell,packages);
        end

        function propertyNameCellNonPackage=getValidNonPackagePropertyNamesForSet(dataObj,elementPath)
            propertyNameCell=autosar.api.TabCompletionUtils.getValidPropertyNamesForSet(dataObj,elementPath);
            packages=autosar.mm.util.XmlOptionsAdapter.getXmlOptionNamesForPackages(dataObj.getM3IModelContext());
            propertyNameCellNonPackage=setdiff(propertyNameCell,packages);
        end

        function propNames=getArchModelXmlOptionsPropNames(archModel)
            propNames=[];
            if is_simulink_handle(archModel.SimulinkHandle)
                dataObj=autosar.api.getAUTOSARProperties(archModel.SimulinkHandle);
                propNames=autosar.api.TabCompletionUtils.getValidPropertyNames(dataObj,'XmlOptions');
            end
        end

        function variableRole=getStaticMemoryRole(modelName)
            variableRole='';
            if~autosar.api.Utils.isMappedToAdaptiveApplication(modelName)
                variableRole='StaticMemory';
            end
        end

        function variableRole=getArTypedPerInstanceMemoryRole(modelName)
            variableRole='';
            if~autosar.api.Utils.isMappedToAdaptiveApplication(modelName)
                variableRole='ArTypedPerInstanceMemory';
            end
        end

        function variableRole=getPersistencyRole(modelName)
            variableRole='';
            if autosar.api.Utils.isMappedToAdaptiveApplication(modelName)
                variableRole=DAStudio.message('autosarstandard:ui:uiPersistencyArDataRole');
            end
        end

        function dataTransferNameCell=getValidSlDataTransferNames(modelName)



            dataTransferNameCell={};


            modelMapping=autosar.api.Utils.modelMapping(modelName);


            mappedDataTransfers=modelMapping.DataTransfers;

            for ii=1:length(mappedDataTransfers)
                dataTransferNameCell{end+1}=mappedDataTransfers(ii).SignalName;%#ok<AGROW>
            end



            mappedRTB=modelMapping.RateTransition;
            for ii=1:length(mappedRTB)
                dataTransferNameCell{end+1}=mappedRTB(ii).Block;%#ok<AGROW>
            end
        end

        function functionNameCell=getValidSlFunctionNames(modelName)



            functionNameCell={};


            isExportStyle=autosar.validation.ExportFcnValidator.isTopModelExportFcn(modelName);


            modelMapping=autosar.api.Utils.modelMapping(modelName);

            if~autosar.api.Utils.isMappedToAdaptiveApplication(modelName)

                functionNameCell{1}='InitializeFunction';
                if~isempty(modelMapping.TerminateFunctions)
                    functionNameCell{2}='TerminateFunction';
                end

                if~isExportStyle
                    functionNameCell{end+1}='StepFunction';


                    stepFunctions=modelMapping.StepFunctions;
                    for ii=2:length(stepFunctions)

                        functionNameCell{end+1}=...
                        ['StepFunction',num2str(ii-1)];%#ok<AGROW>
                    end
                end


                resetFunctions=modelMapping.ResetFunctions;
                for ii=1:length(resetFunctions)
                    functionNameCell{end+1}=resetFunctions(ii).Name;%#ok<AGROW>
                end


                fcnCallInports=modelMapping.FcnCallInports;
                for ii=1:length(fcnCallInports)
                    functionNameCell{end+1}=...
                    autosar.api.TabCompletionUtils.getBlockNameFromPath(fcnCallInports(ii).Block);%#ok<AGROW>
                end
            end

            if autosar.api.getSimulinkMapping.usesFunctionPortMapping(modelName)
                serverPorts=modelMapping.ServerPorts;
                for ii=1:length(serverPorts)
                    curPort=serverPorts(ii);
                    functionNameCell{end+1}=...
                    [curPort.MappedTo.Port,'.',curPort.MappedTo.Method];%#ok<AGROW>
                end
            else

                serverFunctions=modelMapping.ServerFunctions;
                for ii=1:length(serverFunctions)
                    functionNameCell{end+1}=...
                    autosar.api.TabCompletionUtils.getBlockNameFromPath(serverFunctions(ii).Block);%#ok<AGROW>
                end
            end
        end

        function inportNameCell=getValidSlInportNames(modelName)



            inportNameCell={};


            modelMapping=autosar.api.Utils.modelMapping(modelName);


            inports=modelMapping.Inports;
            for ii=1:length(inports)
                inportNameCell{end+1}=...
                autosar.api.TabCompletionUtils.getBlockNameFromPath(inports(ii).Block);%#ok<AGROW>
            end
        end

        function outportNameCell=getValidSlOutportNames(modelName)



            outportNameCell={};


            modelMapping=autosar.api.Utils.modelMapping(modelName);


            outports=modelMapping.Outports;
            for ii=1:length(outports)
                outportNameCell{end+1}=...
                autosar.api.TabCompletionUtils.getBlockNameFromPath(outports(ii).Block);%#ok<AGROW>
            end
        end

        function fcnCallerNameCell=getValidSlFcnCallerNames(modelName)



            fcnCallerNameCell={};


            modelMapping=autosar.api.Utils.modelMapping(modelName);

            if autosar.api.getSimulinkMapping.usesFunctionPortMapping(modelName)
                fcnCallerNameCell=autosar.api.TabCompletionUtils....
                getValidFunctionElementCalls(modelName);
            else

                fcnCallers=modelMapping.FunctionCallers;
                for ii=1:length(fcnCallers)
                    fcnCallerNameCell{end+1}=...
                    autosar.ui.utils.getSlFunctionName(fcnCallers(ii).Block);%#ok<AGROW>
                end
            end
        end

        function fcnElementCallsCell=getValidFunctionElementCalls(modelName)





            modelMapping=autosar.api.Utils.modelMapping(modelName);
            clientPorts=modelMapping.ClientPorts;
            fcnElementCallsCell=cell(length(clientPorts),1);
            for ii=1:length(clientPorts)
                curPort=clientPorts(ii);
                fcnElementCallsCell{ii}=...
                [curPort.MappedTo.Port,'.',curPort.MappedTo.Method];
            end
        end

        function arIRVNameCell=getValidARIRVNames(modelName)



            arIRVNameCell={};

            dataObj=autosar.api.getAUTOSARProperties(modelName);
            componentQualifiedName=dataObj.get('XmlOptions','ComponentQualifiedName');
            ARIRVPaths=dataObj.find(componentQualifiedName,'IrvData',...
            'PathType','FullyQualified');

            for ii=1:length(ARIRVPaths)
                arIRVNameCell{end+1}=dataObj.get(ARIRVPaths{ii},'Name');%#ok<AGROW>
            end
        end

        function arPortNameCell=getValidARPortNames(modelName,slPortName,portTypeList)



            if~any(ismember(portTypeList,'ClientPort'))&&~isempty(slPortName)
                portBlk=strcat(modelName,"/",slPortName);
                if autosar.composition.Utils.isCompositePortBlock(portBlk)
                    arPortNameCell={get_param(portBlk,'PortName')};
                    return;
                end
            end

            arPortNameCell={};

            dataObj=autosar.api.getAUTOSARProperties(modelName);
            componentQualifiedName=dataObj.get('XmlOptions','ComponentQualifiedName');

            if autosar.api.Utils.isMappedToAdaptiveApplication(modelName)
                if any(ismember(portTypeList,'ClientPort'))

                    portTypeList={'ServiceRequiredPort'};
                end
            end

            for portType=portTypeList


                arPortPaths=dataObj.find(componentQualifiedName,portType{1},...
                'PathType','FullyQualified');


                for ii=1:length(arPortPaths)
                    arPortNameCell{end+1}=dataObj.get(arPortPaths{ii},'Name');%#ok<AGROW>
                end
            end
        end

        function arDataElementNameCell=getValidARDataElements(modelName,slPortName,arPortName,portTypeList,isCSCom)




            if nargin<4
                isCSCom=false;
            end

            if~any(ismember(portTypeList,'ClientPort'))&&~isempty(slPortName)
                portBlk=strcat(modelName,"/",slPortName);
                if autosar.composition.Utils.isCompositePortBlock(portBlk)
                    arDataElementNameCell={get_param(portBlk,'Element')};
                    return;
                end
            end

            arDataElementNameCell={};

            dataObj=autosar.api.getAUTOSARProperties(modelName);
            componentQualifiedName=dataObj.get('XmlOptions','ComponentQualifiedName');

            if autosar.api.Utils.isMappedToAdaptiveApplication(modelName)
                if any(ismember(portTypeList,'ClientPort'))

                    portTypeList={'ServiceRequiredPort'};
                end
            end


            for portType=portTypeList


                arPortPath=dataObj.find(componentQualifiedName,portType{1},...
                'Name',arPortName,'PathType','FullyQualified');

                assert(length(arPortPath)<=1,'Expected to find maximum 1 Port');
                if isempty(arPortPath)


                    continue;
                end

                interfacePath=dataObj.get(arPortPath{1},'Interface',...
                'PathType','FullyQualified');


                m3iModel=autosar.api.Utils.m3iModel(modelName);
                m3iInterfaceSeq=autosar.mm.Model.findObjectByName(m3iModel,interfacePath);
                assert(m3iInterfaceSeq.size()==1,'Expected to find 1 interface');

                m3iInterface=m3iInterfaceSeq.at(1);

                if isa(m3iInterface,'Simulink.metamodel.arplatform.interface.ModeSwitchInterface')
                    metaModelClassName='ModeDeclarationGroupElement';
                elseif isa(m3iInterface,'Simulink.metamodel.arplatform.interface.ClientServerInterface')
                    metaModelClassName='Operation';
                elseif isa(m3iInterface,'Simulink.metamodel.arplatform.interface.ParameterInterface')
                    metaModelClassName='ParameterData';
                elseif isa(m3iInterface,'Simulink.metamodel.arplatform.interface.ServiceInterface')&&isCSCom
                    metaModelClassName='Operation';
                else
                    metaModelClassName='FlowData';
                end

                arDataElementPaths=dataObj.find(interfacePath,metaModelClassName,...
                'PathType','FullyQualified');

                for ii=1:length(arDataElementPaths)
                    arDataElementNameCell{end+1}=dataObj.get(arDataElementPaths{ii},'Name');%#ok<AGROW>
                end
            end
        end

        function arDataAccessModeCell=getValidARDataAccessModes(modelName,slPortName,arPortName,isInport)



            arDataAccessModeCell={};

            dataObj=autosar.api.getAUTOSARProperties(modelName);
            componentQualifiedName=dataObj.get('XmlOptions','ComponentQualifiedName');

            if isInport
                portType='RequiredPort';
            else
                portType='ProvidedPort';
            end

            portPath=strcat(modelName,'/',slPortName);
            isBusElementPort=autosar.composition.Utils.isCompositePortBlock(portPath);


            arPortPath=dataObj.find(componentQualifiedName,portType,...
            'Name',arPortName,'PathType','FullyQualified');
            if length(arPortPath)<1
                if isBusElementPort
                    if isInport
                        arDataAccessModeCell=autosar.api.getSimulinkMapping.getValidDataReceiverDAMs(isBusElementPort);
                    else
                        arDataAccessModeCell=autosar.api.getSimulinkMapping.getValidDataSenderDAMs(isBusElementPort);
                    end
                    return;
                else
                    assert(false,'Expected to find 1 Port');
                end
            else
                assert(length(arPortPath)==1,'Expected to find 1 Port');
            end



            m3iModel=autosar.api.Utils.m3iModel(modelName);
            m3iPortSeq=autosar.mm.Model.findObjectByName(m3iModel,arPortPath{1});
            assert(m3iPortSeq.size()==1,'Expected to find 1 Port');

            m3iPort=m3iPortSeq.at(1);

            if isa(m3iPort,'Simulink.metamodel.arplatform.port.DataReceiverPort')
                arDataAccessModeCell=autosar.api.getSimulinkMapping.getValidDataReceiverDAMs(isBusElementPort);
            elseif isa(m3iPort,'Simulink.metamodel.arplatform.port.DataSenderReceiverPort')&&isInport
                arDataAccessModeCell=autosar.api.getSimulinkMapping.getValidDataSenderReceiverDAMsForInports;
            elseif isa(m3iPort,'Simulink.metamodel.arplatform.port.NVDataReceiverPort')||...
                (isa(m3iPort,'Simulink.metamodel.arplatform.port.NVDataSenderReceiverPort')&&isInport)
                arDataAccessModeCell=autosar.api.getSimulinkMapping.getValidNvReceiverDAMs();
            elseif isa(m3iPort,'Simulink.metamodel.arplatform.port.ModeReceiverPort')
                arDataAccessModeCell={'ModeReceive'};
            elseif isa(m3iPort,'Simulink.metamodel.arplatform.port.DataSenderPort')||...
                (isa(m3iPort,'Simulink.metamodel.arplatform.port.DataSenderReceiverPort')&&~isInport)
                arDataAccessModeCell=autosar.api.getSimulinkMapping.getValidDataSenderDAMs(isBusElementPort);
            elseif isa(m3iPort,'Simulink.metamodel.arplatform.port.NVDataReceiverPort')||...
                (isa(m3iPort,'Simulink.metamodel.arplatform.port.NVDataSenderReceiverPort')&&~isInport)
                arDataAccessModeCell=autosar.api.getSimulinkMapping.getValidNvSenderDAMs();
            elseif isa(m3iPort,'Simulink.metamodel.arplatform.port.ModeSenderPort')
                arDataAccessModeCell={'ModeSend'};
            elseif isa(m3iPort,'Simulink.metamodel.arplatform.port.ServiceProvidedPort')
                arDataAccessModeCell=autosar.api.getSimulinkMapping.getValidServiceProvidedAllocateMemory();
            end

        end

        function arRunnableNameCell=getValidARRunnableNames(modelName)



            arRunnableNameCell={};

            dataObj=autosar.api.getAUTOSARProperties(modelName);
            componentQualifiedName=dataObj.get('XmlOptions','ComponentQualifiedName');

            arRunnablePaths=dataObj.find(componentQualifiedName,...
            'Runnable','PathType','FullyQualified');

            for ii=1:length(arRunnablePaths)
                arRunnableNameCell{end+1}=dataObj.get(arRunnablePaths{ii},'Name');%#ok<AGROW>
            end

        end

        function lutNameCell=getValidSlLookupTableNames(modelName)



            lutNameCell={};


            modelMapping=autosar.api.Utils.modelMapping(modelName);


            luts=modelMapping.LookupTablSlPortHandleses;
            for ii=1:length(luts)
                lutNameCell{end+1}=luts(ii).LookupTableName;%#ok<AGROW>
            end
        end

        function paramPortNameCell=getValidARParamPortNames(modelName,parameterAccessMode)



            if strcmp(parameterAccessMode,'PortParameter')
                portType={'ParameterReceiverPort'};
                paramPortNameCell=...
                autosar.api.TabCompletionUtils.getValidARPortNames(modelName,'',portType);
            else



                paramPortNameCell={''};
            end
        end

        function paramDataNameCell=getValidARParamDataNames(modelName,parameterAccessMode,arPortName)



            if strcmp(parameterAccessMode,'PortParameter')
                portType={'ParameterReceiverPort'};
                paramDataNameCell=...
                autosar.api.TabCompletionUtils.getValidARDataElements(modelName,'',arPortName,portType);
            else



                paramDataNameCell={''};
            end
        end

        function blockNameCell=getValidSlStateBlocks(modelName)




            modelMapping=autosar.api.Utils.modelMapping(modelName);

            stateBlocks=modelMapping.States;
            blockNameCell={stateBlocks.OwnerBlockPath};


            blockNameCell=unique(blockNameCell,'stable');
        end

        function stateNameCell=getValidStateNames(modelName,blockName)




            modelMapping=autosar.api.Utils.modelMapping(modelName);

            blockH=get_param(blockName,'Handle');
            states=modelMapping.States.findobj('OwnerBlockHandle',blockH);

            stateNameCell={states.Name};
        end

        function propertyNameCell=getValidPerInstancePropertiesForState(modelName,blockName,stateName)




            modelMapping=autosar.api.Utils.modelMapping(modelName);

            blockH=get_param(blockName,'Handle');
            stateList=modelMapping.States.findobj('OwnerBlockHandle',blockH);

            stateNameList={stateList.Name};
            stateIdx=ismember(stateNameList,stateName);
            selectedState=stateList(stateIdx);
            propertyNameCell=[...
            autosar.api.getSimulinkMapping.getValidCodePerInstanceProperties(selectedState),...
            autosar.api.getSimulinkMapping.getValidCalibrationPerInstanceProperties(selectedState)];
        end

        function blockNameCell=getValidSlDataStoreBlocks(modelName)




            modelMapping=autosar.api.Utils.modelMapping(modelName);

            dataStoreBlocks=modelMapping.DataStores;
            blockNameCell={dataStoreBlocks.OwnerBlockPath};
        end

        function propertyNameCell=getValidPerInstancePropertiesForDataStores(modelName,blockName)




            modelMapping=autosar.api.Utils.modelMapping(modelName);

            blockH=get_param(blockName,'Handle');
            dataStore=modelMapping.DataStores.findobj('OwnerBlockHandle',blockH);
            if autosar.api.Utils.isMappedToAdaptiveApplication(modelName)
                propertyNameCell=autosar.api.getSimulinkMapping.getValidCodePerInstanceProperties(dataStore);
            else
                propertyNameCell=[...
                autosar.api.getSimulinkMapping.getValidCodePerInstanceProperties(dataStore),...
                autosar.api.getSimulinkMapping.getValidCalibrationPerInstanceProperties(dataStore)];
            end
        end

        function paramNameCell=getValidSlParameter(modelName)




            modelMapping=autosar.api.Utils.modelMapping(modelName);

            parameters=modelMapping.ModelScopedParameters;

            if modelMapping.IsSubComponent
                parameters=parameters([parameters.InstanceSpecific]);
            end

            paramNameCell={parameters.Parameter};
        end

        function propertyNameCell=getValidPerInstancePropertiesForParameter(modelName,parameterName)




            modelMapping=autosar.api.Utils.modelMapping(modelName);

            parameter=modelMapping.ModelScopedParameters.findobj('Parameter',parameterName);
            propertyNameCell=[...
            autosar.api.getSimulinkMapping.getValidCodePerInstanceProperties(parameter),...
            autosar.api.getSimulinkMapping.getValidCalibrationPerInstanceProperties(parameter)];
        end

        function propertyNameCell=getValidPerInstancePropertiesForSignal(modelName,portHandle)




            modelMapping=autosar.api.Utils.modelMapping(modelName);

            signal=modelMapping.Signals.findobj('PortHandle',portHandle);
            propertyNameCell=[...
            autosar.api.getSimulinkMapping.getValidCodePerInstanceProperties(signal),...
            autosar.api.getSimulinkMapping.getValidCalibrationPerInstanceProperties(signal)];
        end

        function propertyNameCell=getValidInternalDataPackagingOptions(modelName)



            propertyNameCell=autosar.api.getSimulinkMapping.getValidInternalDataPackagingOptions(modelName);
        end

        function swAddrMethodNameCell=getValidSwAddrMethods(modelName,category)



            m3iModel=autosar.api.Utils.m3iModel(modelName);
            swAddrMethodNameCell=autosar.mm.util.SwAddrMethodHelper.findSwAddrMethodsForCategory(m3iModel,category);
        end

        function buildDirectory=getValidBuildDirectory(modelName)



            bdir=RTW.getBuildDir(modelName);
            buildDirectory={bdir.BuildDirectory};
        end

        function modelClassInstanceName=getValidModelClassInstanceName(modelName)


            instanceName=[modelName{1},'_obj'];
            modelClassInstanceName={instanceName};
        end

        function compositionQName=getValidCompositionQNameFromArxmlInput(arxmlInput)

            if isa(arxmlInput,'arxml.importer')
                importerObj=arxmlInput;
            else
                importerObj=arxml.importer(arxmlInput);
            end
            compositionQName=importerObj.getComponentNames('Composition');
        end

        function portNameCell=getValidPerPRPortNames(modelName)


            portNameCell={};


            dataObj=autosar.api.getAUTOSARProperties(modelName);
            componentQualifiedName=dataObj.get('XmlOptions','ComponentQualifiedName');

            arPortPaths=dataObj.find(componentQualifiedName,'PersistencyProvidedRequiredPort',...
            'PathType','FullyQualified');


            for ii=1:length(arPortPaths)
                portNameCell{end+1}=dataObj.get(arPortPaths{ii},'Name');%#ok<AGROW>
            end
        end

        function dataElementCell=getValidPerDataElementNames(modelName,perPortName)


            dataElementCell={};


            dataObj=autosar.api.getAUTOSARProperties(modelName);
            componentQualifiedName=dataObj.get('XmlOptions','ComponentQualifiedName');

            arPortPath=dataObj.find(componentQualifiedName,'PersistencyProvidedRequiredPort',...
            'Name',perPortName,'PathType','FullyQualified');


            interfacePath=dataObj.get(arPortPath{1},'Interface',...
            'PathType','FullyQualified');

            arDataElementPaths=dataObj.find(interfacePath,'PersistencyData',...
            'PathType','FullyQualified');

            for ii=1:length(arDataElementPaths)
                dataElementCell{end+1}=dataObj.get(arDataElementPaths{ii},'Name');%#ok<AGROW>
            end
        end

        function blockNameCell=getValidSlSynthesizedDataStores(modelName)




            modelMapping=autosar.api.Utils.modelMapping(modelName);

            dataStoreBlocks=modelMapping.SynthesizedDataStores;
            blockNameCell={dataStoreBlocks.Name};
        end
        function propertyNameCell=getValidPerInstancePropertiesForSynthDataStores(modelName,signalName)




            modelMapping=autosar.api.Utils.modelMapping(modelName);

            dataStore=modelMapping.SynthesizedDataStores.findobj('Name',signalName);

            if autosar.api.Utils.isMappedToAdaptiveApplication(modelName)
                propertyNameCell=autosar.api.getSimulinkMapping.getValidCodePerInstanceProperties(dataStore);
            else
                propertyNameCell=[...
                autosar.api.getSimulinkMapping.getValidCodePerInstanceProperties(dataStore),...
                autosar.api.getSimulinkMapping.getValidCalibrationPerInstanceProperties(dataStore)];
            end
        end

        function values=getValidDataDefaultsValues(mappedTo)
            values='';
            if strcmp(mappedTo,'EndToEndProtectionMethod')
                values=autosar.utils.mappingCategories.getMappedToCategoriesForEndToEndProtectionMethods();
            end
        end
    end

    methods(Static,Access=private)
        function blockName=getBlockNameFromPath(blockPath)
            blockName=get_param(blockPath,'Name');
        end

        function propertyNameCell=getValidPropertyNames(dataObj,elementPath,isGetMode)



            propertyNameCell={};

            if strcmp(elementPath,'XmlOptions')


                elementPath='/';
                m3iModel=dataObj.getM3IModel(ForXmlOptions=true);
            else

                if isGetMode
                    propertyNameCell=[propertyNameCell,{'Category'}];
                end

                elementPath=char(elementPath);

                if strcmp(elementPath(end),'/')
                    elementPath=elementPath(1:end-1);
                end
                m3iModel=dataObj.getM3IModel();
            end


            m3iObj=autosar.api.getAUTOSARProperties.findObjByPartialOrFullPath(m3iModel,elementPath);

            propertyNameCell=[propertyNameCell...
            ,autosar.api.getAUTOSARProperties.getValidAttributes(m3iObj,...
            dataObj.getM3IModelContext(),'mixed')];
        end

        function propertyNameCell=getValidPropertyNamesForSet(dataObj,elementPath)



            isGetMode=false;
            propertyNameCell=autosar.api.TabCompletionUtils.getValidPropertyNames(...
            dataObj,elementPath,isGetMode);



            propertyNameCell=setdiff(propertyNameCell,"MoveElements");
        end
    end

end



