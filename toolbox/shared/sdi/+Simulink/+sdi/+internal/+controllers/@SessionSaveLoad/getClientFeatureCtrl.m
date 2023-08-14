function fCtrl=getClientFeatureCtrl(featureName)
    ctrlObj=Simulink.sdi.internal.controllers.SessionSaveLoad.getController();
    fCtrl=ctrlObj.getFeatureCtrl(featureName);
end
