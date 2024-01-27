classdef Results<handle

    properties(SetAccess='private',GetAccess='public')
Candidates
    end

    properties(SetAccess='private',GetAccess='public',Hidden=true)
ModelTransformerInfo
    end


    methods
        function obj=Results(m2mObj)
            obj.Candidates=m2mObj.fCandidates;
            obj.ModelTransformerInfo=m2mObj;
        end
    end
end

