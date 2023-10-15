classdef SingleParameterSpace < simulink.multisim.internal.sampler.ParameterSpaceSampler
    properties ( Access = private )
        Values
    end

    methods
        function obj = SingleParameterSpace( parameterSpace )
            arguments
                parameterSpace( 1, 1 )simulink.multisim.mm.design.SingleParameterSpace
            end

            import simulink.multisim.mm.design.*

            obj = obj@simulink.multisim.internal.sampler.ParameterSpaceSampler( parameterSpace );

            values = parameterSpace.Values;
            switch parameterSpace.ValueType
                case ParameterValueType.List
                    items = values.Items.toArray(  );
                    selectedItems = items( [ items.Selected ] );
                    obj.Values = string( { selectedItems.Label } );

                case ParameterValueType.Explicit
                    if isempty( values.ExpressionString )
                        obj.Values = [  ];
                    else
                        try
                            obj.Values = evalin( "base", values.ExpressionString );
                        catch
                            error( message( "multisim:SetupGUI:InvalidSingleParameterValue", parameterSpace.Label ) );
                        end
                    end
            end
        end

        function numDesignPoints = getNumDesignPoints( obj )
            if matlab.internal.datatypes.isScalarText( obj.Values )
                numDesignPoints = 1;
            else
                numDesignPoints = numel( obj.Values );
            end

            if numDesignPoints == 0
                error( message( "multisim:SetupGUI:EmptySingleParameterSpace", obj.ParameterSpace.Label ) );
            end
        end

        function designPoints = createDesignPoints( obj )
            numDesignPoints = obj.getNumDesignPoints(  );

            designPoints( 1:numDesignPoints ) = simulink.multisim.internal.DesignPoint;

            for valueIdx = 1:numDesignPoints
                paramValue = obj.getValueAtIndex( valueIdx );
                paramSample = simulink.multisim.internal.ParameterSample( obj.ParameterSpace.Type,  ...
                    paramValue );
                designPoints( valueIdx ).ParameterSamples = paramSample;
            end
        end

        function designPoint = createDesignPointAtIndex( obj, index )
            designPoint = simulink.multisim.internal.DesignPoint;
            paramValue = obj.getValueAtIndex( index );
            paramSample = simulink.multisim.internal.ParameterSample( obj.ParameterSpace.Type,  ...
                paramValue );
            designPoint.ParameterSamples = paramSample;
        end
    end

    methods ( Access = private )
        function value = getValueAtIndex( obj, index )
            if matlab.internal.datatypes.isScalarText( obj.Values )
                value = obj.Values;
            elseif iscell( obj.Values )
                value = obj.Values{ index };
            else
                value = obj.Values( index );
            end
        end
    end
end

