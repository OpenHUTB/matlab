function createPersistencyDefaultValues(modelName,buildDir,apiObj)









    m3iModel=autosar.api.Utils.m3iModel(modelName);


    portToDbMappings=autosar.mm.Model.findObjectByMetaClass(m3iModel,...
    Simulink.metamodel.arplatform.manifest.PersistencyPortToKeyValueDatabaseMapping.MetaClass);
    keyValuePairList={};
    requiredMappingInfo=getMappedDSM(modelName);
    for ii=1:portToDbMappings.size()
        portToDb=portToDbMappings.at(ii);
        curKeyValuePairInit.InstanceSpecifier=getInstanceSpecifier(apiObj,portToDb.Port.Name);
        keyValuePairs=portToDb.KeyValueStorage.KeyValuePair;
        for jj=1:keyValuePairs.size()
            curKeyValuePair=keyValuePairs.at(jj);
            curKeyValuePairInit.Key=curKeyValuePair.Name;
            found=false;
            for kk=1:numel(requiredMappingInfo)
                if isequal(requiredMappingInfo{kk}.portName,portToDb.Port.Name)...
                    &&isequal(requiredMappingInfo{kk}.dataElementName,curKeyValuePair.Name)
                    found=true;
                end
            end
            if~found
                continue;
            end
            m3iType=curKeyValuePair.InitValue.Type;

            if isa(m3iType,'Simulink.metamodel.types.Matrix')
                matDim=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getMatrixSize(m3iType);

                if isa(m3iType.BaseType,'Simulink.metamodel.types.Structure')
                    curKeyValuePairInit.ValueType='array';
                    curKeyValuePairInit.ValueDim=int64(matDim);
                    curKeyValuePairInit.ValueBaseType='struct';
                    internalKeyValuePairList={};

                    for kk=1:curKeyValuePair.InitValue.ownedCell.size()
                        curKeyValue=curKeyValuePair.InitValue.ownedCell.at(kk);
                        [~,internalKeyValuePairInit.Value]=getStructInfoFromStructure(curKeyValue);
                        internalKeyValuePairList{end+1}=internalKeyValuePairInit;
                    end
                    curKeyValuePairInit.Value=internalKeyValuePairList;
                else

                    [~,dType]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRTPSMetaDataFromType(m3iType.BaseType);
                    curKeyValuePairInit.ValueType='array';
                    curKeyValuePairInit.ValueDim=int64(matDim);
                    curKeyValuePairInit.ValueBaseType=dType;

                    matInitVal=[];

                    for kk=1:curKeyValuePair.InitValue.ownedCell.size()
                        curCell=curKeyValuePair.InitValue.ownedCell.at(kk);
                        matInitVal=[matInitVal,curCell.Value.Value];%#ok<AGROW>
                    end
                    curKeyValuePairInit.Value=matInitVal;
                end

            elseif isa(m3iType,'Simulink.metamodel.types.Structure')
                curKeyValuePairInit.ValueType='struct';
                internalKeyValuePairList={};

                for kk=1:curKeyValuePair.InitValue.Type.Elements.size
                    type=curKeyValuePair.InitValue.Type.Elements.at(kk).Type;
                    internalKeyValuePairInit=struct();
                    if isa(type,'Simulink.metamodel.types.Structure')
                        curKeyValue=curKeyValuePair.InitValue.OwnedSlot.at(kk);
                        [internalKeyValuePairInit.ValueType,internalKeyValuePairInit.Value]=getStructInfoFromStructure(curKeyValue);
                    elseif isa(type,'Simulink.metamodel.types.Matrix')
                        curKeyValue=curKeyValuePair.InitValue.OwnedSlot.at(kk);
                        [internalKeyValuePairInit.ValueType,internalKeyValuePairInit.ValueDim,internalKeyValuePairInit.ValueBaseType,internalKeyValuePairInit.Value]=getArrayInfoFromStruct(curKeyValue,type);
                    else
                        curKeyValue=curKeyValuePair.InitValue.OwnedSlot.at(kk);
                        [internalKeyValuePairInit.ValueType,internalKeyValuePairInit.Value]=getScalarInfoFromStruct(curKeyValue,type);
                    end
                    internalKeyValuePairList{end+1}=internalKeyValuePairInit;
                end
                curKeyValuePairInit.Value=internalKeyValuePairList;

            else
                [~,dType]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRTPSMetaDataFromType(m3iType);
                curKeyValuePairInit.ValueType=dType;
                if isa(curKeyValuePair.InitValue.Value,'Simulink.metamodel.types.EnumerationLiteral')
                    curKeyValuePairInit.Value=curKeyValuePair.InitValue.Value.Value;
                else
                    curKeyValuePairInit.Value=curKeyValuePair.InitValue.Value;
                end
            end
            keyValuePairList{end+1}=curKeyValuePairInit;
        end
    end
    persistencyInfoStruct.PersistencyKeyValuePairs=keyValuePairList;


    perInitValueFullFilePath=[buildDir.CodeGenFolder,filesep,'PersistencyDefaultValues.json'];
    autosar.internal.adaptive.manifest.createJSONfileFromStruct(persistencyInfoStruct,perInitValueFullFilePath);

