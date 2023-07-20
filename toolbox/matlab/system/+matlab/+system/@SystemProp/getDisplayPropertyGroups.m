function groups=getDisplayPropertyGroups(systemName,argument)


    filepath=which(systemName);
    xmlFileName=[filepath(1:end-2),'_mask','.xml'];
    if~isfile(xmlFileName)
        if(nargin>1)
            groups=feval([systemName,'.getPropertyGroupsImpl'],argument);
        else
            groups=feval([systemName,'.getPropertyGroupsImpl']);
        end
    end
    if strcmp(groups,'default')
        groups=matlab.system.display.internal.getDefaultPropertyGroups(systemName);
    end
    groups=groups(:)';

    validateSystemDisplayGroups(systemName,groups);
end
