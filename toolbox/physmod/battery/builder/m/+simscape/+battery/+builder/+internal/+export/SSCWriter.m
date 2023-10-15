classdef ( Abstract, Hidden, AllowedSubclasses = { ?simscape.battery.builder.internal.export.LumpedBatteryWriter,  ...
        ?simscape.battery.builder.internal.export.DetailedBatteryWriter, ?simscape.battery.builder.internal.export.GroupedBatteryWriter } ) ...
        SSCWriter


    properties
        CellBalancing string{ mustBeTextScalar, mustBeMember( CellBalancing, [ "", "Passive" ] ) } = ""
        ChildComponent string{ mustBeTextScalar( ChildComponent ) } = ""
        ChildComponentIdentifier string{ mustBeTextScalar( ChildComponentIdentifier ) } = "battery"
        ChildrenInSeries uint64{ mustBePositive, mustBeInteger } = 1;
        ChildrenInParallel uint64{ mustBePositive, mustBeInteger } = 1;
        ComponentName string{ mustBeTextScalar( ComponentName ) } = ""
        CompositeComponentName string{ mustBeTextScalar( CompositeComponentName ) } = ""
        CoolingPlateLocation string{ mustBeMember( CoolingPlateLocation, [ "", "Top", "Bottom" ] ) } = "";
        CoolantThermalPath string{ mustBeMember( CoolantThermalPath, [ "", "CellBasedThermalResistance" ] ) } = "";
        AmbientThermalPath string{ mustBeMember( AmbientThermalPath, [ "", "CellBasedThermalResistance" ] ) } = "";
        FilePath string{ mustBeTextScalar( FilePath ) } = ""
        ComponentDescription string{ mustBeTextScalar( ComponentDescription ) } = ""
        NonCellResistanceParameters( 1, 1 ){ mustBeA( NonCellResistanceParameters, "simscape.battery.builder.internal.export.ComponentParameters" ) } = simscape.battery.builder.internal.export.ComponentParameters(  );
        BatteryCompositeComponentParameters{ mustBeA( BatteryCompositeComponentParameters, "simscape.battery.builder.internal.export.CompositeComponentParameters" ) } = simscape.battery.builder.internal.export.CompositeComponentParameters;
        BatteryCompositeComponentInputs{ mustBeA( BatteryCompositeComponentInputs, "simscape.battery.builder.internal.export.ComponentInputs" ) } = simscape.battery.builder.internal.export.ComponentInputs;
        BatteryCompositeComponentVariables{ mustBeA( BatteryCompositeComponentVariables, "simscape.battery.builder.internal.export.CompositeComponentVariables" ) } = simscape.battery.builder.internal.export.CompositeComponentVariables.empty;
        ControlParameters( :, 2 )string{ mustBeText } = string.empty( 0, 2 );
        IconName{ mustBeTextScalar } = ""
    end

    properties ( Constant, Abstract, Access = protected )
        ModelResolution;
    end

    properties ( Access = protected )
        BatteryType string{ mustBeMember( BatteryType, [ "ParallelAssembly", "Module" ] ) }
    end

    properties ( Dependent, Access = protected )
        ScalingParameters
        ComponentParameters
        ComponentInputs
        ComponentVariables
        CellBalancingParameters
        CellBalancingInputs
    end

    properties ( Dependent, Abstract, Access = protected )
        CoolingPathResistanceParameters
        AmbientPathResistanceParameters
        ParallelAssemblyVariables
    end

    properties ( Dependent, Access = private )
        BatteryCountDescription
        FileDescription
    end

    properties ( Constant, Access = protected )
        NonCellResistanceIdentifier = "nonCellResistor";
        ResistanceParameters = [ "R0_mat", "R0_vec", "R0_dis_mat", "R0_dis_vec",  ...
            "R0_ch_mat", "R0_ch_vec", "R1_mat", "R1_vec", "R2_mat", "R2_vec", "R3_mat", "R3_vec",  ...
            "R4_mat", "R4_vec", "R5_mat", "R5_vec", "Rleak_vec", "Rleak" ];
        CapacityParameter = "AH";
        ThermalMassParameter = "thermal_mass";
        VoltageParameters = [ "V_range", "V0_vec", "V0_mat" ];
    end

    methods ( Abstract, Hidden )
        component = addChildComponent( obj, component );
        component = addConnection( obj, component );
        component = addCellBalancing( obj, component );
        component = addNonCellResistor( obj, component );
        component = addCompositeComponentVariables( obj, component );
        component = addCoolingPlateConnections( obj, component );
        component = addLumpedThermalPort( obj, component, portName, resistanceName, resistanceParameter );
        component = addParallelAssemblyVariables( obj, component );
        component = addScaledParameterAssertions( obj, component );
        component = addScaledParameters( obj, component );
    end

    methods ( Abstract, Access = protected )
        variableSizes = getVariableNumericalSize( obj )
        description = getResolutionDescription( obj )
    end

    methods
        function blockDetails = createComponent( obj )

            component = simscape.battery.internal.sscinterface.Component( obj.ComponentName, obj.FileDescription );

            component = obj.addChildComponent( component );
            component = obj.addNonCellResistor( component );
            component = obj.addNodes( component );
            component = obj.addConnection( component );
            component = obj.addCellBalancing( component );
            component = obj.addParameterSection( component );
            component = obj.addScaledParameters( component );
            component = obj.addScalingParameters( component );
            component = obj.addVariablesAssertions( component );
            component = obj.addScaledParameterAssertions( component );
            component = obj.addVariablesSection( component );
            component = obj.addParallelAssemblyVariables( component );
            component = obj.addCompositeComponentVariables( component );
            component = obj.addInputsSection( component );
            component = obj.addInputsConnections( component );
            component = obj.addAnnotationsSection( component );
            component = obj.addThermalOptions( component );
            component = obj.addIcon( component );


            component.writeToFile( fullfile( obj.FilePath, obj.ComponentName + ".ssc" ) );
            obj.copyIcon(  );


            packageName = obj.getPackageName;
            blockInputs = obj.ComponentInputs;
            blockParameters = obj.ComponentParameters;
            componentVariables = obj.ComponentVariables;
            blockDetails = simscape.battery.builder.internal.export.SimscapeBlock( obj.ComponentName, blockParameters, blockInputs, componentVariables, packageName );
        end

        function componentParameters = get.ComponentParameters( obj )

            componentParameters = obj.BatteryCompositeComponentParameters.getParentComponentParameters;
            componentParameters = componentParameters.mergeParameters( obj.NonCellResistanceParameters );
            componentParameters = componentParameters.mergeParameters( obj.CellBalancingParameters.getParentComponentParameters );
            componentParameters = componentParameters.mergeParameters( obj.CoolingPathResistanceParameters.getParentComponentParameters );
            componentParameters = componentParameters.mergeParameters( obj.AmbientPathResistanceParameters.getParentComponentParameters );
        end

        function componentVariables = get.ComponentVariables( obj )

            componentVariables = obj.BatteryCompositeComponentVariables.getParentComponentVariables(  );
            componentVariables = componentVariables.mergeVariables( obj.ParallelAssemblyVariables );
        end

        function cellBalancingParameters = get.CellBalancingParameters( obj )

            componentParameters = simscape.battery.builder.internal.export.ComponentParameters;
            switch obj.CellBalancing
                case "Passive"
                    ids = [ "R_closed", "G_open", "Threshold", "R" ];
                    labels = string( { getString( message( 'physmod:battery:builder:blocks:CellBalancingClosedResistance' ), matlab.internal.i18n.locale( 'en_US' ) ),  ...
                        getString( message( 'physmod:battery:builder:blocks:CellBalancingOpenConductance' ), matlab.internal.i18n.locale( 'en_US' ) ),  ...
                        getString( message( 'physmod:battery:builder:blocks:CellBalancingOperationThreshhold' ), matlab.internal.i18n.locale( 'en_US' ) ),  ...
                        getString( message( 'physmod:battery:builder:blocks:CellBalancingShuntResistance' ), matlab.internal.i18n.locale( 'en_US' ) ) } );
                    defaultValues = [ "0.01", "1e-8", "0.5", "50" ];
                    defaultUnit = [ "Ohm", "1/Ohm", "1", "Ohm" ];
                    group = repmat( "Cell Balancing", 4, 1 );
                    scaling = repmat( "1", size( ids ) );
                    componentParameters = componentParameters.addParameters( ids, labels, defaultValues, defaultUnit, group, scaling );
                    cellBalancingParameters = componentParameters.getDefaultCompositeComponentParameters;
                    cellBalancingParameters = cellBalancingParameters.setParameterSpecification( "R_closed", "Value", "CellBalancingClosedResistance" );
                    cellBalancingParameters = cellBalancingParameters.setParameterSpecification( "G_open", "Value", "CellBalancingOpenConductance" );
                    cellBalancingParameters = cellBalancingParameters.setParameterSpecification( "Threshold", "Value", "CellBalancingThreshold" );
                    cellBalancingParameters = cellBalancingParameters.setParameterSpecification( "R", "Value", "CellBalancingResistance" );

                otherwise
                    cellBalancingParameters = componentParameters.getDefaultCompositeComponentParameters;
            end
        end

        function componentInputs = get.ComponentInputs( obj )

            componentInputs = obj.BatteryCompositeComponentInputs.addDimensionScalingForInput( "enableCellBalancing", "S" );
            componentInputs = componentInputs.mergeInputs( obj.CellBalancingInputs );
        end

        function cellBalancingInputs = get.CellBalancingInputs( obj )

            cellBalancingInputs = simscape.battery.builder.internal.export.ComponentInputs(  );
            cellBalancingScaling = dictionary( [ simscape.battery.builder.ParallelAssembly.Type, simscape.battery.builder.Module.Type ],  ...
                [ "", "S" ] );
            switch obj.CellBalancing
                case "Passive"
                    ids = "enableCellBalancing";
                    labels = "CB";
                    defaultValues = "0";
                    defaultUnit = "1";
                    cellBalancingInputs = cellBalancingInputs.addInputs( ids, labels, defaultValues, defaultUnit );
                    cellBalancingInputs = cellBalancingInputs.addDimensionScalingForInput( "enableCellBalancing", cellBalancingScaling( obj.BatteryType ) );
                otherwise
            end
        end

        function scalingParameters = get.ScalingParameters( obj )

            pId = "P";
            pLabel = string( getString( message( 'physmod:battery:builder:blocks:BatteriesInParallel' ), matlab.internal.i18n.locale( 'en_US' ) ) );
            pDefaultValue = string( obj.ChildrenInParallel );
            pDefaultUnit = "1";
            pGroup = "Battery Layout";
            scalingParameters = simscape.battery.builder.internal.export.ComponentParameters;
            scalingParameters = scalingParameters.addParameters( pId, pLabel, pDefaultValue, pDefaultUnit, pGroup, "1" );

            switch obj.BatteryType
                case simscape.battery.builder.Module.Type
                    sId = "S";
                    sLabel = string( getString( message( 'physmod:battery:builder:blocks:BatteriesInSeries' ), matlab.internal.i18n.locale( 'en_US' ) ) );
                    sDefaultValue = string( obj.ChildrenInSeries );
                    sDefaultUnit = "1";
                    sGroup = "Battery Layout";
                    scalingParameters = scalingParameters.addParameters( sId, sLabel, sDefaultValue, sDefaultUnit, sGroup, "1" );
                otherwise
            end
        end

        function batteryCountDescription = get.BatteryCountDescription( obj )

            switch obj.BatteryType
                case simscape.battery.builder.ParallelAssembly.Type
                    batteryCountDescription = "   Number of cells: " + num2str( obj.ChildrenInParallel );
                otherwise

                    batteryCountDescription = "   Number of parallel assemblies: " + num2str( obj.ChildrenInSeries );
                    batteryCountDescription = batteryCountDescription.append( newline, "   Number of cells per parallel assembly: ", num2str( obj.ChildrenInParallel ) );
            end
        end

        function fileDescription = get.FileDescription( obj )

            tabString = sprintf( "   " );
            fileDescription = obj.ComponentName.append( ":2" );
            fileDescription = fileDescription.append( newline, obj.ComponentDescription );
            resolutionDescription = getString( message( "physmod:battery:builder:blocks:ModelResolutionComment", obj.ModelResolution ),  ...
                matlab.internal.i18n.locale( 'en_US' ) );
            fileDescription = fileDescription.append( newline, tabString, resolutionDescription );
            fileDescription = fileDescription.append( newline, obj.BatteryCountDescription );
            fileDescription = fileDescription.append( obj.getResolutionDescription );


            productLocations = [ "matlab", "toolbox/physmod/battery/library/m/simscapebattery" ];
            fileDescription = fileDescription.append( newline );
            for productIndex = 1:length( productLocations )
                verInfo = ver( productLocations( productIndex ) );
                if ~isempty( verInfo )
                    versionString = getString( message( "physmod:battery:builder:export:VersionInfo", verInfo.Name, verInfo.Version ),  ...
                        matlab.internal.i18n.locale( 'en_US' ) );
                    fileDescription = fileDescription.append( newline, tabString, versionString );
                end
            end


            date = string( datetime( "now" ), [  ], "en_US" );
            codeGeneratedOnInfo = getString( message( 'physmod:battery:builder:export:SimscapeCodeGeneratedOn', date ),  ...
                matlab.internal.i18n.locale( 'en_US' ) );
            fileDescription = fileDescription.append( newline, tabString, codeGeneratedOnInfo );
        end
    end

    methods ( Hidden )
        function component = addAnnotationsSection( obj, component )

            import simscape.battery.internal.sscinterface.*
            componentParameters = obj.ComponentParameters;
            uiGroups = unique( componentParameters.Groups, "stable" );
            uiLayout = UiLayout(  );
            numUiGroups = length( uiGroups );
            for groupIdx = 1:numUiGroups
                parametersInGroup = ( componentParameters.Groups == uiGroups( groupIdx ) );
                uiLayout = uiLayout.addUiGroup( uiGroups( groupIdx ), componentParameters.IDs( parametersInGroup ) );
            end

            if numUiGroups > 0
                annotationsSection = AnnotationsSection(  );
                annotationsSection = annotationsSection.addUiLayout( uiLayout );
                component = component.addSection( annotationsSection );
            else

            end
        end

        function component = addParameterSection( obj, component )

            parametersSection = simscape.battery.internal.sscinterface.ParametersSection(  );
            componentParameters = obj.ComponentParameters;

            for parameterIdx = 1:length( componentParameters.IDs )
                parametersSection = parametersSection.addParameter( componentParameters.IDs( parameterIdx ),  ...
                    componentParameters.DefaultValues( parameterIdx ),  ...
                    componentParameters.Labels( parameterIdx ), Unit = componentParameters.DefaultUnits( parameterIdx ) );
            end
            component = component.addSection( parametersSection );
        end

        function component = addScalingParameters( obj, component )

            parametersSection = simscape.battery.internal.sscinterface.ParametersSection( ExternalAccess = "none" );
            scalingParameters = obj.ScalingParameters;

            for parameterIdx = 1:length( scalingParameters.IDs )
                parametersSection = parametersSection.addParameter( scalingParameters.IDs( parameterIdx ),  ...
                    scalingParameters.DefaultValues( parameterIdx ),  ...
                    scalingParameters.Labels( parameterIdx ) );
            end
            component = component.addSection( parametersSection );
        end

        function component = addVariablesAssertions( obj, component )

            variables = obj.ComponentVariables;

            if ~isempty( variables.IDs )
                equationsSection = simscape.battery.internal.sscinterface.EquationsSection(  );
                for variableIndex = 1:length( obj.ComponentVariables.IDs )
                    parameterId = variables.IDs( variableIndex );
                    assertionCondition = "length(" + parameterId + ") == " + variables.DefaultValuesSize( variableIndex );

                    equationsSection = equationsSection.addAssertion( assertionCondition );
                end
                component = component.addSection( equationsSection );
            else

            end
        end

        function component = addInputsSection( obj, component )

            componentInputs = obj.ComponentInputs;
            if ~isempty( componentInputs.IDs )
                inputSection = simscape.battery.internal.sscinterface.InputsSection(  );
                for inputIndex = 1:length( componentInputs.IDs )
                    inputSection = inputSection.addInput( componentInputs.IDs( inputIndex ), componentInputs.DefaultValues( inputIndex ),  ...
                        Unit = componentInputs.DefaultUnits( inputIndex ), Label = componentInputs.Labels( inputIndex ) );
                end
                component = component.addSection( inputSection );
            else

            end
        end

        function component = addVariablesSection( obj, component )

            variablesSection = simscape.battery.internal.sscinterface.VariablesSection(  );
            variables = obj.ComponentVariables;
            variableDefaultValue = obj.variableDefaultValueString(  );
            for variableIdx = 1:length( variables.IDs )
                variablesSection = variablesSection.addVariable( variables.IDs( variableIdx ),  ...
                    variableDefaultValue( variableIdx ), variables.DefaultUnits( variableIdx ),  ...
                    variables.Labels( variableIdx ), priority = variables.DefaultPriorities( variableIdx ) );
            end
            component = component.addSection( variablesSection );
        end

        function component = addInputsConnections( obj, component )


            if ~isempty( obj.BatteryCompositeComponentInputs.IDs )
                scalingParameterMapping = dictionary( [ simscape.battery.builder.ParallelAssembly.Type, simscape.battery.builder.Module.Type ],  ...
                    [ "P", "S" ] );
                scalingParameter = scalingParameterMapping( obj.BatteryType );
                scalingIndex = scalingParameter + "idx";
                forLoop = simscape.battery.internal.sscinterface.ForLoop( scalingIndex, "1:" + scalingParameter );
                connectionsSection = simscape.battery.internal.sscinterface.ConnectionsSection(  );
                for inputIndex = 1:length( obj.BatteryCompositeComponentInputs.IDs )
                    inputId = obj.BatteryCompositeComponentInputs.IDs( inputIndex );
                    indexArgument = "(" + scalingIndex + ")";
                    connectionsSection = connectionsSection.addConnection( inputId.append( indexArgument ), obj.ChildComponentIdentifier.append( indexArgument, ".", inputId ) );
                end
                forLoop = forLoop.addSection( connectionsSection );
                component = component.addForLoop( forLoop );
            else

            end
        end

        function component = addIcon( obj, component )

            annotationsSection = simscape.battery.internal.sscinterface.AnnotationsSection(  );
            annotationsSection = annotationsSection.setIcon( obj.IconName );
            component = component.addSection( annotationsSection );
        end

        function component = addThermalOptions( obj, component )

            if obj.CoolingPlateLocation ~= ""

                component = obj.addCoolingPlateConnections( component );
            elseif obj.CoolantThermalPath == "CellBasedThermalResistance"

                component = obj.addLumpedThermalPort( component, "ClntH", "CH", "CoolantResistor",  ...
                    obj.CoolingPathResistanceParameters.Values );
            else

            end

            if obj.AmbientThermalPath ~= ""

                component = obj.addLumpedThermalPort( component, "AmbH", "AH", "AmbientResistor",  ...
                    obj.AmbientPathResistanceParameters.Values );
            else

            end
        end
    end

    methods ( Access = private )
        function packageName = getPackageName( obj )

            packageIdx = strfind( obj.FilePath, '+' );
            packagePath = obj.FilePath.extractAfter( packageIdx( 1 ) );
            packageName = packagePath.replace( filesep + "+", "." );
        end

        function copyIcon( obj )

            buildIcon = fullfile( obj.FilePath, obj.IconName );
            if ~isfile( buildIcon )
                internalIcon = fullfile( matlabroot, "toolbox", "physmod", "battery", "builder",  ...
                    "m", "+simscape", "+battery", "+builder", "+internal", "+export", "Icons", obj.IconName );
                copyfile( internalIcon, buildIcon );
            end
        end
    end

    methods ( Access = protected )
        function variableDefaultValue = variableDefaultValueString( obj )

            variablesCount = length( obj.ComponentVariables.IDs );
            variableDefaultValue = repmat( "", variablesCount, 1 );
            variablesSize = obj.getVariableNumericalSize(  );
            for variableIdx = 1:variablesCount
                defaultValue = obj.ComponentVariables.DefaultValues( variableIdx );
                switch variablesSize( variableIdx )
                    case "1"
                        variableDefaultValue( variableIdx ) = defaultValue;
                    otherwise
                        variableDefaultValue( variableIdx ) = "repmat(" + defaultValue + "," ...
                            + variablesSize( variableIdx ) + ",1)";
                end
            end
        end

        function componentsSection = getCellBalancingComponents( obj, componentIndex, resistanceFactor )

            import simscape.battery.internal.sscinterface.CompositeComponent

            componentsSection = simscape.battery.internal.sscinterface.ComponentsSection(  );

            switchResistanceId = "R_closed";
            switchResistanceIdx = obj.CellBalancingParameters.IDs == switchResistanceId;
            switchResistanceValue = obj.CellBalancingParameters.Values( switchResistanceIdx ) + resistanceFactor;
            switchArguments = [ switchResistanceId, switchResistanceValue ];

            switchIds = [ "G_open";"Threshold" ];
            swichArgumentsIdx = ismember( obj.CellBalancingParameters.IDs, switchIds );
            switchArguments = [ switchArguments;obj.CellBalancingParameters.IDs( swichArgumentsIdx ), obj.CellBalancingParameters.Values( swichArgumentsIdx ) ];
            switchCompositeComponent = CompositeComponent( "balancingSwitch" + componentIndex, "foundation.electrical.elements.controlled_switch",  ...
                Parameters = switchArguments );


            resistorId = "R";
            resistorArgumentIdx = ismember( obj.CellBalancingParameters.IDs, resistorId );
            componentsSection = componentsSection.addComponent( switchCompositeComponent );
            resistorArguments = [ obj.CellBalancingParameters.IDs( resistorArgumentIdx ), obj.CellBalancingParameters.Values( resistorArgumentIdx ) + resistanceFactor ];
            resistorCompositeComponent = CompositeComponent( "balancingResistor" + componentIndex, "foundation.electrical.elements.resistor", Parameters = resistorArguments );
            componentsSection = componentsSection.addComponent( resistorCompositeComponent );
        end

        function connectionsSection = getCellBalancingConnections( obj, enableIndex, options )

            arguments
                obj
                enableIndex
                options.BalancingComponentsIndex = "";
                options.ChildBatteryIndex = "";
            end
            connectionsSection = simscape.battery.internal.sscinterface.ConnectionsSection(  );
            connectionsSection = connectionsSection.addConnection( obj.ChildComponentIdentifier.append( options.ChildBatteryIndex, ".p" ), "balancingSwitch" + options.BalancingComponentsIndex + ".p" );
            connectionsSection = connectionsSection.addConnection( "balancingSwitch" + options.BalancingComponentsIndex + ".n",  ...
                "balancingResistor" + options.BalancingComponentsIndex + ".p" );
            connectionsSection = connectionsSection.addConnection( "balancingResistor" + options.BalancingComponentsIndex + ".n",  ...
                obj.ChildComponentIdentifier.append( options.ChildBatteryIndex, ".n" ) );
            connectionsSection = connectionsSection.addConnection( obj.CellBalancingInputs.IDs + enableIndex,  ...
                "balancingSwitch" + options.BalancingComponentsIndex + ".vT" );
        end
    end

    methods ( Static )
        function component = addNodes( component )

            import simscape.battery.internal.sscinterface.*
            nodesSection = NodesSection;
            nodesSection = nodesSection.addNode( 'p', 'foundation.electrical.electrical', Label = "+" );
            nodesSection = nodesSection.addNode( 'n', 'foundation.electrical.electrical', Label = "-" );
            component = component.addSection( nodesSection );

            annotationsSection = AnnotationsSection(  );
            annotationsSection = annotationsSection.addPortLocation( "p", "top" );
            annotationsSection = annotationsSection.addPortLocation( "n", "bottom" );
            component = component.addSection( annotationsSection );
        end
    end
end



