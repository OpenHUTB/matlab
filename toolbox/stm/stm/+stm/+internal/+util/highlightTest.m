function highlightTest(testFilePath,uuid)


    callback=@()stm.internal.openTestCase(testFilePath,uuid);
    sltest.internal.invokeFunctionAfterWindowRenders(callback);
end
