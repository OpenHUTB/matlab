function out=isUnifiedCoderAppFeatureOn

    try
        out=coderdictionary.data.feature.getFeature('CodeGenIntent')>0;
    catch
        out=false;
    end