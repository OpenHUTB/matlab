classdef ComSpecPropertyHandler<handle




    properties(Constant,Access=public)


        SupportedComSpecProperties={{'AliveTimeout','string'},...
        {'HandleNeverReceived','enum'},...
        {'InitValue','string'},...
        {'QueueLength','string'}};
        DefaultAliveTimeout=0;
        DefaultQueueLength=1;
        DefaultHandleNeverReceived=false;
        DefaultInitValue=0;
    end

    methods(Static,Access=public)

        function[errId,suggestion]=checkComSpecPropertyValue(propertyName,value)


            switch propertyName
            case 'AliveTimeout'
                [errId,suggestion]=autosar.validation.AutosarUtils.checkNonNegativeNumericValue(value);
            case 'HandleNeverReceived'
                [errId,suggestion]=autosar.ui.comspec.ComSpecPropertyHandler.checkLogicalValue(value);
            case{'InitValue','InitialValue'}
                [errId,suggestion]=autosar.ui.comspec.ComSpecPropertyHandler.checkScalarNumericValue(value);
            case 'QueueLength'
                [errId,suggestion]=autosar.ui.comspec.ComSpecPropertyHandler.checkPositiveIntegerValue(value);
            otherwise
                assert(false,...
                '%s is not a valid ComSpec property.',...
                propertyName);
            end
        end

        function value=getComSpecDefaultPropertyValue(propertyName)


            switch propertyName
            case 'AliveTimeout'
                value=autosar.ui.comspec.ComSpecPropertyHandler.DefaultAliveTimeout;
            case 'HandleNeverReceived'
                value=autosar.ui.comspec.ComSpecPropertyHandler.DefaultHandleNeverReceived;
            case{'InitValue','InitialValue'}



                value=autosar.ui.comspec.ComSpecPropertyHandler.DefaultInitValue;
            case 'QueueLength'
                value=autosar.ui.comspec.ComspecPropertyHandler.DefaultQueueLength;
            otherwise
                assert(false,...
                '%s is not a valid ComSpec property.',...
                propertyName);
            end
        end

        function valueStr=getComSpecDefaultPropertyValueStr(propertyName)


            defaultVal=autosar.ui.comspec.ComSpecPropertyHandler.getComSpecDefaultPropertyValue(propertyName);
            if~ischar(defaultVal)
                if islogical(defaultVal)
                    if defaultVal
                        valueStr='true';
                    else
                        valueStr='false';
                    end
                else
                    valueStr=Simulink.metamodel.arplatform.getRealStringCompact(defaultVal);
                end
            end
        end

        function valueStr=getComSpecPropertyValueStr(m3iComSpec,propertyName,dataDictionary,createInitValueIfNecessary)



            narginchk(2,4)

            if nargin<4
                createInitValueIfNecessary=true;
                if nargin<3
                    dataDictionary='';
                end
            end

            valueStr='';
            value=autosar.ui.comspec.ComSpecPropertyHandler.getComSpecPropertyValue(...
            m3iComSpec,propertyName,dataDictionary,createInitValueIfNecessary);
            if strcmp(autosar.ui.comspec.ComSpecPropertyHandler.getComSpecPropertyDataType(propertyName),'string')

                valueStr=autosar.ui.comspec.ComSpecPropertyHandler.convertValueToString(value);
            elseif strcmp(autosar.ui.comspec.ComSpecPropertyHandler.getComSpecPropertyDataType(propertyName),'enum')
                if value
                    valueStr='true';
                else
                    valueStr='false';
                end
            end
        end

        function value=getComSpecPropertyValue(m3iComSpec,propertyName,dataDictionary,createInitValueIfNecessary)

            if ismember(propertyName,{'InitValue','InitialValue'})

                value=autosar.ui.comspec.ComSpecPropertyHandler.getInitValue(...
                m3iComSpec,dataDictionary,createInitValueIfNecessary);
            else

                value=m3iComSpec.(propertyName);
            end
            if isempty(value)

                value=autosar.ui.comspec.ComSpecPropertyHandler.getComSpecDefaultPropertyValue(propertyName);
            end
        end

        function setComSpecPropertyValue(m3iComSpec,propertyName,inputValue)


            if ischar(inputValue)
                value=autosar.ui.comspec.ComSpecPropertyHandler.convertPropertyValueFromUI(propertyName,inputValue);
            else
                value=inputValue;
            end

            [errId,suggestion]=autosar.ui.comspec.ComSpecPropertyHandler.checkComSpecPropertyValue(propertyName,value);
            if~isempty(errId)
                DAStudio.error(errId,inputValue,propertyName,suggestion);
            end
            trans=M3I.Transaction(m3iComSpec.modelM3I);
            if ismember(propertyName,{'InitValue','InitialValue'})

                if~ischar(inputValue)
                    inputValue=Simulink.metamodel.arplatform.getRealStringCompact(inputValue);
                end
                autosar.ui.comspec.ComSpecPropertyHandler.setInitValue(m3iComSpec,inputValue);
            else
                m3iComSpec.(propertyName)=value;
            end
            trans.commit();
        end

        function value=getComSpecPropertyValueForPropertyInspector(modelH,mappingObj,propertyName)


            modelName=get_param(modelH,'Name');
            m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);
            m3iPort=autosar.ui.comspec.ComSpecUtils.findM3IPortByName(m3iComp,mappingObj.MappedTo.Port);
            if autosar.api.Utils.isNvPort(m3iPort)
                comSpecPropName='ComSpec';
            else
                comSpecPropName='comSpec';
            end
            if isempty(m3iPort)


                assert(autosar.composition.Utils.isCompositePortBlock(mappingObj.Block),'Only valid for bus port block');
                value=autosar.ui.comspec.ComSpecPropertyHandler.getComSpecDefaultPropertyValueStr(propertyName);
                return;
            end
            isInport=strcmp(get_param(mappingObj.Block,'BlockType'),'Inport');
            m3iInfo=autosar.ui.comspec.ComSpecUtils.findM3IPortInfoForDataElement(m3iPort,mappingObj.MappedTo.Element,isInport);
            if isempty(m3iInfo)
                autosar.mm.sl2mm.ComSpecBuilder.addOrUpdateM3IComSpec(mappingObj.MappedTo.Port,...
                mappingObj.MappedTo.Element,mappingObj.MappedTo.DataAccessMode,modelName);
                m3iInfo=autosar.ui.comspec.ComSpecUtils.findM3IPortInfoForDataElement(m3iPort,mappingObj.MappedTo.Element,isInport);
            end
            if isempty(m3iInfo)

                assert(autosar.composition.Utils.isCompositePortBlock(mappingObj.Block),'Only valid for bus port blocks');
                value=autosar.ui.comspec.ComSpecPropertyHandler.getComSpecDefaultPropertyValueStr(propertyName);
                return;
            end
            try
                dataDictionary=get_param(modelH,'DataDictionary');
                value=autosar.ui.comspec.ComSpecPropertyHandler.getComSpecPropertyValueStr(...
                m3iInfo.(comSpecPropName),propertyName,dataDictionary);
            catch ME

                errordlg(ME.message,...
                autosar.ui.metamodel.PackageString.ErrorTitle,'replace')
            end
        end

        function setComSpecPropertyValueForPropertyInspector(modelH,mappingObj,propertyName,value)


            modelName=get_param(modelH,'Name');
            m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);
            m3iPort=autosar.ui.comspec.ComSpecUtils.findM3IPortByName(m3iComp,mappingObj.MappedTo.Port);
            isBusPortSynced=false;
            if isempty(m3iPort)


                assert(autosar.composition.Utils.isCompositePortBlock(mappingObj.Block),'Only valid for bus port block')


                m3iPort=autosar.simulink.bep.Mapping.syncBusPort(mappingObj.Block);
                isBusPortSynced=true;
                assert(~isempty(m3iPort),'m3iPort should not be empty');
            end
            isInport=strcmp(get_param(mappingObj.Block,'BlockType'),'Inport');
            m3iInfo=autosar.ui.comspec.ComSpecUtils.findM3IPortInfoForDataElement(m3iPort,mappingObj.MappedTo.Element,isInport);
            if isempty(m3iInfo)
                assert(autosar.composition.Utils.isCompositePortBlock(mappingObj.Block),'Only valid for bus port block');

                if~isBusPortSynced

                    m3iPort=autosar.simulink.bep.Mapping.syncBusPort(mappingObj.Block);
                end


                autosar.mm.sl2mm.ComSpecBuilder.addOrUpdateM3IComSpec(mappingObj.MappedTo.Port,...
                mappingObj.MappedTo.Element,mappingObj.MappedTo.DataAccessMode,modelName);

                m3iInfo=autosar.ui.comspec.ComSpecUtils.findM3IPortInfoForDataElement(m3iPort,mappingObj.MappedTo.Element,isInport);
                assert(~isempty(m3iInfo),'m3iInfo should not be empty');
            end
            if autosar.api.Utils.isNvPort(m3iPort)
                comSpecPropName='ComSpec';
            else
                comSpecPropName='comSpec';
            end
            autosar.ui.comspec.ComSpecPropertyHandler.setComSpecPropertyValue(m3iInfo.(comSpecPropName),propertyName,value);
        end

        function validComSpecProperties=getValidComSpecPropertiesFromDAM(arDataAccessModeStr)
            switch arDataAccessModeStr
            case{'ImplicitReceive','ExplicitReceive',...
                'ExplicitReceiveByVal','EndToEndRead'}
                validComSpecProperties=...
                autosar.ui.comspec.ComSpecPropertyHandler.getSupportedComSpecProperties();

                validComSpecProperties=...
                setdiff(validComSpecProperties,'QueueLength');
            case{'ImplicitSend','ImplicitSendByRef',...
                'ExplicitSend','EndToEndWrite'}

                validComSpecProperties={'InitValue'};
            case{'QueuedExplicitReceive','EndToEndQueuedReceive'}
                validComSpecProperties={'QueueLength'};
            case{'QueuedExplicitSend','EndToEndQueuedSend'}

                validComSpecProperties={};
            case autosar.mm.sl2mm.ComSpecBuilder.DataAccessModesWithoutComSpec
                validComSpecProperties={};
            otherwise
                assert(false,'Unsupported data access mode');
            end
        end

        function supportedComSpecProperties=getSupportedComSpecProperties()
            props=autosar.ui.comspec.ComSpecPropertyHandler.SupportedComSpecProperties;
            supportedComSpecProperties=cell(1,size(props,2));
            for i=1:length(supportedComSpecProperties)
                supportedComSpecProperties{i}=props{i}{1};
            end
        end

        function dataType=getComSpecPropertyDataType(propertyName)
            dataType='';
            props=autosar.ui.comspec.ComSpecPropertyHandler.SupportedComSpecProperties;
            supportedComSpecProperties=cell(size(props,2));
            for i=1:length(supportedComSpecProperties)
                if strcmp(propertyName,props{i}{1})
                    dataType=props{i}{2};
                    break;
                end
            end
        end

        function allowedValues=getComSpecPropertyAllowedValues(propertyName)
            allowedValues='';
            if strcmp(propertyName,'HandleNeverReceived')
                allowedValues={'true','false'};
            end
        end

        function validComSpecProperties=getValidComSpecPropertiesForPort(mdlName,portName,isInport,~)


            validComSpecProperties={};
            slMapObj=autosar.api.getSimulinkMapping(mdlName);
            if isInport
                [ARPortName,ARDataName,ARDataAccessMode]=...
                slMapObj.getInport(portName);
            else
                [ARPortName,ARDataName,ARDataAccessMode]=...
                slMapObj.getOutport(portName);
            end
            if~(isempty(ARPortName)||isempty(ARDataName)||...
                isempty(ARDataAccessMode))
                m3iComp=autosar.api.Utils.m3iMappedComponent(mdlName);
                m3iPort=autosar.ui.comspec.ComSpecUtils.findM3IPortByName(m3iComp,ARPortName);
                isNVPort=autosar.api.Utils.isNvPort(m3iPort);
                if isNVPort

                    validComSpecProperties={'InitValue'};
                else
                    validComSpecProperties=...
                    autosar.ui.comspec.ComSpecPropertyHandler.getValidComSpecPropertiesFromDAM(...
                    ARDataAccessMode);
                end
                portPath=[get_param(mdlName,'Name'),'/',portName];
                if autosar.composition.Utils.isCompositeInportBlock(portPath)

                    validComSpecProperties=...
                    setdiff(validComSpecProperties,'QueueLength');
                end
            end
        end

        function value=getInitValueFromExternalToolInfo(m3iComSpec)

            value=[];

            toolId=...
            autosar.ui.comspec.ComSpecPropertyHandler.generateInitValueExtToolId(...
            m3iComSpec);
            if~isempty(toolId)
                value=m3iComSpec.getExternalToolInfo(toolId).externalId;
            end
            if strcmp(value,'uiCannotDisplayHeterogeneousData')

                value=DAStudio.message('autosarstandard:ui:uiCannotDisplayHeterogeneousData');
            end
        end

        function valueStr=getUserInputInitValue(m3iComSpec)



            import autosar.ui.comspec.ComSpecPropertyHandler;

            valueStr=...
            ComSpecPropertyHandler.getInitValueFromExternalToolInfo(...
            m3iComSpec);
            if strcmp(valueStr,DAStudio.message('autosarstandard:ui:uiCannotDisplayHeterogeneousData'))
                valueStr=[];
            end
        end

        function setInitValue(m3iComSpec,value)





            if ischar(value)
                valueStr=value;
            else
                valueStr=Simulink.metamodel.arplatform.getRealStringCompact(value);
            end

            toolId=autosar.ui.comspec.ComSpecPropertyHandler.generateInitValueExtToolId(m3iComSpec);

            m3iComSpec.setExternalToolInfo(M3I.ExternalToolInfo(toolId,valueStr));
        end

        function value=convertPropertyValueFromUI(propertyName,value)




            switch propertyName
            case{'InitValue','InitialValue','AliveTimeout','QueueLength'}
                value=str2double(value);
            case 'HandleNeverReceived'
                if strcmp(value,'1')||strcmp(value,'true')
                    value=true;
                elseif strcmp(value,'0')||strcmp(value,'false')
                    value=false;
                end
            otherwise
                assert(false,'%s is not a valid ComSpec property.',...
                propertyName);
            end
        end

        function valueStr=convertValueExpressionToScalarValueString(hModel,valueExpr)



            if isstring(valueExpr)||ischar(valueExpr)
                [varExists,value]=autosar.utils.Workspace.objectExistsInModelScope(hModel,valueExpr);
                if~varExists
                    value=evalinGlobalScope(hModel,valueExpr);
                end
            else
                value=valueExpr;
            end
            if length(value)>1

                value=value(1);
            end
            if isstruct(value)


                names=fieldnames(value);

                value=...
                autosar.ui.comspec.ComSpecPropertyHandler.convertValueExpressionToScalarValueString(...
                hModel,value.(names{1}));
            end
            valueStr=autosar.ui.comspec.ComSpecPropertyHandler.convertValueToString(value);
        end

        function value=buildSlInitValueFromMetaModel(m3iComSpec,dataDictionary,createNewConstantIfNecessary)
            import autosar.ui.comspec.ComSpecPropertyHandler;

            value=[];
            initValueName=autosar.mm.mm2sl.ConstantBuilder.getInitValuePropertyName(m3iComSpec);
            initValue=m3iComSpec.(initValueName);

            m3iModel=m3iComSpec.modelM3I;

            changeLogger=autosar.updater.ChangeLogger;



            sysConstsValueMap=autosar.api.Utils.createSystemConstantMap(m3iModel,[],[]);
            pbVarCritValueMap=autosar.api.Utils.createPostBuildVariantCriterionMap(m3iModel,[],[]);
            m3iComp=m3iComSpec.containerM3I.containerM3I.containerM3I;
            if~m3iComp.Behavior.isvalid()
                return;
            end
            if isempty(dataDictionary)
                workSpace='base';
            else
                workSpace=Simulink.dd.open(dataDictionary);
                h=onCleanup(@workSpace.close);
            end
            replaceTypeDefinition=false;
            typeBuilder=autosar.mm.mm2sl.TypeBuilder(m3iModel,false,...
            workSpace,changeLogger,sysConstsValueMap,pbVarCritValueMap,ReplaceExistingTypeDefinition=replaceTypeDefinition);
            typeBuilder.buildDataTypeMappingsReferencedByComp(m3iComp);
            constantBuilder=autosar.mm.mm2sl.ConstantBuilder(m3iModel,typeBuilder);
            if~isempty(initValue)
                needTransaction=...
                ComSpecPropertyHandler.checkWhetherConstantBuilderNeedsTransaction(initValue);
                if needTransaction
                    if~createNewConstantIfNecessary



                        return;
                    end
                    trans=M3I.Transaction(m3iModel);
                    if~initValue.Type.isvalid()


                        initValue.Type=...
                        ComSpecPropertyHandler.getM3iTypeFromDataElement(m3iComSpec);
                    end
                end
                try


                    warnId='RTW:autosar:updateChangeClass';
                    warning('off',warnId)
                    cleanUpObj=onCleanup(@()warning('on',warnId));
                    mlVarInfo=constantBuilder.buildConst(initValue);
                catch Me
                    if strcmp(Me.identifier,'autosarstandard:ui:constantNotFoundInEnumeration')





                        if~needTransaction

                            trans=M3I.Transaction(m3iModel);
                        end
                        initValue.destroy();


                        value=ComSpecPropertyHandler.getComSpecDefaultPropertyValue('InitValue');
                        ComSpecPropertyHandler.setInitValue(m3iComSpec,value);
                        trans.commit();

                        DAStudio.error('autosarstandard:validation:initValueInvalidEnum');
                    else
                        rethrow(Me)
                    end
                end
                if mlVarInfo.isHomogeneousValue
                    value=mlVarInfo.firstVisitedValue;
                else
                    value=DAStudio.message('autosarstandard:ui:uiCannotDisplayHeterogeneousData');
                end
                if needTransaction
                    trans.cancel();
                end
            elseif createNewConstantIfNecessary







                m3iType=...
                ComSpecPropertyHandler.getM3iTypeFromDataElement(m3iComSpec);
                if~isempty(m3iType)
                    value=constantBuilder.getBlockInitialValueStringForType(m3iType);
                    if isa(m3iType,'Simulink.metamodel.types.Enumeration')||...
                        (m3iType.has('BaseType')&&isa(m3iType.BaseType,'Simulink.metamodel.types.Enumeration'))||...
                        isa(m3iType,'Simulink.metamodel.types.Boolean')


                        value=double(eval(value));
                    end
                end
            end
        end

        function m3iType=getM3iTypeFromDataElement(m3iComSpec)
            m3iDataElements=m3iComSpec.containerM3I.DataElements;
            if isempty(m3iDataElements)
                return;
            end
            m3iType=m3iDataElements.Type;
        end

        function valueStr=convertValueToString(value)


            if isfi(value)||isenum(value)

                value=value.double();
            end

            if ischar(value)
                valueStr=value;
            elseif(isnumeric(value)||islogical(value))&&numel(value)==1
                valueStr=Simulink.metamodel.arplatform.getRealStringCompact(value);
            elseif isempty(value)
                valueStr=mat2str(value);
            else
                assert(false,'Unrecognized type for InitValue');
            end
        end

        function value=convertValueStrToValue(valueStr)
            if strcmp(valueStr,...
                DAStudio.message('autosarstandard:ui:uiCannotDisplayHeterogeneousData'))

                value=[];
            elseif isempty(valueStr)
                value=[];
            elseif strcmp(valueStr,'true')
                value=true;
            elseif strcmp(valueStr,'false')
                value=false;
            else
                value=str2double(valueStr);
            end
        end
    end

    methods(Static,Access=private)

        function value=getInitValue(m3iComSpec,dataDictionary,canCommitTransaction)



            import autosar.ui.comspec.ComSpecPropertyHandler;


            value=...
            ComSpecPropertyHandler.getInitValueFromExternalToolInfo(m3iComSpec);

            if isempty(value)



                value=ComSpecPropertyHandler.buildSlInitValueFromMetaModel(...
                m3iComSpec,dataDictionary,canCommitTransaction);
                if~isempty(value)&&canCommitTransaction

                    ComSpecPropertyHandler.cacheInitValue(m3iComSpec,value);
                end
            end
        end

        function[errId,suggestion]=checkPositiveIntegerValue(value)

            errId='';
            suggestion='';
            if isempty(value)||value<1||~isnumeric(value)||...
                mod(value,1)~=0
                errId='RTW:autosar:apiInvalidPropertyValue';
                suggestion=DAStudio.message('autosarstandard:validation:suggestionPositiveIntegers');
            end
        end

        function[errId,suggestion]=checkLogicalValue(value)

            errId='';
            suggestion='';
            if isempty(value)||~islogical(value)||...
                (isnumeric(value)&&(value==0||value==1))
                errId='RTW:autosar:apiInvalidPropertyValue';
                suggestion=DAStudio.message('autosarstandard:validation:suggestionLogicalValues');
            end
        end

        function[errId,suggestion]=checkScalarNumericValue(value)

            errId='';
            suggestion='';
            if numel(value)>1||isnan(value)||isinf(value)||...
                ~isnumeric(value)||~isreal(value)
                errId='RTW:autosar:apiInvalidPropertyValue';
                suggestion=DAStudio.message('autosarstandard:validation:suggestionNumericScalarValues');
            end
        end

        function toolId=generateInitValueExtToolId(m3iComSpec)

            toolId='';
            m3iInfo=m3iComSpec.containerM3I;
            m3iPort=m3iInfo.containerM3I;
            if m3iPort.isvalid()&&m3iInfo.isvalid()&&...
                m3iInfo.DataElements.isvalid()
                toolId='UserInput_InitValue';
            end
        end

        function needTransaction=checkWhetherConstantBuilderNeedsTransaction(m3iConst)




            needTransaction=false;



            if m3iConst.getMetaClass()==Simulink.metamodel.types.ConstantReference.MetaClass()
                assert(m3iConst.Value.isvalid()&&m3iConst.Value.ConstantValue.isvalid(),...
                'Unexpected invalid constant reference specification');
                if~m3iConst.Value.ConstantValue.Type.isvalid()
                    needTransaction=true;
                end
            end

            needTransaction=needTransaction||~m3iConst.Type.isvalid();
        end

        function cacheInitValue(m3iComSpec,value)







            m3iModel=m3iComSpec.modelM3I;
            reRegisterListener=...
            autosarcore.unregisterListenerCBTemporarily(m3iModel);%#ok<NASGU>

            trans=M3I.Transaction(m3iModel);
            valueStr=autosar.ui.comspec.ComSpecPropertyHandler.convertValueToString(...
            value);
            if strcmp(valueStr,...
                DAStudio.message('autosarstandard:ui:uiCannotDisplayHeterogeneousData'))



                valueStr='uiCannotDisplayHeterogeneousData';
            end
            autosar.ui.comspec.ComSpecPropertyHandler.setInitValue(...
            m3iComSpec,valueStr);
            trans.commit();
        end
    end
end



