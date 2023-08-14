function updateCfg(dlgsrc)







    dlg=DAStudio.ToolRoot.getOpenDialogs(dlgsrc);
    dlg.apply;

    cfg=dlgsrc.reportCfg;
    cfg.title=dlgsrc.title;
    cfg.subtitle=dlgsrc.subtitle;
    cfg.authorNames=dlgsrc.authorNames;
    cfg.legalNotice=dlgsrc.legalNotice;
    cfg.titleImgPath=dlgsrc.titleImgPath;
    cfg.outputFormat=dlgsrc.outputFormat;
    cfg.modelInformation=dlgsrc.modelInformation;
    cfg.generatedCodeListings=dlgsrc.generatedCodeListings;
    cfg.templateFile=dlgsrc.templateFile;
    cfg.outputDir=dlgsrc.outputDir;
    cfg.outputName=dlgsrc.outputName;
    cfg.targetSystem=dlgsrc.targetSystem;
end










