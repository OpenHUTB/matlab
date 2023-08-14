classdef BDLocation<comparisons.internal.highlight.Location




    properties(GetAccess=public,SetAccess=private)
Type
Handles
    end

    methods(Access=public)
        function obj=BDLocation(type,handles)
            obj.Type=type;
            obj.Handles=handles;
        end
    end
end
