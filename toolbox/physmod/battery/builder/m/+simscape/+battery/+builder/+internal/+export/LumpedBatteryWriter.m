classdef ( Sealed = true, Hidden = true )LumpedBatteryWriter < simscape.battery.builder.internal.export.SSCWriter




    properties ( Dependent, Access = protected )
        CoolingPathResistanceParameters
        AmbientPathResistanceParameters
        ParallelAssemblyVariables
    end

    properties ( Constant, Access = protected )
        ModelResolution = getString( message( "physmod:battery:builder:blocks:ModelResolutionLumped" ),  ...
            matlab.internal.i18n.locale( 'en_US' ) );
    end

    methods
        function obj = LumpedBatteryWriter( batteryType )

            arguments
                batteryType string{ mustBeMember( batteryType, [ "Module", "ParallelAssembly" ] ) }
            end
            obj.BatteryType = batteryType;
        end

        function resistanceParameters = get.CoolingPathResistanceParameters( obj )

            childComponentParams = simscape.battery.builder.internal.export.ComponentParameters;
            if obj.CoolantThermalPath ~= ""
                id = "CoolantResistance";
                label = string( getString( message( 'physmod:battery:builder:blocks:CoolantResistance' ), matlab.internal.i18n.locale( 'en_US' ) ) );
                defaultValue = "1.2";
                defaultUnit = "K/W";
                group = "Thermal";
                childComponentParams = childComponentParams.addParameters( id, label, defaultValue, defaultUnit, group, "1" );
            else

            end
            resistanceParameters = childComponentParams.getDefaultCompositeComponentParameters(  );
        end

        function resistanceParameters = get.AmbientPathResistanceParameters( obj )

            childComponentParams = simscape.battery.builder.internal.export.ComponentParameters;
            if obj.AmbientThermalPath ~= ""
                id = "AmbientResistance";
                label = string( getString( message( 'physmod:battery:builder:blocks:AmbientThermalPathResistance' ), matlab.internal.i18n.locale( 'en_US' ) ) );
                defaultValue = "25";
                defaultUnit = "K/W";
                group = "Thermal";
                childComponentParams = childComponentParams.addParameters( id, label, defaultValue, defaultUnit, group, "1" );
            else

            end
            resistanceParameters = childComponentParams.getDefaultCompositeComponentParameters(  );
        end

        function variables = get.ParallelAssemblyVariables( obj )


            variables = simscape.battery.builder.internal.export.ComponentVariables(  );
            switch obj.BatteryType
                case simscape.battery.builder.ParallelAssembly.Type
                    variableScaling = "1";
                otherwise
                    variableScaling = "S";
            end
            voltageDescription = getString( message( 'physmod:battery:builder:blocks:ParallelAssemblyVoltage' ), matlab.internal.i18n.locale( 'en_US' ) );
            variables = variables.addVariables( "vParallelAssembly", voltageDescription, "0", variableScaling, "V", "priority.none" );
            socDescription = getString( message( 'physmod:battery:builder:blocks:ParallelAssemblySOC' ), matlab.internal.i18n.locale( 'en_US' ) );
            variables = variables.addVariables( "socParallelAssembly", socDescription, "1", variableScaling, "1", "priority.none" );
        end
    end

    methods ( Hidden )
        function component = addChildComponent( obj, component )



            lumpingFactors = obj.getParameterLumpingFactors(  );


            componentsSection = simscape.battery.internal.sscinterface.ComponentsSection(  );
            compositeComponentParameters = [ obj.BatteryCompositeComponentParameters.IDs, obj.BatteryCompositeComponentParameters.Values + lumpingFactors;obj.ControlParameters ];
            variableCount = length( obj.BatteryCompositeComponentVariables.IDs );
            variablePriority = [ obj.BatteryCompositeComponentVariables.IDs, repmat( "priority.none", variableCount, 1 ) ];
            compositeComponent = simscape.battery.internal.sscinterface.CompositeComponent( obj.ChildComponentIdentifier, obj.ChildComponent,  ...
                Parameters = compositeComponentParameters, VariablePriority = variablePriority );
            componentsSection = componentsSection.addComponent( compositeComponent );

            component = component.addSection( componentsSection );
        end

        function component = addCompositeComponentVariables( obj, component )

            if ~isempty( obj.BatteryCompositeComponentVariables.IDs )

                variableAssignment = simscape.battery.internal.sscinterface.EquationsSection(  );
                compositeComponentVariables = obj.BatteryCompositeComponentVariables.IDs;

                for variableIdx = 1:length( compositeComponentVariables )
                    variableAssignment = variableAssignment.addEquation( obj.ChildComponentIdentifier.append( ".", compositeComponentVariables( variableIdx ) ),  ...
                        obj.BatteryCompositeComponentVariables.Values( variableIdx ) );
                end
                component = component.addSection( variableAssignment );



                variables = obj.ComponentVariables;
                [ uniqueVariableSize, ~, variableSizeMapping ] = unique( variables.DefaultValuesSize );
                nonScalarVariablesIdx = ~( uniqueVariableSize == "1" );
                loopingParameter = "CellIdx";
                for currentVariableSizeIdx = find( nonScalarVariablesIdx )'
                    variablesIdx = variableSizeMapping == currentVariableSizeIdx;
                    forLoop = simscape.battery.internal.sscinterface.ForLoop( loopingParameter, "2:" + uniqueVariableSize( currentVariableSizeIdx ) );
                    equationsSection = simscape.battery.internal.sscinterface.EquationsSection(  );
                    for variableIdx = find( variablesIdx )'
                        equationsSection = equationsSection.addEquation( variables.IDs( variableIdx ).append( "(1)" ),  ...
                            variables.IDs( variableIdx ).append( "(CellIdx)" ) );
                    end
                    forLoop = forLoop.addSection( equationsSection );
                    component = component.addForLoop( forLoop );
                end
            else

            end
        end

        function component = addNonCellResistor( obj, component )


            if ~isempty( obj.NonCellResistanceParameters.IDs )
                switch obj.NonCellResistanceParameters.IDs
                    case "NonCellResistanceParallelAssembly"
                        scalingFactor = "*S";
                    otherwise
                        scalingFactor = "";
                end
                componentsSection = simscape.battery.internal.sscinterface.ComponentsSection(  );
                resistanceValue = obj.NonCellResistanceParameters.IDs;
                nonCellResistor = simscape.battery.internal.sscinterface.CompositeComponent( obj.NonCellResistanceIdentifier, "foundation.electrical.elements.resistor", Parameters = [ "R", resistanceValue.append( scalingFactor ) ] );
                componentsSection = componentsSection.addComponent( nonCellResistor );
                component = component.addSection( componentsSection );
            else

            end
        end

        function component = addConnection( obj, component )

            connectionsSection = simscape.battery.internal.sscinterface.ConnectionsSection;
            if ~isempty( obj.NonCellResistanceParameters.IDs )
                connectionsSection = connectionsSection.addConnection( "p", obj.NonCellResistanceIdentifier.append( ".p" ) );
                connectionsSection = connectionsSection.addConnection( obj.NonCellResistanceIdentifier.append( ".n" ), obj.ChildComponentIdentifier.append( ".p" ) );
            else
                connectionsSection = connectionsSection.addConnection( "p", obj.ChildComponentIdentifier.append( ".p" ) );
            end
            connectionsSection = connectionsSection.addConnection( "n", obj.ChildComponentIdentifier.append( ".n" ) );
            component = component.addSection( connectionsSection );
        end

        function component = addCoolingPlateConnections( obj, component )

            import simscape.battery.internal.sscinterface.*
            coolingPlateId = obj.CoolingPlateLocation;
            coolingPlatePort = repmat( "", size( coolingPlateId ) );
            if obj.CoolantThermalPath == "CellBasedThermalResistance"

                componentsSection = ComponentsSection;
                connectionsSection = ConnectionsSection;
                for coolingPlateIdx = 1:length( coolingPlateId )

                    memberComponentName = "CoolantResistance" + coolingPlateId( coolingPlateIdx );

                    switch obj.BatteryType
                        case simscape.battery.builder.Module.Type
                            resistanceValue = obj.CoolingPathResistanceParameters.IDs.append( "/(", obj.getThermalLumpingFactor, ")" );
                        otherwise
                            resistanceValue = obj.CoolingPathResistanceParameters.IDs.append( "/", obj.getThermalLumpingFactor );
                    end

                    memberParameters = [ "resistance", resistanceValue ];
                    compositeComponent = CompositeComponent( memberComponentName, "foundation.thermal.elements.resistance", "Parameters", memberParameters );
                    componentsSection = componentsSection.addComponent( compositeComponent );


                    connectionsSection = connectionsSection.addConnection( obj.ChildComponentIdentifier.append( ".H" ), memberComponentName.append( ".A" ) );

                    coolingPlatePort( coolingPlateIdx ) = memberComponentName.append( ".B" );
                end

                component = component.addSection( componentsSection );
                component = component.addSection( connectionsSection );
            else

                coolingPlatePort( : ) = obj.ChildComponentIdentifier.append( ".H" );
            end

            nodesSection = NodesSection(  );
            connectionsSection = ConnectionsSection(  );
            annotationsSection = AnnotationsSection;

            for coolingPlateIdx = 1:length( coolingPlateId )

                nodeName = coolingPlateId( coolingPlateIdx ).append( "ExtClnt" );
                nodeLabel = "CP" + coolingPlateId( coolingPlateIdx ).extract( 1 );
                nodesSection = nodesSection.addNode( nodeName, "foundation.thermal.thermal", Label = nodeLabel );
                annotationsSection = annotationsSection.addPortLocation( nodeName, lower( coolingPlateId( coolingPlateIdx ) ) );


                connectionsSection = connectionsSection.addConnection( nodeName, coolingPlatePort( coolingPlateIdx ) );
            end

            component = component.addSection( nodesSection );
            component = component.addSection( connectionsSection );
            component = component.addSection( annotationsSection );
        end

        function component = addLumpedThermalPort( obj, component, portName, portLabel, resistanceName, resistanceParameter )

            import simscape.battery.internal.sscinterface.*


            nodesSection = NodesSection(  );
            nodesSection = nodesSection.addNode( portName, "foundation.thermal.thermal", Label = portLabel );
            component = component.addSection( nodesSection );


            componentsSection = ComponentsSection;
            switch obj.BatteryType
                case simscape.battery.builder.Module.Type
                    resistanceValue = resistanceParameter.append( "/(", obj.getThermalLumpingFactor, ")" );
                otherwise
                    resistanceValue = resistanceParameter.append( "/", obj.getThermalLumpingFactor );
            end
            memberParameters = [ "resistance", resistanceValue ];
            compositeComponent = CompositeComponent( resistanceName, "foundation.thermal.elements.resistance", Parameters = memberParameters );
            componentsSection = componentsSection.addComponent( compositeComponent );
            component = component.addSection( componentsSection );


            connectionsSection = ConnectionsSection;
            connectionsSection = connectionsSection.addConnection( obj.ChildComponentIdentifier.append( ".H" ), resistanceName.append( ".A" ) );
            connectionsSection = connectionsSection.addConnection( resistanceName.append( ".B" ), portName );
            component = component.addSection( connectionsSection );
        end

        function component = addParallelAssemblyVariables( obj, component )

            equationsSection = simscape.battery.internal.sscinterface.EquationsSection;

            switch obj.BatteryType
                case simscape.battery.builder.Module.Type
                    variableIndex = "(1)";
                    lumpingFactor = "/S";
                otherwise
                    variableIndex = "";
                    lumpingFactor = "";
            end
            equationsSection = equationsSection.addEquation( "vParallelAssembly" + variableIndex, obj.ChildComponentIdentifier.append( ".v", lumpingFactor ) );
            equationsSection = equationsSection.addEquation( "socParallelAssembly" + variableIndex, obj.ChildComponentIdentifier.append( ".stateOfCharge" ) );
            component = component.addSection( equationsSection );
        end

        function component = addCellBalancing( obj, component )

            switch obj.CellBalancing
                case "Passive"
                    resistanceFactor = dictionary( [ simscape.battery.builder.ParallelAssembly.Type, simscape.battery.builder.Module.Type ],  ...
                        [ "", "*S" ] );
                    balancingComponents = obj.getCellBalancingComponents( "", resistanceFactor( obj.BatteryType ) );
                    enableIndex = dictionary( [ simscape.battery.builder.ParallelAssembly.Type, simscape.battery.builder.Module.Type ],  ...
                        [ "", "(1)" ] );
                    balancingConnections = obj.getCellBalancingConnections( enableIndex( obj.BatteryType ) );
                    component = component.addSection( balancingComponents );
                    component = component.addSection( balancingConnections );
                otherwise
            end
        end

        function component = addScaledParameters( ~, component )

        end

        function component = addScaledParameterAssertions( ~, component )

        end
    end

    methods ( Access = private )
        function lumpingFactors = getParameterLumpingFactors( obj )


            lumpingFactors = repmat( "", size( obj.BatteryCompositeComponentParameters.IDs ) );


            resistanceParameterIdx = ismember( obj.BatteryCompositeComponentParameters.IDs, obj.ResistanceParameters );
            lumpingFactors( resistanceParameterIdx ) = obj.getResistanceLumpingFactor;


            capacityParameterIdx = ismember( obj.BatteryCompositeComponentParameters.IDs, obj.CapacityParameter );
            lumpingFactors( capacityParameterIdx ) = "*P";


            thermalMassIdx = ismember( obj.BatteryCompositeComponentParameters.IDs, obj.ThermalMassParameter );
            lumpingFactors( thermalMassIdx ) = "*" + obj.getThermalLumpingFactor;


            voltageIndex = ismember( obj.BatteryCompositeComponentParameters.IDs, obj.VoltageParameters );
            lumpingFactors( voltageIndex ) = obj.getVoltageLumpingFactor;
        end

        function voltageLumpingFactor = getVoltageLumpingFactor( obj )

            switch obj.BatteryType
                case simscape.battery.builder.Module.Type
                    voltageLumpingFactor = "*S";
                otherwise
                    voltageLumpingFactor = "";
            end
        end

        function resistanceLumpingFactor = getResistanceLumpingFactor( obj )

            switch obj.BatteryType
                case simscape.battery.builder.Module.Type
                    resistanceLumpingFactor = "*S/P";
                otherwise
                    resistanceLumpingFactor = "*1/P";
            end
        end

        function thermalLumpingFactor = getThermalLumpingFactor( obj )

            switch obj.BatteryType
                case simscape.battery.builder.Module.Type
                    thermalLumpingFactor = "S*P";
                otherwise
                    thermalLumpingFactor = "P";
            end
        end
    end

    methods ( Access = protected )
        function numericalSizes = getVariableNumericalSize( obj )

            sizeMapping = dictionary( [ "1", "S" ],  ...
                [ "1", string( obj.ChildrenInSeries ) ] );
            numericalSizes = sizeMapping( obj.ComponentVariables.DefaultValuesSize );
        end

        function description = getResolutionDescription( ~ )



            description = "";
        end
    end
end


