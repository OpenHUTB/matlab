function ClearExclusions(system)




    if nargin==1
        ModelAdvisor.ExclusionManager('clear',system);
    else
        ModelAdvisor.ExclusionManager('clear','*');
    end