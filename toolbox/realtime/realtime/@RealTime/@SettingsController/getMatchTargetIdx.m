function idxs=getMatchTargetIdx(hObj,items,varargin)





    if~iscell(items)
        items={items};
    end
    if(nargin<3)
        [listNames,~]=hObj.getTargetList();
    else
        listNames=varargin{1};
    end

    idxs=1:length(items);
    for i=1:length(items)
        match=find(strcmp(listNames,items{i}));
        if(~isempty(match))
            idxs(i)=match-1;
        else
            idxs(i)=[];
        end
    end
end

