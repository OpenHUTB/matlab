classdef ModificationObject<handle
    properties(SetAccess=protected,GetAccess=public)
        Description;
    end


    methods(Abstract,Access=public)
        exec(this);
    end
end
