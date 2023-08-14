function RtpsSerializerWriter(EventList,intfName,filePath,namespace,suffix)






    codeWriter=rtw.connectivity.CodeWriter.create('callCBeautifier',...
    false,'filename',filePath,'append',true);
    codeWriter.wBlockStart(['namespace ',namespace,'_io']);

    for ii=1:length(EventList)
        m3iEvnt=EventList{ii};
        if isempty(m3iEvnt.Type)
            continue;
        end

        eventName=m3iEvnt.Name;
        eventDataType=m3iEvnt.Type;
        if isa(eventDataType,'Simulink.metamodel.types.Matrix')
            eventDataBaseType=eventDataType.BaseType;
        else
            eventDataBaseType=eventDataType;
        end

        evtSfxName=[intfName,'_',eventName,suffix];


        if isa(eventDataBaseType,'Simulink.metamodel.types.Structure')||...
            isa(eventDataBaseType,'Simulink.metamodel.types.Matrix')




            originalDataTypeName=m3iEvnt.getExternalToolInfo('DDSDataTypeName').externalId;
            writeRTPSStructMultiArrayWrapper(codeWriter,evtSfxName,eventDataType,originalDataTypeName);
            continue;
        end


        [idlType,dataType,idlStructType]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRTPSMetaDataFromType(eventDataBaseType);
        if isa(eventDataType,'Simulink.metamodel.types.Matrix')
            writeRTPSArrayWrapper(codeWriter,evtSfxName,eventDataType,dataType,idlStructType);
        else
            writeRTPSPODWrapper(codeWriter,evtSfxName,idlType,dataType,eventDataType);
        end
    end

    codeWriter.wBlockEnd(['namespace ',namespace,'_io']);
    codeWriter.close();
end

function writeRTPSPODWrapper(codeWriter,className,idlType,dataType,eventDataType)
    if slfeature('ARAComMiddleware')==3
        writeRTPSIdlWrapper(codeWriter,[className,'_t'],className,dataType,eventDataType,dataType);
    else
        writeRTPSDynamicPODWrapper(codeWriter,[className,'_t'],idlType,dataType);
    end
end

function writeRTPSDynamicPODWrapper(codeWriter,className,idlType,dataType)



    codeWriter.wBlockStart(['class ',className]);
    codeWriter.wLine('public:');
    codeWriter.wLine('eprosima::fastrtps::types::DynamicData* mEventData;');
    codeWriter.wLine('eprosima::fastrtps::types::DynamicPubSubType mEventDataType;');

    codeWriter.wBlockStart([className,'(): mEventData{nullptr}']);

    if strcmp(idlType,'int8')||strcmp(idlType,'uint8')
        builderType='byte';
    else
        builderType=idlType;
    end

    codeWriter.wLine(['eprosima::fastrtps::types::DynamicTypeBuilder_ptr dynTypeBuilder = eprosima::fastrtps::types::DynamicTypeBuilderFactory::get_instance()->create_',builderType,'_builder();']);
    codeWriter.wLine('eprosima::fastrtps::types::DynamicType_ptr dynType = eprosima::fastrtps::types::DynamicTypeBuilderFactory::get_instance()->create_type(dynTypeBuilder.get());');
    codeWriter.wLine('mEventDataType.SetDynamicType(dynType);');
    codeWriter.wLine('mEventData = eprosima::fastrtps::types::DynamicDataFactory::get_instance()->create_data(dynType);');
    codeWriter.wBlockEnd();

    codeWriter.wBlockStart(['void eventData(',dataType,' val)']);
    codeWriter.wBlockStart('if (mEventData != nullptr)');
    codeWriter.wLine(['mEventData->set_',idlType,'_value(val, MEMBER_ID_INVALID);']);
    codeWriter.wBlockEnd();
    codeWriter.wBlockEnd();

    codeWriter.wBlockStart([dataType,' eventData()']);
    codeWriter.wLine([dataType,' retVal;']);
    codeWriter.wBlockStart('if (mEventData != nullptr)');
    codeWriter.wLine(['mEventData->get_',idlType,'_value(retVal, MEMBER_ID_INVALID);']);
    codeWriter.wBlockEnd();
    codeWriter.wLine('return retVal;');
    codeWriter.wBlockEnd();

    codeWriter.wBlockStart(['~ ',className,'()']);
    codeWriter.wBlockStart('if (mEventData != nullptr)');
    codeWriter.wLine('eprosima::fastrtps::types::DynamicDataFactory::get_instance()->delete_data(mEventData);');
    codeWriter.wBlockEnd();
    codeWriter.wBlockEnd();

    codeWriter.wBlockEnd();
    codeWriter.wLine([';','// class ',className]);
