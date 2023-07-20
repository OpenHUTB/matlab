function ResultDescription=fixmeSampleTimeChecks(mdlTaskObj)







    ruleName='runSampleTimeChecks';
    mdlAdvObj=mdlTaskObj.MAObj;
    partiallyQualifiedCheckName=ruleName;
    UserData=mdlAdvObj.UserData(partiallyQualifiedCheckName);
    checker=UserData{1};

    infCandidateBlks=hdlcoder.ModelChecker.getInfSampleTimeSrcs(checker.m_DUT);
    contCandidateBlks=hdlcoder.ModelChecker.getContinuousSampleTimeSrcs(checker.m_DUT);

    ResultDescription=hdlcoder.ModelChecker.setSampleTime('-1',[contCandidateBlks,infCandidateBlks]);
end
