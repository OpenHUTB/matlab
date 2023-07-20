function ret=isExtendedConfigSetForConcurrency(configSet)
    ret=strcmpi(get_param(configSet,'ConcurrentTasks'),'on')&&...
    strcmpi(get_param(configSet.getModel,'ExplicitPartitioning'),'on');
end

