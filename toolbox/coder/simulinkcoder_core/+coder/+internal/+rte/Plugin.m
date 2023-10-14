classdef Plugin < handle

    properties ( GetAccess = public, SetAccess = private )
        Name
        Type
        Function
    end

    methods
        function this = Plugin( name, type, func )
            arguments
                name( 1, 1 )coder.internal.rte.PluginName
                type( 1, 1 )coder.internal.rte.PluginType
                func( 1, 1 )function_handle
            end
            this.Name = name;
            this.Type = type;
            this.Function = func;
        end
    end

end


