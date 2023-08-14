function resultObj=run(parallelize,testTagStr)



    import stm.internal.SlicerDebuggingStatus;

    stm.internal.util.checkLicense();

    if stm.internal.slicerDebugStatus~=SlicerDebuggingStatus.DebugInactive
        error(message('stm:general:OperationProhibitedWhileDebugging','sltest.testmanager.run'));
    end

    testFile=sltest.testmanager.getTestFiles;


    fileList=testFile.getID;
    idMap=fileList.';
    if~isempty(idMap)
        idMap(:,end+1)=2;
    end

    resultObj=stm.internal.apiDetail.runWrapper('idMap',idMap,...
    'parallel',parallelize,...
    'tag',testTagStr,'rootId',fileList);
end