end

function instSpec=getInstanceSpecifier(apiObj,perPortName)
    portType='PersistencyProvidedRequiredPort';
    componentQualifiedName=apiObj.get('XmlOptions','ComponentQualifiedName');
    instSpecName=apiObj.find(componentQualifiedName,portType,...
    'Name',perPortName,'PathType','FullyQualified');
    instSpec='';
    if~isempty(instSpecName)
        instSpec=instSpecName{1};
    end
end

function requiredMappingInfo=getMappedDSM(modelName)

    requiredMappingInfo={};
    modelMapping=autosar.api.Utils.modelMapping(modelName);
    for ii=1:numel(modelMapping.DataStores)
        dsMapping=modelMapping.DataStores(ii);
        if strcmp(dsMapping.MappedTo.ArDataRole,'Persistency')
            curDataStore.portName=dsMapping.MappedTo.getPerInstancePropertyValue('Port');
            curDataStore.dataElementName=dsMapping.MappedTo.getPerInstancePropertyValue('DataElement');
            requiredMappingInfo{end+1}=curDataStore;
        end
    end
end

function[valueType,value]=getScalarInfoFromStruct(curKeyValue,m3iType)

    [~,dType]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRTPSMetaDataFromType(m3iType);
    valueType=dType;
    if isa(curKeyValue.Value,'Simulink.metamodel.types.EnumerationLiteral')
        value=curKeyValue.Value.Value.Value;
    else
        value=curKeyValue.Value.Value;
    end
end

function[valueType,valueDim,valueBaseType,value]=getArrayInfoFromStruct(curKeyValue,m3iType)

    matDim=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getMatrixSize(m3iType);
    if isa(m3iType.BaseType,'Simulink.metamodel.types.Structure')
        valueType='array';
        valueDim=int64(matDim);
        valueBaseType='struct';
        internalKeyValuePairList={};
        for ii=1:curKeyValue.Value.ownedCell.size()
            internalKeyValuePairInit=struct();
            curKeyValue=curKeyValuePair.Value.ownedCell.at(ii);
            [internalKeyValuePairInit.ValueType,internalKeyValuePairInit.Value]=getStructInfoFromStructure(curKeyValue);
            internalKeyValuePairList{end+1}=internalKeyValuePairInit;
        end
        value=internalKeyValuePairList;
    elseif isa(m3iType.BaseType,'Simulink.metamodel.types.Matrix')
        valueType='array';
        valueDim=int64(matDim);
        valueBaseType='array';
        internalKeyValuePairList={};
        for ii=1:curKeyValue.Value.ownedCell.size()
            internalKeyValuePairInit=struct();
            curKeyValue=curKeyValuePair.Value.ownedCell.at(ii);
            [internalKeyValuePairInit.ValueType,internalKeyValuePairInit.ValueDim,internalKeyValuePairInit.ValueBaseType,internalKeyValuePairInit.Value]=getArrayInfoFromStruct(curKeyValue,m3iType.BaseType);
            internalKeyValuePairList{end+1}=internalKeyValuePairInit;
        end
        value=internalKeyValuePairList;
    else
        [~,dType]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRTPSMetaDataFromType(m3iType.BaseType);
        valueType='array';
        valueDim=int64(matDim);
        valueBaseType=dType;
        value=[];

        for ii=1:curKeyValue.Value.ownedCell.size()
            curCell=curKeyValue.Value.ownedCell.at(ii);
            if isa(curCell.Value.Value,'Simulink.metamodel.types.EnumerationLiteral')
                value=[value,curCell.Value.Value.Value];
            else
                value=[value,curCell.Value.Value];
            end
        end
    end
end

function[valueType,value]=getStructInfoFromStructure(curKeyValuePair)

    valueType='struct';
    internalKeyValuePairList={};
    for ii=1:curKeyValuePair.Value.OwnedSlot.size
        type=curKeyValuePair.Value.OwnedSlot.at(ii).Value.Type;
        internalKeyValuePairInit=struct();
        if isa(type,'Simulink.metamodel.types.Structure')
            curKeyValue=curKeyValuePair.Value.OwnedSlot.at(ii);
            [internalKeyValuePairInit.ValueType,internalKeyValuePairInit.Value]=getStructInfoFromStructure(curKeyValue);
        elseif isa(type,'Simulink.metamodel.types.Matrix')
            curKeyValue=curKeyValuePair.Value.OwnedSlot.at(ii);
            [internalKeyValuePairInit.ValueType,internalKeyValuePairInit.ValueDim,internalKeyValuePairInit.ValueBaseType,internalKeyValuePairInit.Value]=getArrayInfoFromStruct(curKeyValue,type);
        else
            curKeyValue=curKeyValuePair.Value.OwnedSlot.at(ii);
            [internalKeyValuePairInit.ValueType,internalKeyValuePairInit.Value]=getScalarInfoFromStruct(curKeyValue,type);
        end
        internalKeyValuePairList{end+1}=internalKeyValuePairInit;
    end
    value=internalKeyValuePairList;
end
