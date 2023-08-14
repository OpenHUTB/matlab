

function isCharOrString(val)
    if~(ischar(val)||isstring(val))
        DAStudio.error('slcheck:metricengine:StringOrCharInputError');
    end
end
