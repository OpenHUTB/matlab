classdef ( Abstract )DataAdapter

    properties ( Access = protected )
        dataWrapper
    end

    properties ( Constant )
        DEFAULT = string.empty;
    end

    methods
        function obj = DataAdapter( dataSource )
            arguments
                dataSource( 1, 1 )compiler.internal.deployScriptData.Data
            end
            obj.dataWrapper = dataSource;
        end
    end

    methods ( Abstract )
        value = getOptionValue( obj, option )
    end
end


