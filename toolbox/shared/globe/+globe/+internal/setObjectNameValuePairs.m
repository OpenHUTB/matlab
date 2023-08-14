function setObjectNameValuePairs(obj,pvpairs)










    try
        if isscalar(pvpairs)
            error(message('MATLAB:class:BadParamValuePairs'))
        elseif~isempty(pvpairs)
            set(obj,pvpairs{:});
        end
    catch e
        throwAsCaller(e);
    end
end
