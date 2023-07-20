function ok=okFeature(feature)




    str=builtin('license','inuse',feature);
    ok=~isempty(str)&&strcmpi(str.feature,feature);
end

