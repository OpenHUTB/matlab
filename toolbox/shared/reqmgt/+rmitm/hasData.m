function yesno=hasData(testSuiteFile)

    testSuiteFile=convertStringsToChars(testSuiteFile);


    if~any(testSuiteFile=='.')
        testSuiteFile=rmitm.getFilePath(testSuiteFile);
    end
    yesno=slreq.hasData(testSuiteFile);

end
