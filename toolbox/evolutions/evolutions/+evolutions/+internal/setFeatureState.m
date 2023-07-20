function setFeatureState(featureName,featureVal)




    featureStates=evolutions.internal.session.SessionManager.getFeatureStates;
    featureStates.(featureName)=featureVal;
end
