function setRecentFilesFromPrefs(modelHandle,designSession)
    modelName=get_param(modelHandle,"Name");
    prefGroup="MultipleSimulationsPrefs";
    prefName="RecentFiles";

    prefValue=getpref(prefGroup,prefName,containers.Map);

    if prefValue.isKey(modelName)
        fileList=prefValue(modelName);

        for fileIdx=1:numel(fileList)
            designSession.RecentFiles.add(fileList{fileIdx});
        end
    end
end