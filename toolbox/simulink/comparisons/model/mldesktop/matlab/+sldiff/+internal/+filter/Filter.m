classdef Filter





    properties(GetAccess=public,SetAccess=immutable)
ID
    end

    methods
        function f=Filter(id)
            f.ID=id;
        end
    end
    enumeration
        Nonfunctional("sldiff.filter.nonfunctional")
        Lines("sldiff.filter.lines")
    end

end
