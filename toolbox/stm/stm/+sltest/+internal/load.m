



function tfile=load(fileName)
    assert(isStringScalar(fileName));

    import stm.internal.SlicerDebuggingStatus;
    stm.internal.util.checkLicense();
    stm.internal.apiDetail.checkAPIRunningPermission('sltest.testmanager.load');
    if stm.internal.slicerDebugStatus~=SlicerDebuggingStatus.DebugInactive
        error(message('stm:general:OperationProhibitedWhileDebugging','sltest.testmanager.load'));
    end

    [filePath,name,fileExt]=fileparts(fileName);

    if fileExt==""
        fileExt=".mldatx";
    end

    if isfile(fileName)

    elseif filePath==""

        fileName=string(which(fullfile(name+fileExt)));
    end

    pathNameCheck=name==""||fileName==""||(fileExt~=".mldatx"&&fileExt~=".m");
    if pathNameCheck
        error(message('stm:reportOptionDialogText:InvalidPathName'));
    end


    [status,msg]=simulinktest.munitutils.isSLTestMUnitFile(fileName);
    if~status&&~isempty(msg)
        error(msg);
    end

    stm.internal.openMasterSuite(fileName);


    tfile=sltest.testmanager.TestFile(fileName);
end
