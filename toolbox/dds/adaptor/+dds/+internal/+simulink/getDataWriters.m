function dataWriters=getDataWriters(modelName,topicPath)







    dataWriters={};
    dd=get_param(modelName,'DataDictionary');
    if isempty(dd)
        return;
    end

    ddConn=Simulink.data.dictionary.open(dd);
    if~Simulink.DDSDictionary.ModelRegistry.hasDDSPart(ddConn.filepath)
        return;
    end

    dataWrtRefs={};

    if(isempty(topicPath))
        return;
    end
    topicRef=dds.internal.simulink.Util.getTopic(modelName,topicPath);
    if(isempty(topicRef))
        return;
    end
    for dw=1:topicRef.DataWriterRefs.Size
        dataWrtRefs{end+1}=topicRef.DataWriterRefs(dw);%#ok<AGROW>
    end


    dataWriters=cell(numel(dataWrtRefs),1);
    for i=1:numel(dataWrtRefs)
        dataWriters{i}=[dataWrtRefs{i}.Parent.Parent.Parent.Name,'/',...
        dataWrtRefs{i}.Parent.Parent.Name,'/',dataWrtRefs{i}.Parent.Name,'/',dataWrtRefs{i}.Name];
    end
end

