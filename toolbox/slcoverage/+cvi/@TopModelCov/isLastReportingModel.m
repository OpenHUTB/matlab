




function res=isLastReportingModel(modelH)

    res=0;

    try
        modelCovId=get_param(modelH,'CoverageId');
        if modelCovId==0
            return
        end
        coveng=cvi.TopModelCov.getInstance(modelH);

        res=coveng.isLastReporting(modelH);

    catch MEx %#ok

    end
