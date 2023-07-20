function out=isUnifiedCoderAppFeatureOff

    try
        out=coderdictionary.data.feature.getFeature('CodeGenIntent')==0;
    catch
        out=true;
    end
