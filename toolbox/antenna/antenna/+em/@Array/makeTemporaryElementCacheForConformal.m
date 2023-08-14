function tempElement=makeTemporaryElementCacheForConformal(obj,n)


    if iscell(obj.Element)
        tempElement=obj.Element;
    else
        if isscalar(obj.Element)
            tempElement=repmat(obj.Element,1,n);
        else
            tempElement=obj.Element;
        end
        tempElement=num2cell(tempElement);
    end

