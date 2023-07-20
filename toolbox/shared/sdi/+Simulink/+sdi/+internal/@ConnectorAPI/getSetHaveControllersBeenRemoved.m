function ret=getSetHaveControllersBeenRemoved(varargin)

    persistent bAreRemoved;
    mlock;


    if nargin
        assert(islogical(varargin{1}));
        bAreRemoved=varargin{1};
    end


    ret=false;
    if~isempty(bAreRemoved)
        ret=bAreRemoved;
    end



    if~ret
        if~Simulink.sdi.internal.controllers.SDIDispatcher.isConstructed()
            ret=true;
        end
    end
end
