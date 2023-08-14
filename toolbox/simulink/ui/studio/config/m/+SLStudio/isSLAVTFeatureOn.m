function result=isSLAVTFeatureOn(feature)
    if nargin>0
        feature=convertStringsToChars(feature);
    end
    try
        result=slavteng('feature',feature);
    catch ME %#ok<NASGU>
        result=0;
    end
end