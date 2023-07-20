classdef(Abstract)AbstractResult<handle





    properties
        ID=[];
    end


    methods(Access=public)

        function res=AbstractResult(ID)

            validateattributes(ID,{'fxptds.AbstractIdentifier'},{'scalar','nonempty'});
            res.ID=ID;
        end
    end
end


