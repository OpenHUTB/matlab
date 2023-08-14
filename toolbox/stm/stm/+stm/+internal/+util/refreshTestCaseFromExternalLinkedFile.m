
function errorMessage=refreshTestCaseFromExternalLinkedFile(testCaseId,filePath,adapter)
    testCase=sltest.testmanager.TestCase([],testCaseId);
    if(nargin(adapter)~=2)
        try
            error(message('stm:LinkToExternalFile:AdapterAcceptTwoArgs',adapter));
        catch me
            errorMessage=getReport(me);
        end
        return;
    end
    adapter=str2func(adapter);
    errorMessage='';
    try
        adapter(testCase,filePath);
    catch me
        errorMessage=getReport(me);
    end
end
