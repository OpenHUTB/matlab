function bool=isSupportedBySLXEditor(type)

    persistent supportedTypes;
    if isempty(supportedTypes)
        supportedTypes=["System","Component","Port","Segment"];
    end

    bool=any(type==supportedTypes);
end
