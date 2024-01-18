function wasSaved=close(testSuite)
    testSuite=convertStringsToChars(testSuite);
    testFilePath=rmitm.getFilePath(testSuite);

    wasSaved=slreq.close(testFilePath);

end