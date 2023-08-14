function registerBlock(handle,varargin)




    narginchk(1,3);
    if nargin==1
        assert(ishandle(handle),'registerBlock expects block handle if no other arguments are provided.');
    else
        events=varargin{1};
        if nargin==2
            soc.internal.ESBRegistry.addBlock(handle,events);
        else
            commType=varargin{2};
            soc.internal.ESBRegistry.addBlock(handle,events,commType);
        end
    end
end
