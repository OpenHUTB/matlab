function checkReportFolder(aReportFolder)



    try
        rtw_checkdir(aReportFolder);
    catch ME
        switch ME.identifier
        case 'RTW:buildProcess:buildDirInMatlabDir'
            DAStudio.error('Slci:ui:ERROR_MATLABDIR_EXPORTFOLDER',aReportFolder);
        case 'RTW:buildProcess:buildDirInRTWProjDir'
            DAStudio.error('Slci:ui:ERROR_RTWPROJDIR_EXPORTFOLDER',aReportFolder);
        case 'RTW:buildProcess:buildDirInBuildDir'

        otherwise
            rethrow(ME);
        end
    end

    if~isWriteableFolder(aReportFolder)
        DAStudio.error('Slci:ui:NONWRITEABLE_EXPORTFOLDER',aReportFolder);
    end
end


function isWriteable=isWriteableFolder(folderPath)
    isWriteable=false;

    testdir=folderPath;
    if exist(folderPath,'dir')
        testdir=fullfile(testdir,filesep,['test_',num2str(int32(rand*1000))]);
    end

    [~,errmsg,~]=builtin('mkdir',testdir);
    if isempty(errmsg)


        builtin('rmdir',testdir);
        isWriteable=true;
    end
end