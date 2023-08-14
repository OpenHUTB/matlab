function ai=createAggregatedTestInfo(cvd)




    try
        ai.uniqueId=cvd.uniqueId;
        ai.analyzedModel=cvd.getAnalyzedModel();
        ai.description=cvd.description;
        ai.date=cvd.stopTime;
        ai.testRunInfo=cvd.testRunInfo;

    catch MEx
        rethrow(MEx);
    end
end
