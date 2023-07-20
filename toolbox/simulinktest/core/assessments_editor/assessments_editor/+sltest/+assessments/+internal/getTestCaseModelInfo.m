function[modelName,systemModelName]=getTestCaseModelInfo(testCaseId)
    tc=sltest.testmanager.TestCase('',str2double(testCaseId));
    mainModelName=tc.getProperty('model');
    harnessModelName=tc.getProperty('harnessname');
    if isempty(harnessModelName)
        modelName=mainModelName;
        systemModelName='';
    else
        modelName=harnessModelName;
        systemModelName=mainModelName;
    end
end

