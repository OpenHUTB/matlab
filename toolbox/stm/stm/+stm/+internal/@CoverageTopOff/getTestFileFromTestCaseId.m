

function tfObj=getTestFileFromTestCaseId(tcId)
    pp=stm.internal.getTestProperty(tcId,'testcase');
    tfObj=sltest.testmanager.TestFile(pp.testFilePath);
end
