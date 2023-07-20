classdef(Abstract)AbstractAction<handle







    properties(Access=protected)
sysToScaleName
refMdls
proposalSettings
    end

    methods(Abstract,Access=public)
        execute(this)
    end

end

