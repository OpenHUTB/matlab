function dataReaders=getDataReaders(modelName,topicPath)







    dataReaders={};
    dd=get_param(modelName,'DataDictionary');
    if isempty(dd)
        return;
    end

    ddConn=Simulink.data.dictionary.open(dd);
    if~Simulink.DDSDictionary.ModelRegistry.hasDDSPart(ddConn.filepath)
        return;
    end

    dataRdrRefs={};

    if(isempty(topicPath))
        return;
    end
    topicRef=dds.internal.simulink.Util.getTopic(modelName,topicPath);
    if(isempty(topicRef))
        return;
    end
    for dr=1:topicRef.DataReaderRefs.Size
        dataRdrRefs{end+1}=topicRef.DataReaderRefs(dr);%#ok<AGROW>
    end


    dataReaders=cell(numel(dataRdrRefs),1);
    for i=1:numel(dataRdrRefs)
        dataReaders{i}=[dataRdrRefs{i}.Parent.Parent.Parent.Name,'/',...
        dataRdrRefs{i}.Parent.Parent.Name,'/',dataRdrRefs{i}.Parent.Name,'/',dataRdrRefs{i}.Name];
    end
end

