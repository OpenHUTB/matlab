

classdef DebugInfo<handle

    methods(Access=public)
        function obj=DebugInfo()
            obj.value=false;
            obj.appendDebugStr='';
        end
    end

    properties(Access=public)
        value=false;
        appendDebugStr='';
    end
end
