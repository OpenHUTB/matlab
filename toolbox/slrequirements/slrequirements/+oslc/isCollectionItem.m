function tf=isCollectionItem(label)

    tf=startsWith(label,oslc.matlab.Constants.Module)||...
    startsWith(label,oslc.matlab.Constants.Collection);

end

