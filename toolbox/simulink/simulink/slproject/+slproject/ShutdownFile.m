classdef ShutdownFile

















    properties(GetAccess=public,SetAccess=immutable)
        File(1,:)char;
    end

    methods(Access=public,Hidden=true)
        function obj=ShutdownFile(file)
            obj.File=file;
        end
    end

end
