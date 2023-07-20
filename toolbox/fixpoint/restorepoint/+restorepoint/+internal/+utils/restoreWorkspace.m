function restoreWorkspace(fullRestoreDir,restoreData)




    if isempty(restoreData.OriginalWorkspaceVariables)
        return;
    end
    [~,storedWorkspaceFileName,storedWorkspaceFileExtension]=...
    fileparts(restoreData.WorkspaceFile);
    backupFullFile=fullfile(fullRestoreDir,[storedWorkspaceFileName,storedWorkspaceFileExtension]);
    variables=load(backupFullFile);
    fields=fieldnames(variables);
    for idx=1:numel(fields)
        fieldName=fields{idx};
        value=variables.(fieldName);
        assignin('base',fieldName,value);
    end
end
