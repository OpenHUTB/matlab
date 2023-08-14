function val=getFeatureState(featureName)




    featureStates=evolutions.internal.session.SessionManager.getFeatureStates;
    val=featureStates.(featureName);
end
