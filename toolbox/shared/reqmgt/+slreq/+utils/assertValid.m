


function assertValid(obj)
    if~isempty(obj)
        if isstruct(obj)
            debug=0;
        elseif iscell(obj)
            debug=0;
        elseif any(~isvalid(obj))
            assert(false);
        end
    end
end