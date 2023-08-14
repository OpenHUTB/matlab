function discard(testSuite)




    testSuite=convertStringsToChars(testSuite);

    tPath=rmitm.getFilePath(testSuite);

    slreq.discardLinkSet(tPath);
end

