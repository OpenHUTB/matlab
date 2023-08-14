function setClientFeatureCtrl(featureName,featureVal)
    ctrlObj=Simulink.sdi.internal.controllers.SessionSaveLoad.getController();
    ctrlObj.setFeatureCtrl(featureName,featureVal);
end
