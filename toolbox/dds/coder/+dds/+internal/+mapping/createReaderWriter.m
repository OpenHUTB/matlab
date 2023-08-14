function readerWriterPath=createReaderWriter(modelName,blockPath,topicPath,qosPath,...
    isInport,filterKind,filterExpression,filterParameterList)









    readerWriterPath='';

    if isInport
        InOutStr='Inport';
        ReaderWriterStr='DataReader';
    else
        InOutStr='Outport';
        ReaderWriterStr='DataWriter';
    end

    if isempty(topicPath)
        if isempty(qosPath)||...
            ~isempty(dds.internal.simulink.Util.getQoS(modelName,qosPath,isInport))
            warning(message('dds:cgen:CreateDataReaderWriterFailedTopicNotMapped',...
            ReaderWriterStr,InOutStr,blockPath));
            return;
        else
            warning(message('dds:cgen:CreateDataReaderWriterFailedQoSNotExistAndTopicNotMapped',...
            ReaderWriterStr,InOutStr,blockPath,qosPath));
            return;
        end
    else
        topic=dds.internal.simulink.Util.getTopic(modelName,topicPath);
        qos=dds.internal.simulink.Util.getQoS(modelName,qosPath,isInport);
        if isempty(topic)
            if isempty(qos)&&~isempty(qosPath)
                warning(message('dds:cgen:CreateDataReaderWriterFailedQoSAndTopicNotExist',...
                ReaderWriterStr,InOutStr,blockPath,topicPath,qosPath));
            else
                warning(message('dds:cgen:CreateDataReaderWriterFailedTopicNotExist',...
                ReaderWriterStr,InOutStr,blockPath,topicPath));
            end
            return;
        elseif isempty(qos)&&~isempty(qosPath)
            warning(message('dds:cgen:CreateDataReaderWriterFailedQoSNotExist',...
            ReaderWriterStr,InOutStr,blockPath,qosPath));
            return;
        end
    end

    if isempty(topic)
        if isempty(qos)&&~isempty(qosPath)
            warning(message('dds:cgen:CreateDataReaderWriterFailedQoSAndTopicNotExist',...
            ReaderWriterStr,InOutStr,blockPath,topicPath,qosPath));
        else
            warning(message('dds:cgen:CreateDataReaderWriterFailedTopicNotExist',...
            ReaderWriterStr,InOutStr,blockPath,topicPath));
        end
        return;
    elseif isempty(qos)&&~isempty(qosPath)
        warning(message('dds:cgen:CreateDataReaderWriterFailedQoSNotExist',...
        ReaderWriterStr,InOutStr,blockPath,qosPath));
        return;
    end

    blocks=split(blockPath,'/');
    portName=blocks{end};
    if isInport
        dataReader=dds.internal.simulink.addOrGetDataReader(modelName,portName,...
        topicPath,qosPath,filterKind,filterExpression,filterParameterList);
        readerWriterPath=[dataReader.Parent.Parent.Parent.Name,'/',...
        dataReader.Parent.Parent.Name,'/',dataReader.Parent.Name,'/',...
        dataReader.Name];
    else
        dataWriter=dds.internal.simulink.addOrGetDataWriter(modelName,portName,topicPath,qosPath);
        readerWriterPath=[dataWriter.Parent.Parent.Parent.Name,'/',...
        dataWriter.Parent.Parent.Name,'/',dataWriter.Parent.Name,'/',...
        dataWriter.Name];
    end
end