end

function writeRTPSArrayWrapper(codeWriter,className,eventDataType,dataType,idlStructType)
    if slfeature('ARAComMiddleware')==3
        arrayType=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRecursiveArrayType(eventDataType);
        writeRTPSIdlWrapper(codeWriter,[className,'_t'],className,arrayType,eventDataType,idlStructType);
    else
        writeRTPSDynamicArrayWrapper(codeWriter,[className,'_t'],eventDataType,dataType);
    end
end

function writeRTPSDynamicArrayWrapper(codeWriter,className,eventDataType,dataType)



    codeWriter.wBlockStart(['class ',className]);
    codeWriter.wLine('public:');
    codeWriter.wLine('eprosima::fastrtps::types::DynamicData* mEventData;');
    codeWriter.wLine('eprosima::fastrtps::types::DynamicPubSubType mEventDataType;');

    matDim=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getMatrixSize(eventDataType);

    codeWriter.wBlockStart([className,'(): mEventData{nullptr}']);
    codeWriter.wLine(['eprosima::fastrtps::types::DynamicTypeBuilder_ptr dynTypeBuilder = eprosima::fastrtps::types::DynamicTypeBuilderFactory::get_instance()->create_string_builder(2 * ',num2str(matDim),' * sizeof(',dataType,') + 1);']);
    codeWriter.wLine('eprosima::fastrtps::types::DynamicType_ptr dynType = eprosima::fastrtps::types::DynamicTypeBuilderFactory::get_instance()->create_type(dynTypeBuilder.get());');
    codeWriter.wLine('mEventDataType.SetDynamicType(dynType);');
    codeWriter.wLine('mEventData = eprosima::fastrtps::types::DynamicDataFactory::get_instance()->create_data(dynType);');
    codeWriter.wBlockEnd();

    arrayType=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRecursiveArrayType(eventDataType);




    codeWriter.wBlockStart(['void eventData(',arrayType,' arVal)']);
    codeWriter.wBlockStart('if (mEventData != nullptr)');
    codeWriter.wLine(['mEventData->set_string_value(ara::com::_RtpsSerialize<',arrayType,'>{}(arVal), MEMBER_ID_INVALID);']);
    codeWriter.wBlockEnd();
    codeWriter.wBlockEnd();


    codeWriter.wBlockStart([arrayType,' eventData()']);
    codeWriter.wBlockStart('if (mEventData != nullptr)');
    codeWriter.wLine('std::string lRawStr;');
    codeWriter.wLine('mEventData->get_string_value(lRawStr, MEMBER_ID_INVALID);');
    codeWriter.wLine(['return ara::com::_RtpsDeserialize<',arrayType,'>{}(0, lRawStr);']);
    codeWriter.wBlockEnd();
    codeWriter.wLine(['return ',arrayType,'{};']);
    codeWriter.wBlockEnd();

    codeWriter.wBlockStart(['~ ',className,'()']);
    codeWriter.wBlockStart('if (mEventData != nullptr)');
    codeWriter.wLine('eprosima::fastrtps::types::DynamicDataFactory::get_instance()->delete_data(mEventData);');
    codeWriter.wBlockEnd();
    codeWriter.wBlockEnd();

    codeWriter.wBlockEnd();
    codeWriter.wLine([';','// class ',className]);
