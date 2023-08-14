function hiliteVariable(location,name,dictionary)
    switch location
    case 'base'
        slprivate('exploreListNode',dictionary,'base',name);
    case 'dictionary'
        slprivate('exploreListNode',dictionary,'dictionary',name);
    otherwise
    end
end
