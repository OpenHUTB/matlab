function featureRefString=getFeatureReference(instanceElement)







    featureRefElement=instanceElement.SW_FEATURE_REF;


    featureRefString=strings(1);


    if~isempty(featureRefElement)
        featureRefString=string(featureRefElement.elementValue);
    end

end