end

function writeRTPSStructMultiArrayWrapper(codeWriter,className,eventDataType,originalDataTypeName)
    if slfeature('ARAComMiddleware')==3
        writeRTPSIdlDynamicStructMultiArrayWrapper(codeWriter,[className,'_t'],className,eventDataType,originalDataTypeName);
    else
        writeRTPSDynamicStructMultiArrayWrapper(codeWriter,[className,'_t'],eventDataType);
    end
end

function writeRTPSDynamicStructMultiArrayWrapper(codeWriter,className,eventDataType)



    codeWriter.wBlockStart(['class ',className]);
    codeWriter.wLine('public:');
    codeWriter.wLine('eprosima::fastrtps::types::DynamicData* mEventData;');
    codeWriter.wLine('eprosima::fastrtps::types::DynamicPubSubType mEventDataType;');


    if isa(eventDataType,'Simulink.metamodel.types.Structure')
        codeWriter.wBlockStart(['void eventData(',eventDataType.Name,' val)']);
    else
        arrayType=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRecursiveArrayType(eventDataType);
        codeWriter.wBlockStart(['void eventData(',arrayType,' val)']);
    end
    lambdaNum=0;
    sizeCode=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.generateSerializationLambda(codeWriter,lambdaNum,eventDataType);
    codeWriter.wBlockStart('if (mEventData != nullptr)');
    codeWriter.wLine(['mEventData->set_string_value(',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getLambdaName(lambdaNum),'(val), MEMBER_ID_INVALID);']);
    codeWriter.wBlockEnd();
    codeWriter.wBlockEnd();


    if isa(eventDataType,'Simulink.metamodel.types.Structure')
        codeWriter.wBlockStart([eventDataType.Name,' eventData()']);
    else
        codeWriter.wBlockStart([arrayType,' eventData()']);
    end
    lambdaNum=0;
    autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.generateDeserializationLambda(codeWriter,lambdaNum,eventDataType);
    codeWriter.wBlockStart('if (mEventData != nullptr)');
    codeWriter.wLine('std::string lRawStr;');
    codeWriter.wLine('size_t st = 0;');
    codeWriter.wLine('mEventData->get_string_value(lRawStr, MEMBER_ID_INVALID);');
    codeWriter.wLine(['return ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getLambdaName(lambdaNum),'(st, lRawStr);']);
    codeWriter.wBlockEnd();
    if isa(eventDataType,'Simulink.metamodel.types.Structure')
        codeWriter.wLine(['return ',eventDataType.Name,'{};']);
    else
        codeWriter.wLine(['return ',arrayType,'{};']);
    end
    codeWriter.wBlockEnd();


    codeWriter.wBlockStart([className,'(): mEventData{nullptr}']);
    codeWriter.wLine(['auto sizeOfSerStr = ',sizeCode,';']);
    codeWriter.wLine('eprosima::fastrtps::types::DynamicTypeBuilder_ptr dynTypeBuilder = eprosima::fastrtps::types::DynamicTypeBuilderFactory::get_instance()->create_string_builder(sizeOfSerStr);');
    codeWriter.wLine('eprosima::fastrtps::types::DynamicType_ptr dynType = eprosima::fastrtps::types::DynamicTypeBuilderFactory::get_instance()->create_type(dynTypeBuilder.get());');
    codeWriter.wLine('mEventDataType.SetDynamicType(dynType);');
    codeWriter.wLine('mEventData = eprosima::fastrtps::types::DynamicDataFactory::get_instance()->create_data(dynType);');
    codeWriter.wBlockEnd();


    codeWriter.wBlockStart(['~ ',className,'()']);
    codeWriter.wBlockStart('if (mEventData != nullptr)');
    codeWriter.wLine('eprosima::fastrtps::types::DynamicDataFactory::get_instance()->delete_data(mEventData);');
    codeWriter.wBlockEnd();
    codeWriter.wBlockEnd();

    codeWriter.wBlockEnd();
    codeWriter.wLine([';','// class ',className]);
end

function writeRTPSIdlWrapper(codeWriter,className,idlClassName,dataType,eventDataType,idlStructType)
    namespacePfx='eprosima_dds::';
    evtDataTypeName=eventDataType.Name;

    codeWriter.wBlockStart(['class ',className,' final']);
    codeWriter.wLine('public:');
    codeWriter.wLine([namespacePfx,idlClassName,' mEventData;']);
    codeWriter.wLine([namespacePfx,idlClassName,'PubSubType mEventDataType;']);

    codeWriter.wBlockStart([className,'(): mEventData{}, mEventDataType{}']);
    codeWriter.wLine(['mEventDataType.setName("',evtDataTypeName,'");']);
    codeWriter.wBlockEnd();

    codeWriter.wLine(['~ ',className,'() = default;']);




    codeWriter.wLine([className,'(const ',className,'&) = default;']);
    codeWriter.wLine([className,'& operator =(const ',className,'&) & = default;']);


    codeWriter.wLine([className,'(',className,'&&) = default;']);
    codeWriter.wLine([className,'& operator =(',className,'&&) & = default;']);

    if isa(eventDataType,'Simulink.metamodel.types.Matrix')&&isequal(idlStructType,'char')
        codeWriter.wBlockStart(['void eventData( const ',dataType,' implValue)']);
        matDim=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getMatrixSize(eventDataType);
        codeWriter.wLine(['const std::int32_t arrSize = ',num2str(matDim),';']);
        codeWriter.wLine('std::array<char, arrSize> idlVal;');
        codeWriter.wBlockStart('for(std::int32_t i=0;i< arrSize; i++)');
        codeWriter.wLine('idlVal[i] = static_cast<char>(implValue[i]);')
        codeWriter.wBlockEnd();
        codeWriter.wLine(['mEventData.m_',evtDataTypeName,'(idlVal);']);
    elseif(isa(eventDataType,'Simulink.metamodel.types.Matrix')&&isa(eventDataType.BaseType,'Simulink.metamodel.types.Enumeration'))
        codeWriter.wBlockStart(['void eventData( const ',dataType,' implValue)']);
        [~,platformType,~]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRTPSMetaDataFromType(eventDataType.BaseType);
        matDim=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getMatrixSize(eventDataType);
        codeWriter.wLine(['const std::int32_t arrSize = ',num2str(matDim),';']);
        codeWriter.wLine(['std::array<',platformType,', arrSize > intArrayVal;']);
        codeWriter.wBlockStart('for (std::int32_t i = 0; i < arrSize; i++)');
        codeWriter.wLine(['intArrayVal[i] = static_cast<',platformType,'>(implValue[i]);']);
        codeWriter.wBlockEnd();
        codeWriter.wLine(['mEventData.m_',evtDataTypeName,'(intArrayVal);']);
    elseif isa(eventDataType,'Simulink.metamodel.types.Enumeration')


        qualifiedTypeName=autosar.mm.mm2ara.NamespaceHelper.getQualifiedTypeName(eventDataType);
        codeWriter.wBlockStart(['void eventData( const ',qualifiedTypeName,' implValue)']);
        codeWriter.wLine(['const ',dataType,' convertedVal = static_cast<',dataType,'>(implValue);']);
        codeWriter.wLine(['mEventData.m_',evtDataTypeName,'(convertedVal);']);
    else
        codeWriter.wBlockStart(['void eventData( const ',dataType,' implValue)']);
        codeWriter.wLine(['mEventData.m_',evtDataTypeName,'(implValue);']);
    end
    codeWriter.wBlockEnd();

    codeWriter.wBlockStart([dataType,' eventData()']);
    if isa(eventDataType,'Simulink.metamodel.types.Matrix')&&isequal(idlStructType,'char')
        matDim=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getMatrixSize(eventDataType);
        codeWriter.wLine(['const std::int32_t arrSize = ',num2str(matDim),';']);
        codeWriter.wLine(['std::array<char, arrSize> idlVal = mEventData.m_',evtDataTypeName,'();']);
        codeWriter.wLine('std::array<int8_t, arrSize> implVal;');
        codeWriter.wBlockStart('for(std::int32_t i=0;i< arrSize; i++)');
        codeWriter.wLine('implVal[i] = static_cast<int8_t>(idlVal[i]);')
        codeWriter.wBlockEnd();
        codeWriter.wLine('return implVal;');
    elseif(isa(eventDataType,'Simulink.metamodel.types.Matrix')&&isa(eventDataType.BaseType,'Simulink.metamodel.types.Enumeration'))
        [~,platformType,~]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getRTPSMetaDataFromType(eventDataType.BaseType);
        matDim=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getMatrixSize(eventDataType);
        codeWriter.wLine(['const std::int32_t arrSize = ',num2str(matDim),';']);
        codeWriter.wLine(['std::array<',platformType,', arrSize> intArrayVal = mEventData.m_',evtDataTypeName,'();']);
        codeWriter.wLine([evtDataTypeName,' enumArrayVal;']);
        codeWriter.wBlockStart('for (std::int32_t i = 0; i < arrSize; i++)');
        codeWriter.wLine(['enumArrayVal[i] = static_cast<',eventDataType.BaseType.Name,'>(intArrayVal[i]);']);
        codeWriter.wBlockEnd();
        codeWriter.wLine('return enumArrayVal;');
    else
        codeWriter.wLine(['return mEventData.m_',evtDataTypeName,'();']);
    end
    codeWriter.wBlockEnd();

    codeWriter.wBlockEnd(['class ',className],false,true);
end

function writeRTPSIdlDynamicStructMultiArrayWrapper(codeWriter,className,idlClassName,eventDataType,originalDataTypeName)
    namespacePfx='eprosima_dds::';
    dataType=autosar.mm.mm2ara.TypeWriter.getUsingTypeName(eventDataType);
    qualifiedDataTypeName=autosar.mm.mm2ara.NamespaceHelper.getQualifiedTypeName(eventDataType);
    codeWriter.wBlockStart(['class ',className,' final']);
    codeWriter.wLine('public:');
    codeWriter.wLine([namespacePfx,idlClassName,' mEventData;']);
    codeWriter.wLine([namespacePfx,idlClassName,'PubSubType mEventDataType;']);

    codeWriter.wBlockStart([className,'(): mEventData{}, mEventDataType{}']);
    if isempty(originalDataTypeName)


        codeWriter.wLine(['mEventDataType.setName("',dataType,'");']);
    else
        codeWriter.wLine(['mEventDataType.setName("',originalDataTypeName,'");']);
    end
    codeWriter.wBlockEnd();

    codeWriter.wLine(['~ ',className,'() = default;']);




    codeWriter.wLine([className,'(const ',className,'&) = default;']);
    codeWriter.wLine([className,'& operator =(const ',className,'&) & = default;']);


    codeWriter.wLine([className,'(',className,'&&) = default;']);
    codeWriter.wLine([className,'& operator =(',className,'&&) & = default;']);

    codeWriter.wBlockStart(['void eventData( const ',qualifiedDataTypeName,' implValue)']);
    lambdaNum=0;
    arrSizeNum=0;
    autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.generateImplToIdlConversionLambda(codeWriter,lambdaNum,eventDataType,arrSizeNum);
    codeWriter.wLine(['mEventData.m_',dataType,'(',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getLambdaName(lambdaNum),'(implValue));']);
    codeWriter.wBlockEnd();

    codeWriter.wBlockStart([qualifiedDataTypeName,' eventData()']);
    autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.generateIdlToImplConversionLambda(codeWriter,lambdaNum,eventDataType,arrSizeNum);
    codeWriter.wLine(['return ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getLambdaName(lambdaNum),'(mEventData.m_',dataType,'());']);
    codeWriter.wBlockEnd();

    codeWriter.wBlockEnd(['class ',className],false,true);
end


