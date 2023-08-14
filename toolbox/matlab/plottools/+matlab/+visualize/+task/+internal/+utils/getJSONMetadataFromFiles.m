function visualizeMetaData=getJSONMetadataFromFiles(filePaths)







    visualizeMetaData=[];

    for i=1:numel(filePaths)
        filePath=fullfile(filePaths{i});
        jsonMetaData=jsondecode(fileread(filePath));
        fieldNames=fieldnames(jsonMetaData);

        for j=1:numel(fieldNames)
            funcMetaData=jsonMetaData.(fieldNames{j});
            if isfield(funcMetaData,'taskInfo')&&isfield(funcMetaData.taskInfo,'VisualizeTaskInfo')
                visualizeMetaData(end+1).Name=fieldNames{j};%#ok<AGROW>
                funcMetaData.fileName=filePath;
                visualizeMetaData(end).MetaData=funcMetaData;
            end
        end
    end
end