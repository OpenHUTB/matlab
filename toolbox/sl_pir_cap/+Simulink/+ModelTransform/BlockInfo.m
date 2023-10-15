classdef BlockInfo
    properties
        Path
    end

    methods
        function obj = BlockInfo( path )
            arguments
                path
            end
            obj.Path = path;
        end
    end
end

