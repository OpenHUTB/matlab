function fileName=getXmlFileName(modelName,buildInfo)














    fileName=[dds.internal.simulink.Util.getApplicationName(modelName),'.xml'];
    existedNames={};
    for i=1:numel(buildInfo.Inc.Files)
        [~,name,~]=fileparts(buildInfo.Inc.Files(i).FileName);
        existedNames{end+1}=name;
    end
    for i=1:numel(buildInfo.Src)
        [~,name,~]=fileparts(buildInfo.Src.Files(i).FileName);
        existedNames{end+1}=name;
    end
    index=1;
    [~,fileName,~]=fileparts(fileName);
    originFileName=fileName;
    while any(strcmp(fileName,existedNames))
        fileName=[originFileName,'_',int2str(index)];
        index=index+1;
    end
    fileName=[fileName,'.xml'];
end


