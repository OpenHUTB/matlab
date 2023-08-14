function listenr=addListener(obj,varargin)

    if isa(obj,'double')
        obj=get_param(obj,'Object');
        if iscell(obj)
            obj=[obj{:}];
        end
    end

    listenr=addlistener(obj,varargin{:});

end