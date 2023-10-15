classdef PackCreator < simscape.battery.builder.internal.export.BatteryTypeCreator





    properties


        Pack( 1, 1 )simscape.battery.builder.Pack


        FilePath( 1, 1 ){ mustBeTextScalar( FilePath ) } = ""


        IsHighestLevel( 1, 1 )logical{ mustBeA( IsHighestLevel, "logical" ) }

        BlockDatabase( 1, 1 ){ mustBeA( BlockDatabase, "simscape.battery.builder.internal.export.BlockDatabase" ) } ...
            = simscape.battery.builder.internal.export.BlockDatabase(  );

        LibraryName( 1, 1 )string = "Batteries"
    end

    properties ( Constant )


        DiagramStartXLocation = 100;


        DiagramStartYLocation = 100;

        LabelBlockWidth = 80;

        LabelBlockHeight = 30;


        ConnLabelBlockWidth = 40;


        ConnLabelBlockHeight = 20;
        MuxBlockWidth = 5;


        XOffsetFromArea = 40;


        YOffsetFromArea = 40;

        SelectorBlockWidth = 40;

        SelectorBlockHeight = 40;

        ResistorBlockWidth = 35;

        ResistorBlockHeight = 20;
    end

    properties ( Dependent )
        PackBlockWidth
        PackBlockHeight
        MuxBlockHeight
        ModuleAssemblyBlockWidth
        ModuleAssemblyBlockHeight
        AreaSectionStartXLocation
        AreaSectionEndXLocation
        InterModuleAssemblySpacingFactor
    end

    properties ( SetAccess = private )
        BatterySectionStartYLocation
        BatterySectionEndYLocation
        SignalSectionStartYLocation
        SignalSectionEndYLocation
        ThermalSectionStartYLocation
        ThermalSectionEndYLocation
        BalancingSectionStartYLocation
        BalancingSectionEndYLocation
        ThirdSectionStartYLocation
        ThirdSectionEndYLocation
        FourthSectionStartYLocation
        FourthSectionEndYLocation
        ClntHConnID
        AmbHConnID
        OutputSignals
    end

    methods
        function obj = PackCreator( pack, filePath, isHighestLevel, blockDatabase, libraryName )
            arguments
                pack( 1, 1 )simscape.battery.builder.Pack
                filePath( 1, 1 ){ mustBeTextScalar( filePath ) }
                isHighestLevel( 1, 1 )logical{ mustBeA( isHighestLevel, "logical" ) }
                blockDatabase( 1, 1 ){ mustBeA( blockDatabase, "simscape.battery.builder.internal.export.BlockDatabase" ) }
                libraryName( 1, 1 )string
            end
            obj.Pack = pack;
            obj.FilePath = filePath;
            obj.IsHighestLevel = isHighestLevel;
            obj.BlockDatabase = blockDatabase;
            obj.LibraryName = libraryName;
        end

        function obj = setOutputSignalNames( obj, childComponent )
            moduleAssemblyIdentifier = strcat( obj.LibraryName, "/ModuleAssemblies/", childComponent( 1 ).ModuleAssemblyBlocks.Identifier );
            if strcmp( obj.Pack.NonCellResistance, "Yes" )
                [ ~, name, ~ ] = fileparts( ( [ find_system( moduleAssemblyIdentifier, 'LookUnderMasks', 'on', 'FollowLinks', 'on', 'SearchDepth', 1, 'BlockType', 'Outport' ) ] ) );
            else
                [ ~, name, ~ ] = fileparts( ( [ find_system( moduleAssemblyIdentifier, 'BlockType', 'Outport' ) ] ) );
            end
            obj.OutputSignals = sortrows( name );
        end

        function blockDetails = createBlock( obj )



            blockDetails = simscape.battery.builder.internal.export.SimulinkBlock( obj.Pack.BlockType, [  ], obj.FilePath );
            blockDetails = blockDetails.setBatteryType( simscape.battery.builder.Pack.Type );

            childComponent = obj.getChildBlock( obj.Pack, obj.BlockDatabase );

            systemName = obj.LibraryName;
            subsystemName = obj.Pack.Name;
            packBlockName = strcat( systemName, '/', subsystemName );

            load_system( systemName );
            set_param( systemName, 'Lock', 'off' );

            obj = obj.setOutputSignalNames( childComponent );

            copyFcnText = "battery_builder_rtmsupport('copyfcn',gcbh);";
            preCopyFcnText = "battery_builder_rtmsupport('precopyfcn',gcbh);";
            preDeleteFcnText = "battery_builder_rtmsupport('predeletefcn',gcbh);";
            loadFcnText = "battery_builder_rtmsupport('loadfcn',gcbh);";

            add_block( 'built-in/Subsystem', packBlockName );
            set_param( packBlockName, 'position',  ...
                [ obj.DiagramStartXLocation,  ...
                obj.DiagramStartYLocation,  ...
                obj.DiagramStartXLocation + obj.PackBlockWidth,  ...
                obj.DiagramStartYLocation + obj.PackBlockHeight ],  ...
                "Orientation", "down", "NameLocation", "bottom",  ...
                'CopyFcn', copyFcnText,  ...
                'PreDeleteFcn', preDeleteFcnText,  ...
                'LoadFcn', loadFcnText,  ...
                'PreCopyFcn', preCopyFcnText );

            obj = obj.setAreaLocations(  );

            for moduleAssemblyIdx = 1:obj.Pack.TotNumModuleAssemblies
                currentBlockName = strcat( packBlockName, '/', obj.Pack.ModuleAssembly( moduleAssemblyIdx ).Name );
                add_block( strcat( obj.LibraryName, "/ModuleAssemblies/", childComponent( moduleAssemblyIdx ).ModuleAssemblyBlocks.Identifier ) ...
                    , currentBlockName );
                set_param( currentBlockName, 'position',  ...
                    [ obj.DiagramStartXLocation + obj.InterModuleAssemblySpacingFactor * moduleAssemblyIdx,  ...
                    obj.DiagramStartYLocation,  ...
                    obj.DiagramStartXLocation + obj.ModuleAssemblyBlockWidth + obj.InterModuleAssemblySpacingFactor * moduleAssemblyIdx,  ...
                    obj.DiagramStartYLocation + obj.ModuleAssemblyBlockHeight ],  ...
                    "Orientation", "down", "NameLocation", "bottom" );
            end
            obj = setConnectorIDs( obj );
            obj = obj.addMainConnectors( packBlockName );
            obj = obj.addSignalRouting( packBlockName );
            obj = obj.addAmbientPath( packBlockName );
            obj = obj.addCoolantPath( packBlockName );
            obj = obj.addBalancingSignalRouting( packBlockName );
            obj = obj.updatePackSubsystemApperance( packBlockName );
            obj = obj.addPackAreas( packBlockName );
            obj = obj.createPackMask( packBlockName );
            set_param( systemName, 'Lock', 'on' );
            save_system( obj.LibraryName );
            close_system( obj.LibraryName );
        end


        function value = get.PackBlockWidth( obj )
            value = length( obj.OutputSignals ) * ( obj.LabelBlockHeight );
        end

        function value = get.PackBlockHeight( obj )
            value = length( obj.OutputSignals ) * ( obj.LabelBlockHeight );
        end

        function value = get.MuxBlockHeight( obj )
            value = obj.Pack.TotNumModuleAssemblies * ( obj.LabelBlockHeight + 10 );
        end

        function value = get.ModuleAssemblyBlockWidth( obj )
            value = length( obj.OutputSignals ) * ( obj.LabelBlockHeight );
        end

        function value = get.ModuleAssemblyBlockHeight( obj )
            value = length( obj.OutputSignals ) * ( obj.LabelBlockHeight );
        end

        function value = get.AreaSectionStartXLocation( obj )
            value = obj.DiagramStartXLocation + obj.InterModuleAssemblySpacingFactor - 200;
        end

        function value = get.AreaSectionEndXLocation( obj )
            if obj.Pack.TotNumModuleAssemblies >= length( obj.OutputSignals )
                value = obj.DiagramStartXLocation + obj.InterModuleAssemblySpacingFactor + ( obj.InterModuleAssemblySpacingFactor ) * obj.Pack.TotNumModuleAssemblies;
            else
                value = obj.DiagramStartXLocation + 1.5 * obj.InterModuleAssemblySpacingFactor + ( obj.InterModuleAssemblySpacingFactor ) * ( length( obj.OutputSignals ) - 1 );
            end
        end

        function value = get.InterModuleAssemblySpacingFactor( obj )
            if strcmp( obj.Pack.ModuleAssembly( 1 ).Module( 1 ).BalancingStrategy, "Passive" )
                value = 450;
            else
                value = 350;
            end
        end

    end

    methods ( Access = private )


        function obj = addMainConnectors( obj, packBlockName )

            for moduleAssemblyIdx = 1:obj.Pack.TotNumModuleAssemblies
                currentBlockName = strcat( packBlockName, '/', obj.Pack.ModuleAssembly( moduleAssemblyIdx ).Name );
                currentModuleAssemblyHandle = get_param( currentBlockName, 'PortHandles' );

                if moduleAssemblyIdx == 1
                    initialModuleAssemblyHandle = currentModuleAssemblyHandle;
                end
                if moduleAssemblyIdx > 1
                    previousBlockName = strcat( packBlockName, '/', obj.Pack.ModuleAssembly( moduleAssemblyIdx - 1 ).Name );
                    previousModuleHandle = get_param( previousBlockName, 'PortHandles' );
                    switch obj.Pack.CircuitConnection
                        case "Series"
                            add_line( packBlockName, currentModuleAssemblyHandle.LConn( 1 ), previousModuleHandle.RConn( 1 ), autorouting = 'smart' );
                        otherwise
                            add_line( packBlockName, currentModuleAssemblyHandle.LConn( 1 ), previousModuleHandle.LConn( 1 ), autorouting = 'smart' );
                            add_line( packBlockName, currentModuleAssemblyHandle.RConn( 1 ), previousModuleHandle.RConn( 1 ), autorouting = 'smart' );
                    end
                end
            end
            endModuleAssemblyHandle = currentModuleAssemblyHandle;
            if strcmp( obj.Pack.NonCellResistance, "Yes" )
                add_block( 'nesl_utility/Connection Port', strcat( packBlockName, '/+' ) );
                set_param( strcat( packBlockName, '/+' ),  ...
                    'position',  ...
                    [ obj.AreaSectionStartXLocation + obj.XOffsetFromArea,  ...
                    obj.BatterySectionStartYLocation + obj.YOffsetFromArea,  ...
                    obj.AreaSectionStartXLocation + obj.YOffsetFromArea + obj.ConnLabelBlockWidth,  ...
                    obj.BatterySectionStartYLocation + obj.YOffsetFromArea + obj.ConnLabelBlockHeight ] );
                positivePortHandle = get_param( strcat( packBlockName, '/+' ), 'PortHandles' );

                ResistorValue = strcat( "1/1000", "/", string( 2 ) );
                add_block( 'fl_lib/Electrical/Electrical Elements/Resistor', strcat( string( packBlockName ), "/", "Resistor", string( 1 ) ), "R", ResistorValue );
                set_param( strcat( string( packBlockName ), "/", "Resistor", string( 1 ) ), 'position',  ...
                    [ obj.AreaSectionStartXLocation + obj.XOffsetFromArea * 2 + obj.ConnLabelBlockWidth,  ...
                    obj.BatterySectionStartYLocation + obj.YOffsetFromArea,  ...
                    obj.AreaSectionStartXLocation + obj.YOffsetFromArea * 2 + obj.ConnLabelBlockWidth + obj.ResistorBlockWidth,  ...
                    obj.BatterySectionStartYLocation + obj.YOffsetFromArea + obj.ResistorBlockHeight ],  ...
                    "ShowName", "off", "NameLocation", "bottom" );
                resistorHandle = get_param( strcat( string( packBlockName ), "/", "Resistor", string( 1 ) ), "PortHandles" );
                add_line( packBlockName, positivePortHandle.RConn, resistorHandle.LConn, autorouting = 'smart' );
                add_line( packBlockName, resistorHandle.RConn, initialModuleAssemblyHandle.LConn, autorouting = 'smart' )

                add_block( 'nesl_utility/Connection Port', strcat( packBlockName, '/-' ) );
                set_param( strcat( packBlockName, '/-' ),  ...
                    'position', [ obj.AreaSectionEndXLocation - obj.XOffsetFromArea - 20,  ...
                    obj.DiagramStartYLocation - 40,  ...
                    obj.AreaSectionEndXLocation - obj.XOffsetFromArea + obj.ConnLabelBlockWidth - 20,  ...
                    obj.DiagramStartYLocation - 20 ], 'Orientation', 'left', 'Side', 'right' );
                negativePortHandle = get_param( strcat( packBlockName, '/-' ), 'PortHandles' );

                add_block( 'fl_lib/Electrical/Electrical Elements/Resistor', strcat( string( packBlockName ), "/", "Resistor", string( 2 ) ), "R", ResistorValue );
                set_param( strcat( string( packBlockName ), "/", "Resistor", string( 2 ) ), 'position',  ...
                    [ obj.AreaSectionEndXLocation - obj.XOffsetFromArea * 2 - 20 - obj.ConnLabelBlockWidth,  ...
                    obj.DiagramStartYLocation - 40,  ...
                    obj.AreaSectionEndXLocation - obj.XOffsetFromArea * 2 - 20 - obj.ConnLabelBlockWidth + obj.ConnLabelBlockWidth,  ...
                    obj.DiagramStartYLocation - 20 ],  ...
                    "ShowName", "off", "NameLocation", "bottom" );
                resistorHandle = get_param( strcat( string( packBlockName ), "/", "Resistor", string( 2 ) ), "PortHandles" );

                add_line( packBlockName, endModuleAssemblyHandle.RConn( 1 ), resistorHandle.LConn, autorouting = 'smart' );
                add_line( packBlockName, resistorHandle.RConn, negativePortHandle.RConn, autorouting = 'smart' );

            elseif strcmp( obj.Pack.NonCellResistance, "No" )
                add_block( 'nesl_utility/Connection Port', strcat( packBlockName, '/+' ) );
                set_param( strcat( packBlockName, '/+' ),  ...
                    'position', [ obj.DiagramStartXLocation + obj.InterModuleAssemblySpacingFactor - 80,  ...
                    obj.DiagramStartYLocation - 40,  ...
                    obj.DiagramStartXLocation + obj.InterModuleAssemblySpacingFactor - 40,  ...
                    obj.DiagramStartYLocation - 20 ] );
                positivePortHandle = get_param( strcat( packBlockName, '/+' ), 'PortHandles' );
                add_line( packBlockName, initialModuleAssemblyHandle.LConn( 1 ), positivePortHandle.RConn, autorouting = 'smart' );

                add_block( 'nesl_utility/Connection Port', strcat( packBlockName, '/-' ) );
                set_param( strcat( packBlockName, '/-' ),  ...
                    'position', [ obj.AreaSectionEndXLocation - obj.XOffsetFromArea - 20,  ...
                    obj.DiagramStartYLocation - 40,  ...
                    obj.AreaSectionEndXLocation - obj.XOffsetFromArea + obj.ConnLabelBlockWidth - 20,  ...
                    obj.DiagramStartYLocation - 20 ], 'Orientation', 'left', 'Side', 'right' );
                negativePortHandle = get_param( strcat( packBlockName, '/-' ), 'PortHandles' );
                add_line( packBlockName, endModuleAssemblyHandle.RConn( 1 ), negativePortHandle.RConn, autorouting = 'smart' );
            end
        end

        function obj = addSignalRouting( obj, packBlockName )
            for moduleAssemblyIdx = 1:obj.Pack.TotNumModuleAssemblies
                currentBlockName = strcat( packBlockName, '/', obj.Pack.ModuleAssembly( moduleAssemblyIdx ).Name );
                currentModuleAssemblyHandle = get_param( currentBlockName, 'PortHandles' );

                for labelIdx = 1:length( obj.OutputSignals )

                    add_block( 'simulink/Signal Routing/Goto', strcat( packBlockName, '/', obj.OutputSignals( labelIdx ), 'To', string( moduleAssemblyIdx ) ),  ...
                        'position', [ obj.DiagramStartXLocation + obj.InterModuleAssemblySpacingFactor * moduleAssemblyIdx + obj.ModuleAssemblyBlockWidth + 20,  ...
                        obj.DiagramStartYLocation + 30 * ( labelIdx - 1 ) + 5,  ...
                        obj.DiagramStartXLocation + obj.InterModuleAssemblySpacingFactor * moduleAssemblyIdx + obj.ModuleAssemblyBlockWidth + obj.LabelBlockWidth + 20,  ...
                        obj.DiagramStartYLocation + 20 + 30 * ( labelIdx - 1 ) + 5 ],  ...
                        "ShowName", "off", "GotoTag", strcat( obj.OutputSignals( labelIdx ), string( moduleAssemblyIdx ) ) );

                    toLabelPortHandle = get_param( strcat( packBlockName, '/', obj.OutputSignals( labelIdx ), 'To', string( moduleAssemblyIdx ) ), 'PortHandles' );
                    add_line( packBlockName, currentModuleAssemblyHandle.Outport( labelIdx ), toLabelPortHandle.Inport, autorouting = 'smart' );

                    if moduleAssemblyIdx == 1

                        add_block( 'simulink/Commonly Used Blocks/Mux', strcat( packBlockName, '/', obj.OutputSignals( labelIdx ), 'Mux' ),  ...
                            'position', [ obj.DiagramStartXLocation + obj.InterModuleAssemblySpacingFactor + ( labelIdx - 1 ) * 250,  ...
                            obj.SignalSectionStartYLocation + obj.YOffsetFromArea + ( moduleAssemblyIdx - 1 ) * 40,  ...
                            obj.DiagramStartXLocation + obj.InterModuleAssemblySpacingFactor + ( labelIdx - 1 ) * 250 + obj.MuxBlockWidth,  ...
                            obj.SignalSectionStartYLocation + obj.YOffsetFromArea + obj.MuxBlockHeight + ( moduleAssemblyIdx - 1 ) * 40 ],  ...
                            "Inputs", string( obj.Pack.TotNumModuleAssemblies ), "ShowName", "off" );

                        add_block( 'simulink/Commonly Used Blocks/Out1', strcat( packBlockName, '/', obj.OutputSignals( labelIdx ) ),  ...
                            'position', [ ( obj.DiagramStartXLocation + obj.InterModuleAssemblySpacingFactor + ( labelIdx - 1 ) * 250 + obj.MuxBlockWidth + 30 ),  ...
                            ( obj.SignalSectionStartYLocation + obj.YOffsetFromArea + obj.MuxBlockHeight / 2 - obj.ConnLabelBlockHeight / 2 ),  ...
                            ( obj.DiagramStartXLocation + obj.InterModuleAssemblySpacingFactor + ( labelIdx - 1 ) * 250 + obj.MuxBlockWidth + 30 + obj.ConnLabelBlockWidth + 10 ),  ...
                            ( obj.SignalSectionStartYLocation + obj.YOffsetFromArea + obj.MuxBlockHeight / 2 - obj.ConnLabelBlockHeight / 2 + obj.ConnLabelBlockHeight ) ], "ShowName", "on" );

                        muxPortHandle = get_param( strcat( packBlockName, '/', obj.OutputSignals( labelIdx ), 'Mux' ), 'PortHandles' );
                        outPortHandle = get_param( strcat( packBlockName, '/', obj.OutputSignals( labelIdx ) ), 'PortHandles' );
                        add_line( packBlockName, muxPortHandle.Outport, outPortHandle.Inport, autorouting = 'smart' )
                    end

                    add_block( 'simulink/Signal Routing/From', strcat( packBlockName, '/', obj.OutputSignals( labelIdx ), 'From', string( moduleAssemblyIdx ) ),  ...
                        'position', [ ( obj.DiagramStartXLocation + obj.InterModuleAssemblySpacingFactor + ( labelIdx - 1 ) * 250 - obj.LabelBlockWidth - 30 ),  ...
                        ( obj.SignalSectionStartYLocation + obj.YOffsetFromArea + ( moduleAssemblyIdx - 1 ) * 40 + 5 ),  ...
                        ( obj.DiagramStartXLocation + obj.InterModuleAssemblySpacingFactor + ( ( labelIdx - 1 ) * 250 ) - 30 ),  ...
                        ( obj.SignalSectionStartYLocation + obj.YOffsetFromArea + ( moduleAssemblyIdx - 1 ) * 40 + 5 + obj.LabelBlockHeight ) ],  ...
                        "ShowName", "off", "GotoTag", strcat( obj.OutputSignals( labelIdx ), string( moduleAssemblyIdx ) ) );
                    fromLabelPortHandle = get_param( strcat( packBlockName, '/', obj.OutputSignals( labelIdx ), 'From', string( moduleAssemblyIdx ) ), 'PortHandles' );
                    muxPortHandle = get_param( strcat( packBlockName, '/', obj.OutputSignals( labelIdx ), 'Mux' ), 'PortHandles' );
                    add_line( packBlockName, fromLabelPortHandle.Outport, muxPortHandle.Inport( moduleAssemblyIdx ), autorouting = 'smart' );
                end
            end
        end

        function obj = addAmbientPath( obj, packBlockName )
            if ~strcmp( obj.Pack.ModuleAssembly( 1 ).Module( 1 ).AmbientThermalPath, "" )
                for moduleAssemblyIdx = 1:obj.Pack.TotNumModuleAssemblies
                    currentBlockName = strcat( packBlockName, '/', obj.Pack.ModuleAssembly( moduleAssemblyIdx ).Name );
                    currentModuleAssemblyHandle = get_param( currentBlockName, 'PortHandles' );
                    moduleAssemblyPortConnectivity = get_param( currentBlockName, 'PortConnectivity' );
                    ambPortPosition = moduleAssemblyPortConnectivity( obj.AmbHConnID ).Position;
                    ambPortPositionX = ambPortPosition( 1 );
                    ambPortPositionY = ambPortPosition( 2 );
                    add_block( 'nesl_utility/Connection Label', strcat( packBlockName, '/AmbH_To_', string( moduleAssemblyIdx ) ),  ...
                        "position", [ ambPortPositionX - obj.ConnLabelBlockHeight / 2,  ...
                        ambPortPositionY + obj.ConnLabelBlockWidth,  ...
                        ambPortPositionX + obj.ConnLabelBlockHeight / 2,  ...
                        ambPortPositionY + obj.ConnLabelBlockWidth + 5 ],  ...
                        'Orientation', 'down', "label", strcat( "ambH_", string( moduleAssemblyIdx ) ),  ...
                        "ShowName", "off" );

                    ambToConnLabelPortHandle = get_param( strcat( packBlockName, '/AmbH_To_', string( moduleAssemblyIdx ) ), 'PortHandles' );
                    add_line( packBlockName, ambToConnLabelPortHandle.LConn( 1 ), currentModuleAssemblyHandle.RConn( 2 ), autorouting = 'smart' );


                    if moduleAssemblyIdx == 1
                        add_block( 'nesl_utility/Connection Port', strcat( packBlockName, '/AmbH' ) );
                        set_param( strcat( packBlockName, '/AmbH' ),  ...
                            'position', [ ( obj.AreaSectionStartXLocation + obj.XOffsetFromArea ),  ...
                            ( obj.ThermalSectionStartYLocation + obj.YOffsetFromArea ),  ...
                            ( obj.AreaSectionStartXLocation + obj.XOffsetFromArea + obj.ConnLabelBlockWidth ),  ...
                            ( obj.ThermalSectionStartYLocation + obj.YOffsetFromArea + obj.ConnLabelBlockHeight ) ],  ...
                            'Orientation', 'right', 'Side', 'right', "ConnectionType", "Connection: foundation.thermal.thermal" );
                        ambHPortHandle = get_param( strcat( packBlockName, '/AmbH' ), 'PortHandles' );
                    end
                    add_block( 'nesl_utility/Connection Label', strcat( packBlockName, '/AmbH_From_', string( moduleAssemblyIdx ) ),  ...
                        "position", [ ( obj.AreaSectionStartXLocation + obj.XOffsetFromArea + 80 ),  ...
                        ( obj.ThermalSectionStartYLocation + obj.YOffsetFromArea + ( moduleAssemblyIdx - 1 ) * 40 ),  ...
                        ( obj.AreaSectionStartXLocation + obj.XOffsetFromArea + 80 + obj.ConnLabelBlockWidth ),  ...
                        ( obj.ThermalSectionStartYLocation + obj.YOffsetFromArea + ( moduleAssemblyIdx - 1 ) * 40 + obj.ConnLabelBlockHeight ) ],  ...
                        'Orientation', 'right', "label", strcat( "ambH_", string( moduleAssemblyIdx ) ),  ...
                        "ShowName", "off" );
                    ambFromConnLabelPortHandle = get_param( strcat( packBlockName, '/AmbH_From_', string( moduleAssemblyIdx ) ), 'PortHandles' );
                    add_line( packBlockName, ambFromConnLabelPortHandle.LConn, ambHPortHandle.RConn, autorouting = 'smart' )
                end
            end
        end

        function obj = addCoolantPath( obj, packBlockName )
            if ~strcmp( obj.Pack.CoolantThermalPath, "" ) && all( strcmp( obj.Pack.ModuleAssembly( 1 ).Module( 1 ).CoolingPlate, "" ) )
                for moduleAssemblyIdx = 1:obj.Pack.TotNumModuleAssemblies
                    currentBlockName = strcat( packBlockName, '/', obj.Pack.ModuleAssembly( moduleAssemblyIdx ).Name );
                    currentModuleAssemblyHandle = get_param( currentBlockName, 'PortHandles' );
                    moduleAssemblyPortConnectivity = get_param( currentBlockName, 'PortConnectivity' );
                    clntPortPosition = moduleAssemblyPortConnectivity( obj.ClntHConnID ).Position;
                    clntPortPositionX = clntPortPosition( 1 );
                    clntPortPositionY = clntPortPosition( 2 );

                    add_block( 'nesl_utility/Connection Label', strcat( packBlockName, '/ClntH_To_', string( moduleAssemblyIdx ) ),  ...
                        "position", [ clntPortPositionX - obj.ConnLabelBlockHeight / 2,  ...
                        clntPortPositionY + obj.ConnLabelBlockWidth,  ...
                        clntPortPositionX + obj.ConnLabelBlockHeight / 2,  ...
                        clntPortPositionY + obj.ConnLabelBlockWidth + 5 ],  ...
                        'Orientation', 'down', "label", strcat( "clntH_", string( moduleAssemblyIdx ) ),  ...
                        "ShowName", "off" );
                    clntToConnLabelPortHandle = get_param( strcat( packBlockName, '/ClntH_To_', string( moduleAssemblyIdx ) ), 'PortHandles' );
                    if ~strcmp( obj.Pack.ModuleAssembly( 1 ).Module( 1 ).AmbientThermalPath, "" )
                        add_line( packBlockName, clntToConnLabelPortHandle.LConn( 1 ), currentModuleAssemblyHandle.RConn( 3 ), autorouting = 'smart' );
                    else
                        add_line( packBlockName, clntToConnLabelPortHandle.LConn( 1 ), currentModuleAssemblyHandle.RConn( 2 ), autorouting = 'smart' );
                    end

                    if moduleAssemblyIdx == 1
                        add_block( 'nesl_utility/Connection Port', strcat( packBlockName, '/ClntH' ) );
                        set_param( strcat( packBlockName, '/ClntH' ), 'position', [ obj.AreaSectionStartXLocation + obj.XOffsetFromArea + obj.InterModuleAssemblySpacingFactor,  ...
                            obj.ThermalSectionStartYLocation + obj.YOffsetFromArea,  ...
                            obj.AreaSectionStartXLocation + obj.XOffsetFromArea + obj.ConnLabelBlockWidth + obj.InterModuleAssemblySpacingFactor,  ...
                            obj.ThermalSectionStartYLocation + obj.YOffsetFromArea + obj.ConnLabelBlockHeight ],  ...
                            'Orientation', 'right', 'Side', 'right', "ConnectionType", "Connection: foundation.thermal.thermal" );
                        clntHPortHandle = get_param( strcat( packBlockName, '/ClntH' ), 'PortHandles' );
                    end
                    add_block( 'nesl_utility/Connection Label', strcat( packBlockName, '/ClntH_From_', string( moduleAssemblyIdx ) ),  ...
                        "position", [ ( obj.AreaSectionStartXLocation + obj.XOffsetFromArea + 80 + obj.InterModuleAssemblySpacingFactor ),  ...
                        ( obj.ThermalSectionStartYLocation + obj.YOffsetFromArea + ( moduleAssemblyIdx - 1 ) * 40 ),  ...
                        ( obj.AreaSectionStartXLocation + obj.XOffsetFromArea + 80 + obj.ConnLabelBlockWidth + obj.InterModuleAssemblySpacingFactor ),  ...
                        ( obj.ThermalSectionStartYLocation + obj.YOffsetFromArea + ( moduleAssemblyIdx - 1 ) * 40 + obj.ConnLabelBlockHeight ) ],  ...
                        'Orientation', 'right', "label", strcat( "clntH_", string( moduleAssemblyIdx ) ),  ...
                        "ShowName", "off" );
                    clntFromConnLabelPortHandle = get_param( strcat( packBlockName, '/ClntH_From_', string( moduleAssemblyIdx ) ), 'PortHandles' );
                    add_line( packBlockName, clntFromConnLabelPortHandle.LConn, clntHPortHandle.RConn, autorouting = 'smart' )
                end
            end
        end


        function obj = addPackAreas( obj, packBlockName )

            add_block( 'built-in/Area', strcat( packBlockName, '/Battery Module Assemblies' ),  ...
                'Position', [  ...
                obj.AreaSectionStartXLocation,  ...
                obj.BatterySectionStartYLocation,  ...
                obj.AreaSectionEndXLocation,  ...
                obj.BatterySectionEndYLocation ], "DropShadow", "on", "FontWeight", "bold" )

            add_block( 'built-in/Area', strcat( packBlockName, '/Output Signals' ),  ...
                'Position', [  ...
                obj.AreaSectionStartXLocation,  ...
                obj.SignalSectionStartYLocation,  ...
                obj.AreaSectionEndXLocation,  ...
                obj.SignalSectionEndYLocation ], "DropShadow", "on", "FontWeight", "bold" )

            if ~strcmp( obj.Pack.ModuleAssembly( 1 ).Module( 1 ).AmbientThermalPath, "" ) || ~strcmp( obj.Pack.ModuleAssembly( 1 ).Module( 1 ).CoolantThermalPath, "" )
                add_block( 'built-in/Area', strcat( packBlockName, '/Thermal Boundary Conditions' ),  ...
                    'Position', [  ...
                    obj.AreaSectionStartXLocation,  ...
                    obj.ThermalSectionStartYLocation,  ...
                    obj.AreaSectionEndXLocation,  ...
                    obj.ThermalSectionEndYLocation ], "DropShadow", "on", "FontWeight", "bold" )
            end

            if ~strcmp( obj.Pack.ModuleAssembly( 1 ).Module( 1 ).BalancingStrategy, "" )
                add_block( 'built-in/Area', strcat( packBlockName, '/Balancing Signals' ),  ...
                    'Position', [  ...
                    obj.AreaSectionStartXLocation,  ...
                    obj.BalancingSectionStartYLocation,  ...
                    obj.AreaSectionEndXLocation,  ...
                    obj.BalancingSectionEndYLocation ], "DropShadow", "on", "FontWeight", "bold" )
            end

        end


        function obj = addBalancingSignalRouting( obj, packBlockName )

            if ~strcmp( obj.Pack.ModuleAssembly( 1 ).Module( 1 ).BalancingStrategy, "" )


                TotParallelAssemblies = 0;
                TrackingIndex = 1;
                for moduleAssemblyIdx = 1:obj.Pack.TotNumModuleAssemblies
                    for moduleIdx = 1:obj.Pack.ModuleAssembly( moduleAssemblyIdx ).TotNumModules
                        moduleNumParallelAssemblies = obj.Pack.ModuleAssembly( moduleAssemblyIdx ).Module( moduleIdx ).NumSeriesAssemblies;
                        TotParallelAssemblies = moduleNumParallelAssemblies + TotParallelAssemblies;
                    end
                    ModuleAssembly( moduleAssemblyIdx ).ParallelAssembliesIndices = TrackingIndex:TotParallelAssemblies;%#ok<AGROW>
                    TrackingIndex = TotParallelAssemblies + 1;
                end

                add_block( 'simulink/Commonly Used Blocks/In1', strcat( packBlockName, '/balancing' ),  ...
                    "position", [  ...
                    ( obj.AreaSectionStartXLocation + obj.XOffsetFromArea ),  ...
                    ( obj.BalancingSectionStartYLocation + obj.YOffsetFromArea + obj.MuxBlockHeight / 2 ),  ...
                    ( obj.AreaSectionStartXLocation + obj.XOffsetFromArea + obj.ConnLabelBlockWidth ),  ...
                    ( obj.BalancingSectionStartYLocation + obj.YOffsetFromArea + obj.ConnLabelBlockHeight + obj.MuxBlockHeight / 2 ) ],  ...
                    "PortDimensions", string( TotParallelAssemblies ) );
                balacingIn1Handle = get_param( strcat( packBlockName, '/balancing' ), 'PortHandles' );

                for moduleAssemblyIdx = 1:obj.Pack.TotNumModuleAssemblies

                    currentBlockName = strcat( packBlockName, '/', obj.Pack.ModuleAssembly( moduleAssemblyIdx ).Name );
                    currentModuleAssemblyHandle = get_param( currentBlockName, 'PortHandles' );

                    add_block( 'simulink/Signal Routing/Selector', strcat( packBlockName, '/balancingSelector', string( moduleAssemblyIdx ) ),  ...
                        "position", [  ...
                        ( obj.AreaSectionStartXLocation + obj.XOffsetFromArea + 80 ),  ...
                        ( obj.BalancingSectionStartYLocation + obj.YOffsetFromArea + 10 + ( moduleAssemblyIdx - 1 ) * 40 ),  ...
                        ( obj.AreaSectionStartXLocation + obj.XOffsetFromArea + obj.SelectorBlockWidth + 80 ),  ...
                        ( obj.BalancingSectionStartYLocation + obj.YOffsetFromArea + 10 + ( moduleAssemblyIdx - 1 ) * 40 ) + obj.SelectorBlockHeight ],  ...
                        "InputPortWidth", num2str( TotParallelAssemblies ),  ...
                        "Indices", strcat( '[', num2str( [ ModuleAssembly( moduleAssemblyIdx ).ParallelAssembliesIndices ] ), ']' ),  ...
                        "ShowName", "off" );
                    balacingSelectorHandle = get_param( strcat( packBlockName, '/balancingSelector', string( moduleAssemblyIdx ) ), 'PortHandles' );
                    add_block( 'simulink/Signal Routing/Goto', strcat( packBlockName, '/', "balancing", string( moduleAssemblyIdx ), '_', 'To' ), 'position',  ...
                        [ obj.AreaSectionStartXLocation + obj.XOffsetFromArea + 80 + obj.SelectorBlockWidth + 40,  ...
                        ( obj.BalancingSectionStartYLocation + obj.YOffsetFromArea + 15 + ( moduleAssemblyIdx - 1 ) * 40 ),  ...
                        obj.AreaSectionStartXLocation + obj.XOffsetFromArea + 80 + obj.SelectorBlockWidth + 40 + obj.LabelBlockWidth,  ...
                        ( obj.BalancingSectionStartYLocation + obj.YOffsetFromArea + 15 + ( moduleAssemblyIdx - 1 ) * 40 ) + obj.LabelBlockHeight ],  ...
                        "ShowName", "off", "GotoTag", strcat( "balancing", string( moduleAssemblyIdx ) ) );

                    balacingGotoHandle = get_param( strcat( packBlockName, '/', "balancing", string( moduleAssemblyIdx ), '_', 'To' ), 'PortHandles' );
                    add_line( packBlockName, balacingSelectorHandle.Outport, balacingGotoHandle.Inport, autorouting = 'smart' )
                    add_line( packBlockName, balacingIn1Handle.Outport, balacingSelectorHandle.Inport, autorouting = 'smart' );

                    add_block( 'simulink/Signal Routing/From', strcat( packBlockName, '/', "balancing", string( moduleAssemblyIdx ), '_', 'From' ), 'position',  ...
                        [ obj.DiagramStartXLocation + obj.InterModuleAssemblySpacingFactor * moduleAssemblyIdx - obj.LabelBlockWidth - 20,  ...
                        obj.DiagramStartYLocation + obj.ModuleAssemblyBlockHeight / 2 - obj.LabelBlockHeight / 2,  ...
                        obj.DiagramStartXLocation + obj.InterModuleAssemblySpacingFactor * moduleAssemblyIdx - 20,  ...
                        obj.DiagramStartYLocation + obj.ModuleAssemblyBlockHeight / 2 - obj.LabelBlockHeight / 2 + obj.LabelBlockHeight ],  ...
                        "ShowName", "off", "GotoTag", strcat( "balancing", string( moduleAssemblyIdx ) ) );

                    balacingFromHandle = get_param( strcat( packBlockName, '/', "balancing", string( moduleAssemblyIdx ), '_', 'From' ), 'PortHandles' );
                    add_line( packBlockName, balacingFromHandle.Outport, currentModuleAssemblyHandle.Inport )
                end
            end
        end


        function obj = setAreaLocations( obj )
            obj.BatterySectionStartYLocation = obj.DiagramStartYLocation - 100;
            obj.BatterySectionEndYLocation = obj.DiagramStartYLocation + obj.ModuleAssemblyBlockHeight + obj.YOffsetFromArea * 3;

            obj.SignalSectionStartYLocation = obj.BatterySectionEndYLocation + obj.YOffsetFromArea;
            obj.SignalSectionEndYLocation = obj.BatterySectionEndYLocation + obj.MuxBlockHeight + obj.YOffsetFromArea * 3;

            obj.ThirdSectionStartYLocation = obj.SignalSectionEndYLocation + obj.YOffsetFromArea;
            obj.ThirdSectionEndYLocation = obj.SignalSectionEndYLocation + obj.YOffsetFromArea + ( obj.Pack.TotNumModuleAssemblies ) * 40 + 100;

            obj.FourthSectionStartYLocation = obj.ThirdSectionEndYLocation + obj.YOffsetFromArea;
            obj.FourthSectionEndYLocation = obj.FourthSectionStartYLocation + ( obj.Pack.TotNumModuleAssemblies ) * 40 + 100;

            if ( ~strcmp( obj.Pack.AmbientThermalPath, "" ) || ~strcmp( obj.Pack.CoolantThermalPath, "" ) ) ...
                    && ~strcmp( obj.Pack.BalancingStrategy, "" )
                obj.ThermalSectionStartYLocation = obj.ThirdSectionStartYLocation;
                obj.ThermalSectionEndYLocation = obj.ThirdSectionEndYLocation;
                obj.BalancingSectionStartYLocation = obj.FourthSectionStartYLocation;
                obj.BalancingSectionEndYLocation = obj.FourthSectionEndYLocation;
            elseif ( strcmp( obj.Pack.AmbientThermalPath, "" ) || strcmp( obj.Pack.CoolantThermalPath, "" ) ) ...
                    && ~strcmp( obj.Pack.BalancingStrategy, "" )
                obj.ThermalSectionStartYLocation = [  ];
                obj.ThermalSectionEndYLocation = [  ];
                obj.BalancingSectionStartYLocation = obj.ThirdSectionStartYLocation;
                obj.BalancingSectionEndYLocation = obj.ThirdSectionEndYLocation;
            elseif ( strcmp( obj.Pack.AmbientThermalPath, "" ) || strcmp( obj.Pack.CoolantThermalPath, "" ) ) ...
                    && strcmp( obj.Pack.BalancingStrategy, "" )
                obj.ThermalSectionStartYLocation = obj.ThirdSectionStartYLocation;
                obj.ThermalSectionEndYLocation = obj.ThirdSectionEndYLocation;
                obj.BalancingSectionStartYLocation = [  ];
                obj.BalancingSectionEndYLocation = [  ];
            elseif ( ~strcmp( obj.Pack.AmbientThermalPath, "" ) || ~strcmp( obj.Pack.CoolantThermalPath, "" ) ) ...
                    && strcmp( obj.Pack.BalancingStrategy, "" )
                obj.ThermalSectionStartYLocation = obj.ThirdSectionStartYLocation;
                obj.ThermalSectionEndYLocation = obj.ThirdSectionEndYLocation;
                obj.BalancingSectionStartYLocation = [  ];
                obj.BalancingSectionEndYLocation = [  ];
            end

        end

        function obj = createPackMask( obj, packBlockName )
            packMaskObj = Simulink.Mask.create( packBlockName );
            packMaskObj.ImageFile = fullfile( matlabroot, 'toolbox', 'physmod', 'battery', 'builder', 'm', '+simscape', '+battery', '+builder', '+internal', '+export', 'Icons', 'pack.JPG' );
            Simulink.Mask.convertToInternalImage( packBlockName )
            packMaskObj.Display = "image('$imagefile')";
            packMaskObj.IconOpaque = "opaque-with-ports";
            save_system;
        end

        function obj = updatePackSubsystemApperance( obj, packBlockName )
            packBlockHandles = get_param( packBlockName, "PortHandles" );
            signalPlacementIdx = length( obj.OutputSignals );
            for outputSignalIdx = 1:length( obj.OutputSignals )
                Simulink.PortPlacement.setPortLocation( packBlockHandles.Outport( signalPlacementIdx ), 'Bottom:1', 'block' )
                signalPlacementIdx = signalPlacementIdx - 1;
            end
            if ~strcmp( obj.Pack.ModuleAssembly( 1 ).Module( 1 ).BalancingStrategy, "" )
                Simulink.PortPlacement.setPortLocation( packBlockHandles.Inport( 1 ), 'Top:1', 'block' )
            end
        end

        function obj = setConnectorIDs( obj )
            if ~strcmp( obj.Pack.AmbientThermalPath, "" ) && ~strcmp( obj.Pack.CoolantThermalPath, "" ) ...
                    && ~strcmp( obj.Pack.BalancingStrategy, "" ) && all( strcmp( obj.Pack.ModuleAssembly( 1 ).Module( 1 ).CoolingPlate, "" ) )
                obj.ClntHConnID = length( obj.OutputSignals ) + 5;
                obj.AmbHConnID = length( obj.OutputSignals ) + 4;
            elseif strcmp( obj.Pack.AmbientThermalPath, "" ) && strcmp( obj.Pack.CoolantThermalPath, "" ) ...
                    && strcmp( obj.Pack.BalancingStrategy, "" ) && all( strcmp( obj.Pack.ModuleAssembly( 1 ).Module( 1 ).CoolingPlate, "" ) )
                obj.ClntHConnID = [  ];
                obj.AmbHConnID = [  ];
            elseif strcmp( obj.Pack.AmbientThermalPath, "" ) && strcmp( obj.Pack.CoolantThermalPath, "" ) ...
                    && ~strcmp( obj.Pack.BalancingStrategy, "" ) && all( strcmp( obj.Pack.ModuleAssembly( 1 ).Module( 1 ).CoolingPlate, "" ) )
                obj.ClntHConnID = [  ];
                obj.AmbHConnID = [  ];
            elseif ~strcmp( obj.Pack.AmbientThermalPath, "" ) && strcmp( obj.Pack.CoolantThermalPath, "" ) &&  ...
                    strcmp( obj.Pack.BalancingStrategy, "" ) && all( strcmp( obj.Pack.ModuleAssembly( 1 ).Module( 1 ).CoolingPlate, "" ) )
                obj.ClntHConnID = [  ];
                obj.AmbHConnID = length( obj.OutputSignals ) + 3;
            elseif strcmp( obj.Pack.AmbientThermalPath, "" ) && ~strcmp( obj.Pack.CoolantThermalPath, "" ) &&  ...
                    strcmp( obj.Pack.BalancingStrategy, "" ) && all( strcmp( obj.Pack.ModuleAssembly( 1 ).Module( 1 ).CoolingPlate, "" ) )
                obj.ClntHConnID = length( obj.OutputSignals ) + 3;
                obj.AmbHConnID = [  ];
            elseif ~strcmp( obj.Pack.AmbientThermalPath, "" ) && strcmp( obj.Pack.CoolantThermalPath, "" ) &&  ...
                    ~strcmp( obj.Pack.BalancingStrategy, "" ) && all( strcmp( obj.Pack.ModuleAssembly( 1 ).Module( 1 ).CoolingPlate, "" ) )
                obj.ClntHConnID = [  ];
                obj.AmbHConnID = length( obj.OutputSignals ) + 4;
            elseif ~strcmp( obj.Pack.AmbientThermalPath, "" ) && ~strcmp( obj.Pack.CoolantThermalPath, "" ) &&  ...
                    ~strcmp( obj.Pack.BalancingStrategy, "" ) && ~all( strcmp( obj.Pack.ModuleAssembly( 1 ).Module( 1 ).CoolingPlate, "" ) )
                obj.ClntHConnID = [  ];
                obj.AmbHConnID = length( obj.OutputSignals ) + 4;
            elseif ~strcmp( obj.Pack.AmbientThermalPath, "" ) && ~strcmp( obj.Pack.CoolantThermalPath, "" ) &&  ...
                    strcmp( obj.Pack.BalancingStrategy, "" ) && all( strcmp( obj.Pack.ModuleAssembly( 1 ).Module( 1 ).CoolingPlate, "" ) )
                obj.ClntHConnID = length( obj.OutputSignals ) + 4;
                obj.AmbHConnID = length( obj.OutputSignals ) + 3;
            elseif ~strcmp( obj.Pack.AmbientThermalPath, "" ) && strcmp( obj.Pack.CoolantThermalPath, "" ) &&  ...
                    strcmp( obj.Pack.BalancingStrategy, "" ) && ~all( strcmp( obj.Pack.ModuleAssembly( 1 ).Module( 1 ).CoolingPlate, "" ) )
                obj.ClntHConnID = [  ];
                obj.AmbHConnID = length( obj.OutputSignals ) + 3;
            elseif ~strcmp( obj.Pack.AmbientThermalPath, "" ) && strcmp( obj.Pack.CoolantThermalPath, "" ) &&  ...
                    ~strcmp( obj.Pack.BalancingStrategy, "" ) && ~all( strcmp( obj.Pack.ModuleAssembly( 1 ).Module( 1 ).CoolingPlate, "" ) )
                obj.ClntHConnID = [  ];
                obj.AmbHConnID = length( obj.OutputSignals ) + 4;
            elseif strcmp( obj.Pack.AmbientThermalPath, "" ) && ~strcmp( obj.Pack.CoolantThermalPath, "" ) &&  ...
                    ~strcmp( obj.Pack.BalancingStrategy, "" ) && all( strcmp( obj.Pack.ModuleAssembly( 1 ).Module( 1 ).CoolingPlate, "" ) )
                obj.ClntHConnID = length( obj.OutputSignals ) + 4;
                obj.AmbHConnID = [  ];
            elseif ~strcmp( obj.Pack.AmbientThermalPath, "" ) && ~strcmp( obj.Pack.CoolantThermalPath, "" ) &&  ...
                    strcmp( obj.Pack.BalancingStrategy, "" ) && ~all( strcmp( obj.Pack.ModuleAssembly( 1 ).Module( 1 ).CoolingPlate, "" ) )
                obj.ClntHConnID = length( obj.OutputSignals ) + 4;
                obj.AmbHConnID = length( obj.OutputSignals ) + 3;
            end
        end

    end

    methods ( Static, Access = private )

        function block = getChildBlock( pack, blockDatabase )

            for moduleAssemlbyIdx = 1:pack.TotNumModuleAssemblies
                block( moduleAssemlbyIdx ).ModuleAssemblyBlocks = blockDatabase.getBlock( "ModuleAssembly", pack.ModuleAssembly( moduleAssemlbyIdx ).BlockType );%#ok<AGROW>
            end
        end
    end

end


