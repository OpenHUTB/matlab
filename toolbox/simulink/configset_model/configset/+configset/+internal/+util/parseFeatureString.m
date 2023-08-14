function out=parseFeatureString(featureStr)




    if isempty(featureStr)
        out=[];
    else
        featureList=regexp(featureStr,':','split');
        if length(featureList)>2
            error(['Unsupported feature control specifier: ',featureStr]);
        end
        feature.Name=featureList{1};
        if length(featureList)>1
            num=str2double(featureList{2});
            if isnan(num)
                if strcmp(featureList{2},'true')
                    feature.Value=true;
                else
                    error(['Unsupported feature value: ',featureList{2}]);
                end
            else
                feature.Value=num;
            end
        else
            feature.Value=true;
        end

        out=feature;
    end

