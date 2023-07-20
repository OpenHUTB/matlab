


classdef FileInfoRetriever<handle

    properties(Abstract,Access=public)
Names
    end

    methods(Abstract,Access=public)
        values=getValuesForFile(obj,file)
    end

end

