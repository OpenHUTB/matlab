classdef NodeData

    properties ( Dependent, SetAccess = private )
        Text( 1, 1 )string
        Icon( 1, 1 )string
    end

    properties ( SetAccess = immutable, GetAccess = private )
        Data( 1, 2 )cell
    end

    methods
        function obj = NodeData( args )
            arguments
                args.Text( 1, 1 )string = ""
                args.Icon( 1, 1 )string = ""
            end
            obj.Data = { args.Text, args.Icon };
        end
        function out = get.Text( obj )
            out = obj.Data{ 1 };
        end
        function out = get.Icon( obj )
            out = obj.Data{ 2 };
        end
    end
end
