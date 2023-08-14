function configuration=createConfigurationForSubModel(aObj,mdl)





    configuration=slci.Configuration(mdl);


    configuration.setGenerateCode(false);
    configuration.setCodeFolder(aObj.ChildModelFolder(mdl))
    configuration.setTerminateOnIncompatibility(aObj.getTerminateOnIncompatibility());
    configuration.setTopModel(false);


    configuration.setFollowModelLinks(false);
    configuration.setCodePlacement(aObj.getCodePlacement());
    configuration.setReportFolder(aObj.getReportFolder());
    configuration.setDisplayResults(aObj.getDisplayResults());
    configuration.setIncludeTopModelChecksumForRefModels(...
    aObj.getIncludeTopModelChecksumForRefModels());
    configuration.fViaGUI=aObj.fViaGUI;
end

