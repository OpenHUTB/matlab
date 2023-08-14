classdef CGInUse<handle




    properties
        slBuildIsInUse=false;
        libCodeGeninProgress=false;
    end

    methods
        function reset(obj)
            obj.slBuildIsInUse=false;
            obj.libCodeGeninProgress=false;
        end

    end

end

