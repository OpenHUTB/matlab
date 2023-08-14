function setFeatureCtrl(this,featureName,featureVal)
    this.ClientFeatureCtrl.(featureName)=featureVal;
    this.cb_SendClientFeature();
end
