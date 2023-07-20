

function[tcObj,tfObj,newFileCreated]=createTestCase(testFileId,testFilePath,testCaseType)
    newFileCreated=false;
    if(testFileId>0)
        pp=stm.internal.getTestProperty(testFileId,'testsuite');
        tfObj=sltest.testmanager.load(pp.testFilePath);
    else
        try
            stm.internal.openMasterSuite(testFilePath,false,false);
        catch
            newFileCreated=true;
        end
        hasError=false;
        try
            tfObj=sltest.testmanager.TestFile(testFilePath);
        catch
            hasError=true;
        end
        if(hasError)
            if(newFileCreated)
                error(message('stm:general:FileCouldNotBeCreated',testFilePath));
            else
                error(message('stm:general:FileNotFound',testFilePath));
            end
        end

        ts=tfObj.getTestSuites();
        ts.remove();
    end
    ts=tfObj.createTestSuite();

    testType='baseline';
    if(testCaseType==0)
        testType='simulation';
    elseif(testCaseType==1)
        testType='equivalence';
    end
    tcObj=ts.createTestCase(testType);
end
