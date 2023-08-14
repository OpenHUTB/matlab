function[groups,hasHiddenGroups]=getCPPSystemObjectPropertyGroups(obj,isLongDisplay)












    mainProperties=obj.getDisplayPropertiesImpl;
    if islogical(mainProperties)
        systemObjectGroups=matlab.system.display.internal.Memoizer.getPropertyGroups(class(obj));
        [groups,hasHiddenGroups]=convertSystemObjectGroupsToCustomDisplayGroups(obj,systemObjectGroups,isLongDisplay);
    else
        mainGroup=createMainPropertyGroup(obj,mainProperties);



        fpGroup=createFixedPointPropertyGroup(obj);

        if isLongDisplay
            groups=[mainGroup,fpGroup];
            hasHiddenGroups=false;
        else
            groups=mainGroup;
            hasHiddenGroups=~isempty(fpGroup);
        end
    end
end

function mainGroup=createMainPropertyGroup(obj,mainProperties)

    mainIdx=false(size(mainProperties));
    for n=1:numel(mainProperties)
        mainIdx(n)=~isInactiveProperty(obj,mainProperties{n});
    end
    activeMainProperties=mainProperties(mainIdx);

    mainGroup=matlab.mixin.util.PropertyGroup(activeMainProperties);
end

function fpGroup=createFixedPointPropertyGroup(obj)
    fpProperties=obj.getDisplayFixedPointPropertiesImpl;
    if islogical(fpProperties)
        activeFPProperties={};
    else

        fpIdx=false(size(fpProperties));
        for n=1:numel(fpProperties)
            fpIdx(n)=~isInactiveProperty(obj,fpProperties{n});
        end
        activeFPProperties=fpProperties(fpIdx);
    end

    if isempty(activeFPProperties)
        fpGroup=matlab.mixin.util.PropertyGroup.empty;
    else
        fpGroup=matlab.mixin.util.PropertyGroup(activeFPProperties,...
        getString(message('MATLAB:system:DataTypesGroupDefaultTitle')));
    end
end
