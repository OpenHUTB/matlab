function yesno=hasChanges(testFile)




    testFilePath=rmitm.getFilePath(testFile);

    yesno=slreq.hasChanges(testFilePath);

end
