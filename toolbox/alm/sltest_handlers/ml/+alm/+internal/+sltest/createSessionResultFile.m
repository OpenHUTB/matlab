function fullFileName=createSessionResultFile(projectRootFolder,resultSet)
    fullFileName=[];


    if isempty(resultSet)
        return;
    end

    databaseFullFilePath=alm.internal.ArtifactService.getDatabaseLocation(...
    projectRootFolder);
    [databasePath,~]=fileparts(databaseFullFilePath);
    targetFolder=fullfile(databasePath,'sltest');

    if~isfolder(targetFolder)
        mkdir(targetFolder);
    end

    fullFileName=fullfile(targetFolder,[resultSet.UUID,'.sltsrf']);
    writeJsonFiles(fullFileName,resultSet);

end

function writeJsonFiles(fullFileName,resultSet)
    file=fopen(fullFileName,'wt');

    jsonData.Type='sl_test_session_result_file';
    jsonData.sl_test_resultset.Name=resultSet.Name;
    jsonData.sl_test_resultset.Uuid=resultSet.UUID;
    jsonData.sl_test_resultset.Outcome=resultSet.Outcome;

    fwrite(file,jsonencode(jsonData));

    fclose(file);
end

