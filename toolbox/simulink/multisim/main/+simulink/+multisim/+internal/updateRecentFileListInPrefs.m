function updateRecentFileListInPrefs(modelHandle,designSession)
    modelName=get_param(modelHandle,"Name");
    fileList=designSession.RecentFiles.toArray();
    prefGroup="MultipleSimulationsPrefs";
    prefName="RecentFiles";

    prefValue=getpref(prefGroup,prefName,containers.Map);
    prefValue(modelName)=fileList;
    setpref(prefGroup,prefName,prefValue)
end