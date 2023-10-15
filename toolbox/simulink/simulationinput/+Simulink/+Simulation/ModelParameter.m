



















classdef ModelParameter
    properties ( SetAccess = private, GetAccess = public )
        Name
    end

    properties ( SetAccess = public, GetAccess = public )
        Value
    end

    properties ( SetAccess = private, GetAccess = public, Hidden = true )
        IsReadOnly = false
    end

    properties ( Constant, Access = private )
        ModelParameterHelper = getSimulationInputModelParameterHelper(  )
    end

    methods
        function obj = ModelParameter( name, value )
            if ~isvarname( name )
                throw( MException( message( 'Simulink:Commands:ParamUnknown', 'block_diagram', name ) ) );
            end
            obj.Name = name;
            obj.Value = value;
            obj.IsReadOnly = obj.ModelParameterHelper.isReadOnly( name );
        end

        function validate( obj, slObj )
            arguments
                obj( 1, 1 )Simulink.Simulation.ModelParameter
                slObj( 1, 1 )double = 0
            end

            obj.ModelParameterHelper.validateParam( obj.Name, slObj );
        end

        function T = table( obj )
            T = table;
            for i = 1:numel( obj )
                value = Simulink.Simulation.internal.varValue2str( obj( i ).Value );
                T = [ T;{ i, obj( i ).Name, value } ];
            end
            T.Properties.VariableNames = [ "Index", "Name", "Value" ];


            T.Name = categorical( T.Name );
            T.Value = categorical( T.Value );
        end
    end
end

