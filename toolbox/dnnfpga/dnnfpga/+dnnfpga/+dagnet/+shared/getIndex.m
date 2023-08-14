






function index=getIndex(label,object,noErrorIfNoMap)
    if nargin<3
        noErrorIfNoMap=true;
    end
    index={};
    if isa(object,'containers.Map')
        index=object(label);
    end
    if isa(object,'struct')
        aMap={};
        try
            aMap=object.addrMap;
        catch
        end
        if~isempty(aMap)
            index=aMap(label);
        end
    end
    if isempty(index)
        if noErrorIfNoMap
            index=-1;
        else
            error("Unable to find address map.");
        end
    end
end


