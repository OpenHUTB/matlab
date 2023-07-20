function getTaskDurationFromDiagnosticsFile(taskName,fileName,~)





    if~exist(fileName,'file')
        error(message('soc:scheduler:MetaDataFileNotFound',taskName));
    end
end
