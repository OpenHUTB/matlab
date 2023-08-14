function out=featureOpenInStudio(value)
    persistent featureValue
    if isempty(featureValue)
        featureValue=false;
    end
    out=featureValue;
    if nargin>0
        featureValue=value;
    end
end
