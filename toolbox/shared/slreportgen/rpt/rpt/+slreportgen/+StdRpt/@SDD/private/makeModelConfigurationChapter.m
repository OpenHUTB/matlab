function makeModelConfigurationChapter(sddRpt)






















    import mlreportgen.report.*
    import slreportgen.report.*


    chap=Chapter();
    chap.Title=...
    getString(message("slreportgen:StdRpt:SDD:cfgSetSectTitle"));


    modelConfig=ModelConfiguration(sddRpt.Model);


    append(chap,modelConfig);


    append(sddRpt,chap);
end