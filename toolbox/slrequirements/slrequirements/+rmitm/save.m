function reqFilePath=save(testSuite)




    testSuite=convertStringsToChars(testSuite);

    suiteFilePath=rmitm.getFilePath(testSuite);

    if slreq.hasData(suiteFilePath)
        reqFilePath=slreq.saveLinks(suiteFilePath);
    else
        reqFilePath='';
    end
end


