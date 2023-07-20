function tf=isLibraryLoaded(newVal)









    persistent STATE
    if isempty(STATE)
        STATE=false;
mlock
    end
    tf=STATE;
    if nargin>0&&newVal
        STATE=true;
    end
end