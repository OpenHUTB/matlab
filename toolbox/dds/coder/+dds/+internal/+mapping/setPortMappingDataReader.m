function setPortMappingDataReader(mappingObj,modelName,readerPath)





    if isempty(readerPath)
        mappingObj.setMsgCustomizationProperty('ReaderWriterQoS','');
        mappingObj.setMsgCustomizationProperty('ReaderWriterXMLTag',readerPath);
        mappingObj.setMsgCustomizationProperty('FilterExpression','');
        mappingObj.setMsgCustomizationProperty('FilterParameterList','');
        return;
    end

    ddsMf0Model=dds.internal.simulink.Util.getMf0ModelFromSimulinkModel(modelName);
    dataReader=dds.internal.simulink.getDataReader(modelName,readerPath);

    mappingObj.setMsgCustomizationProperty('ReaderWriterXMLTag',readerPath);

    if isempty(dataReader.QosRef)
        mappingObj.setMsgCustomizationProperty('ReaderWriterQoS','');
    else
        qosPath=dds.internal.simulink.Util.getQoSPath(ddsMf0Model,dataReader.QosRef);
        mappingObj.setMsgCustomizationProperty('ReaderWriterQoS',qosPath);
    end

    if(isempty(dataReader.ContentFilter))
        mappingObj.setMsgCustomizationProperty('FilterExpression','');
        mappingObj.setMsgCustomizationProperty('FilterParameterList','');
    else
        if(isequal(dataReader.ContentFilter.Kind,dds.datamodel.domainparticipant.ddstypes.FilterKind.builtin_stringMatch))
            mappingObj.setMsgCustomizationProperty('FilterKind','StringMatch');
        else
            mappingObj.setMsgCustomizationProperty('FilterKind','SQL');
        end
        mappingObj.setMsgCustomizationProperty('FilterExpression',dataReader.ContentFilter.Expression);
        paramListStr='';
        for i=1:dataReader.ContentFilter.ParameterList.Size
            param=dataReader.ContentFilter.ParameterList(i);
            if(isequal(i,1))
                paramListStr=param{1};
            else
                paramListStr=strcat(paramListStr,newline,param{1});
            end
        end
        mappingObj.setMsgCustomizationProperty('FilterParameterList',paramListStr);
    end
end
