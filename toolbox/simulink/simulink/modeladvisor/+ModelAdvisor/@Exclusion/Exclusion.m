classdef Exclusion<handle
    properties(Hidden)
        Factory='off';
        FilteredObjs={};
    end

    properties(SetAccess=public)
        Rationale='';
        CheckIDs={};
        Rules={};
        CheckType='';
    end

    methods

        function Exclusion=Exclusion()
        end

    end
end