function out=isFeatureActive(feature)





    if isempty(feature)
        out=true;
    else
        status=slfeature(feature.Name);
        if isnumeric(feature.Value)
            out=(status==feature.Value);
        else
            if status
                out=feature.Value;
            else
                out=~feature.Value;
            end
        end
    end