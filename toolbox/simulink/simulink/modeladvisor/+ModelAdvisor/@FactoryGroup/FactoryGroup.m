classdef(CaseInsensitiveProperties=true)FactoryGroup<ModelAdvisor.Group
    properties(Hidden=true)
        MAT='';
        MATIndex=0;
        Top=true;
    end

    methods(Access='public')
        function this=FactoryGroup(varargin)
mlock
            this=this@ModelAdvisor.Group(varargin{:});
        end

    end
end
