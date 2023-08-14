function flag=isHalfFeatureAvailable()




    featureValue=fixed.internal.utility.featuremanager.FeatureManager.getStatus('SLHalfPrecisionSupport');
    flag=featureValue>0;
end