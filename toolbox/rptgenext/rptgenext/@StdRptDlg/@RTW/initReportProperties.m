function initReportProperties(dlgsrc)











    dlgsrc.reportCfg=dlgsrc.getCfg();

    rpt=dlgsrc.reportCfg;
    dlgsrc.title=rpt.title;
    dlgsrc.subtitle=rpt.subtitle;
    dlgsrc.authorNames=rpt.authorNames;
    dlgsrc.titleImgPath=rpt.titleImgPath;
    dlgsrc.legalNotice=rpt.legalNotice;
    dlgsrc.outputFormat=rpt.outputFormat;
    dlgsrc.modelInformation=rpt.modelInformation;
    dlgsrc.generatedCodeListings=rpt.generatedCodeListings;
    if isempty(rpt.templateFile)||isempty(strtrim(rpt.templateFile))
        dlgsrc.templateFile=coder.report.internal.slcoderPublishCode.getDefaultTemplate;
    else
        dlgsrc.templateFile=rpt.templateFile;
    end
    dlgsrc.outputDir=rpt.outputDir;
    dlgsrc.outputName=rpt.outputName;
    dlgsrc.targetSystem=rpt.targetSystem;
end



