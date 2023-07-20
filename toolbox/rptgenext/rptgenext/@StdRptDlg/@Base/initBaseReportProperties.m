function rptCfg=initBaseReportProperties(dlgsrc)











    dlgsrc.reportCfg=dlgsrc.getCfg();

    rptCfg=dlgsrc.reportCfg;
    dlgsrc.title=rptCfg.title;
    dlgsrc.subtitle=rptCfg.subtitle;
    dlgsrc.authorNames=rptCfg.authorNames;
    dlgsrc.titleImgPath=rptCfg.titleImgPath;
    dlgsrc.legalNotice=rptCfg.legalNotice;
    dlgsrc.outputFormat=rptCfg.outputFormat;
    dlgsrc.packageType=rptCfg.packageType;
    dlgsrc.outputName=rptCfg.outputName;
    dlgsrc.outputDir=rptCfg.outputDir;
    dlgsrc.incrOutputName=rptCfg.incrOutputName;
    dlgsrc.stylesheetIndex=rptCfg.stylesheetIndex;

end










