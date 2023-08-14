function bool=isSupportedBySLEditor(type)




    persistent supportedTypes;
    if isempty(supportedTypes)
        supportedTypes=["System","Annotation","Block","Segment","Line"];
    end

    bool=any(type==supportedTypes);
end

