







function count=remove(varargin)

    foundItems=slreq.find(varargin{:});

    count=0;
    for i=length(foundItems):-1:1
        count=count+foundItems(i).remove();
    end

end

