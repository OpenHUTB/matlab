function RegisterExclusion(exclusionObj,system,varargin)




    if nargin<2
        error(message('ModelAdvisor:engine:ExclusionRegisterError'));
    end

    if iscell(system)
        for i=1:length(system)
            ModelAdvisor.ExclusionManager('add',system{i},exclusionObj);
        end
    else
        ModelAdvisor.ExclusionManager('add',system,exclusionObj);
    end