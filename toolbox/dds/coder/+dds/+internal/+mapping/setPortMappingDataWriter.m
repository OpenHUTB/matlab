function setPortMappingDataWriter(mappingObj,modelName,writerPath)






    if isempty(writerPath)
        mappingObj.setMsgCustomizationProperty('ReaderWriterQoS','');
        mappingObj.setMsgCustomizationProperty('ReaderWriterXMLTag',writerPath);
        return;
    end

    ddsMf0Model=dds.internal.simulink.Util.getMf0ModelFromSimulinkModel(modelName);
    dataWriter=dds.internal.simulink.getDataWriter(modelName,writerPath);
    mappingObj.setMsgCustomizationProperty('ReaderWriterXMLTag',writerPath);

    if isempty(dataWriter.QosRef)
        mappingObj.setMsgCustomizationProperty('ReaderWriterQoS','');
    else

        qosPath=dds.internal.simulink.Util.getQoSPath(ddsMf0Model,dataWriter.QosRef);
        mappingObj.setMsgCustomizationProperty('ReaderWriterQoS',qosPath);
    end
end
