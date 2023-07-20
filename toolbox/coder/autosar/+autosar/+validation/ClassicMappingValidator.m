classdef ClassicMappingValidator<autosar.validation.PhasedValidator




    properties(Access=private)
        DataObjectValidator autosar.validation.DataObjectValidator;
    end

    properties(Constant,Access=private)
        E2EDataAccessModes={'EndToEndRead','EndToEndWrite',...
        'EndToEndQueuedReceive','EndToEndQueuedSend'};
        QoSDataAccessModes={'ErrorStatus','IsUpdated'};
    end

    methods(Access=public)
        function this=ClassicMappingValidator(modelHandle)
            this@autosar.validation.PhasedValidator('ModelHandle',modelHandle);
            this.DataObjectValidator=autosar.validation.DataObjectValidator(modelHandle);
        end
    end

    methods(Access=protected)

        function verifyInitial(this,hModel)
            this.verifySLPortRTEAPIs(hModel);
            this.verifyNvPortDataAccessModes(hModel);
            if strcmp(autosar.validation.Validator.getValidationLevel(),'partial')


                this.verifyMappingPartial(hModel);
            end
            this.verifyValidDefaultMappingForInternalData(hModel);
            this.verifyEndToEndProtectionMethodSupport(hModel);
        end

        function verifyPostProp(this,hModel)
            this.verifyMappingFull(hModel);
            this.verifyDuplicateCallerBlocks(hModel);
            this.verifySLPortStatusConnections(hModel);
            this.verifySampleTimesStepFunctions(hModel);
            this.verifyRateTransitions(hModel);
            this.verifySignalInvalidationBlocks(hModel);
            this.verifyRateTransitionDataTypes(hModel);
            this.verifySLPortElementDataTypes(hModel);
            this.verifyReferencedDataTypeMapping(hModel);
            this.verifyLookupTables(hModel);
            this.verifyQueuedPorts(hModel);
            this.verifyModelScopedParameterDataType(hModel);
            this.verifyInitValue(hModel);
        end

    end

    methods(Access=private)
        function verifyModelScopedParameterDataType(this,hModel)

            mapping=autosar.api.Utils.modelMapping(hModel);
            if~isempty(mapping.ModelScopedParameters)
                cs=getActiveConfigSet(hModel);
                maxShortNameLength=get_param(cs,'AutosarMaxShortNameLength');

                isSupportMatrixIOAsArray=strcmpi(...
                get_param(hModel,'AutosarMatrixIOAsArray'),'on')||...
                strcmpi(get_param(hModel,'ArrayLayout'),'row-major');

                for i=1:length(mapping.ModelScopedParameters)
                    parameterMapping=mapping.ModelScopedParameters(i);
                    arRole=parameterMapping.MappedTo.ArDataRole;
                    paramName=parameterMapping.Parameter;
                    [paramObjExists,paramObj]=autosar.utils.Workspace.objectExistsInModelScope(hModel,paramName);
                    if paramObjExists&&isa(paramObj,"Simulink.Parameter")...
                        &&(isequal(arRole,'PortParameter')||isequal(arRole,'SharedParameter')||isequal(arRole,'PerInstanceParameter'))
                        prefix=[parameterMapping.MappedTo.ArDataRole,' ',paramName];
                        this.AutosarUtilsValidator.checkDataType(...
                        prefix,paramObj.DataType,...
                        maxShortNameLength,isSupportMatrixIOAsArray)
                    end
                end
            end
        end

        function verifyLookupTables(this,hModel)



            modelMapping=autosar.api.Utils.modelMapping(hModel);
            dataObj=autosar.api.getAUTOSARProperties(hModel,true);
            componentQualifiedName=dataObj.get('XmlOptions',...
            'ComponentQualifiedName');
            m3iModel=autosar.api.Utils.m3iModel(hModel);
            compObjSeq=autosar.mm.Model.findObjectByName(m3iModel,componentQualifiedName);
            assert(compObjSeq.size()>0);
            compObj=compObjSeq.at(1);
            paramsMap=containers.Map;
            for ii=1:numel(modelMapping.LookupTables)
                mapping=modelMapping.LookupTables(ii);



                if strcmp(mapping.MappedTo.ParameterAccessMode,'Auto')
                    continue;
                end

                if strcmp(mapping.MappedTo.ParameterAccessMode,'PortParameter')
                    m3iPort=Simulink.metamodel.arplatform.ModelFinder.findNamedItemInSequence(...
                    compObj,compObj.ParameterReceiverPorts,mapping.MappedTo.Port,...
                    'Simulink.metamodel.arplatform.port.ParameterReceiverPort');
                    assert(m3iPort.isvalid(),'Invalid Parameter Receiver Port.');
                    m3iData=Simulink.metamodel.arplatform.ModelFinder.findNamedItemInSequence(m3iPort.Interface,...
                    m3iPort.Interface.DataElements,mapping.MappedTo.Parameter,...
                    'Simulink.metamodel.arplatform.interface.ParameterData');
                    this.verifyLookupTableM3iDataAndMapping(hModel,m3iData,mapping);
                    if paramsMap.isKey([m3iPort.Interface.Name,'.',mapping.MappedTo.Parameter])
                        ndx=paramsMap([m3iPort.Interface.Name,'.',mapping.MappedTo.Parameter]);
                        param1=modelMapping.LookupTables(ndx).LookupTableName;
                        param2=mapping.LookupTableName;

                        [param1Exists,obj1]=autosar.utils.Workspace.objectExistsInModelScope(hModel,param1);
                        [param2Exists,obj2]=autosar.utils.Workspace.objectExistsInModelScope(hModel,param2);
                        if param1Exists&&param2Exists
                            autosar.validation.Validator.logError('autosarstandard:validation:duplicateMappedParameters',...
                            class(obj1),param1,class(obj2),param2);
                        end
                    else
                        paramsMap([m3iPort.Interface.Name,'.',mapping.MappedTo.Parameter])=ii;
                    end
                else
                    if paramsMap.isKey(mapping.MappedTo.Parameter)
                        ndx=paramsMap(mapping.MappedTo.Parameter);
                        param1=modelMapping.LookupTables(ndx).LookupTableName;
                        param2=mapping.LookupTableName;
                        [param1Exists,obj1]=autosar.utils.Workspace.objectExistsInModelScope(hModel,param1);
                        [param2Exists,obj2]=autosar.utils.Workspace.objectExistsInModelScope(hModel,param2);
                        if param1Exists&&param2Exists
                            autosar.validation.Validator.logError('autosarstandard:validation:duplicateMappedParametersInternal',...
                            class(obj1),param1,class(obj2),param2,mapping.MappedTo.Parameter);
                        end
                    else
                        paramsMap(mapping.MappedTo.Parameter)=ii;
                    end
                    if isempty(mapping.MappedTo.Parameter)&&...
                        autosar.utils.Workspace.objectExistsInModelScope(hModel,mapping.LookupTableName)
                        autosar.validation.Validator.logError('autosarstandard:validation:unmappedLookup',mapping.LookupTableName,...
                        get_param(hModel,'Name'));
                    end
                    behaviorObj=compObj.Behavior;
                    calPrmName=mapping.MappedTo.Parameter;
                    m3iData=Simulink.metamodel.arplatform.ModelFinder.findNamedItemInSequence(...
                    compObj,behaviorObj.Parameters,calPrmName,...
                    'Simulink.metamodel.arplatform.interface.ParameterData');
                    this.verifyLookupTableM3iDataAndMapping(hModel,m3iData,mapping);
                end
            end
        end

        function verifyLookupTableM3iDataAndMapping(this,hModel,m3iData,lutMapping)
            if~m3iData.isvalid()
                if autosar.utils.Workspace.objectExistsInModelScope(hModel,lutMapping.LookupTableName)



                    autosar.validation.Validator.logError(...
                    'autosarstandard:validation:ParamDoesNotExist',...
                    lutMapping.LookupTableName,lutMapping.MappedTo.Parameter,...
                    lutMapping.MappedTo.ParameterAccessMode);
                end
            else
                [lutObjExists,lutObj]=autosar.utils.Workspace.objectExistsInModelScope(hModel,lutMapping.LookupTableName);
                if lutObjExists
                    this.DataObjectValidator.validateLookupTableParamObj(...
                    lutObj,lutMapping.LookupTableName,lutMapping.MappedTo.ParameterAccessMode,hModel);
                end
            end
        end

    end

    methods(Static,Access=private)
        function verifyMappingFull(hModel)

            mapping=autosar.api.Utils.modelMapping(hModel);
            try
                mapping.validate();
            catch ME
                autosar.validation.Validator.logError(ME.identifier,ME);
            end
            autosar.validation.ClassicMappingValidator.verifyValidMappedToForInternalData(hModel);
            autosar.validation.ClassicMappingValidator.verifyValidMappingMdlWSParameters(hModel);
        end

        function verifyMappingPartial(hModel)

            mapping=autosar.api.Utils.modelMapping(hModel);
            try
                mapping.validateIO();
            catch ME




                autosar.validation.Validator.logError(ME.identifier,ME);
            end
        end

        function verifyValidMappingMdlWSParameters(hModel)
            mapping=autosar.api.Utils.modelMapping(hModel);
            hws=get_param(hModel,'modelworkspace');
            paramArgs=strsplit(get_param(hModel,'ParameterArgumentNames'),',');
            portParamApiMap=containers.Map();
            for i=1:length(mapping.ModelScopedParameters)
                parameterMapping=mapping.ModelScopedParameters(i);
                paramName=parameterMapping.Parameter;
                arDataRole=parameterMapping.MappedTo.ArDataRole;
                if~strcmp(arDataRole,'Auto')&&...
                    ~strcmp(hws.getVariable(paramName).CoderInfo.StorageClass,'Auto')
                    autosar.validation.Validator.logError('autosarstandard:validation:invalidParamterMappingAndStorageClass',paramName);
                end

                if ismember(paramName,paramArgs)&&~(...
                    any(strcmp(arDataRole,{'Auto','PerInstanceParameter','PortParameter'})))
                    autosar.validation.Validator.logError('autosarstandard:validation:invalidParamterMappingAndArgumentProperty',paramName);
                end

                if~ismember(paramName,paramArgs)&&any(strcmp(arDataRole,{'PerInstanceParameter','PortParameter'}))
                    autosar.validation.Validator.logError('autosarstandard:validation:invalidParamterMappingAndArgumentProperty',paramName);
                end

                if strcmp(parameterMapping.MappedTo.ArDataRole,'PortParameter')


                    arParamPortName=parameterMapping.MappedTo.getPerInstancePropertyValue('Port');
                    arParamDataElementName=parameterMapping.MappedTo.getPerInstancePropertyValue('DataElement');
                    if isempty(arParamPortName)||isempty(arParamDataElementName)

                        autosar.validation.Validator.logError('autosarstandard:validation:unmappedPortParam',paramName,get_param(hModel,'Name'));
                        continue;
                    end

                    apiObj=autosar.api.getAUTOSARProperties(hModel);
                    componentQName=apiObj.get('XmlOptions','ComponentQualifiedName');
                    arParamPort=apiObj.find(componentQName,'ParameterReceiverPort','Name',arParamPortName);
                    assert(length(arParamPort)==1,'Expected to find exactly 1 parameter port');
                    arParamItf=apiObj.get(arParamPort{1},'Interface','PathType','FullyQualified');
                    assert(~isempty(arParamItf),'Expected to find parameter interface');
                    arDataElement=apiObj.find(arParamItf,'ParameterData','Name',arParamDataElementName);
                    assert(length(arDataElement)==1,'Expected to find exactly 1 parameter element');

                    paramAPI=[arParamPortName,'_',arParamDataElementName];
                    if portParamApiMap.isKey(paramAPI)


                        otherParamName=portParamApiMap(paramAPI);
                        autosar.validation.Validator.logError('autosarstandard:validation:duplicatePortParamMapping',...
                        paramName,otherParamName,arParamPortName,arParamDataElementName);
                    else

                        portParamApiMap(paramAPI)=paramName;
                    end
                end
            end
        end

        function verifyValidDefaultMappingForInternalData(hModel)
            mapObj=autosar.api.getSimulinkMapping(hModel);
            internalDataMappedTo=mapObj.getInternalDataPackaging();

            if autosar.validation.CommonConfigSetValidator.isCodeInterfacePackagingReusable(hModel)
                if~strcmp(internalDataMappedTo,'Default')&&...
                    ~(matlab.internal.feature("ArMultiInstInternalDataPackaging")&&strcmp(internalDataMappedTo,'CTypedPerInstanceMemory'))
                    autosar.validation.Validator.logError('autosarstandard:validation:invalidInternalDataDefaultForMultiInstOrSubComp',...
                    internalDataMappedTo);
                end
            else
                if strcmp(internalDataMappedTo,'CTypedPerInstanceMemory')
                    autosar.validation.Validator.logError('autosarstandard:validation:invalidInternalDataDefaultForSingleInst',...
                    internalDataMappedTo);
                end
            end
        end

        function verifyEndToEndProtectionMethodSupport(hModel)



            mapObj=autosar.api.getSimulinkMapping(hModel);
            e2eProtectionMethod=mapObj.getDataDefaults('InportsOutports','EndToEndProtectionMethod');


            if strcmp(e2eProtectionMethod,'ProtectionWrapper')
                return
            end

            schemaVersion=get_param(hModel,'AutosarSchemaVersion');
            doesSchemaSupportTransformerError=slfeature('AutosarTransformer')&&...
            ~strcmp(schemaVersion,'4.0')&&~strcmp(schemaVersion,'4.1');


            if~doesSchemaSupportTransformerError
                autosar.validation.Validator.logError('autosarstandard:validation:invalidAUTOSARSchemaForTransformerError',...
                schemaVersion);
            end


            autosar.validation.ClassicMappingValidator....
            verifyE2ETransformerErrorMappingConsistency(hModel);
        end

        function verifyE2ETransformerErrorMappingConsistency(hModel)






            import autosar.validation.ClassicMappingValidator;

            mapObj=autosar.api.getSimulinkMapping(hModel);
            e2eProtectionMethod=mapObj.getDataDefaults('InportsOutports','EndToEndProtectionMethod');

            assert(strcmp(e2eProtectionMethod,'TransformerError'),...
            'Unexpected e2e protection method')

            mapping=autosar.api.Utils.modelMapping(hModel);
            ports=[mapping.Inports,mapping.Outports];
            if~ClassicMappingValidator.hasEndToEndPorts(ports)

                return;
            end

            portToTransformerMap=containers.Map();
            for portIdx=1:length(ports)
                curPort=ports(portIdx);
                if ClassicMappingValidator.isQoSPort(curPort)


                    continue;
                end
                portName=curPort.MappedTo.Port;
                isCurPortE2E=ClassicMappingValidator.isE2EPort(curPort);
                if~portToTransformerMap.isKey(portName)
                    portToTransformerMap(portName)=isCurPortE2E;
                else



                    if isCurPortE2E~=portToTransformerMap(portName)
                        autosar.validation.Validator.logError(...
                        'autosarstandard:validation:inconsistentE2EMapping',...
                        portName,get_param(hModel,'Name'));
                    end
                end

            end

        end

        function hasE2EPort=hasEndToEndPorts(ports)

            hasE2EPort=any(arrayfun(...
            @(port)autosar.validation.ClassicMappingValidator.isE2EPort(port),...
            ports));
        end

        function isE2E=isE2EPort(portMapping)
            isE2E=any(strcmp(portMapping.MappedTo.DataAccessMode,...
            autosar.validation.ClassicMappingValidator.E2EDataAccessModes));
        end

        function isQoS=isQoSPort(portMapping)
            isQoS=any(strcmp(portMapping.MappedTo.DataAccessMode,...
            autosar.validation.ClassicMappingValidator.QoSDataAccessModes));
        end

        function verifyValidMappedToForInternalData(hModel)
            mapping=autosar.api.Utils.modelMapping(hModel);


            isMultiinstance=strcmp(get_param(hModel,'CodeInterfacePackaging'),'Reusable function');
            if isMultiinstance
                invalidMappedToForMultiinstance={'StaticMemory','ConstantMemory'};
                for i=1:length(mapping.Signals)
                    signalMapping=mapping.Signals(i);

                    if isMultiinstance

                        index=find(ismember(invalidMappedToForMultiinstance,signalMapping.MappedTo.ArDataRole));
                        if~isempty(index)
                            mappedToColumnName=DAStudio.message('coderdictionary:mapping:MappedToColumnName');
                            autosar.validation.Validator.logError('RTW:autosar:invalidSignalMappedToForMultiinstance',invalidMappedToForMultiinstance{index}...
                            ,mappedToColumnName,signalMapping.Name);
                        end
                    end

                end

                for i=1:length(mapping.States)
                    stateMapping=mapping.States(i);

                    if isMultiinstance
                        index=find(ismember(invalidMappedToForMultiinstance,stateMapping.MappedTo.ArDataRole));
                        if~isempty(index)
                            mappedToColumnName=DAStudio.message('coderdictionary:mapping:MappedToColumnName');
                            autosar.validation.Validator.logError('RTW:autosar:invalidStateMappedToForMultiinstance',invalidMappedToForMultiinstance{index},...
                            mappedToColumnName,stateMapping.OwnerBlockPath);
                        end
                    end
                end


                for i=1:length(mapping.DataStores)
                    dsmMapping=mapping.DataStores(i);

                    if isMultiinstance
                        index=find(ismember(invalidMappedToForMultiinstance,dsmMapping.MappedTo.ArDataRole));
                        if~isempty(index)
                            mappedToColumnName=DAStudio.message('coderdictionary:mapping:MappedToColumnName');
                            autosar.validation.Validator.logError('RTW:autosar:invalidDSMMappedToForMultiinstance',invalidMappedToForMultiinstance{index}...
                            ,mappedToColumnName,dsmMapping.Name);
                        end
                    end
                end

                for i=1:length(mapping.SynthesizedDataStores)
                    synthDSMapping=mapping.SynthesizedDataStores(i);

                    if isMultiinstance
                        index=find(ismember(invalidMappedToForMultiinstance,synthDSMapping.MappedTo.ArDataRole));
                        if~isempty(index)
                            mappedToColumnName=DAStudio.message('coderdictionary:mapping:MappedToColumnName');
                            autosar.validation.Validator.logError('RTW:autosar:invalidDSMMappedToForMultiinstance',invalidMappedToForMultiinstance{index}...
                            ,mappedToColumnName,synthDSMapping.Name);
                        end
                    end
                end

                for i=1:length(mapping.ModelScopedParameters)
                    parameterMapping=mapping.ModelScopedParameters(i);

                    if isMultiinstance
                        invalidMappedToForMultiinstance={'ConstantMemory'};
                        index=find(ismember(invalidMappedToForMultiinstance,parameterMapping.MappedTo.ArDataRole));
                        if~isempty(index)
                            mappedToColumnName=DAStudio.message('coderdictionary:mapping:MappedToColumnName');
                            autosar.validation.Validator.logError('RTW:autosar:invalidParameterMappedToForMultiinstance',invalidMappedToForMultiinstance{index}...
                            ,mappedToColumnName,parameterMapping.Parameter);
                        end
                    end
                end
            end
        end

        function verifyReferencedDataTypeMapping(hModel)
            import Simulink.metamodel.types.CompuMethodCategory;
            import autosar.mm.util.ExternalToolInfoAdapter;

            m3iModel=autosar.api.Utils.m3iModel(hModel);
            arRoot=m3iModel.RootPackage.front();
            m3iSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectByMetaClass(arRoot,...
            Simulink.metamodel.types.CompuMethod.MetaClass,true);
            for ii=1:m3iSeq.size()
                compuMethod=m3iSeq.at(ii);
                slDataTypes=ExternalToolInfoAdapter.get(compuMethod,...
                autosar.ui.metamodel.PackageString.SlDataTypes);
                for jj=1:numel(slDataTypes)
                    if~isempty(compuMethod)&&compuMethod.isvalid()
                        errorCodes=autosar.mm.util.checkDataTypeCompuMethodCompatibility(...
                        get_param(hModel,'Name'),slDataTypes{jj},compuMethod,true);
                        if numel(errorCodes)>0
                            autosar.validation.Validator.logError(errorCodes{1:numel(errorCodes)})
                        end
                    end
                end
            end
            if autosar.mm.arxml.Exporter.hasExternalReference(arRoot)
                m3iSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectByParentMetaClass(arRoot,...
                Simulink.metamodel.foundation.ValueType.MetaClass,true);
                for ii=1:m3iSeq.size()
                    implDataType=m3iSeq.at(ii);
                    if~implDataType.IsApplication
                        slDataTypes=ExternalToolInfoAdapter.get(implDataType,...
                        autosar.ui.metamodel.PackageString.SlDataTypes);
                        for jj=1:numel(slDataTypes)
                            if~isempty(implDataType)&&implDataType.isvalid()
                                errorCodes=autosar.mm.util.checkImplementationDataTypeCompatibility(...
                                get_param(hModel,'Name'),slDataTypes{jj},implDataType);
                                if numel(errorCodes)>0
                                    autosar.validation.Validator.logError(errorCodes{1:numel(errorCodes)})
                                end
                            end
                        end
                    end
                end
            end
        end
        function E2EMethod=getE2EMethod(hModel,port)
            isE2EAccess=strcmp(port.MappedTo.DataAccessMode,'EndToEndRead')||...
            strcmp(port.MappedTo.DataAccessMode,'EndToEndWrite');
            if~isE2EAccess
                E2EMethod='';
            else
                mapping=autosar.api.getSimulinkMapping(hModel);
                E2EMethod=mapping.getDataDefaults('InportsOutports','EndToEndProtectionMethod');
            end
        end

        function verifySLPortElementDataTypes(hModel)


            mapping=autosar.api.Utils.modelMapping(hModel);
            dataObj=autosar.api.getAUTOSARProperties(hModel,true);
            componentQName=dataObj.get('XmlOptions','ComponentQualifiedName');



            arPortToSlPortNumMap=containers.Map();
            for dataIdx=1:length(mapping.Inports)
                inport=mapping.Inports(dataIdx);
                arPortName=inport.MappedTo.Port;
                arElementName=inport.MappedTo.Element;
                switch inport.MappedTo.DataAccessMode
                case{'ImplicitReceive',...
                    'ExplicitReceive',...
                    'QueuedExplicitReceive',...
                    'QueuedExplicitSend',...
                    'EndToEndRead'}
                    mapKey=[arPortName,'/',arElementName];
                    arPortToSlPortNumMap(mapKey)=dataIdx;
                otherwise

                end
            end


            elementInfoMap=containers.Map();
            for inportIdx=1:length(mapping.Inports)
                inport=mapping.Inports(inportIdx);

                if~inport.IsActive||isempty(inport.MappedTo.Port)||...
                    isempty(inport.MappedTo.Element)
                    continue;
                end

                elementInfoMap=autosar.validation.ClassicMappingValidator.i_checkElement(dataObj,componentQName,...
                elementInfoMap,inport,true);

                switch inport.MappedTo.DataAccessMode
                case 'ExplicitReceiveByVal'
                    autosar.validation.ClassicMappingValidator.i_checkExplicitReceiveByValDataType(hModel,inport);
                case 'ErrorStatus'
                    arPortName=inport.MappedTo.Port;
                    arElementName=inport.MappedTo.Element;
                    mapKey=[arPortName,'/',arElementName];
                    if~arPortToSlPortNumMap.isKey(mapKey)



                        continue;
                    end

                    receiverInPort=mapping.Inports(arPortToSlPortNumMap(mapKey));
                    E2EMethod=autosar.validation.ClassicMappingValidator.getE2EMethod(hModel,receiverInPort);

                    autosar.validation.ClassicMappingValidator.i_checkErrorStatusDataType(inport,E2EMethod);

                case 'IsUpdated'
                    autosar.validation.ClassicMappingValidator.i_checkIsUpdatedDataType(inport);
                case 'ModeReceive'
                    autosar.validation.ClassicMappingValidator.i_checkModeDataType(inport,hModel);
                otherwise

                end
            end

            for outportIdx=1:length(mapping.Outports)
                outport=mapping.Outports(outportIdx);

                if~outport.IsActive||isempty(outport.MappedTo.Port)||...
                    isempty(outport.MappedTo.Element)
                    continue;
                end

                elementInfoMap=autosar.validation.ClassicMappingValidator.i_checkElement(dataObj,componentQName,...
                elementInfoMap,outport,false);
                switch outport.MappedTo.DataAccessMode
                case 'ModeSend'
                    autosar.validation.ClassicMappingValidator.i_checkModeDataType(outport,hModel);
                otherwise

                end
            end

        end

        function statusStr=convertBoolToEnabledStr(booleanValue)
            if booleanValue
                statusStr='enabled';
            else
                statusStr='disabled';
            end
        end

        function verifySLPortStatusConnections(hModel)


            mapping=autosar.api.Utils.modelMapping(hModel);


            referredToByErrorStatus={};
            referringToErrorStatus={};
            referredToByIsUpdated={};
            referringToIsUpdated={};
            for statusInportIdx=1:length(mapping.Inports)
                statusInport=mapping.Inports(statusInportIdx);
                statusDataAccessMode=statusInport.MappedTo.DataAccessMode;
                if~ismember(statusDataAccessMode,{'ErrorStatus','IsUpdated'})
                    continue
                end
                statusInportName=get_param(statusInport.Block,'Name');

                arPortName=statusInport.MappedTo.Port;
                arElementName=statusInport.MappedTo.Element;
                statusIsEnabled=strcmp(get_param(statusInport.Block,'CompiledIsActive'),'on');

                for dataIdx=1:length(mapping.Inports)
                    dataInport=mapping.Inports(dataIdx);
                    dataInportName=get_param(dataInport.Block,'Name');
                    dataAccessMode=dataInport.MappedTo.DataAccessMode;

                    if~ismember(dataAccessMode,{'ImplicitReceive',...
                        'ExplicitReceive','ExplicitReceiveByVal',...
                        'EndToEndRead','QueuedExplicitReceive',...
                        'QueuedExplicitSend','EndToEndQueuedSend','EndToEndQueuedReceive'})
                        continue
                    end

                    dataInportIsEnabled=strcmp(...
                    get_param(dataInport.Block,'CompiledIsActive'),...
                    'on');
                    if strcmp(dataInport.MappedTo.Port,arPortName)&&...
                        strcmp(dataInport.MappedTo.Element,arElementName)
                        switch statusDataAccessMode
                        case{'ErrorStatus'}
                            if strcmp(dataAccessMode,'ExplicitReceiveByVal')
                                autosar.validation.Validator.logError('autosarstandard:validation:explicitReceiveByValErrorStatus',...
                                statusInport.Block,...
                                dataInport.Block);
                            end
                            if strcmp(dataAccessMode,'QueuedExplicitReceive')


                                isMessageOutport=get_param(dataInport.Block,'CompiledPortIsMessage');
                                isMessage=isMessageOutport.Outport;
                                if(isMessage==1)
                                    autosar.validation.Validator.logError('autosarstandard:validation:QueuedExplicitReceiveErrorStatus',...
                                    statusInport.Block,...
                                    dataInport.Block);
                                end
                            end

                            existingRef=find(ismember(referredToByErrorStatus,...
                            dataInportName));
                            if~isempty(existingRef)
                                msg=DAStudio.message('RTW:autosar:errorStatusPortNumClash',...
                                statusInportName,...
                                dataInportName,...
                                referringToErrorStatus{existingRef},...
                                dataInportName);
                                autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                            end

                            if(statusIsEnabled~=dataInportIsEnabled)
                                statusEnabledStr=autosar.validation.ClassicMappingValidator.convertBoolToEnabledStr(statusIsEnabled);
                                dataEnabledStr=autosar.validation.ClassicMappingValidator.convertBoolToEnabledStr(dataInportIsEnabled);
                                autosar.validation.Validator.logError('autosarstandard:validation:errorStatusVariantMismatch',...
                                statusInport.Block,statusEnabledStr,...
                                dataInport.Block,dataEnabledStr);
                            end

                            referredToByErrorStatus{end+1}=dataInportName;%#ok<AGROW>
                            referringToErrorStatus{end+1}=statusInportName;%#ok<AGROW>
                        case{'IsUpdated'}
                            existingRef=find(ismember(referredToByIsUpdated,...
                            dataInportName));
                            if~isempty(existingRef)
                                autosar.validation.Validator.logError('autosarstandard:validation:isUpdatedPortNumClash',...
                                statusInport.Block,...
                                dataInport.Block,...
                                referringToIsUpdated{existingRef});
                            end
                            referredToByIsUpdated{end+1}=dataInportName;%#ok<AGROW>
                            referringToIsUpdated{end+1}=statusInport.Block;%#ok<AGROW>

                            if~ismember(dataAccessMode,{...
                                'ExplicitReceive',...
                                'ExplicitReceiveByVal',...
                                'EndToEndRead'})
                                autosar.validation.Validator.logError('autosarstandard:validation:isUpdatedPortWithoutExplicitReceive',...
                                dataInport.Block,...
                                statusInport.Block);
                            end

                            if(statusIsEnabled~=dataInportIsEnabled)
                                statusEnabledStr=autosar.validation.ClassicMappingValidator.convertBoolToEnabledStr(statusIsEnabled);
                                dataEnabledStr=autosar.validation.ClassicMappingValidator.convertBoolToEnabledStr(dataInportIsEnabled);
                                autosar.validation.Validator.logError('autosarstandard:validation:isUpdatedVariantMismatch',...
                                statusInport.Block,statusEnabledStr,...
                                dataInport.Block,dataEnabledStr);
                            end
                        otherwise
                            assert(false,'Did not recognize DataAccessMode %s',statusDataAccessMode);
                        end
                        break
                    end
                end


                if autosar.validation.ExportFcnValidator.isExportFcn(hModel)
                    dataPortH=get_param(dataInport.Block,'Handle');
                    dataPortLineH=get_param(dataPortH,'LineHandles');
                    dataPortLineObj=get_param(dataPortLineH.Outport,'Object');

                    statusPortH=get_param(statusInport.Block,'Handle');
                    statusPortLineH=get_param(statusPortH,'LineHandles');
                    statusPortLineObj=get_param(statusPortLineH.Outport,'Object');

                    dataPortDstBlocks=autosar.validation.walkThruVirtualBlockToDsts(dataPortLineObj,hModel,true);
                    statusPortDstBlocks=autosar.validation.walkThruVirtualBlockToDsts(statusPortLineObj,hModel,true);


                    for dstIdx=1:length(statusPortDstBlocks)
                        if slInternal('isFunctionCallSubsystem',statusPortDstBlocks(dstIdx))


                            if~ismember(statusPortDstBlocks(dstIdx),dataPortDstBlocks)
                                switch statusDataAccessMode
                                case{'ErrorStatus'}
                                    invalidRunnableErrorId='autosarstandard:validation:errorStatusPortInvalidRunnable';
                                case{'IsUpdated'}
                                    invalidRunnableErrorId='autosarstandard:validation:isUpdatedPortInvalidRunnable';
                                otherwise
                                    assert(false,'Did not recognize DataAccessMode %s',statusDataAccessMode);
                                end
                                autosar.validation.Validator.logError(invalidRunnableErrorId,...
                                dataInport.Block,...
                                statusInport.Block);
                            end
                        end
                    end
                end

            end

        end

        function verifySampleTimesStepFunctions(hModel)
            mapping=autosar.api.Utils.modelMapping(hModel);

            if autosar.validation.ExportFcnValidator.isExportFcn(hModel)
                if~isempty(mapping.StepFunctions)
                    autosar.validation.Validator.logError('RTW:autosar:periodRunnableSyncNeeded');
                end
                return;
            end

            mapping.validateStepFunctions();
        end

        function verifyRateTransitions(hModel)
            mapping=autosar.api.Utils.modelMapping(hModel);
            if autosar.validation.ExportFcnValidator.isExportFcn(hModel)

                return
            end

            if~isempty(mapping.RateTransition)
                dataObj=autosar.api.getAUTOSARProperties(hModel,true);
                componentQualifiedName=dataObj.get('XmlOptions',...
                'ComponentQualifiedName');

                irvNames=arrayfun(@(x)x.MappedTo.IrvName,...
                mapping.RateTransition,'UniformOutput',false);
                for i=1:length(mapping.RateTransition)
                    if isempty(mapping.RateTransition(i).MappedTo.IrvName)
                        blkPath=mapping.RateTransition(i).Block;
                        autosar.validation.Validator.logError(...
                        'autosarstandard:validation:unmappedRateTransition',...
                        blkPath);
                    else
                        if any(strcmp(irvNames(i),irvNames(i+1:end)))
                            blkPath=mapping.RateTransition(i).Block;
                            autosar.validation.Validator.logError(...
                            'autosarstandard:validation:duplicateIRVMappedToRTB',...
                            blkPath,irvNames{i});
                        else
                            ARIRVPath=dataObj.find(componentQualifiedName,...
                            'IrvData','Name',irvNames{i});
                            if isempty(ARIRVPath)


                                autosar.validation.Validator.logError(...
                                'autosarstandard:validation:irvDoesNotExist',...
                                mapping.RateTransition(i).Block,...
                                irvNames{i});
                            end
                        end
                    end
                end
            end

            if length(mapping.StepFunctions)<=1

                return;
            end
            rtBlks=find_system(get_param(hModel,'Name'),'FollowLinks','on',...
            'MatchFilter',@Simulink.match.activeVariants,...
            'LookUnderMasks','all','BlockType','RateTransition');
            for i=1:length(rtBlks)
                if~(strcmp(get_param(rtBlks{i},'Integrity'),'on')&&...
                    strcmp(get_param(rtBlks{i},'Deterministic'),'off'))
                    autosar.validation.Validator.logError(...
                    'autosarstandard:validation:RateTranBlkForIRV',...
                    rtBlks{i});
                end
            end
        end

        function verifyRateTransitionDataTypes(hModel)
            mapping=autosar.api.Utils.modelMapping(hModel);
            if autosar.validation.ExportFcnValidator.isExportFcn(hModel)||...
                (length(mapping.StepFunctions)<=1)


                return
            end

            if~isempty(mapping.RateTransition)
                for i=1:length(mapping.RateTransition)
                    blk=mapping.RateTransition(i).Block;

                    complexSigs=get_param(blk,'CompiledPortComplexSignals');
                    if complexSigs.Inport
                        autosar.validation.Validator.logError('autosarstandard:validation:RTBComplex',...
                        blk);
                    end
                end
            end
        end

        function verifySLPortRTEAPIs(hModel)

            mapping=autosar.api.Utils.modelMapping(hModel);


            apiMap=containers.Map();
            for inportIdx=1:length(mapping.Inports)
                inport=mapping.Inports(inportIdx);
                if strcmp(get_param(inport.Block,'IsBusElementPort'),'on')
                    continue;
                end
                apiMap=autosar.validation.ClassicMappingValidator.i_checkAPI(hModel,apiMap,inport);
            end

            for outportIdx=1:length(mapping.Outports)
                outport=mapping.Outports(outportIdx);
                if strcmp(get_param(outport.Block,'IsBusElementPort'),'on')
                    continue;
                end
                apiMap=autosar.validation.ClassicMappingValidator.i_checkAPI(hModel,apiMap,outport);
            end

        end

        function verifyDuplicateCallerBlocks(hModel)
            mapping=autosar.api.Utils.modelMapping(hModel);
            dups=containers.Map;
            for index=1:length(mapping.FunctionCallers)
                if~isempty(mapping.FunctionCallers(index).MappedTo)&&...
                    mapping.FunctionCallers(index).IsActive&&...
                    ~autosar.blocks.InternalTriggerBlock.isInternalTriggerBlock(...
                    mapping.FunctionCallers(index).Block)
                    key=[mapping.FunctionCallers(index).MappedTo.ClientPort,'/'...
                    ,mapping.FunctionCallers(index).MappedTo.Operation];
                    if~isKey(dups,key)
                        dups(key)=mapping.FunctionCallers(index).Block;
                    else
                        if~strcmp(get_param(mapping.FunctionCallers(index).Block,'FunctionPrototype'),...
                            get_param(dups(key),'FunctionPrototype'))
                            msg=DAStudio.message('RTW:autosar:duplicateMappedClientBlock',...
                            mapping.FunctionCallers(index).Block,...
                            dups(key));
                            autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                        end
                    end
                end
            end
        end

        function verifyNvPortDataAccessModes(hModel)


            dataObj=autosar.api.getAUTOSARProperties(hModel,true);
            compQName=dataObj.get('XmlOptions','ComponentQualifiedName');
            nvReceiverPorts=dataObj.get(compQName,'NvReceiverPorts',...
            'PathType','FullyQualified');
            nvSenderPorts=dataObj.get(compQName,'NvSenderPorts',...
            'PathType','FullyQualified');
            nvSenderReceiverPorts=dataObj.get(compQName,'NvSenderReceiverPorts',...
            'PathType','FullyQualified');

            arPorts=[nvReceiverPorts,nvSenderPorts,nvSenderReceiverPorts];
            if isempty(arPorts)
                return
            end


            for ii=1:length(arPorts)
                arPorts{ii}=dataObj.get(arPorts{ii},'Name');
            end


            mapping=autosar.api.Utils.modelMapping(hModel);
            for dataIdx=1:length(mapping.Inports)
                blkMap=mapping.Inports(dataIdx);
                dataAccessMode=blkMap.MappedTo.DataAccessMode;
                switch dataAccessMode
                case autosar.api.getSimulinkMapping.getValidNvReceiverDAMs()

                otherwise
                    arPortName=blkMap.MappedTo.Port;
                    arElementName=blkMap.MappedTo.Element;
                    if any(strcmp(arPortName,arPorts))
                        autosar.validation.Validator.logError('autosarstandard:validation:invalidNvPortDAM',...
                        blkMap.Block,arPortName,arElementName,dataAccessMode);
                    end
                end
            end
            for dataIdx=1:length(mapping.Outports)
                blkMap=mapping.Outports(dataIdx);
                dataAccessMode=blkMap.MappedTo.DataAccessMode;
                switch dataAccessMode
                case autosar.api.getSimulinkMapping.getValidNvSenderDAMs()

                otherwise
                    arPortName=blkMap.MappedTo.Port;
                    arElementName=blkMap.MappedTo.Element;
                    if any(strcmp(arPortName,arPorts))
                        autosar.validation.Validator.logError('autosarstandard:validation:invalidNvPortDAM',...
                        blkMap.Block,arPortName,arElementName,dataAccessMode);
                    end
                end
            end

        end


        function verifySignalInvalidationBlocks(hModel)


            siBlks=find_system(get_param(hModel,'Name'),...
            'MatchFilter',@Simulink.match.allVariants,...
            'FollowLinks','on','LookUnderMasks','all','BlockType','SignalInvalidation');

            for i=1:length(siBlks)
                currBlk=siBlks{i};

                cLine=get_param(currBlk,'LineHandles');
                currOutport=cLine.Outport;

                if currOutport<0
                    autosar.validation.Validator.logError('autosarstandard:validation:signalInvalidationBlockActualDestination',...
                    currBlk);
                end

                dataPortLineObj=get_param(currOutport,'Object');
                assert(dataPortLineObj.SrcPortHandle>=0);
                srcPortObj=get_param(dataPortLineObj.SrcPortHandle,'Object');

                if isempty(autosar.simulink.bep.Utils.findBusElementPortsAtRoot(hModel))


                    eiPval=slfeature('EngineInterface',Simulink.EngineInterfaceVal.embeddedCoder);
                    actDstInfo=srcPortObj.getActualDst();
                    slfeature('EngineInterface',eiPval);
                    if autosar.validation.ClassicMappingValidator.isInsideInactiveVariant(actDstInfo)
                        continue;
                    end
                else

                    dstPort=autosar.mm.mm2sl.SLModelBuilder.getAllDestinationPortsThroughVirtualBlocks(srcPortObj.Parent);
                    actDstInfo=[dstPort{:}]';
                end

                if(size(actDstInfo,1)<1)
                    autosar.validation.Validator.logError('autosarstandard:validation:signalInvalidationBlockActualDestination',...
                    currBlk);
                elseif(size(actDstInfo,1)>1)
                    autosar.validation.Validator.logError('autosarstandard:validation:signalInvalidationBlockMultipleDestinations',...
                    currBlk);
                end
                dstPortHdl=actDstInfo(1);
                outBlk=get_param(dstPortHdl,'Parent');

                if~strcmp(get_param(outBlk,'BlockType'),'Outport')||...
                    (hModel~=get_param(get_param(outBlk,'Parent'),'Handle'))
                    autosar.validation.Validator.logError('autosarstandard:validation:signalInvalidationBlockActualDestination',...
                    currBlk);
                end

                outBlkName=get_param(outBlk,'Name');
                outBlkFullName=getfullname(outBlk);

                mapping=autosar.api.getSimulinkMapping(hModel);
                [outBlkPort,outBlkElem,outBlkDataAccess]=mapping.getOutport(outBlkName);
                if~ismember(outBlkDataAccess,...
                    {'ExplicitSend','EndToEndWrite'})
                    msg=message('autosarstandard:validation:signalInvalidationBlockAccessMode',...
                    outBlkFullName,currBlk);
                    ME=MSLException(msg);
                    ME.throw();
                end

                rawBlkInitValueStr=get_param(currBlk,'InitialOutput');


                blkInitValueStr=...
                autosar.ui.comspec.ComSpecPropertyHandler.convertValueExpressionToScalarValueString(...
                hModel,rawBlkInitValueStr);
                m3iComp=autosar.api.Utils.m3iMappedComponent(hModel);
                m3iComSpec=autosar.ui.comspec.ComSpecUtils.getM3IComSpec(...
                m3iComp,outBlkPort,outBlkElem,...
                false);
                if isempty(m3iComSpec)...
                    &&isempty(autosar.ui.comspec.ComSpecUtils.findM3IPortByName(...
                    m3iComp,outBlkPort))
                    autosar.validation.AutosarUtils.reportErrorWithFixit('autosarstandard:validation:MissingPortDefinition',outBlkPort,getfullname(hModel),outBlkFullName);
                end
                dataDictionary=get_param(hModel,'DataDictionary');
                createInitValueIfNecessary=true;
                mmInitValueStr=...
                autosar.ui.comspec.ComSpecPropertyHandler.getComSpecPropertyValueStr(...
                m3iComSpec,'InitValue',dataDictionary,createInitValueIfNecessary);

                if~strcmp(mmInitValueStr,DAStudio.message('autosarstandard:ui:uiCannotDisplayHeterogeneousData'))&&...
                    ~(strcmp(blkInitValueStr,mmInitValueStr)...
                    ||strcmp(rawBlkInitValueStr,mmInitValueStr))
                    autosar.validation.Validator.logError(...
                    'autosarstandard:validation:signalInvalidationInitValueMismatch',...
                    'InitialOutput',currBlk,rawBlkInitValueStr,...
                    mmInitValueStr,'InitValue',outBlk,blkInitValueStr);
                end
            end
        end

        function isInsideInactiveVariant=isInsideInactiveVariant(actDstInfo)




            isInsideInactiveVariant=isempty(actDstInfo)&&(size(actDstInfo,2)~=5);
        end


        function verifyQueuedPorts(hModel)
            mapping=autosar.api.Utils.modelMapping(hModel);

            dataObj=autosar.api.getAUTOSARProperties(hModel,true);
            componentQualifiedName=dataObj.get('XmlOptions',...
            'ComponentQualifiedName');
            m3iModel=autosar.api.Utils.m3iModel(hModel);

            multiInstance=strcmp(get_param(hModel,'CodeInterfacePackaging'),'Reusable function');


            for dataIdx=1:length(mapping.Inports)
                inport=mapping.Inports(dataIdx);
                if~inport.IsActive

                    continue;
                end
                dataAccessMode=inport.MappedTo.DataAccessMode;
                switch dataAccessMode
                case{'ImplicitReceive','ExplicitReceive',...
                    'ExplicitReceiveByVal','EndToEndRead'}
                    IsQueued=false;
                case{'QueuedExplicitReceive','EndToEndQueuedReceive'}
                    IsQueued=true;
                otherwise
                    continue;
                end

                if strcmp(dataAccessMode,'EndToEndQueuedReceive')==1&&slfeature('E2ECodeGenSupport')==0

                    assert(false,'Feature E2ECodeGenSupport must be turned on to use EndToEndQueuedReceive Data access mode');
                end

                if IsQueued
                    autosar.validation.ClassicMappingValidator.i_verifyQueuedSwCalibrationAccess(hModel,inport);
                end

                isMessageOutport=get_param(inport.Block,'CompiledPortIsMessage');
                isMessage=isMessageOutport.Outport;
                if(isMessage==0)&&IsQueued

                    searchResults=autosar.mm.Model.findObjectByName(m3iModel,[componentQualifiedName,'/',inport.MappedTo.Port]);
                    isCompositePort=autosar.composition.Utils.isCompositePortBlock(inport.Block);
                    assert(searchResults.size==1||isCompositePort);
                    if searchResults.size==1
                        info=searchResults.at(1).info;



                        if(info.size==0)||...
                            (isfield(info.at(1).comSpec,'QueueLength')==0)||...
                            (info.at(1).comSpec.QueueLength==1)

                            continue;
                        end
                    end



                    autosar.validation.Validator.logError('autosarstandard:validation:invalidQueuedAccess',inport.Block,getfullname(hModel),'ExplicitReceive');

                elseif(isMessage==1)&&~IsQueued
                    correctDataAccessMode=autosar.ui.wizard.PackageString.DefaultQueuedDataAccessInport;
                    autosar.validation.Validator.logError(...
                    'autosarstandard:validation:invalidDataAccessModeForQueue',...
                    inport.Block,dataAccessMode,correctDataAccessMode,get_param(hModel,'Name'))
                elseif(isMessage==1)
                    if(multiInstance)
                        autosar.validation.Validator.logError('autosarstandard:validation:multiInstanceCodegenForQueue');
                    end
                end
            end

            for dataIdx=1:length(mapping.Outports)
                outport=mapping.Outports(dataIdx);
                if~outport.IsActive

                    continue;
                end
                dataAccessMode=outport.MappedTo.DataAccessMode;
                switch dataAccessMode
                case{'ImplicitSend','ImplicitSendByRef',...
                    'ExplicitSend','EndToEndWrite'}
                    IsQueued=false;
                case{'QueuedExplicitSend','EndToEndQueuedSend'}
                    IsQueued=true;
                otherwise
                    continue;
                end

                if strcmp(dataAccessMode,'EndToEndQueuedSend')==1&&slfeature('E2ECodeGenSupport')==0

                    assert(false,'Feature E2ECodeGenSupport must be turned on to use EndToEndQueuedSend Data access mode');
                end

                isMessageInport=get_param(outport.Block,'CompiledPortIsMessage');
                isMessage=isMessageInport.Inport;
                if(isMessage==0)&&IsQueued


                    autosar.validation.Validator.logError('autosarstandard:validation:invalidQueuedAccess',...
                    outport.Block,getfullname(hModel),'ExplicitSend');
                elseif(isMessage==1)&&~IsQueued
                    correctDataAccessMode=autosar.ui.wizard.PackageString.DefaultQueuedDataAccessOutport;
                    autosar.validation.Validator.logError(...
                    'autosarstandard:validation:invalidDataAccessModeForQueue',...
                    outport.Block,dataAccessMode,correctDataAccessMode,get_param(hModel,'Name'))
                elseif(isMessage==1)
                    if(multiInstance)
                        autosar.validation.Validator.logError('autosarstandard:validation:multiInstanceCodegenForQueue');
                    end
                    autosar.validation.ClassicMappingValidator.i_verifyQueuedSwCalibrationAccess(hModel,outport);
                end
            end
        end

        function i_verifyQueuedSwCalibrationAccess(hModel,portMapping)





            m3iDataElement=autosar.validation.AutosarUtils.findM3IDataElement(...
            hModel,portMapping.MappedTo.Port,portMapping.MappedTo.Element);
            if isempty(m3iDataElement)
                if autosar.composition.Utils.isCompositePortBlock(portMapping.Block)



                    return;
                else
                    assert(false,'Expected to find data element');
                end
            end
            m3iSwCalibrationAccess=m3iDataElement.SwCalibrationAccess;
            if m3iSwCalibrationAccess~=Simulink.metamodel.foundation.SwCalibrationAccessKind.NotAccessible
                autosar.validation.Validator.logError(...
                'autosarstandard:validation:invalidQueuedSwCalibrationAccess',...
                m3iDataElement.Name,portMapping.Block,...
                m3iSwCalibrationAccess.toString(),get_param(hModel,'Name'),...
                portMapping.MappedTo.Port);
            end
        end



        function verifyInitValue(hModel)
            mapping=autosar.api.Utils.modelMapping(hModel);
            m3iComp=autosar.api.Utils.m3iMappedComponent(hModel);

            portTypes={'Inports','Outports'};
            isInport=[true,false];
            for ii=1:length(portTypes)
                portList=mapping.(portTypes{ii});
                for jj=1:length(portList)
                    port=portList(jj);
                    if any(strcmp(port.MappedTo.DataAccessMode,...
                        autosar.mm.sl2mm.ComSpecBuilder.DataAccessModesWithoutComSpec))


                        continue;
                    end
                    m3iComSpec=autosar.ui.comspec.ComSpecUtils.getM3IComSpec(...
                    m3iComp,port.MappedTo.Port,port.MappedTo.Element,...
                    isInport(ii));
                    if isempty(m3iComSpec)


                        continue;
                    end

                    userInitValueStr=...
                    autosar.ui.comspec.ComSpecPropertyHandler.getInitValueFromExternalToolInfo(m3iComSpec);
                    if isempty(userInitValueStr)

                        continue;
                    end

                    portDataType=get_param(port.Block,'CompiledPortDataTypes');
                    if isInport(ii)
                        portDataType=portDataType.Outport{1};
                    else
                        portDataType=portDataType.Inport{1};
                    end
                    autosar.validation.InitValueChecker.checkInitValue(...
                    hModel,userInitValueStr,portDataType,port.Block);
                end
            end
        end

        function elementInfoMap=i_checkElement(dataObj,componentQName,elementInfoMap,port,isInport)

            dataAccessMode=port.MappedTo.DataAccessMode;
            switch dataAccessMode
            case{'ImplicitReceive',...
                'ExplicitReceive',...
                'ExplicitReceiveByVal',...
                'QueuedExplicitReceive',...
                'ImplicitSend',...
                'ImplicitSendByRef',...
                'ExplicitSend',...
                'QueuedExplicitSend',...
                'ModeReceive',...
                'EndToEndRead',...
                'EndToEndWrite',...
                'ModeSend',...
                'EndToEndQueuedReceive',...
                'EndToEndQueuedSend'}

                arPortName=port.MappedTo.Port;
                arElementName=port.MappedTo.Element;
                slPortName=get_param(port.Block,'Name');

                if strcmp(get_param(port.Block,'IsBusElementPort'),'on')
                    return;
                end

                interfaceQName=dataObj.get([componentQName,'/',arPortName],'Interface','PathType','FullyQualified');
                elementQName=[interfaceQName,'/',arElementName];

                if~ismember(dataAccessMode,{'ModeReceive','ModeSend'})
                    displayFormat=dataObj.get(elementQName,'DisplayFormat');
                    [isValid,msg]=autosar.validation.AutosarUtils.checkDisplayFormat(displayFormat,elementQName);
                    if~isValid
                        autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                    end
                end

                elementDataTypesAliased=get_param(port.Block,'CompiledPortDataTypes');
                elementWidths=get_param(port.Block,'CompiledPortWidths');
                if isInport
                    elementDataType=elementDataTypesAliased.Outport{1};
                    elementWidth=elementWidths.Outport(1);
                else
                    elementDataType=elementDataTypesAliased.Inport{1};
                    elementWidth=elementWidths.Inport(1);
                end

                elementDataType=autosar.validation.ClassicMappingValidator.convertToAutosarPlatformTypeName(elementDataType);

                if elementInfoMap.isKey(elementQName)
                    elementInfo=elementInfoMap(elementQName);

                    usrReadableRefStr=DAStudio.message('RTW:autosar:simulinkPort',slPortName);
                    if ismember(dataAccessMode,{'ModeReceive','ModeSend'})
                        interfaceType='Mode-Switch';
                    else
                        interfaceType='Sender-Receiver';
                    end

                    if~strcmp(elementDataType,elementInfo.DataType)
                        msg=DAStudio.message('RTW:autosar:dataTypeThroughout',...
                        arElementName,interfaceType,usrReadableRefStr,elementInfo.UsrReadableRefStr,...
                        interfaceQName,elementDataType,elementInfo.DataType);
                        autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                    end

                    if elementWidth~=elementInfo.Width
                        msg=DAStudio.message('RTW:autosar:widthThroughout',...
                        arElementName,interfaceType,usrReadableRefStr,elementInfo.UsrReadableRefStr,...
                        interfaceQName,elementWidth,elementInfo.Width);
                        autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                    end

                else

                    elementInfo.DataType=elementDataType;
                    elementInfo.Width=elementWidth;
                    elementInfo.UsrReadableRefStr=DAStudio.message('RTW:autosar:simulinkPort',slPortName);
                    elementInfoMap(elementQName)=elementInfo;
                end

            case{'ErrorStatus','IsUpdated'}

            otherwise
                assert(false,'Did not recognize DataAccessMode %s',dataAccessMode);
            end

        end

        function i_checkExplicitReceiveByValDataType(hModel,port)


            dataTypes=get_param(port.Block,'CompiledPortAliasedThruDataTypes');
            dataType=dataTypes.Outport{1};

            [dtExists,dtObj]=autosar.utils.Workspace.objectExistsInModelScope(hModel,dataType);
            if dtExists&&isa(dtObj,'Simulink.Bus')
                autosar.validation.Validator.logError('autosarstandard:validation:explicitReceiveByValInvalidType',port.Block);
            end

            widths=get_param(port.Block,'CompiledPortWidths');
            width=widths.Outport(1);

            if width>1
                autosar.validation.Validator.logError('autosarstandard:validation:explicitReceiveByValInvalidType',port.Block);
            end

            complexity=get_param(port.Block,'SignalType');
            if strcmp(complexity,'complex')
                autosar.validation.Validator.logError('autosarstandard:validation:explicitReceiveByValInvalidType',port.Block);
            end
        end

        function i_checkErrorStatusDataType(port,E2EMethod)


            slPortName=get_param(port.Block,'Name');

            dataTypes=get_param(port.Block,'CompiledPortAliasedThruDataTypes');
            dataType=dataTypes.Outport{1};

            widths=get_param(port.Block,'CompiledPortWidths');
            width=widths.Outport(1);

            switch(E2EMethod)
            case 'ProtectionWrapper'
                if~strcmp(dataType,'uint32')
                    msg=DAStudio.message('RTW:autosar:errorStatusPortInvalidDataType',slPortName,'uint32');
                    autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                end
            otherwise

                if~strcmp(dataType,'uint8')
                    msg=DAStudio.message('RTW:autosar:errorStatusPortInvalidDataType',slPortName,'uint8');
                    autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                end
            end

            if width>1
                msg=DAStudio.message('RTW:autosar:errorStatusPortInvalidWidth',slPortName);
                autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
            end
        end

        function i_checkIsUpdatedDataType(port)


            dataTypes=get_param(port.Block,'CompiledPortAliasedThruDataTypes');
            dataType=dataTypes.Outport{1};

            widths=get_param(port.Block,'CompiledPortWidths');
            width=widths.Outport(1);

            if~strcmp(dataType,'boolean')
                autosar.validation.Validator.logError('autosarstandard:validation:isUpdatedPortInvalidDataType',port.Block);
            end

            if width>1
                autosar.validation.Validator.logError('autosarstandard:validation:isUpdatedPortInvalidDataType',port.Block);
            end
        end

        function i_checkModeDataType(port,hModel)



            slPortName=get_param(port.Block,'Name');

            dataTypes=get_param(port.Block,'CompiledPortAliasedThruDataTypes');
            widths=get_param(port.Block,'CompiledPortWidths');

            dataAccessMode=port.MappedTo.DataAccessMode;
            switch dataAccessMode
            case{'ModeReceive'}
                dataType=dataTypes.Outport{1};
                width=widths.Outport(1);

            case{'ModeSend'}
                dataType=dataTypes.Inport{1};
                width=widths.Inport(1);

            otherwise
                assert(false,'DataAccessMode %s not recognized in Mode Send/Receive port validation',dataAccessMode);
            end

            if Simulink.data.isSupportedEnumClass(dataType)==0
                autosar.validation.Validator.logError('autosarstandard:validation:invalidDataTypeForMode',slPortName);
            else
                storageType=Simulink.data.getEnumTypeInfo(dataType,'StorageType');
                if~strcmp(storageType,'int')
                    MdgSupportedStorageTypes={'uint8','uint16','int8','int16','int32'};
                    MdgSupportedStorageTypesStr={'uint8, uint16, int8, int16, int32'};
                    if~any(strcmp(storageType,MdgSupportedStorageTypes))
                        autosar.validation.Validator.logError('autosarstandard:validation:invalidStorageTypeForMode',...
                        storageType,slPortName,...
                        MdgSupportedStorageTypesStr{1});
                    end
                end




                [~,modeValues,~,storageType,~,~]=...
                autosar.mm.sl2mm.ModelBuilder.getMdgDataFromEnum(...
                hModel,dataType);
                uint8_min=intmin('uint8');
                uint_max=intmax(storageType);
                [minV,minIndex]=min(modeValues);
                if minV<uint8_min
                    autosar.validation.Validator.logError('autosarstandard:validation:invalidModeValueForEnumeration',...
                    dataType,modeValues(minIndex),slPortName,...
                    uint8_min,uint_max);
                end
                switch storageType
                case{'int8','int16','int32'}
                    autosar.mm.util.MessageReporter.createWarning(...
                    'autosarstandard:validation:SignedModeDeclaration',...
                    dataType,storageType);
                end
            end
            if width>1
                autosar.validation.Validator.logError('autosarstandard:validation:modePortInvalidWidth',...
                slPortName);
            end
        end


        function apiMap=i_checkAPI(hModel,apiMap,port)


            arPortName=port.MappedTo.Port;
            arElementName=port.MappedTo.Element;
            arDataAccessMode=port.MappedTo.DataAccessMode;

            switch arDataAccessMode
            case{'ImplicitReceive','ExplicitReceive',...
                'ExplicitReceiveByVal','QueuedExplicitReceive',...
                'EndToEndRead','EndToEndQueuedReceive'}






                apiModeStr='Read';
            case{'ImplicitSend','ImplicitSendByRef','ExplicitSend','EndToEndWrite',...
                'QueuedExplicitSend','EndToEndQueuedSend'}




                apiModeStr='Write';
            case{'ErrorStatus'}

                return
            case{'IsUpdated'}

                return
            case{'ModeReceive','ModeSend'}
                apiModeStr='Mode';
            case{'BasicSoftwarePort'}
                pName=get_param(port.Block,'Name');
                autosar.validation.Validator.logError('autosarstandard:validation:BasicSoftwarePortNotSupported',...
                pName);
            otherwise
                assert(false,'Did not recognize data access mode %s',arDataAccessMode);
            end

            apiStr=sprintf('Rte_%s_%s_%s',apiModeStr,arPortName,arElementName);

            usrReadableRefStr=DAStudio.message('RTW:autosar:simulinkPort',port.Block);
            if apiMap.isKey(apiStr)&&~isempty(arPortName)&&~isempty(arElementName)

                dataObj=autosar.api.getAUTOSARProperties(hModel,true);
                componentQName=dataObj.get('XmlOptions','ComponentQualifiedName');
                interfaceQName=dataObj.get([componentQName,'/',arPortName],'Interface','PathType','FullyQualified');

                msg=DAStudio.message('RTW:autosar:duplicateApi',...
                usrReadableRefStr,apiMap(apiStr).usrReadableRefStr,arElementName,interfaceQName,arPortName);
                autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
            else

                apiMap(apiStr)=struct('usrReadableRefStr',usrReadableRefStr);
            end
        end


        function arName=convertToAutosarPlatformTypeName(slTypeName)


            persistent typeMap

            if isempty(typeMap)

                arNames={'Boolean','Boolean','SInt8','SInt16','SInt32',...
                'UInt8','UInt16','UInt32','Float','Double'};


                matlabNames={'logical','boolean','int8','int16','int32',...
                'uint8','uint16','uint32','single','double'};

                typeMap=containers.Map(matlabNames,arNames);
            end

            if typeMap.isKey(slTypeName)
                arName=typeMap(slTypeName);
            else
                arName=slTypeName;
            end


        end
    end

end






