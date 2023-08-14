function[groups,hasHiddenGroups]=getDefaultCustomDisplayPropertyGroups(obj,isLongDisplay)




    if isa(obj,'matlab.system.SystemAdaptor')
        [groups,hasHiddenGroups]=getCPPSystemObjectPropertyGroups(obj,isLongDisplay);
    else
        systemObjectGroups=matlab.system.display.internal.Memoizer.getPropertyGroups(class(obj));
        [groups,hasHiddenGroups]=convertSystemObjectGroupsToCustomDisplayGroups(obj,systemObjectGroups,isLongDisplay);
    end
end
