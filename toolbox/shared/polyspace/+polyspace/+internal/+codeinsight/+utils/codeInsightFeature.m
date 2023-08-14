function oldvalue=codeInsightFeature(featureName,value)
    persistent feature;
    if isempty(feature)
        feature=struct(...
        'PSCleanFile',false,...
        'PSPreProcessedFile',false...
        );
    end
    if~(isfield(feature,featureName))
        error("Unknown feature '"+featureName+"'");
    end
    oldvalue=feature.(featureName);
    if nargin>=2
        feature.(featureName)=value;
    end
end

