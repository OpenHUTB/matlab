function taskMgr=getTaskManagerBlock(mdl,varargin)






    taskMgr=find_system(mdl,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'MaskType','Task Manager');
    if isempty(taskMgr)

        if(nargin==1)
            assert(false,'Task Manager not found');
        end
    else
        if iscell(taskMgr)&&isequal(numel(taskMgr),1)
            taskMgr=taskMgr{1};
        end
    end
end
