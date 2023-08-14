classdef(Abstract)FileType<handle



    properties(SetAccess=protected,GetAccess=public)
FilePath
    end

    methods(Abstract)
        accept(visitor)
    end
end
