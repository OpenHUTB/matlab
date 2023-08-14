function out=featureReportV2(value)



    persistent featureValue

    if isempty(featureValue)

        featureValue=true;
    end
    out=featureValue;
    if nargin>0
        featureValue=value;
    end
end


