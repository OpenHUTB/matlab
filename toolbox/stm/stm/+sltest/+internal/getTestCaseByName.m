



function tc=getTestCaseByName(obj,name)
    p=inputParser;
    p.addRequired('obj',@(x)validateattributes(x,...
    {'sltest.testmanager.TestFile','sltest.testmanager.TestSuite'},{'scalar','nonempty'}));
    p.parse(obj);
    testCaseID=stm.internal.getTestCases(obj.getID(),name);
    if isempty(testCaseID)
        tc=sltest.testmanager.TestCase.empty(1,0);
    else
        tc=sltest.testmanager.TestCase(obj,testCaseID);
    end
end
