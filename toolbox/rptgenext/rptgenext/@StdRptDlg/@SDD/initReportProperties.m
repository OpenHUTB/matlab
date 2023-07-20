function initReportProperties(dlgsrc)











    dlgsrc.reportCfg=dlgsrc.getCfg();

    rpt=dlgsrc.reportCfg;
    dlgsrc.title=rpt.title;
    dlgsrc.subtitle=rpt.subtitle;
    dlgsrc.authorNames=rpt.authorNames;
    dlgsrc.titleImgPath=rpt.titleImgPath;
    dlgsrc.legalNotice=rpt.legalNotice;
    dlgsrc.outputFormat=rpt.outputFormat;
    dlgsrc.packageType=rpt.packageType;
    dlgsrc.outputName=rpt.outputName;
    dlgsrc.outputDir=rpt.outputDir;
    dlgsrc.incrOutputName=rpt.incrOutputName;

    if(rpt.stylesheetIndex>0)
        dlgsrc.stylesheetIndex=rpt.stylesheetIndex;
    else
        dlgsrc.stylesheetIndex=1;
    end

    dlgsrc.includeDetails=rpt.includeDetails;
    dlgsrc.includeModelRefs=rpt.includeModelRefs;
    dlgsrc.includeRequirementsLinks=rpt.includeRequirementsLinks;
    dlgsrc.includeCustomLibraries=rpt.includeCustomLibraries;
    dlgsrc.includeGlossary=rpt.includeGlossary;

end










