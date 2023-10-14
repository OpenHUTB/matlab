classdef CompositeComponentVariables

    properties ( Access = private, Constant )
        cellVariableNamesMapping = dictionary( [ "i", "v", "stateOfCharge", "num_cycles", "cell_temperature" ],  ...
            [ "iCellModel", "vCellModel", "socCellModel", "numCyclesCellModel", "temperatureCellModel" ] );
    end

    properties ( Access = private )
        Variables = table( string.empty( 0, 1 ), string.empty( 0, 1 ), string.empty( 0, 1 ), string.empty( 0, 1 ), string.empty( 0, 1 ), string.empty( 0, 1 ), string.empty( 0, 1 ) ...
            , 'VariableNames', [ "Value", "ID", "Label", "DefaultValue", "DefaultValueSize", "DefaultUnit", "DefaultPriority" ] );
    end

    properties ( Dependent )
        Values
        IDs
        Labels
        DefaultValues
        DefaultValuesSize
        DefaultUnits
        DefaultPriorities
    end

    methods
        function obj = CompositeComponentVariables( componentVariables, factor )

            arguments
                componentVariables{ mustBeScalarOrEmpty, mustBeA( componentVariables, "simscape.battery.builder.internal.export.ComponentVariables" ) }
                factor{ mustBeTextScalar, mustBeMember( factor, [ "1", "S", "P", "CellCount", "TotalNumModels" ] ) }
            end


            ids = componentVariables.IDs;
            labels = componentVariables.Labels;
            isCellVariable = ismember( ids, obj.cellVariableNamesMapping.keys );
            ids( isCellVariable ) = obj.cellVariableNamesMapping( ids( isCellVariable ) );
            labels( isCellVariable ) = "Cell model " + lower( labels( isCellVariable ).extractBefore( 2 ) ) + labels( isCellVariable ).extractAfter( 1 );


            currentVariablesSize = componentVariables.DefaultValuesSize;
            updatedVariableSize = repmat( "", size( currentVariablesSize ) );
            for variableIdx = 1:length( componentVariables.IDs )
                switch currentVariablesSize( variableIdx )
                    case "1"
                        updatedVariableSize( variableIdx ) = factor;
                    otherwise
                        updatedVariableSize( variableIdx ) = currentVariablesSize( variableIdx ) + "*" + factor;
                end
            end


            updatedVariableSize = strrep( updatedVariableSize, "P*S", "CellCount" );

            obj.Variables = table( ids, componentVariables.IDs, labels, componentVariables.DefaultValues, updatedVariableSize, componentVariables.DefaultUnits,  ...
                componentVariables.DefaultPriorities, 'VariableNames', [ "Value", "ID", "Label", "DefaultValue", "DefaultValueSize", "DefaultUnit", "DefaultPriority" ] );
        end

        function componentVariables = getParentComponentVariables( obj )

            componentVariables = simscape.battery.builder.internal.export.ComponentVariables;
            componentVariables = componentVariables.addVariables( obj.Values,  ...
                obj.Labels, obj.DefaultValues, obj.DefaultValuesSize, obj.DefaultUnits, obj.DefaultPriorities );
        end
        function values = get.Values( obj )

            values = obj.Variables.Value;
        end

        function ids = get.IDs( obj )

            ids = obj.Variables.ID;
        end

        function labels = get.Labels( obj )

            labels = obj.Variables.Label;
        end

        function defaultValues = get.DefaultValues( obj )

            defaultValues = obj.Variables.DefaultValue;
        end

        function defaultValuesSize = get.DefaultValuesSize( obj )

            defaultValuesSize = obj.Variables.DefaultValueSize;
        end

        function defaultUnits = get.DefaultUnits( obj )

            defaultUnits = obj.Variables.DefaultUnit;
        end

        function defaultPriorities = get.DefaultPriorities( obj )

            defaultPriorities = obj.Variables.DefaultPriority;
        end
    end
end

