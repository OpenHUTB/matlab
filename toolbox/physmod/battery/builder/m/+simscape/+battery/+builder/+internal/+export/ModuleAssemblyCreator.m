classdef ModuleAssemblyCreator < simscape.battery.builder.internal.export.BatteryTypeCreator

    properties

        ModuleAssembly( 1, 1 )simscape.battery.builder.ModuleAssembly


        FilePath( 1, 1 ){ mustBeTextScalar( FilePath ) } = ""


        IsHighestLevel( 1, 1 )logical{ mustBeA( IsHighestLevel, "logical" ) }

        BlockDatabase( 1, 1 ){ mustBeA( BlockDatabase, "simscape.battery.builder.internal.export.BlockDatabase" ) } ...
            = simscape.battery.builder.internal.export.BlockDatabase(  );

        LibraryName( 1, 1 )string = "Batteries"
    end

    properties ( Constant )

        ModuleBlockWidth = 200;

        ModuleBlockHeight = 200;


        DiagramStartXLocation = 100;


        DiagramStartYLocation = 100;

        ProbeBlockWidth = 80;

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

        ModuleAssemblyBlockWidth

        ModuleAssemblyBlockHeight

        InterModuleSpacingFactor

        ProbeBlockHeight

        MuxBlockHeight

        ProbeBlockYLocation

        AreaSectionStartXLocation

        AreaSectionEndXLocation
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
        ConnIDs
        OutputSignals
    end

    methods
        function obj = ModuleAssemblyCreator( moduleAssembly, filePath, isHighestLevel, blockDatabase, libraryName )
            arguments
                moduleAssembly( 1, 1 )simscape.battery.builder.ModuleAssembly
                filePath( 1, 1 ){ mustBeTextScalar( filePath ) }
                isHighestLevel( 1, 1 )logical{ mustBeA( isHighestLevel, "logical" ) }
                blockDatabase( 1, 1 ){ mustBeA( blockDatabase, "simscape.battery.builder.internal.export.BlockDatabase" ) }
                libraryName( 1, 1 )string
            end
            obj.ModuleAssembly = moduleAssembly;
            obj.FilePath = filePath;
            obj.IsHighestLevel = isHighestLevel;
            obj.BlockDatabase = blockDatabase;
            obj.LibraryName = libraryName;
        end

        function value = get.InterModuleSpacingFactor( obj )
            if strcmp( obj.ModuleAssembly.Module( 1 ).BalancingStrategy, "Passive" )
                value = 400;
            else
                value = 300;
            end
        end

        function value = get.ProbeBlockHeight( obj )
            value = length( obj.OutputSignals ) * obj.LabelBlockHeight;
        end

        function value = get.MuxBlockHeight( obj )
            value = obj.ModuleAssembly.TotNumModules * obj.LabelBlockHeight;
        end

        function value = get.ProbeBlockYLocation( obj )
            value = obj.DiagramStartYLocation + obj.ModuleBlockHeight + 200;
        end

        function value = get.AreaSectionStartXLocation( obj )
            value = obj.DiagramStartXLocation + obj.InterModuleSpacingFactor - 200;
        end

        function value = get.AreaSectionEndXLocation( obj )
            if obj.ModuleAssembly.TotNumModules >= length( obj.OutputSignals )
                value = obj.DiagramStartXLocation + obj.InterModuleSpacingFactor + obj.InterModuleSpacingFactor * ( obj.ModuleAssembly.TotNumModules );
            else
                value = obj.DiagramStartXLocation + 1.5 * obj.InterModuleSpacingFactor + obj.InterModuleSpacingFactor * ( length( obj.OutputSignals ) - 1 );
            end
        end

        function value = get.ModuleAssemblyBlockWidth( obj )
            value = length( obj.OutputSignals ) * ( obj.LabelBlockHeight );
        end

        function value = get.ModuleAssemblyBlockHeight( obj )
            value = length( obj.OutputSignals ) * ( obj.LabelBlockHeight );
        end

        function obj = setOutputSignalNames( obj, childComponent )
            obj.OutputSignals = sortrows( [ childComponent( 1 ).ModuleBlocks( 1 ).BlockVariables.IDs ] );
        end

        function blockDetails = createBlock( obj )



            blockDetails = simscape.battery.builder.internal.export.SimulinkBlock( obj.ModuleAssembly.BlockType, [  ], obj.FilePath );
            blockDetails = blockDetails.setBatteryType( simscape.battery.builder.ModuleAssembly.Type );
            childComponent = obj.getChildBlock( obj.ModuleAssembly, obj.BlockDatabase );
            obj = obj.setOutputSignalNames( childComponent );

            if ( exist( obj.LibraryName ) == 0 )%#ok<EXIST>
                new_system( obj.LibraryName, 'Library' );
            else
                load_system( obj.LibraryName );
                set_param( obj.LibraryName, 'Lock', 'off' );
            end
            if obj.IsHighestLevel
                moduleAssemblyBlockName = strcat( obj.LibraryName, '/', obj.ModuleAssembly.Name );
            else
                if ( getSimulinkBlockHandle( strcat( obj.LibraryName, "/ModuleAssemblies" ) ) ==  - 1 )
                    add_block( 'built-in/Subsystem', strcat( obj.LibraryName, "/ModuleAssemblies" ) );
                    set_param( strcat( obj.LibraryName, "/ModuleAssemblies" ), 'position',  ...
                        [ obj.DiagramStartXLocation + 300,  ...
                        obj.DiagramStartYLocation,  ...
                        obj.DiagramStartXLocation + 300 + obj.ModuleAssemblyBlockWidth,  ...
                        obj.DiagramStartYLocation + obj.ModuleAssemblyBlockHeight ] );
                    Simulink.Mask.create( strcat( obj.LibraryName, "/ModuleAssemblies" ) );
                end
                moduleAssemblyBlockName = strcat( obj.LibraryName, "/ModuleAssemblies/", obj.ModuleAssembly.BlockType );
            end
            blockTypeIdx = str2double( regexp( obj.ModuleAssembly.BlockType, '\d*', 'Match' ) );

            add_block( 'built-in/Subsystem', moduleAssemblyBlockName );
            parentBlockName = moduleAssemblyBlockName;

            copyFcnText = "battery_builder_rtmsupport('copyfcn',gcbh);";
            preCopyFcnText = "battery_builder_rtmsupport('precopyfcn',gcbh);";
            preDeleteFcnText = "battery_builder_rtmsupport('predeletefcn',gcbh);";
            loadFcnText = "battery_builder_rtmsupport('loadfcn',gcbh);";

            set_param( moduleAssemblyBlockName, 'position',  ...
                [ obj.DiagramStartXLocation + 300 * ( blockTypeIdx - 1 ),  ...
                obj.DiagramStartYLocation,  ...
                obj.DiagramStartXLocation + obj.ModuleAssemblyBlockWidth + 300 * ( blockTypeIdx - 1 ),  ...
                obj.DiagramStartYLocation + obj.ModuleAssemblyBlockHeight ],  ...
                "NameLocation", "bottom",  ...
                'CopyFcn', copyFcnText,  ...
                'PreDeleteFcn', preDeleteFcnText,  ...
                'LoadFcn', loadFcnText,  ...
                'PreCopyFcn', preCopyFcnText );

            obj = obj.setAreaLocations(  );


            for moduleIdx = 1:obj.ModuleAssembly.TotNumModules
                currentBlockName = strcat( string( parentBlockName ), '/', obj.ModuleAssembly.Module( moduleIdx ).Name );
                add_block( strcat( obj.LibraryName, "_lib/Modules/", childComponent( moduleIdx ).ModuleBlocks.Identifier ) ...
                    , currentBlockName );
                simscape.scalable.setBlockConfig( currentBlockName, 'on' )
                set_param( currentBlockName, 'position', [  ...
                    obj.DiagramStartXLocation + obj.InterModuleSpacingFactor * moduleIdx,  ...
                    obj.DiagramStartYLocation,  ...
                    obj.DiagramStartXLocation + obj.InterModuleSpacingFactor * moduleIdx + obj.ModuleBlockWidth,  ...
                    obj.DiagramStartYLocation + obj.ModuleBlockHeight ],  ...
                    "ShowName", "on", "NameLocation", "bottom" );
                obj = obj.setConnectorIDs( moduleIdx );
            end
            obj = addMainConnectors( obj, parentBlockName );
            obj = obj.addSignalRouting( parentBlockName );
            obj = obj.addAmbientPath( parentBlockName );
            obj = obj.addCoolantPath( parentBlockName );
            obj = obj.addBalancingSignalRouting( parentBlockName );
            obj = obj.updateModuleAssemblySubsystemApperance( moduleAssemblyBlockName );
            obj = obj.addModuleAssemblyAreas( parentBlockName );
            obj.createModuleAssemblyMask( moduleAssemblyBlockName );
        end
    end


    methods ( Access = private )

        function obj = addMainConnectors( obj, parentBlockName )
            for moduleIdx = 1:obj.ModuleAssembly.TotNumModules
                currentBlockName = strcat( string( parentBlockName ), '/', obj.ModuleAssembly.Module( moduleIdx ).Name );
                currentModuleHandle = get_param( currentBlockName, 'PortHandles' );
                if moduleIdx == 1
                    initialModuleHandle = currentModuleHandle;
                end
                if moduleIdx > 1
                    previousBlockName = strcat( string( parentBlockName ), "/", obj.ModuleAssembly.Module( moduleIdx - 1 ).Name );
                    previousModuleHandle = get_param( previousBlockName, "PortHandles" );
                    switch obj.ModuleAssembly.CircuitConnection
                        case "Series"
                            add_line( parentBlockName, currentModuleHandle.LConn( obj.ConnIDs( moduleIdx ).PosConnID ), previousModuleHandle.RConn( obj.ConnIDs( moduleIdx - 1 ).NegConnID ), autorouting = 'smart' );
                        otherwise
                            add_line( parentBlockName, currentModuleHandle.LConn( obj.ConnIDs( moduleIdx ).PosConnID ), previousModuleHandle.LConn( obj.ConnIDs( moduleIdx - 1 ).PosConnID ), autorouting = 'smart' );
                            add_line( parentBlockName, currentModuleHandle.RConn( obj.ConnIDs( moduleIdx ).NegConnID ), previousModuleHandle.RConn( obj.ConnIDs( moduleIdx - 1 ).NegConnID ), autorouting = 'smart' );
                    end
                end
            end
            endModuleHandle = currentModuleHandle;
            if strcmp( obj.ModuleAssembly( 1 ).NonCellResistance, "Yes" )
                add_block( 'nesl_utility/Connection Port', strcat( parentBlockName, '/+' ) );
                set_param( strcat( parentBlockName, '/+' ), 'position', [  ...
                    obj.AreaSectionStartXLocation + obj.XOffsetFromArea,  ...
                    obj.BatterySectionStartYLocation + obj.YOffsetFromArea,  ...
                    obj.AreaSectionStartXLocation + obj.YOffsetFromArea + obj.ConnLabelBlockWidth,  ...
                    obj.BatterySectionStartYLocation + obj.YOffsetFromArea + obj.ConnLabelBlockHeight ] );
                positivePortHandle = get_param( strcat( parentBlockName, '/+' ), 'PortHandles' );

                ResistorValue = strcat( "1/1000", "/", string( 2 ) );
                add_block( 'fl_lib/Electrical/Electrical Elements/Resistor', strcat( string( parentBlockName ), "/", "Resistor", string( 1 ) ), "R", ResistorValue );
                set_param( strcat( string( parentBlockName ), "/", "Resistor", string( 1 ) ), 'position',  ...
                    [ obj.AreaSectionStartXLocation + obj.XOffsetFromArea * 2 + obj.ConnLabelBlockWidth,  ...
                    obj.BatterySectionStartYLocation + obj.YOffsetFromArea,  ...
                    obj.AreaSectionStartXLocation + obj.YOffsetFromArea * 2 + obj.ConnLabelBlockWidth + obj.ResistorBlockWidth,  ...
                    obj.BatterySectionStartYLocation + obj.YOffsetFromArea + obj.ResistorBlockHeight ],  ...
                    "ShowName", "off", "NameLocation", "bottom" );
                resistorHandle = get_param( strcat( string( parentBlockName ), "/", "Resistor", string( 1 ) ), "PortHandles" );
                add_line( parentBlockName, positivePortHandle.RConn, resistorHandle.LConn, autorouting = 'smart' );
                add_line( parentBlockName, resistorHandle.RConn, initialModuleHandle.LConn( obj.ConnIDs( 1 ).PosConnID ), autorouting = 'smart' )

                add_block( 'nesl_utility/Connection Port', strcat( parentBlockName, '/-' ) );
                set_param( strcat( parentBlockName, '/-' ),  ...
                    'position', [ obj.AreaSectionEndXLocation - obj.XOffsetFromArea - 20,  ...
                    obj.DiagramStartYLocation - 40,  ...
                    obj.AreaSectionEndXLocation - obj.XOffsetFromArea + obj.ConnLabelBlockWidth - 20,  ...
                    obj.DiagramStartYLocation - 20 ], 'Orientation', 'left', 'Side', 'right' );
                negativePortHandle = get_param( strcat( parentBlockName, '/-' ), 'PortHandles' );

                add_block( 'fl_lib/Electrical/Electrical Elements/Resistor', strcat( string( parentBlockName ), "/", "Resistor", string( 2 ) ), "R", ResistorValue );
                set_param( strcat( string( parentBlockName ), "/", "Resistor", string( 2 ) ), 'position',  ...
                    [ obj.AreaSectionEndXLocation - obj.XOffsetFromArea * 2 - 20 - obj.ConnLabelBlockWidth,  ...
                    obj.DiagramStartYLocation - 40,  ...
                    obj.AreaSectionEndXLocation - obj.XOffsetFromArea * 2 - 20 - obj.ConnLabelBlockWidth + obj.ConnLabelBlockWidth,  ...
                    obj.DiagramStartYLocation - 20 ],  ...
                    "ShowName", "off", "NameLocation", "bottom" );
                resistorHandle = get_param( strcat( string( parentBlockName ), "/", "Resistor", string( 2 ) ), "PortHandles" );

                add_line( parentBlockName, endModuleHandle.RConn( 1 ), resistorHandle.LConn, autorouting = 'smart' );
                add_line( parentBlockName, resistorHandle.RConn, negativePortHandle.RConn, autorouting = 'smart' );

            elseif strcmp( obj.ModuleAssembly( 1 ).NonCellResistance, "No" )

                add_block( 'nesl_utility/Connection Port', strcat( parentBlockName, '/+' ) );
                set_param( strcat( parentBlockName, '/+' ), 'position', [  ...
                    obj.AreaSectionStartXLocation + obj.XOffsetFromArea,  ...
                    obj.BatterySectionStartYLocation + obj.YOffsetFromArea,  ...
                    obj.AreaSectionStartXLocation + obj.YOffsetFromArea + obj.ConnLabelBlockWidth,  ...
                    obj.BatterySectionStartYLocation + obj.YOffsetFromArea + obj.ConnLabelBlockHeight ] );
                positivePortHandle = get_param( strcat( parentBlockName, '/+' ), 'PortHandles' );

                add_block( 'nesl_utility/Connection Port', strcat( parentBlockName, '/-' ) );
                set_param( strcat( parentBlockName, '/-' ),  ...
                    'position', [ obj.AreaSectionEndXLocation - obj.XOffsetFromArea - 20,  ...
                    obj.DiagramStartYLocation - 40,  ...
                    obj.AreaSectionEndXLocation - obj.XOffsetFromArea + obj.ConnLabelBlockWidth - 20,  ...
                    obj.DiagramStartYLocation - 20 ], 'Orientation', 'left', 'Side', 'right' );
                negativePortHandle = get_param( strcat( parentBlockName, '/-' ), 'PortHandles' );
                add_line( parentBlockName, initialModuleHandle.LConn( obj.ConnIDs( 1 ).PosConnID ), positivePortHandle.RConn, autorouting = 'smart' );
                add_line( parentBlockName, endModuleHandle.RConn( obj.ConnIDs( end  ).NegConnID ), negativePortHandle.RConn, autorouting = 'smart' );
            end
        end

        function obj = addSignalRouting( obj, parentBlockName )
            FromBlockPositionIndex = obj.ModuleAssembly.TotNumModules;
            for moduleIdx = 1:obj.ModuleAssembly.TotNumModules
                currentBlockName = strcat( string( parentBlockName ), '/', obj.ModuleAssembly.Module( moduleIdx ).Name );

                add_block( 'nesl_utility/Probe', strcat( currentBlockName, '_', "outputs" ),  ...
                    'position', [  ...
                    obj.DiagramStartXLocation + obj.InterModuleSpacingFactor * moduleIdx,  ...
                    obj.SignalSectionStartYLocation + obj.YOffsetFromArea,  ...
                    obj.DiagramStartXLocation + obj.ProbeBlockWidth + obj.InterModuleSpacingFactor * moduleIdx + 50,  ...
                    obj.SignalSectionStartYLocation + obj.YOffsetFromArea + obj.ProbeBlockHeight ] );

                simscape.probe.setBoundBlock( strcat( currentBlockName, '_', "outputs" ), strcat( currentBlockName ) );
                simscape.probe.setVariables( strcat( currentBlockName, '_', "outputs" ), obj.OutputSignals, 'Sort', true );
                connectionIndex = length( obj.OutputSignals );

                for labelIdx = 1:length( obj.OutputSignals )
                    add_block( 'simulink/Signal Routing/Goto', strcat( parentBlockName, '/', obj.OutputSignals( labelIdx ), string( moduleIdx ), '_', 'To' ), 'position',  ...
                        [ ( obj.DiagramStartXLocation + obj.InterModuleSpacingFactor * moduleIdx + 80 + obj.ProbeBlockWidth ),  ...
                        ( obj.SignalSectionStartYLocation + obj.ProbeBlockHeight + 10 - ( labelIdx - 1 ) * 30 ),  ...
                        ( obj.DiagramStartXLocation + obj.InterModuleSpacingFactor * moduleIdx + 80 + obj.ProbeBlockWidth + obj.LabelBlockWidth ),  ...
                        ( obj.SignalSectionStartYLocation + obj.LabelBlockHeight + obj.ProbeBlockHeight + 10 - ( labelIdx - 1 ) * 30 ) ],  ...
                        "ShowName", "off", "GotoTag", strcat( obj.OutputSignals( length( obj.OutputSignals ) + 1 - labelIdx ), string( moduleIdx ) ) );

                    probePortHandle = get_param( strcat( currentBlockName, '_', "outputs" ), 'PortHandles' );
                    toLabelPortHandle = get_param( strcat( parentBlockName, '/', obj.OutputSignals( labelIdx ), string( moduleIdx ), '_', 'To' ), 'PortHandles' );
                    add_line( parentBlockName, probePortHandle.Outport( connectionIndex ), toLabelPortHandle.Inport( 1 ), autorouting = 'smart' );

                    add_block( 'simulink/Signal Routing/From', strcat( parentBlockName, '/', obj.OutputSignals( labelIdx ), string( moduleIdx ), '_', 'From' ), 'position',  ...
                        [ ( obj.DiagramStartXLocation + labelIdx * obj.InterModuleSpacingFactor * 0.7 + 100 ),  ...
                        ( obj.SignalSectionStartYLocation + obj.YOffsetFromArea + obj.ProbeBlockHeight + obj.YOffsetFromArea + obj.MuxBlockHeight - ( FromBlockPositionIndex ) * 30 ),  ...
                        ( obj.DiagramStartXLocation + obj.LabelBlockWidth + ( labelIdx ) * obj.InterModuleSpacingFactor * 0.7 + 100 ),  ...
                        ( obj.SignalSectionStartYLocation + obj.YOffsetFromArea + obj.ProbeBlockHeight + obj.YOffsetFromArea + obj.MuxBlockHeight + obj.LabelBlockHeight - ( FromBlockPositionIndex ) * 30 ) ],  ...
                        "ShowName", "off", "GotoTag", strcat( obj.OutputSignals( labelIdx ), string( moduleIdx ) ) );

                    if moduleIdx == 1
                        add_block( 'simulink/Commonly Used Blocks/Mux', strcat( parentBlockName, '/', obj.OutputSignals( labelIdx ), 'Mux' ), 'position',  ...
                            [ obj.DiagramStartXLocation + ( labelIdx ) * obj.InterModuleSpacingFactor * 0.7 + 130 + obj.LabelBlockWidth,  ...
                            obj.SignalSectionStartYLocation + obj.YOffsetFromArea + obj.ProbeBlockHeight + obj.YOffsetFromArea,  ...
                            obj.DiagramStartXLocation + ( labelIdx ) * obj.InterModuleSpacingFactor * 0.7 + 130 + obj.LabelBlockWidth + obj.MuxBlockWidth,  ...
                            obj.SignalSectionStartYLocation + obj.YOffsetFromArea + obj.ProbeBlockHeight + obj.YOffsetFromArea + obj.MuxBlockHeight ],  ...
                            "Inputs", string( obj.ModuleAssembly.TotNumModules ), "ShowName", "off" );

                        add_block( 'simulink/Commonly Used Blocks/Out1', strcat( parentBlockName, '/', obj.OutputSignals( labelIdx ) ), 'position',  ...
                            [ obj.DiagramStartXLocation + ( labelIdx ) * obj.InterModuleSpacingFactor * 0.7 + 130 + obj.LabelBlockWidth + 30,  ...
                            obj.SignalSectionStartYLocation + obj.YOffsetFromArea + obj.ProbeBlockHeight + obj.YOffsetFromArea + ( obj.MuxBlockHeight ) / 2 - 10,  ...
                            obj.DiagramStartXLocation + ( labelIdx ) * obj.InterModuleSpacingFactor * 0.7 + 130 + obj.LabelBlockWidth + obj.MuxBlockWidth + 60,  ...
                            obj.SignalSectionStartYLocation + obj.YOffsetFromArea + obj.ProbeBlockHeight + obj.YOffsetFromArea + ( obj.MuxBlockHeight ) / 2 - 10 + 20 ], "ShowName", "on" );

                        muxPortHandle = get_param( strcat( parentBlockName, '/', obj.OutputSignals( labelIdx ), 'Mux' ), 'PortHandles' );
                        outPortHandle = get_param( strcat( parentBlockName, '/', obj.OutputSignals( labelIdx ) ), 'PortHandles' );
                        add_line( parentBlockName, muxPortHandle.Outport, outPortHandle.Inport, autorouting = 'smart' );
                    end
                    fromLabelPortHandle = get_param( strcat( parentBlockName, '/', obj.OutputSignals( labelIdx ), string( moduleIdx ), '_', 'From' ), 'PortHandles' );
                    muxPortHandle = get_param( strcat( parentBlockName, '/', obj.OutputSignals( labelIdx ), 'Mux' ), 'PortHandles' );
                    add_line( parentBlockName, fromLabelPortHandle.Outport( 1 ), muxPortHandle.Inport( moduleIdx ), autorouting = 'smart' );
                    connectionIndex = connectionIndex - 1;
                end
                FromBlockPositionIndex = FromBlockPositionIndex - 1;
            end
        end

        function obj = addAmbientPath( obj, parentBlockName )

            if ~strcmp( obj.ModuleAssembly.AmbientThermalPath, "" )
                for moduleIdx = 1:obj.ModuleAssembly.TotNumModules
                    currentBlockName = strcat( string( parentBlockName ), '/', obj.ModuleAssembly.Module( moduleIdx ).Name );
                    currentModuleHandle = get_param( currentBlockName, 'PortHandles' );
                    modulePortConnectivity = get_param( currentBlockName, 'PortConnectivity' );
                    ambPortPosition = modulePortConnectivity( obj.ConnIDs( moduleIdx ).AmbHConnID ).Position;
                    ambPortPositionX = ambPortPosition( 1 );
                    ambPortPositionY = ambPortPosition( 2 );

                    add_block( 'nesl_utility/Connection Label', strcat( parentBlockName, '/AmbH_To_', string( moduleIdx ) ),  ...
                        "position", [ ambPortPositionX - obj.ConnLabelBlockWidth - 10,  ...
                        ambPortPositionY - obj.ConnLabelBlockHeight / 2,  ...
                        ambPortPositionX - obj.ConnLabelBlockWidth,  ...
                        ambPortPositionY + obj.ConnLabelBlockHeight / 2 ],  ...
                        'Orientation', 'left', "label", strcat( "ambH_", string( moduleIdx ) ),  ...
                        "ShowName", "off" );
                    ambToConnLabelPortHandle = get_param( strcat( parentBlockName, '/AmbH_To_', string( moduleIdx ) ), 'PortHandles' );
                    add_line( parentBlockName, ambToConnLabelPortHandle.LConn( 1 ), currentModuleHandle.LConn( obj.ConnIDs( moduleIdx ).AmbHConnID ), autorouting = 'smart' );

                    if moduleIdx == 1
                        add_block( 'nesl_utility/Connection Port', strcat( parentBlockName, '/AmbH' ) );
                        set_param( strcat( parentBlockName, '/AmbH' ), 'position',  ...
                            [ ( obj.AreaSectionStartXLocation + 100 ),  ...
                            ( obj.ThermalSectionStartYLocation + 60 ),  ...
                            ( obj.AreaSectionStartXLocation + 100 + obj.ConnLabelBlockWidth ),  ...
                            ( obj.ThermalSectionStartYLocation + 60 + obj.ConnLabelBlockHeight ) ],  ...
                            'Orientation', 'right', 'Side', 'right' );
                        ambHPortHandle = get_param( strcat( parentBlockName, '/AmbH' ), 'PortHandles' );
                    end

                    add_block( 'nesl_utility/Connection Label', strcat( parentBlockName, '/AmbH_From_', string( moduleIdx ) ),  ...
                        "position", [ obj.DiagramStartXLocation + obj.InterModuleSpacingFactor + 80,  ...
                        obj.ThermalSectionStartYLocation + 60 + ( moduleIdx - 1 ) * 30,  ...
                        obj.DiagramStartXLocation + obj.InterModuleSpacingFactor + 80 + obj.ConnLabelBlockWidth,  ...
                        obj.ThermalSectionStartYLocation + 60 + obj.ConnLabelBlockHeight + ( moduleIdx - 1 ) * 30 ],  ...
                        'Orientation', 'right', "label", strcat( "ambH_", string( moduleIdx ) ),  ...
                        "ShowName", "off" );
                    ambFromConnLabelPortHandle = get_param( strcat( parentBlockName, '/AmbH_From_', string( moduleIdx ) ), 'PortHandles' );
                    add_line( parentBlockName, ambFromConnLabelPortHandle.LConn, ambHPortHandle.RConn, autorouting = 'smart' )
                end
            end
        end


        function obj = addCoolantPath( obj, parentBlockName )

            for moduleIdx = 1:obj.ModuleAssembly.TotNumModules
                if ~strcmp( obj.ModuleAssembly.CoolantThermalPath, "" ) && all( strcmp( obj.ModuleAssembly.Module( moduleIdx ).CoolingPlate, "" ) )
                    currentBlockName = strcat( string( parentBlockName ), '/', obj.ModuleAssembly.Module( moduleIdx ).Name );
                    currentModuleHandle = get_param( currentBlockName, 'PortHandles' );
                    modulePortConnectivity = get_param( currentBlockName, 'PortConnectivity' );
                    clntPortPosition = modulePortConnectivity( obj.ConnIDs( moduleIdx ).ClntHConnID ).Position;
                    clntPortPositionX = clntPortPosition( 1 );
                    clntPortPositionY = clntPortPosition( 2 );

                    add_block( 'nesl_utility/Connection Label', strcat( parentBlockName, '/ClntH_To_', string( moduleIdx ) ),  ...
                        "position", [ clntPortPositionX - obj.ConnLabelBlockWidth - 10,  ...
                        clntPortPositionY - obj.ConnLabelBlockHeight / 2,  ...
                        clntPortPositionX - obj.ConnLabelBlockWidth,  ...
                        clntPortPositionY + obj.ConnLabelBlockHeight / 2 ],  ...
                        'Orientation', 'left', "label", strcat( "clntH_", string( moduleIdx ) ),  ...
                        "ShowName", "off" );
                    ambToConnLabelPortHandle = get_param( strcat( parentBlockName, '/ClntH_To_', string( moduleIdx ) ), 'PortHandles' );
                    add_line( parentBlockName, ambToConnLabelPortHandle.LConn( 1 ), currentModuleHandle.LConn( obj.ConnIDs( moduleIdx ).ClntHConnID ), autorouting = 'smart' );
                    if ~strcmp( obj.ModuleAssembly.AmbientThermalPath, "" )
                        clntInOffSet = 300;
                    else
                        clntInOffSet = 0;
                    end

                    if ( getSimulinkBlockHandle( strcat( parentBlockName, '/ClntH' ) ) ==  - 1 )
                        add_block( 'nesl_utility/Connection Port', strcat( parentBlockName, '/ClntH' ) );
                        set_param( strcat( parentBlockName, '/ClntH' ), 'position',  ...
                            [ obj.AreaSectionStartXLocation + 100 + clntInOffSet,  ...
                            obj.ThermalSectionStartYLocation + 60,  ...
                            obj.AreaSectionStartXLocation + 100 + obj.ConnLabelBlockWidth + clntInOffSet,  ...
                            obj.ThermalSectionStartYLocation + 60 + obj.ConnLabelBlockHeight ],  ...
                            'Orientation', 'right', 'Side', 'right' );
                        clntHPortHandle = get_param( strcat( parentBlockName, '/ClntH' ), 'PortHandles' );
                    end
                    add_block( 'nesl_utility/Connection Label', strcat( parentBlockName, '/ClntH_From_', string( moduleIdx ) ),  ...
                        "position", [ obj.DiagramStartXLocation + obj.InterModuleSpacingFactor + 80 + clntInOffSet,  ...
                        obj.ThermalSectionStartYLocation + 60 +  + ( moduleIdx - 1 ) * 30,  ...
                        obj.DiagramStartXLocation + obj.InterModuleSpacingFactor + 80 + obj.ConnLabelBlockWidth + clntInOffSet,  ...
                        obj.ThermalSectionStartYLocation + 60 + obj.ConnLabelBlockHeight + ( moduleIdx - 1 ) * 30 ],  ...
                        'Orientation', 'right', "label", strcat( "clntH_", string( moduleIdx ) ),  ...
                        "ShowName", "off" );
                    clntFromConnLabelPortHandle = get_param( strcat( parentBlockName, '/ClntH_From_', string( moduleIdx ) ), 'PortHandles' );
                    add_line( parentBlockName, clntFromConnLabelPortHandle.LConn, clntHPortHandle.RConn, autorouting = 'smart' )
                end
            end
        end

        function obj = addBalancingSignalRouting( obj, parentBlockName )

            if ~strcmp( obj.ModuleAssembly.Module( 1 ).BalancingStrategy, "" )


                TotParallelAssemblies = 0;
                TrackingIndex = 1;
                for moduleIdx = 1:obj.ModuleAssembly.TotNumModules
                    moduleNumParallelAssemblies = obj.ModuleAssembly.Module( moduleIdx ).NumSeriesAssemblies;
                    TotParallelAssemblies = moduleNumParallelAssemblies + TotParallelAssemblies;
                    ParallelAssembliesVec( moduleIdx ).ParallelAssembliesIndices = TrackingIndex:( moduleNumParallelAssemblies + TrackingIndex - 1 );%#ok<AGROW>
                    TrackingIndex = moduleNumParallelAssemblies + TrackingIndex;
                end

                add_block( 'simulink/Commonly Used Blocks/In1', strcat( parentBlockName, '/balancing' ),  ...
                    "position", [  ...
                    ( obj.AreaSectionStartXLocation + obj.XOffsetFromArea ),  ...
                    ( obj.BalancingSectionStartYLocation + obj.YOffsetFromArea + obj.MuxBlockHeight / 2 ),  ...
                    ( obj.AreaSectionStartXLocation + obj.XOffsetFromArea + obj.ConnLabelBlockWidth ),  ...
                    ( obj.BalancingSectionStartYLocation + obj.YOffsetFromArea + obj.ConnLabelBlockHeight + obj.MuxBlockHeight / 2 ) ],  ...
                    "PortDimensions", string( TotParallelAssemblies ) );
                balacingIn1Handle = get_param( strcat( parentBlockName, '/balancing' ), 'PortHandles' );

                for moduleIdx = 1:obj.ModuleAssembly.TotNumModules
                    currentBlockName = strcat( string( parentBlockName ), '/', obj.ModuleAssembly.Module( moduleIdx ).Name );
                    modulePortConnectivity = get_param( currentBlockName, 'PortConnectivity' );
                    balPortPosition = modulePortConnectivity( obj.ConnIDs( moduleIdx ).CellBalancingConnID ).Position;
                    balPortPositionX = balPortPosition( 1 );
                    balPortPositionY = balPortPosition( 2 );

                    add_block( 'simulink/Signal Routing/Selector', strcat( parentBlockName, '/balancingSelector', string( moduleIdx ) ),  ...
                        "position", [  ...
                        ( obj.AreaSectionStartXLocation + obj.XOffsetFromArea + 80 ),  ...
                        ( obj.BalancingSectionStartYLocation + obj.YOffsetFromArea + 10 + ( moduleIdx - 1 ) * 40 ),  ...
                        ( obj.AreaSectionStartXLocation + obj.XOffsetFromArea + obj.SelectorBlockWidth + 80 ),  ...
                        ( obj.BalancingSectionStartYLocation + obj.YOffsetFromArea + 10 + ( moduleIdx - 1 ) * 40 ) + obj.SelectorBlockHeight ],  ...
                        "InputPortWidth", num2str( TotParallelAssemblies ),  ...
                        "Indices", strcat( '[', num2str( [ ParallelAssembliesVec( moduleIdx ).ParallelAssembliesIndices ] ), ']' ),  ...
                        "ShowName", "off" );

                    add_block( 'simulink/Signal Routing/Goto', strcat( parentBlockName, '/', "balancing", string( moduleIdx ), '_', 'To' ),  ...
                        'position',  ...
                        [ obj.AreaSectionStartXLocation + obj.XOffsetFromArea + 140 + obj.SelectorBlockWidth,  ...
                        ( obj.BalancingSectionStartYLocation + obj.YOffsetFromArea + 15 + ( moduleIdx - 1 ) * 40 ),  ...
                        obj.AreaSectionStartXLocation + obj.XOffsetFromArea + 140 + obj.SelectorBlockWidth + obj.LabelBlockWidth,  ...
                        ( obj.BalancingSectionStartYLocation + obj.YOffsetFromArea + 15 + ( moduleIdx - 1 ) * 40 ) + obj.LabelBlockHeight ],  ...
                        "ShowName", "off", "GotoTag", strcat( "balancing", string( moduleIdx ) ) );

                    add_block( 'simulink/Signal Routing/From', strcat( parentBlockName, '/', "balancing", string( moduleIdx ), '_', 'From' ),  ...
                        'position',  ...
                        [ balPortPositionX - obj.LabelBlockWidth - 100,  ...
                        balPortPositionY - obj.LabelBlockHeight / 2,  ...
                        balPortPositionX - 100,  ...
                        balPortPositionY + obj.LabelBlockHeight / 2 ],  ...
                        "ShowName", "off", "GotoTag", strcat( "balancing", string( moduleIdx ) ), "orientation", "right" );

                    add_block( 'nesl_utility/Simulink-PS Converter', strcat( parentBlockName, '/Converter', string( moduleIdx ) ),  ...
                        "position",  ...
                        [ balPortPositionX - obj.ConnLabelBlockWidth - 30,  ...
                        balPortPositionY - obj.ConnLabelBlockHeight / 2,  ...
                        balPortPositionX - 30,  ...
                        balPortPositionY + obj.ConnLabelBlockHeight / 2 ],  ...
                        "ShowName", "off" );

                    moduleHandle = get_param( currentBlockName, 'PortHandles' );
                    balacingSelectorHandle = get_param( strcat( parentBlockName, '/balancingSelector', string( moduleIdx ) ), 'PortHandles' );
                    converterHandle = get_param( strcat( parentBlockName, '/Converter', string( moduleIdx ) ), 'PortHandles' );
                    balacingGotoHandle = get_param( strcat( parentBlockName, '/', "balancing", string( moduleIdx ), '_', 'To' ), 'PortHandles' );
                    balacingFromHandle = get_param( strcat( parentBlockName, '/', "balancing", string( moduleIdx ), '_', 'From' ), 'PortHandles' );

                    add_line( parentBlockName, balacingIn1Handle.Outport, balacingSelectorHandle.Inport( 1 ), autorouting = 'smart' );
                    add_line( parentBlockName, balacingSelectorHandle.Outport, balacingGotoHandle.Inport, autorouting = 'smart' )
                    add_line( parentBlockName, balacingFromHandle.Outport, converterHandle.Inport, autorouting = 'smart' );
                    add_line( parentBlockName, converterHandle.RConn, moduleHandle.LConn( obj.ConnIDs( moduleIdx ).CellBalancingConnID ), autorouting = 'smart' )

                end
            end
        end

        function obj = setAreaLocations( obj )
            obj.BatterySectionStartYLocation = obj.DiagramStartYLocation - 100;
            obj.BatterySectionEndYLocation = obj.DiagramStartYLocation + obj.ModuleBlockHeight + obj.YOffsetFromArea * 3;

            obj.SignalSectionStartYLocation = obj.BatterySectionEndYLocation + obj.YOffsetFromArea;
            obj.SignalSectionEndYLocation = obj.BatterySectionEndYLocation + obj.ProbeBlockHeight + obj.MuxBlockHeight + obj.YOffsetFromArea * 4;

            obj.ThirdSectionStartYLocation = obj.SignalSectionEndYLocation + obj.YOffsetFromArea;
            obj.ThirdSectionEndYLocation = obj.SignalSectionEndYLocation + obj.YOffsetFromArea + ( obj.ModuleAssembly.TotNumModules ) * 40 + 100;

            obj.FourthSectionStartYLocation = obj.ThirdSectionEndYLocation + obj.YOffsetFromArea;
            obj.FourthSectionEndYLocation = obj.FourthSectionStartYLocation + ( obj.ModuleAssembly.TotNumModules ) * 40 + 100;

            if ( ~strcmp( obj.ModuleAssembly.Module( 1 ).AmbientThermalPath, "" ) || ~strcmp( obj.ModuleAssembly.Module( 1 ).CoolantThermalPath, "" ) ) ...
                    && ~strcmp( obj.ModuleAssembly.Module( 1 ).BalancingStrategy, "" )
                obj.ThermalSectionStartYLocation = obj.ThirdSectionStartYLocation;
                obj.ThermalSectionEndYLocation = obj.ThirdSectionEndYLocation;
                obj.BalancingSectionStartYLocation = obj.FourthSectionStartYLocation;
                obj.BalancingSectionEndYLocation = obj.FourthSectionEndYLocation;
            elseif ( strcmp( obj.ModuleAssembly.Module( 1 ).AmbientThermalPath, "" ) || strcmp( obj.ModuleAssembly.Module( 1 ).CoolantThermalPath, "" ) ) ...
                    && ~strcmp( obj.ModuleAssembly.Module( 1 ).BalancingStrategy, "" )
                obj.ThermalSectionStartYLocation = [  ];
                obj.ThermalSectionEndYLocation = [  ];
                obj.BalancingSectionStartYLocation = obj.ThirdSectionStartYLocation;
                obj.BalancingSectionEndYLocation = obj.ThirdSectionEndYLocation;
            else
                obj.ThermalSectionStartYLocation = obj.ThirdSectionStartYLocation;
                obj.ThermalSectionEndYLocation = obj.ThirdSectionEndYLocation;
                obj.BalancingSectionStartYLocation = [  ];
                obj.BalancingSectionEndYLocation = [  ];
            end

        end

        function obj = updateModuleAssemblySubsystemApperance( obj, moduleAssemblyBlockName )
            set_param( moduleAssemblyBlockName, "Orientation", "down", "NameLocation", "bottom" );
            moduleAssemblyHandles = get_param( moduleAssemblyBlockName, 'PortHandles' );
            signalPlacementIdx = length( obj.OutputSignals );
            for outputSignalIdx = 1:length( obj.OutputSignals )
                Simulink.PortPlacement.setPortLocation( moduleAssemblyHandles.Outport( signalPlacementIdx ), 'Bottom:1', 'block' )
                signalPlacementIdx = signalPlacementIdx - 1;
            end
            if ~strcmp( obj.ModuleAssembly.Module( 1 ).BalancingStrategy, "" )
                Simulink.PortPlacement.setPortLocation( moduleAssemblyHandles.Inport( 1 ), 'Top:1', 'block' )
            end
        end

        function obj = addModuleAssemblyAreas( obj, parentBlockName )
            add_block( 'built-in/Area', strcat( parentBlockName, '/Battery Modules' ),  ...
                'Position', [  ...
                obj.AreaSectionStartXLocation,  ...
                obj.BatterySectionStartYLocation,  ...
                obj.AreaSectionEndXLocation,  ...
                obj.BatterySectionEndYLocation ], "DropShadow", "on", "FontWeight", "bold" )

            add_block( 'built-in/Area', strcat( parentBlockName, '/Output Signals' ),  ...
                'Position', [  ...
                obj.AreaSectionStartXLocation,  ...
                obj.SignalSectionStartYLocation,  ...
                obj.AreaSectionEndXLocation,  ...
                obj.SignalSectionEndYLocation ], "DropShadow", "on", "FontWeight", "bold" )

            if ~strcmp( obj.ModuleAssembly.Module( 1 ).AmbientThermalPath, "" ) || ~strcmp( obj.ModuleAssembly.Module( 1 ).CoolantThermalPath, "" )
                add_block( 'built-in/Area', strcat( parentBlockName, '/Thermal Boundary Conditions' ),  ...
                    'Position', [  ...
                    obj.AreaSectionStartXLocation,  ...
                    obj.ThermalSectionStartYLocation,  ...
                    obj.AreaSectionEndXLocation,  ...
                    obj.ThermalSectionEndYLocation ], "DropShadow", "on", "FontWeight", "bold" )
            end

            if ~strcmp( obj.ModuleAssembly.Module( 1 ).BalancingStrategy, "" )
                add_block( 'built-in/Area', strcat( parentBlockName, '/Balancing Signals' ),  ...
                    'Position', [  ...
                    obj.AreaSectionStartXLocation,  ...
                    obj.BalancingSectionStartYLocation,  ...
                    obj.AreaSectionEndXLocation,  ...
                    obj.BalancingSectionEndYLocation ], "DropShadow", "on", "FontWeight", "bold" )
            end
        end

        function obj = createModuleAssemblyMask( obj, moduleAssemblyBlockName )
            if obj.IsHighestLevel
            else
                open_system( strcat( obj.LibraryName, "/ModuleAssemblies" ) );
            end
            moduleAssemblyMaskObj = Simulink.Mask.create( moduleAssemblyBlockName );
            moduleAssemblyMaskObj.ImageFile = fullfile( matlabroot, 'toolbox', 'physmod', 'battery', 'builder', 'm', '+simscape', '+battery', '+builder', '+internal', '+export', 'Icons', 'moduleAssembly.JPG' );
            Simulink.Mask.convertToInternalImage( moduleAssemblyBlockName )
            moduleAssemblyMaskObj.Display = "image('$imagefile')";
            moduleAssemblyMaskObj.IconOpaque = "opaque-with-ports";
            open_system( obj.LibraryName );
            save_system( obj.LibraryName );
            close_system( obj.LibraryName );
        end

        function obj = setConnectorIDs( obj, moduleIdx )
            if ~strcmp( obj.ModuleAssembly.AmbientThermalPath, "" ) && ~strcmp( obj.ModuleAssembly.CoolantThermalPath, "" ) ...
                    && ~strcmp( obj.ModuleAssembly.BalancingStrategy, "" ) && all( strcmp( obj.ModuleAssembly.Module( moduleIdx ).CoolingPlate, "" ) )
                obj.ConnIDs( moduleIdx ).PosConnID = 4;
                obj.ConnIDs( moduleIdx ).NegConnID = 1;
                obj.ConnIDs( moduleIdx ).ClntHConnID = 2;
                obj.ConnIDs( moduleIdx ).AmbHConnID = 3;
                obj.ConnIDs( moduleIdx ).CellBalancingConnID = 1;
            elseif strcmp( obj.ModuleAssembly.AmbientThermalPath, "" ) && strcmp( obj.ModuleAssembly.CoolantThermalPath, "" ) ...
                    && strcmp( obj.ModuleAssembly.BalancingStrategy, "" ) && all( strcmp( obj.ModuleAssembly.Module( moduleIdx ).CoolingPlate, "" ) )
                obj.ConnIDs( moduleIdx ).PosConnID = 1;
                obj.ConnIDs( moduleIdx ).NegConnID = 1;
                obj.ConnIDs( moduleIdx ).ClntHConnID = [  ];
                obj.ConnIDs( moduleIdx ).AmbHConnID = [  ];
                obj.ConnIDs( moduleIdx ).CellBalancingConnID = [  ];
            elseif strcmp( obj.ModuleAssembly.AmbientThermalPath, "" ) && strcmp( obj.ModuleAssembly.CoolantThermalPath, "" ) ...
                    && ~strcmp( obj.ModuleAssembly.BalancingStrategy, "" ) && all( strcmp( obj.ModuleAssembly.Module( moduleIdx ).CoolingPlate, "" ) )
                obj.ConnIDs( moduleIdx ).PosConnID = 2;
                obj.ConnIDs( moduleIdx ).NegConnID = 1;
                obj.ConnIDs( moduleIdx ).ClntHConnID = [  ];
                obj.ConnIDs( moduleIdx ).AmbHConnID = [  ];
                obj.ConnIDs( moduleIdx ).CellBalancingConnID = 1;
            elseif ~strcmp( obj.ModuleAssembly.AmbientThermalPath, "" ) && strcmp( obj.ModuleAssembly.CoolantThermalPath, "" ) &&  ...
                    strcmp( obj.ModuleAssembly.BalancingStrategy, "" ) && all( strcmp( obj.ModuleAssembly.Module( moduleIdx ).CoolingPlate, "" ) )
                obj.ConnIDs( moduleIdx ).PosConnID = 2;
                obj.ConnIDs( moduleIdx ).NegConnID = 1;
                obj.ConnIDs( moduleIdx ).ClntHConnID = [  ];
                obj.ConnIDs( moduleIdx ).AmbHConnID = 1;
                obj.ConnIDs( moduleIdx ).CellBalancingConnID = [  ];
            elseif strcmp( obj.ModuleAssembly.AmbientThermalPath, "" ) && ~strcmp( obj.ModuleAssembly.CoolantThermalPath, "" ) &&  ...
                    strcmp( obj.ModuleAssembly.BalancingStrategy, "" ) && all( strcmp( obj.ModuleAssembly.Module( moduleIdx ).CoolingPlate, "" ) )
                obj.ConnIDs( moduleIdx ).PosConnID = 2;
                obj.ConnIDs( moduleIdx ).NegConnID = 1;
                obj.ConnIDs( moduleIdx ).ClntHConnID = 1;
                obj.ConnIDs( moduleIdx ).AmbHConnID = [  ];
                obj.ConnIDs( moduleIdx ).CellBalancingConnID = [  ];
            elseif ~strcmp( obj.ModuleAssembly.AmbientThermalPath, "" ) && strcmp( obj.ModuleAssembly.CoolantThermalPath, "" ) &&  ...
                    ~strcmp( obj.ModuleAssembly.BalancingStrategy, "" ) && all( strcmp( obj.ModuleAssembly.Module( 1 ).CoolingPlate, "" ) )
                obj.ConnIDs( moduleIdx ).PosConnID = 3;
                obj.ConnIDs( moduleIdx ).NegConnID = 1;
                obj.ConnIDs( moduleIdx ).ClntHConnID = [  ];
                obj.ConnIDs( moduleIdx ).AmbHConnID = 2;
                obj.ConnIDs( moduleIdx ).CellBalancingConnID = 1;
            elseif ~strcmp( obj.ModuleAssembly.AmbientThermalPath, "" ) && ~strcmp( obj.ModuleAssembly.CoolantThermalPath, "" ) &&  ...
                    strcmp( obj.ModuleAssembly.BalancingStrategy, "" ) && all( strcmp( obj.ModuleAssembly.Module( moduleIdx ).CoolingPlate, "" ) )
                obj.ConnIDs( moduleIdx ).PosConnID = 3;
                obj.ConnIDs( moduleIdx ).NegConnID = 1;
                obj.ConnIDs( moduleIdx ).ClntHConnID = 1;
                obj.ConnIDs( moduleIdx ).AmbHConnID = 2;
                obj.ConnIDs( moduleIdx ).CellBalancingConnID = [  ];
            elseif ~strcmp( obj.ModuleAssembly.AmbientThermalPath, "" ) && ~strcmp( obj.ModuleAssembly.CoolantThermalPath, "" ) &&  ...
                    strcmp( obj.ModuleAssembly.BalancingStrategy, "" ) &&  ...
                    ( any( strcmp( obj.ModuleAssembly.Module( moduleIdx ).CoolingPlate, "Top" ) ) || any( strcmp( obj.ModuleAssembly.Module( moduleIdx ).CoolingPlate, "Bottom" ) ) )
                obj.ConnIDs( moduleIdx ).PosConnID = 2;
                obj.ConnIDs( moduleIdx ).NegConnID = 1;
                obj.ConnIDs( moduleIdx ).ClntHConnID = [  ];
                obj.ConnIDs( moduleIdx ).AmbHConnID = 1;
                obj.ConnIDs( moduleIdx ).CellBalancingConnID = [  ];
            elseif ~strcmp( obj.ModuleAssembly.AmbientThermalPath, "" ) && ~strcmp( obj.ModuleAssembly.CoolantThermalPath, "" ) &&  ...
                    ~strcmp( obj.ModuleAssembly.BalancingStrategy, "" ) &&  ...
                    ( any( strcmp( obj.ModuleAssembly.Module( moduleIdx ).CoolingPlate, "Top" ) ) || any( strcmp( obj.ModuleAssembly.Module( moduleIdx ).CoolingPlate, "Bottom" ) ) )
                obj.ConnIDs( moduleIdx ).PosConnID = 3;
                obj.ConnIDs( moduleIdx ).NegConnID = 1;
                obj.ConnIDs( moduleIdx ).ClntHConnID = [  ];
                obj.ConnIDs( moduleIdx ).AmbHConnID = 2;
                obj.ConnIDs( moduleIdx ).CellBalancingConnID = 1;
            elseif ~strcmp( obj.ModuleAssembly.AmbientThermalPath, "" ) && strcmp( obj.ModuleAssembly.CoolantThermalPath, "" ) &&  ...
                    ~strcmp( obj.ModuleAssembly.BalancingStrategy, "" ) &&  ...
                    ( any( strcmp( obj.ModuleAssembly.Module( moduleIdx ).CoolingPlate, "Top" ) ) || any( strcmp( obj.ModuleAssembly.Module( moduleIdx ).CoolingPlate, "Bottom" ) ) )
                obj.ConnIDs( moduleIdx ).PosConnID = 3;
                obj.ConnIDs( moduleIdx ).NegConnID = 1;
                obj.ConnIDs( moduleIdx ).ClntHConnID = [  ];
                obj.ConnIDs( moduleIdx ).AmbHConnID = 2;
                obj.ConnIDs( moduleIdx ).CellBalancingConnID = 1;
            elseif strcmp( obj.ModuleAssembly.AmbientThermalPath, "" ) && ~strcmp( obj.ModuleAssembly.CoolantThermalPath, "" ) &&  ...
                    ~strcmp( obj.ModuleAssembly.BalancingStrategy, "" ) &&  ...
                    ( any( strcmp( obj.ModuleAssembly.Module( moduleIdx ).CoolingPlate, "Top" ) ) || any( strcmp( obj.ModuleAssembly.Module( moduleIdx ).CoolingPlate, "Bottom" ) ) )
                obj.ConnIDs( moduleIdx ).PosConnID = 2;
                obj.ConnIDs( moduleIdx ).NegConnID = 1;
                obj.ConnIDs( moduleIdx ).ClntHConnID = [  ];
                obj.ConnIDs( moduleIdx ).AmbHConnID = [  ];
                obj.ConnIDs( moduleIdx ).CellBalancingConnID = 1;
            elseif strcmp( obj.ModuleAssembly.AmbientThermalPath, "" ) && ~strcmp( obj.ModuleAssembly.CoolantThermalPath, "" ) &&  ...
                    strcmp( obj.ModuleAssembly.BalancingStrategy, "" ) &&  ...
                    ( any( strcmp( obj.ModuleAssembly.Module( moduleIdx ).CoolingPlate, "Top" ) ) || any( strcmp( obj.ModuleAssembly.Module( moduleIdx ).CoolingPlate, "Bottom" ) ) )
                obj.ConnIDs( moduleIdx ).PosConnID = 1;
                obj.ConnIDs( moduleIdx ).NegConnID = 1;
                obj.ConnIDs( moduleIdx ).ClntHConnID = [  ];
                obj.ConnIDs( moduleIdx ).AmbHConnID = [  ];
                obj.ConnIDs( moduleIdx ).CellBalancingConnID = [  ];
            elseif strcmp( obj.ModuleAssembly.AmbientThermalPath, "" ) && strcmp( obj.ModuleAssembly.CoolantThermalPath, "" ) &&  ...
                    strcmp( obj.ModuleAssembly.BalancingStrategy, "" ) &&  ...
                    ( any( strcmp( obj.ModuleAssembly.Module( moduleIdx ).CoolingPlate, "Top" ) ) || any( strcmp( obj.ModuleAssembly.Module( moduleIdx ).CoolingPlate, "Bottom" ) ) )
                obj.ConnIDs( moduleIdx ).PosConnID = 1;
                obj.ConnIDs( moduleIdx ).NegConnID = 1;
                obj.ConnIDs( moduleIdx ).ClntHConnID = [  ];
                obj.ConnIDs( moduleIdx ).AmbHConnID = [  ];
                obj.ConnIDs( moduleIdx ).CellBalancingConnID = [  ];
            elseif strcmp( obj.ModuleAssembly.AmbientThermalPath, "" ) && ~strcmp( obj.ModuleAssembly.CoolantThermalPath, "" ) &&  ...
                    ~strcmp( obj.ModuleAssembly.BalancingStrategy, "" ) &&  ...
                    all( strcmp( obj.ModuleAssembly.Module( moduleIdx ).CoolingPlate, "" ) )
                obj.ConnIDs( moduleIdx ).PosConnID = 3;
                obj.ConnIDs( moduleIdx ).NegConnID = 1;
                obj.ConnIDs( moduleIdx ).ClntHConnID = 2;
                obj.ConnIDs( moduleIdx ).AmbHConnID = [  ];
                obj.ConnIDs( moduleIdx ).CellBalancingConnID = 1;
            elseif ~strcmp( obj.ModuleAssembly.AmbientThermalPath, "" ) && strcmp( obj.ModuleAssembly.CoolantThermalPath, "" ) &&  ...
                    strcmp( obj.ModuleAssembly.BalancingStrategy, "" ) &&  ...
                    ( any( strcmp( obj.ModuleAssembly.Module( moduleIdx ).CoolingPlate, "Top" ) ) || any( strcmp( obj.ModuleAssembly.Module( moduleIdx ).CoolingPlate, "Bottom" ) ) )
                obj.ConnIDs( moduleIdx ).PosConnID = 2;
                obj.ConnIDs( moduleIdx ).NegConnID = 1;
                obj.ConnIDs( moduleIdx ).ClntHConnID = [  ];
                obj.ConnIDs( moduleIdx ).AmbHConnID = 1;
                obj.ConnIDs( moduleIdx ).CellBalancingConnID = [  ];
            elseif strcmp( obj.ModuleAssembly.AmbientThermalPath, "" ) && strcmp( obj.ModuleAssembly.CoolantThermalPath, "" ) &&  ...
                    ~strcmp( obj.ModuleAssembly.BalancingStrategy, "" ) &&  ...
                    ( any( strcmp( obj.ModuleAssembly.Module( moduleIdx ).CoolingPlate, "Top" ) ) || any( strcmp( obj.ModuleAssembly.Module( moduleIdx ).CoolingPlate, "Bottom" ) ) )
                obj.ConnIDs( moduleIdx ).PosConnID = 2;
                obj.ConnIDs( moduleIdx ).NegConnID = 1;
                obj.ConnIDs( moduleIdx ).ClntHConnID = [  ];
                obj.ConnIDs( moduleIdx ).AmbHConnID = [  ];
                obj.ConnIDs( moduleIdx ).CellBalancingConnID = 1;
            end
        end

    end

    methods ( Static, Access = private )

        function block = getChildBlock( moduleAssembly, blockDatabase )

            for moduleIdx = 1:moduleAssembly.TotNumModules
                block( moduleIdx ).ModuleBlocks = blockDatabase.getBlock( "Module", moduleAssembly.Module( moduleIdx ).BlockType );%#ok<AGROW>
            end
        end
    end

end

