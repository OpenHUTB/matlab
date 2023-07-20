classdef StringLocation<slxmlcomp.internal.highlight.Location




    properties(GetAccess=public,SetAccess=private)
Type
        Location(1,1)string
    end

    methods(Access=public)
        function obj=StringLocation(type,location)
            obj.Type=type;
            obj.Location=location;
        end
    end
end
