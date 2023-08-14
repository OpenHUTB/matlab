function tf=verifyTestFileExists(testPath,expectedFileName)




    [~,testFileName,~]=sltest.internal.getSuiteFromTestPath(testPath);
    tf=strcmp(expectedFileName,testFileName);
end
