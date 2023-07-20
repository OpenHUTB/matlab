function[testProcedureNames,isFileLevel]=getTestNamesUnderRange(filepath,positions)




    munitData=rmiml.RmiMUnitData.getInstance;
    cacheKey=sprintf('%s::%d::%d',filepath,positions(1),positions(2));
    if isKey(munitData.bookmarkToTestCache,cacheKey)

        val=munitData.bookmarkToTestCache(cacheKey);
        testProcedureNames=val.(munitData.FIELD_NAMES);
        isFileLevel=val.(munitData.FIELD_ISFILELEVEL);
        return;
    end




    munitData.readAllBookmarksForTestNames(filepath);


    if isKey(munitData.bookmarkToTestCache,cacheKey)


        val=munitData.bookmarkToTestCache(cacheKey);
        testProcedureNames=val.(munitData.FIELD_NAMES);
        isFileLevel=val.(munitData.FIELD_ISFILELEVEL);
    else


        [testProcedureNames,isFileLevel]=munitData.getTestNamesUnderRangeRaw(filepath,positions);

        cacheVal=struct();
        cacheVal.(munitData.FIELD_NAMES)=testProcedureNames;
        cacheVal.(munitData.FIELD_ISFILELEVEL)=isFileLevel;
        munitData.bookmarkToTestCache(cacheKey)=cacheVal;
    end
end
