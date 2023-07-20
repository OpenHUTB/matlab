function term(coveng,modelH)









    if~coveng.isLastReporting(modelH)
        return
    end


    cvi.SFunctionCov.term(coveng);


    if~SlCov.isSLCustomCodeCovFeatureOn()
        return
    end
    cvi.SLCustomCodeCov.updateResults(coveng);

