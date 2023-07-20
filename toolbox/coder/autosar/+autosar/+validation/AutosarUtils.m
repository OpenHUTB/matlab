classdef AutosarUtils<handle




    properties(Access=private)
        InterfaceDictionaryDataTypeNames='';
        ModelName;
    end

    methods(Access=public)
        function this=AutosarUtils(modelNameOrHandle)
            if is_simulink_handle(modelNameOrHandle)
                this.ModelName=get_param(modelNameOrHandle,'Name');
            else
                this.ModelName=modelNameOrHandle;
            end

            this.initInterfaceDictionaryDataTypeNames();
        end

        function checkDataType(this,blockIdentifier,dataTypeName,maxShortNameLength,supportMatrixIOAsArray)






            dataTypeName=autosar.utils.StripPrefix(dataTypeName);
            blockIdentifier=strtrim(blockIdentifier);
            mdlName=this.ModelName;

            if Simulink.CodeMapping.isAutosarAdaptiveSTF(mdlName)
                isAdaptive=true;
            else
                isAdaptive=false;
            end


            if length(dataTypeName)>maxShortNameLength
                msg=DAStudio.message('RTW:autosar:invalidDataTypeName',blockIdentifier,dataTypeName,maxShortNameLength,maxShortNameLength);
                autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
            end

            [objExists,slObj]=autosar.utils.Workspace.objectExistsInModelScope(mdlName,dataTypeName);
            if objExists

                if isa(slObj,'Simulink.AliasType')||...
                    isa(slObj,'Simulink.NumericType')||...
                    isa(slObj,'Simulink.StructType')
                    isEnumType=false;
                    this.checkHeaderFile(mdlName,slObj.HeaderFile,blockIdentifier,dataTypeName,isEnumType,isAdaptive);
                    if isprop(slObj,'DataScope')&&...
                        strcmp(slObj.DataScope,'Exported')
                        autosar.validation.Validator.logError('RTW:autosar:invalidDataTypeScope',blockIdentifier,dataTypeName,get_param(mdlName,'Name'));
                    end
                else

                end


                if isa(slObj,'Simulink.AliasType')

                    if strcmp(dataTypeName,slObj.BaseType)

                    else
                        this.checkDataType(blockIdentifier,slObj.BaseType,maxShortNameLength,supportMatrixIOAsArray);
                    end
                elseif isa(slObj,'Simulink.NumericType')&&~strcmp(slObj.DataTypeMode,'Double')
                    autosar.validation.AutosarUtils.doWordSizeCheck(mdlName,dataTypeName,slObj.WordLength);
                elseif isa(slObj,'Simulink.StructType')


                    if~supportMatrixIOAsArray
                        autosar.validation.AutosarUtils.checkStructTypeDimension(mdlName,slObj,blockIdentifier,dataTypeName);
                    end


                    for elemIdx=1:length(slObj.Elements)
                        elem=slObj.Elements(elemIdx);


                        this.checkDataType(blockIdentifier,elem.DataType,maxShortNameLength,supportMatrixIOAsArray);

                        if isAdaptive


                            autosar.validation.AutosarUtils.checkStructElementTypeNameClash(blockIdentifier,dataTypeName,elem);
                        end
                    end
                else

                end
            end

            if isvarname(dataTypeName)
                if Simulink.data.isSupportedEnumClass(dataTypeName)
                    headerFile=Simulink.data.getEnumTypeInfo(dataTypeName,'HeaderFile');
                    isEnumType=true;
                    this.checkHeaderFile(mdlName,headerFile,blockIdentifier,dataTypeName,isEnumType,isAdaptive);
                    dataScope=Simulink.data.getEnumTypeInfo(dataTypeName,'DataScope');
                    if strcmp(dataScope,'Exported')
                        autosar.validation.Validator.logError('RTW:autosar:invalidEnumScope',dataTypeName);
                    end
                elseif(fixed.internal.type.isNameOfTraditionalFixedPointType(dataTypeName,false))

                    numType=numerictype(dataTypeName);
                    autosar.validation.AutosarUtils.doWordSizeCheck(mdlName,dataTypeName,numType.WordLength);
                elseif strncmp(dataTypeName,'str',3)&&...
                    ~isempty(Simulink.internal.getStringDTExprFromDTName(dataTypeName))
                    if autosar.api.Utils.isMappedToAdaptiveApplication(mdlName)
                        if slfeature('AUTOSARStringsAdaptive')==0


                            autosar.validation.Validator.logError('autosarstandard:validation:stringNotSupported',dataTypeName);
                        end
                    else
                        if slfeature('AUTOSARStringsClassic')==0


                            autosar.validation.Validator.logError('autosarstandard:validation:stringNotSupported',dataTypeName);
                        end
                    end
                elseif strcmp(dataTypeName,'half')
                    autosar.validation.Validator.logError('autosarstandard:validation:HalfPrecisionNotSupported',blockIdentifier,dataTypeName);
                elseif Simulink.ImageType.IsNameOfImageType(dataTypeName)
                    autosar.validation.Validator.logError('autosarstandard:validation:ImageTypeNotSupported',blockIdentifier,dataTypeName);
                else

                end
            end

        end

        function skipInterfaceDictionaryHeaderCheck=skipHeaderFileCheck(this,dataTypeName)


            skipInterfaceDictionaryHeaderCheck=false;

            if matlab.internal.feature("DisableClassicAUTOSARHeaderFileValidation")==1
                if~isempty(this.InterfaceDictionaryDataTypeNames)
                    skipInterfaceDictionaryHeaderCheck=any(contains(this.InterfaceDictionaryDataTypeNames,dataTypeName));
                end
            end
        end

    end

    methods(Access=private)
        function initInterfaceDictionaryDataTypeNames(this)


            m3iModel=autosar.api.Utils.m3iModel(this.ModelName);

            if~Simulink.AutosarDictionary.ModelRegistry.hasReferencedModels(m3iModel)



                return;
            end

            [isLinkedToInterfaceDict,interfaceDicts]=...
            autosar.dictionary.internal.DictionaryLinkUtils.isModelLinkedToAUTOSARInterfaceDictionary(this.ModelName);

            if isLinkedToInterfaceDict
                for dictIdx=1:length(interfaceDicts)
                    dictHandle=Simulink.interface.dictionary.open(interfaceDicts{dictIdx});
                    this.InterfaceDictionaryDataTypeNames=[this.InterfaceDictionaryDataTypeNames,dictHandle.getDataTypeNames()];
                end
            end
        end

        function checkHeaderFile(this,hModel,headerFileStr,blockIdentifier,dataTypeName,isEnum,isAdaptive)



            skipInterfaceDictionaryHeaderCheck=this.skipHeaderFileCheck(dataTypeName);

            if skipInterfaceDictionaryHeaderCheck
                return;
            end

            if isAdaptive







                expectedHeaderFileStr=lower(['impl_type_',dataTypeName,'.h']);
                invalidDataTypeHeaderErrMsg='autosarstandard:validation:rootPortDataTypeHeader';
                mdlName=get_param(hModel,'Name');
                errorArgs={blockIdentifier,dataTypeName,mdlName};
            else
                expectedHeaderFileStr='Rte_Type.h';
                invalidDataTypeHeaderErrMsg='RTW:autosar:invalidDataTypeHeader';
                errorArgs={blockIdentifier,dataTypeName};
            end

            if~strcmp(headerFileStr,expectedHeaderFileStr)

                if isEnum


                    invalidEnumHeaderErrMsg='RTW:autosar:invalidEnumHeader';
                    autosar.validation.Validator.logError(invalidEnumHeaderErrMsg,dataTypeName,expectedHeaderFileStr)
                else
                    autosar.validation.Validator.logError(invalidDataTypeHeaderErrMsg,errorArgs{:})
                end
            end
        end
    end

    methods(Static,Access=public)
        function[isValid,errorMessage,propertyValue]=isValidPerInstanceProperty(...
            modelName,mappingObj,source,propertyName,propertyValue)
            isValid=true;
            errorMessage='';
            nvBlockNeedsPerInstanceProps=autosar.api.getSimulinkMapping.getValidNvBlockNeedsPerInstanceProperties(mappingObj);
            switch propertyName
            case 'DisplayFormat'
                if strlength(propertyValue)>0
                    [isValid,errorMessage]=autosar.validation.AutosarUtils.checkDisplayFormat(propertyValue,source);
                end
            case{'IsVolatile','IsConst'}
                if islogical(propertyValue)
                    propertyValue=autosar.validation.AutosarUtils.convertLogicalToString(propertyValue);
                end
            case 'ShortName'
                if strlength(propertyValue)>0
                    maxShortNameLength=get_param(modelName,'AutosarMaxShortNameLength');
                    idcheckmessage=autosar.ui.utils.isValidARIdentifier(propertyValue,'shortName',...
                    maxShortNameLength);
                    if~isempty(idcheckmessage)
                        isValid=false;
                        errorMessage=idcheckmessage;
                    else
                        [isValid,errorId,arg1,arg2]=autosar.validation.AutosarUtils.validateSubModelShortNames(modelName,mappingObj,propertyValue);
                        if~isValid
                            errorMessage=DAStudio.message(errorId,arg1,arg2);
                        end
                    end
                end
            case 'LongName'
                if strlength(propertyValue)>0
                    [isValid,errorMessage,propertyValue]=autosar.validation.AutosarUtils.validateLongNameValue(propertyValue);
                end
            case 'SwCalibrationAccess'
                propertyValue=validatestring(propertyValue,...
                {'NotAccessible','ReadOnly','ReadWrite'});
            case 'Qualifier'
                validateattributes(propertyValue,{'char','string'},...
                {'scalartext'},propertyName);


                if~isempty(propertyValue)

                    validCIdentifierPattern='^[_a-zA-Z][_a-zA-Z0-9]{0,30}$';
                    identifierCellStr=strsplit(propertyValue);
                    for ii=1:length(identifierCellStr)
                        isValid=~isempty(regexp(identifierCellStr{ii},validCIdentifierPattern,'ONCE'));
                        if~isValid


                            errorMessage=DAStudio.message('autosarstandard:validation:invalidCQualifier',propertyValue,source);
                            return;
                        end
                    end
                end
            case 'NeedsNVRAMAccess'
                if islogical(propertyValue)
                    propertyValue=autosar.validation.AutosarUtils.convertLogicalToString(propertyValue);
                end
            case nvBlockNeedsPerInstanceProps
                if islogical(propertyValue)
                    propertyValue=autosar.validation.AutosarUtils.convertLogicalToString(propertyValue);
                end
            end
        end

        function propertyValue=convertLogicalToString(propertyValue)
            assert(islogical(propertyValue),'Expected boolean input.');
            if propertyValue
                propertyValue='true';
            else
                propertyValue='false';
            end
        end

        function[isValid,errorId,arg1,arg2]=validateSubModelShortNames(...
            modelName,mappingObj,propertyValue)






            isValid=true;
            errorId='';
            arg1='';
            arg2='';
            [isMappedToSubComponent,modelMapping]=Simulink.CodeMapping.isMappedToAutosarSubComponent(modelName);
            if isMappedToSubComponent
                paramNames={};
                for ii=1:numel(modelMapping.ModelScopedParameters)
                    paramMapping=modelMapping.ModelScopedParameters(ii);
                    if~isempty(mappingObj)&&paramMapping==mappingObj
                        continue;
                    end
                    mappedTo=paramMapping.MappedTo;
                    if~strcmp(mappedTo.ArDataRole,'Auto')
                        paramNames=[paramNames,paramMapping.Parameter];%#ok<AGROW>
                    end
                end

                signalNames=autosar.validation.AutosarUtils.getShortNames(modelMapping.Signals,mappingObj);
                stateNames=autosar.validation.AutosarUtils.getShortNames(modelMapping.States,mappingObj);
                dataStores=autosar.validation.AutosarUtils.getShortNames(modelMapping.DataStores,mappingObj);
                synthesizedDataStores=autosar.validation.AutosarUtils.getShortNames(modelMapping.SynthesizedDataStores,mappingObj);

                if isempty(propertyValue)
                    internalDataShortNames=[paramNames,signalNames,stateNames,dataStores,synthesizedDataStores];
                else
                    internalDataShortNames=[paramNames,signalNames,stateNames,dataStores,synthesizedDataStores,{propertyValue}];
                end
                [~,unique_indices]=unique(internalDataShortNames);
                duplicates=unique(internalDataShortNames(setdiff(1:length(internalDataShortNames),...
                unique_indices)));
                if~isempty(duplicates)
                    errorId='autosarstandard:validation:subComponentInternalDataNameClash';
                    arg1=modelName;
                    arg2=duplicates{1};
                    isValid=false;
                end
            end
        end

        function[isValid,errorId,arg1,arg2]=validateSubModelShortNamesForCodeGen(...
            subModelMapping,subModelInternalDataMap)





            isValid=true;
            errorId='';
            arg1='';
            arg2='';
            if~isempty(subModelMapping)
                paramNames={};
                if~isempty(subModelMapping.Parameters)
                    paramMappings=jsondecode(subModelMapping.Parameters);
                    for ii=1:numel(paramMappings)
                        parameterMapping=paramMappings(ii);
                        if~strcmp(parameterMapping.ArDataRole,'Auto')
                            paramNames=[paramNames,parameterMapping.Name];%#ok<AGROW>
                        end
                    end
                end
                internalDataShortNames=[paramNames,subModelInternalDataMap.keys];
                [~,unique_indices]=unique(internalDataShortNames);
                duplicates=unique(internalDataShortNames(setdiff(1:length(internalDataShortNames),...
                unique_indices)));
                if~isempty(duplicates)
                    errorId='autosarstandard:validation:subComponentInternalDataNameClash';
                    arg1=subModelMapping.Name;
                    arg2=duplicates{1};
                    isValid=false;
                end
            end
        end

        function[isValid,errorMessage,longNameValue,errorId]=validateLongNameValue(longNameValue)

            isValid=true;
            errorId='';
            errorMessage='';


            if contains(longNameValue,newline)

                splitLongName=splitlines(longNameValue);
                singleLineLongNameValue=join(splitLongName);
                longNameValue=singleLineLongNameValue{1};
            end


            longNameValue=char(longNameValue);
            for j=1:strlength(longNameValue)
                if~isempty(regexp(longNameValue(j),'[^\x00-\x7F ]+','ONCE'))

                    if~isempty(regexp(longNameValue(j),'[a-zA-Z0-9À-ž]','ONCE'))

                        continue;
                    end
                    isValid=false;
                    errorId='autosarstandard:validation:invalidLongNameValue';
                    errorMessage=DAStudio.message(errorId,longNameValue);
                    break;
                end
            end
        end

        function msg=isValidIdentifier(cellstrToTest,idType,maxShortNameLength)




            msg='';

            for idx=1:length(cellstrToTest)
                str=cellstrToTest{idx};

                [isvalid,msg]=autosarcore.checkIdentifier(str,idType,maxShortNameLength);
                if~isvalid||~isempty(msg)
                    return;
                end

            end

        end

        function checkShortNameCaseClash(shortNames)




            if isempty(shortNames)
                return
            end

            shortNameMap=containers.Map(lower(shortNames),shortNames);

            for i=1:length(shortNames)
                shortName1=shortNames{i};
                shortName2=shortNameMap(lower(shortName1));
                if~strcmp(shortName1,shortName2)
                    autosar.validation.Validator.logError('RTW:autosar:shortNameCaseClash',shortName1,shortName2);
                end
            end

        end

        function isNotCKeyword=isNotCKeyword(name)




            dummyConfigEntry=RTW.FcnArgSpec;
            dummyConfigEntry.ArgName=name;

            isNotCKeyword=dummyConfigEntry.isValidIdentifier();
        end

        function isErrArg=isErrorArgument(mdlName,Identifier)




            isErrArg=false;
            if autosar.api.Utils.isMappedToAdaptiveApplication(mdlName)




                return;
            end
            [~,opName,intfQName]=autosar.validation.AutosarUtils.getInterface(mdlName,Identifier);
            if~isempty(intfQName)
                argName=get_param(Identifier,'ArgumentName');
                dataobj=autosar.api.getAUTOSARProperties(mdlName,true);
                direction=dataobj.get([intfQName,'/',opName,'/',argName],'Direction');
                isErrArg=strcmp(direction,'Error');
            end
        end

        function[intfName,opName,intfQName]=getInterface(mdlName,Identifier)





            [parentBlk,~,~]=fileparts(Identifier);
            [~,~,fcnName]=autosar.validation.ClientServerValidator.getBlockInOutParams(...
            parentBlk);
            mapping=autosar.api.getSimulinkMapping(mdlName);
            if Simulink.CodeMapping.isAutosarAdaptiveSTF(mdlName)
                [intfName,opName,intfQName]=...
                autosar.validation.AutosarUtils.getInterfaceForPortMethod(mdlName,mapping,fcnName,parentBlk);
            else
                [intfName,opName,intfQName]=...
                autosar.validation.AutosarUtils.getInterfaceForRunnable(mdlName,mapping,fcnName);
            end
        end

        function[intfName,opName,intfQName]=getInterfaceForRunnable(mdlName,mapping,fcnName)
            intfName='';
            opName='';
            intfQName='';

            runName=mapping.getFunction(['SimulinkFunction:',fcnName]);

            dataobj=autosar.api.getAUTOSARProperties(mdlName,true);
            swc=dataobj.get('XmlOptions','ComponentQualifiedName');
            behavior=dataobj.get(swc,'Behavior','PathType','FullyQualified');
            runnablePath=[behavior,'/',runName];
            opEvents=dataobj.find(behavior,'OperationInvokedEvent','StartOnEvent',runnablePath,'PathType','FullyQualified');
            if length(opEvents)~=1
                return;
            end
            trigger=dataobj.get(opEvents{1},'Trigger');
            if isempty(trigger)
                return;
            end
            trigger=strsplit(trigger,'.');


            serverPorts=dataobj.find(swc,'ServerPort','PathType','FullyQualified');
            serverPath=serverPorts(cellfun(@(x)~isempty(x),regexp(serverPorts,['/',trigger{1},'$'])));


            intfQName=dataobj.get(serverPath{1},'Interface','PathType','FullyQualified');
            [~,intfName,~]=fileparts(intfQName);
            opName=trigger{2};
        end

        function[intfName,methodName,intfQName]=getInterfaceForPortMethod(mdlName,mapping,fcnName,parentBlk)

            if autosar.validation.ExportFcnValidator.isPortScopedSimulinkFunction(parentBlk)

                triggerBlk=...
                find_system(parentBlk,'SearchDepth',1,'BlockType','TriggerPort');
                portName=get_param(triggerBlk,'ScopeName');
                portName=portName{1};
                componentAdapter=...
                autosar.ui.wizard.builder.ComponentAdapter.getComponentAdapter(bdroot(parentBlk));
                methodName=componentAdapter.getAutosarMethodName(fcnName);
            else
                [portName,methodName]=mapping.getFunction(fcnName);
            end

            dataobj=autosar.api.getAUTOSARProperties(mdlName,true);
            swc=dataobj.get('XmlOptions','ComponentQualifiedName');
            portPath=dataobj.find(swc,'ServiceProvidedPort','Name',portName,...
            'PathType','FullyQualified');
            if isempty(portPath)


                intfName='';
                intfQName='';
            else

                intfQName=dataobj.get(portPath{1},'Interface','PathType','FullyQualified');
                [~,intfName,~]=fileparts(intfQName);
            end
        end

        function[propertyValue,interfaceName]=getInterfaceElementProperty(mdlName,portName,elementName,propertyName)




            dataObj=autosar.api.getAUTOSARProperties(mdlName,true);
            swc=dataObj.get('XmlOptions','ComponentQualifiedName');
            port=dataObj.find(swc,'ProvidedPort','Name',portName,'PathType','FullyQualified');
            if iscell(port)
                assert(length(port)==1);
                port=port{1};
            end
            interfaceName=dataObj.get(port,'Interface','PathType','FullyQualified');
            dataElem=dataObj.find(interfaceName,'FlowData','Name',elementName,'PathType','FullyQualified');
            if iscell(dataElem)
                assert(length(dataElem)==1);
                dataElem=dataElem{1};
            end
            propertyValue=dataObj.get(dataElem,propertyName);
        end

        function checkDataTypeForErrArg(mdlName,blkPath,~,~)




            portHandles=get_param(blkPath,'PortHandles');
            errPortH=portHandles.Inport(1);

            [~,~,intfQName]=autosar.validation.AutosarUtils.getInterface(mdlName,blkPath);
            m3iModel=autosar.api.Utils.m3iModel(mdlName);
            arRoot=m3iModel.RootPackage.front();
            intfSeq=autosar.mm.Model.findObjectByNameAndMetaClass(arRoot,...
            intfQName,...
            Simulink.metamodel.arplatform.interface.ClientServerInterface.MetaClass());
            assert(intfSeq.size()==1,'Did not find client server interface');
            m3iInterface=intfSeq.at(1);

            autosar.validation.AutosarUtils.checkDataTypeForErrArgPort(errPortH,m3iInterface);

        end

        function checkDataTypeForErrArgPort(portH,~)




            blkPath=get_param(portH,'Parent');

            width=get_param(portH,'CompiledPortWidth');

            if width>1
                autosar.validation.Validator.logError('autosarstandard:validation:errorArgInvalidWidth',...
                blkPath);
            end

            dataType=get_param(portH,'CompiledPortAliasedThruDataType');

            aliasDataType=get_param(portH,'CompiledPortDataType');

            if strcmp(dataType,'uint8')

                return
            elseif Simulink.data.isSupportedEnumClass(dataType)
                storageType=Simulink.data.getEnumTypeInfo(dataType,'StorageType');
                if~strcmp(storageType,'uint8')
                    autosar.validation.Validator.logError('autosarstandard:validation:errorArgInvalidDataType',blkPath,aliasDataType);
                end
            else
                autosar.validation.Validator.logError('autosarstandard:validation:errorArgInvalidDataType',blkPath,aliasDataType);
            end




            errCodes=enumeration(dataType);
            if isempty(errCodes)
                msg=DAStudio.message('RTW:autosar:invalidErrorEnum',dataType);
                autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
            end


            for ii=1:length(errCodes)
                errCodeValue=uint8(errCodes(ii));
                if errCodeValue<0||errCodeValue>63
                    msg=DAStudio.message('autosarstandard:validation:invalidAppErrValue',...
                    dataType,...
                    num2str(errCodes(ii)));
                    autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                end
            end

        end

        function checkStructElementTypeNameClash(blockIdentifier,structName,element)




            elementName=element.Name;
            elementTypeName=autosar.utils.StripPrefix(element.DataType);
            if strcmp(elementName,elementTypeName)
                autosar.validation.Validator.logError('autosarstandard:validation:structFieldNameTypeNameClash',structName,elementName,blockIdentifier);
            end
        end

        function str=removeNewLine(str)


            str=strrep(str,newline,' ');
        end

        function[isValid,errmsg]=checkVersion(propValue,propName)





            if isnumeric(propValue)
                isValid=(propValue>=0);
            else

                isValid=(str2double(propValue)>=0);
            end

            errmsg=[];
            if~isValid
                errId='RTW:autosar:apiInvalidPropertyValue';
                suggestion=DAStudio.message('autosarstandard:validation:suggestionPositiveIntegers');
                if propName==1
                    errmsg={errId,suggestion};
                else
                    errmsg=DAStudio.message(errId,propValue,propName,suggestion);
                end
            end
        end

        function[isValid,errmsg]=checkSymbol(str)





            isValid=...
            autosar.validation.AutosarUtils.isNotCKeyword(str)&&...
            all(regexp(str,'[_a-zA-Z][_a-zA-Z0-9]*'));

            if isValid==true
                errmsg=[];
            else
                errmsg=DAStudio.message('RTW:autosar:invalidSymbol',str);
            end
        end

        function[isValid,errmsg]=checkDisplayFormat(str,identifier)
            isValid=false;
            errmsg=[];
            if~isempty(str)

                expression='%[ \-+#]?[0-9]*(\.[0-9])?[diouxXfeEgGcs]';
                [startRegex,endRegex]=regexp(str,expression,'ONCE');
                if~isempty(startRegex)&&startRegex==1&&strlength(str)==endRegex
                    isValid=true;
                else
                    errmsg=DAStudio.message('autosarstandard:ui:validateDisplayFormat',identifier);
                end
            else
                isValid=true;
            end
        end

        function[isValid,errmsg]=checkServiceInstanceId(str,identifier)
            isValid=false;
            errmsg=[];
            if~isempty(str)
                expression='[1-9][0-9]*|0[xX][0-9a-fA-F]+|0[0-7]*|0[bB][0-1]+|ANY';
                [startRegex,endRegex]=regexp(str,expression,'ONCE');
                if~isempty(startRegex)&&startRegex==1&&numel(str)==endRegex
                    isValid=true;
                else
                    errmsg=DAStudio.message('autosarstandard:ui:validateServiceInstanceId',identifier);
                end
            end
        end

        function[isValid,errmsg]=checkDdsIdentifier(str,identifier)
            isValid=false;
            errmsg=[];
            if~isempty(str)
                expression='[a-zA-Z][a-zA-Z0-9-]*';
                [startRegex,endRegex]=regexp(str,expression,'ONCE');
                if~isempty(startRegex)&&startRegex==1&&numel(str)==endRegex
                    isValid=true;
                else
                    errmsg=DAStudio.message('autosarstandard:ui:validateDdsIdentifierName','TopicName',identifier,'TopicName');
                end
            end
        end

        function[isValid,errmsg]=checkFnmatchPattern(str,identifier)
            isValid=false;
            errmsg=[];
            if~isempty(str)
                expression='(\*)*(\?)*(\!)*(\[(.*?)\])*';
                startRegex=regexp(str,expression,'ONCE');
                if isempty(startRegex)
                    isValid=true;
                else
                    errmsg=DAStudio.message('autosarstandard:ui:validateDdsIdentifierNameFnmatchPattern','TopicName',identifier,'TopicName');
                end
            end
        end


        function doWordSizeCheck(modelName,objectName,wordLength)




            if wordLength<0||wordLength>64
                autosar.validation.Validator.logError('autosarstandard:validation:incorrectExportedWordSize',...
                objectName,int2str(wordLength));
            elseif strcmp(get_param(modelName,'TargetLongLongMode'),'off')&&wordLength>32
                autosar.validation.Validator.logError('autosarstandard:validation:incorrectTargetLongLongMode');
            end
        end

        function reportErrorWithFixit(errId,varargin)




            msg=message(errId,varargin{:});
            MSLException([],msg).throw();
        end

        function checkAdaptiveModelSetup(modelName)



            if autosar.api.Utils.isMappedToAdaptiveApplication(modelName)



                if~Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName)



                    autosar.validation.Validator.logError('autosarstandard:validation:invalidAdaptiveMapping',modelName);
                end
            end
        end

        function blkPaths=getFullBlockPathsForError(blks)
            blkPaths=getfullname(blks);


            if iscell(blkPaths)
                blkPaths=strjoin(blkPaths,',');
            end
        end

        function m3iDataElement=findM3IDataElement(hModel,portName,dataElementName)

            m3iDataElement=[];
            compObj=autosar.api.Utils.m3iMappedComponent(hModel);
            m3iPortSeq=autosar.mm.Model.findObjectByName(...
            compObj,portName);

            if~(m3iPortSeq.size()==1)

                return
            end
            m3iPort=m3iPortSeq.at(1);
            m3iDataElement=Simulink.metamodel.arplatform.ModelFinder.findNamedItemInSequence(...
            m3iPort.Interface,m3iPort.Interface.DataElements,...
            dataElementName,...
            'Simulink.metamodel.arplatform.interface.FlowData');
        end

        function verifyNonNegativeNumber(value,propertyName)


            if ischar(value)
                value=str2double(value);
            end
            [errId,suggestion]=autosar.validation.AutosarUtils.checkNonNegativeNumericValue(value);

            if~isempty(errId)
                DAStudio.error(errId,num2str(value),propertyName,suggestion);
            end
        end

        function[errId,suggestion]=checkNonNegativeNumericValue(value)
            errId='';
            suggestion='';
            if isempty(value)||isnan(value)||value<0||isinf(value)||...
                ~isnumeric(value)||~isreal(value)
                errId='RTW:autosar:apiInvalidPropertyValue';
                suggestion=DAStudio.message('autosarstandard:validation:suggestionNonNegativeNumbers');
            end
        end
    end

    methods(Static,Access=private)

        function names=getShortNames(internalData,mappingObj)
            names={};
            for ii=1:numel(internalData)
                mapping=internalData(ii);
                if~isempty(mappingObj)&&mapping==mappingObj
                    continue;
                end
                mappedTo=mapping.MappedTo;
                if~strcmp(mappedTo.ArDataRole,'Auto')
                    shortName=mappedTo.getPerInstancePropertyValue('ShortName');
                    if~isempty(shortName)
                        names=[names,shortName];%#ok<AGROW>
                    end
                end
            end
        end

        function checkStructTypeDimension(mdlName,slObj,Identifier,dataTypeName)




            for elemIdx=1:length(slObj.Elements)
                elem=slObj.Elements(elemIdx);
                if length(elem.Dimensions)>1
                    if(length(elem.Dimensions)==2&&(elem.Dimensions(1)==1||...
                        elem.Dimensions(2)==1))

                    else
                        msg=DAStudio.message('RTW:autosar:invalidStructTypeDimension',Identifier,dataTypeName);
                        autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                    end
                end


                [objExists,elemObj]=autosar.utils.Workspace.objectExistsInModelScope(mdlName,elem.DataType);
                if objExists
                    if isa(elemObj,'Simulink.StructType')
                        autosar.validation.AutosarUtils.checkStructTypeDimension(mdlName,elemObj,Identifier,elem.DataType);
                    else

                    end
                end
            end
        end

    end

end




