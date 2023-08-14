function readerWriterPath=createReaderWriter(modelName,blockPath,topicPath,qosPath,...
    isReader,filterKind,filterExpression,filterParameterList)







    blockId=slrealtime.internal.dds.simulink.getCppIdentifierForBlock(blockPath,'');
    if isReader
        dataReader=slrealtime.internal.dds.simulink.addOrGetDataReader(modelName,blockId,...
        topicPath,qosPath,filterKind,filterExpression,filterParameterList);
        readerWriterPath=[dataReader.Parent.Parent.Parent.Name,'/',...
        dataReader.Parent.Parent.Name,'/',dataReader.Parent.Name,'/',...
        dataReader.Name];
    else
        dataWriter=slrealtime.internal.dds.simulink.addOrGetDataWriter(modelName,blockId,topicPath,qosPath);
        readerWriterPath=[dataWriter.Parent.Parent.Parent.Name,'/',...
        dataWriter.Parent.Parent.Name,'/',dataWriter.Parent.Name,'/',...
        dataWriter.Name];
    end
end