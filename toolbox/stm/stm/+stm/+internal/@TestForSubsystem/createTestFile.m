function tfObj=createTestFile(testFilePath)




    tfObj=[];

    if(~ischar(testFilePath)&&~isstring(testFilePath))||(testFilePath=="")
        error(message('stm:general:InvalidTestFileLocation'));
    end
    testFilePath=char(testFilePath);

    [parentPath,partName,ext]=fileparts(testFilePath);
    if isempty(parentPath)
        parentPath=pwd;
    end
    if isempty(ext)
        ext='.mldatx';
    end


    if exist(parentPath,'dir')==0
        bSuccess=stm.internal.report.createPath(parentPath);
        if~bSuccess
            error(message('stm:general:FailedToCreateDirectory',parentPath));
        end
    end


    testFilePath=fullfile(parentPath,[partName,ext]);


    if exist(testFilePath,'dir')
        error(message('stm:general:InvalidTestFileLocation'));
    end

    if exist(testFilePath,'file')

        tfObj=sltest.testmanager.TestFile(testFilePath);
    else

        tfObj=sltest.testmanager.TestFile(testFilePath);


        ts=tfObj.getTestSuites;
        assert(length(ts)==1);
        ts.remove;


        tfObj.saveToFile;

    end

end
