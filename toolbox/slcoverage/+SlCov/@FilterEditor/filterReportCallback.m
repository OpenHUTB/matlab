function filterReportCallback(this)



    try
        preApply(this);
        postApply(this);
        [cvd,cvdc]=this.applyFilter;
        coveng=cvi.TopModelCov.getInstance(this.modelName);
        outputDir=cvi.TopModelCov.checkOutputDir(coveng.resultSettings.covOutputDir);
        coveng.makeReport(cvd,cvdc,outputDir);

    catch MEx
    end
