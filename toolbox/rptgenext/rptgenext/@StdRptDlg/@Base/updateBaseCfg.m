function cfg=updateBaseCfg(dlgsrc)












    dlg=DAStudio.ToolRoot.getOpenDialogs(dlgsrc);
    dlg.apply;

    cfg=dlgsrc.reportCfg;
    cfg.title=dlgsrc.title;
    cfg.subtitle=dlgsrc.subtitle;
    cfg.authorNames=dlgsrc.authorNames;
    cfg.legalNotice=dlgsrc.legalNotice;
    cfg.titleImgPath=dlgsrc.titleImgPath;
    cfg.outputFormat=dlgsrc.outputFormat;
    cfg.packageType=dlgsrc.packageType;
    cfg.outputName=dlgsrc.outputName;
    cfg.outputDir=dlgsrc.outputDir;
    cfg.stylesheetIndex=dlgsrc.stylesheetIndex;
    cfg.incrOutputName=dlgsrc.incrOutputName;
    cfg.retainXMLSource=dlgsrc.retainXMLSource;
    cfg.displayReport=~dlgsrc.noView;

end










