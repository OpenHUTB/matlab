function idxs=getMatchIdx(hView,listNames,items)%#ok<INUSL>



    if~iscell(items)
        items={items};
    end

    idxs=1:length(items);
    for i=1:length(items)
        match=strmatch(items{i},listNames,'exact');
        if(~isempty(match))
            idxs(i)=match-1;
        else
            idxs(i)=[];
        end
    end
