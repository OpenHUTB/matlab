classdef ( Sealed )Pack < simscape.battery.builder.internal.Battery

    properties ( Dependent )



        ModuleAssembly( :, : )simscape.battery.builder.ModuleAssembly



        InterModuleAssemblyGap( 1, 1 ){ mustBeA( InterModuleAssemblyGap, [ "simscape.Value", "double" ] ) }


        BalancingStrategy( 1, 1 )string{ mustBeMember( BalancingStrategy,  ...
            [ "Passive", "" ] ) }



        AmbientThermalPath( 1, 1 )string{ mustBeMember( AmbientThermalPath,  ...
            [ "CellBasedThermalResistance", "" ] ) }






        CoolantThermalPath( 1, 1 )string{ mustBeMember( CoolantThermalPath,  ...
            [ "CellBasedThermalResistance", "" ] ) }



        Position( 1, 3 )double{ mustBeReal, mustBeFinite }

        Name( 1, 1 )string


        CircuitConnection( 1, 1 )string{ mustBeMember( CircuitConnection,  ...
            [ "Series", "Parallel" ] ) }



        StackingAxis( 1, 1 )string{ mustBeMember( StackingAxis,  ...
            [ "X", "Y" ] ) }




        MassFactor( 1, 1 )double{ mustBeReal, mustBeFinite, mustBePositive,  ...
            mustBeGreaterThanOrEqual( MassFactor, 1 ) }



        NonCellResistance( 1, 1 )string{ mustBeMember( NonCellResistance,  ...
            [ "Yes", "No" ] ) }
    end

    properties ( Dependent, SetAccess = private, GetAccess = public )


        PackagingVolume( 1, 1 ){ mustBeA( PackagingVolume, "simscape.Value" ),  ...
            simscape.mustBeCommensurateUnit( PackagingVolume, "m^3" ) }


        CumulativeMass( 1, 1 ){ mustBeA( CumulativeMass, "simscape.Value" ),  ...
            simscape.mustBeCommensurateUnit( CumulativeMass, "kg" ) }


        NumModels( 1, 1 )double{ mustBeInteger }
    end

    properties ( SetAccess = private, Hidden )


        ModuleAssemblyInternal( :, : )simscape.battery.builder.ModuleAssembly



        InterModuleAssemblyGapInternal( 1, 1 ){ mustBeA( InterModuleAssemblyGapInternal, "simscape.Value" ),  ...
            simscape.mustBeCommensurateUnit( InterModuleAssemblyGapInternal, "m" ) } = simscape.Value( 0.005, "m" )


        CoolantFlowDistributionInternal( 1, : )double ...
            { mustBePositive( CoolantFlowDistributionInternal ),  ...
            mustBeLessThan( CoolantFlowDistributionInternal, 1.00001 ) }


        ModuleAssemblyPositions


        ModuleAssemblyPoints


        Layout

        PositionInternal simscape.battery.builder.internal.Position

        NameInternal( 1, 1 )string


        CircuitConnectionInternal( 1, 1 )string ...
            { mustBeMember( CircuitConnectionInternal, [ "Series", "Parallel" ] ) } = "Series"




        MassFactorInternal( 1, 1 )double{ mustBeReal, mustBeFinite, mustBePositive,  ...
            mustBeGreaterThanOrEqual( MassFactorInternal, 1 ) } = 1

        BatteryPatchDefinition( :, 1 )

        SimulationStrategyPatchDefinition( :, 1 )

        StackingAxisInternal( 1, 1 )string{ mustBeMember( StackingAxisInternal,  ...
            [ "X", "Y" ] ) } = "X"
        ModuleAssemblyOriginalPositions



        NonCellResistanceInternal( 1, 1 )string{ mustBeMember( NonCellResistanceInternal,  ...
            [ "Yes", "No" ] ) } = "No"



        BalancingStrategyInternal( 1, 1 )string{ mustBeMember( BalancingStrategyInternal,  ...
            [ "Passive", "" ] ) }



        AmbientThermalPathInternal( 1, 1 )string{ mustBeMember( AmbientThermalPathInternal,  ...
            [ "CellBasedThermalResistance", "" ] ) }






        CoolantThermalPathInternal( 1, 1 )string{ mustBeMember( CoolantThermalPathInternal,  ...
            [ "CellBasedThermalResistance", "" ] ) }
    end

    properties ( Dependent, SetAccess = protected, Hidden )


        SimulationToHardwareMapping( :, : )uint16{ mustBeInteger }


        TotNumModuleAssemblies( 1, 1 )double{ mustBeInteger }


        UniqueComponents

        AllModules
    end

    properties ( SetAccess = private )

        CellNumbering
    end

    properties ( Constant )

        Type = "Pack"
    end

    properties ( Hidden )
        BlockType( :, 1 )string
    end

    methods
        function obj = Pack( namedArgs )
            arguments
                namedArgs.ModuleAssembly ...
                    simscape.battery.builder.ModuleAssembly = simscape.battery.builder.ModuleAssembly(  )
                namedArgs.InterModuleAssemblyGap( 1, 1 ) ...
                    { mustBeA( namedArgs.InterModuleAssemblyGap, [ "simscape.Value", "double" ] ) } = simscape.Value( 1 / 1000, "m" )
                namedArgs.Position( 1, 3 )double{ mustBeReal, mustBeFinite } = [ 0, 0, 0 ]
                namedArgs.BalancingStrategy( 1, 1 )string{ mustBeMember( namedArgs.BalancingStrategy,  ...
                    [ "Passive", "" ] ) } = ""
                namedArgs.AmbientThermalPath( 1, 1 )string{ mustBeMember( namedArgs.AmbientThermalPath,  ...
                    [ "CellBasedThermalResistance", "" ] ) } = ""
                namedArgs.CoolantThermalPath( 1, 1 )string{ mustBeMember( namedArgs.CoolantThermalPath,  ...
                    [ "CellBasedThermalResistance", "" ] ) } = ""
                namedArgs.CircuitConnection( :, 1 )string{ mustBeMember( namedArgs.CircuitConnection,  ...
                    [ "Series", "Parallel" ] ) } = "Series"
                namedArgs.StackingAxis( 1, 1 )string{ mustBeMember( namedArgs.StackingAxis,  ...
                    [ "X", "Y" ] ) } = "X"
                namedArgs.MassFactor( 1, 1 )double{ mustBeReal, mustBeFinite, mustBePositive,  ...
                    mustBeGreaterThanOrEqual( namedArgs.MassFactor, 1 ) } = 1
                namedArgs.Name( 1, 1 )string = "Pack1"
                namedArgs.NonCellResistance( 1, 1 )string = "No"
            end

            if ~pmsl_checklicense( 'simscape_battery' )
                error( message( 'physmod:battery:license:MissingLicense' ) );
            end
            obj.StackingAxis = namedArgs.StackingAxis;
            obj.ModuleAssembly = namedArgs.ModuleAssembly;
            obj.CircuitConnection = namedArgs.CircuitConnection;
            obj.InterModuleAssemblyGap = namedArgs.InterModuleAssemblyGap;
            obj.MassFactor = namedArgs.MassFactor;
            obj.Position = namedArgs.Position;
            obj.Name = namedArgs.Name;
            obj.BlockType = "PackType1";
            obj.BalancingStrategy = namedArgs.BalancingStrategy;
            obj.AmbientThermalPath = namedArgs.AmbientThermalPath;
            obj.CoolantThermalPath = namedArgs.CoolantThermalPath;
            obj.NonCellResistance = namedArgs.NonCellResistance;
        end

        function obj = set.ModuleAssembly( obj, val )
            try
                assert( ~isequal( val, simscape.battery.builder.ModuleAssembly.empty(  ) ),  ...
                    message( "physmod:battery:builder:batteryclasses:EmptyModuleAssemblyProperty" ) );
            catch me
                throwAsCaller( me )
            end
            if ~isempty( obj.ModuleAssembly )
                allModuleAssemblies = [ val( : ) ];
                if all( [ allModuleAssemblies.BalancingStrategy ] == obj.BalancingStrategy )
                else
                    try
                        assert( ~any( [ allModuleAssemblies.BalancingStrategy ] ~= "" ) && strcmp( obj.BalancingStrategy, "" ),  ...
                            message( "physmod:battery:builder:batteryclasses:BalancingStrategyMismatchWithPack" ) );
                    catch me
                        throwAsCaller( me )
                    end
                end
                if all( [ allModuleAssemblies.AmbientThermalPath ] == obj.AmbientThermalPath )
                else
                    try
                        assert( ~any( [ allModuleAssemblies.AmbientThermalPath ] ~= "" ) && strcmp( obj.AmbientThermalPath, "" ),  ...
                            message( "physmod:battery:builder:batteryclasses:AmbientThermalPathMismatchWithPack" ) );
                    catch me
                        throwAsCaller( me )
                    end
                end
                if all( [ allModuleAssemblies.CoolantThermalPath ] == obj.CoolantThermalPath )
                else
                    try
                        assert( ~any( [ allModuleAssemblies.CoolantThermalPath ] ~= "" ) && strcmp( obj.CoolantThermalPath, "" ),  ...
                            message( "physmod:battery:builder:batteryclasses:CoolantThermalPathMismatchWithPack" ) );
                    catch me
                        throwAsCaller( me )
                    end
                end
            end

            if isempty( obj.ModuleAssemblyInternal )
                obj = updateModuleAssemblyOriginalPositions( obj, val );
            else
                if numel( val ) ~= numel( obj.ModuleAssemblyOriginalPositions )
                    obj = updateModuleAssemblyOriginalPositions( obj, val );
                end
            end
            obj.ModuleAssemblyInternal = val;
            obj = updateBlockTypes( obj );
            obj = obj.updateLayout;
        end

        function value = get.ModuleAssembly( obj )
            value = obj.ModuleAssemblyInternal;
        end

        function obj = set.InterModuleAssemblyGap( obj, val )
            if strcmp( class( val ), "double" )
                warning( message( "physmod:battery:builder:batteryclasses:DoubleToSimscapeValueMeters" ) )
                val = simscape.Value( val, "m" );
            end
            simscape.mustBeCommensurateUnit( val, "m" )
            try
                assert( value( val, "m" ) <= 10,  ...
                    message( "physmod:battery:builder:batteryclasses:HighInterModuleAssemblyGap", "10" ) );
                assert( value( val, "m" ) > 0,  ...
                    message( "physmod:battery:builder:batteryclasses:InvalidInterModuleAssemblyGap" ) );
            catch me
                throwAsCaller( me )
            end
            obj.InterModuleAssemblyGapInternal = val;
            obj = obj.updateLayout;
        end

        function value = get.InterModuleAssemblyGap( obj )
            value = obj.InterModuleAssemblyGapInternal;
        end

        function value = get.TotNumModuleAssemblies( obj )
            packRows = length( obj.ModuleAssemblyInternal( :, 1 ) );
            packColumns = length( obj.ModuleAssemblyInternal( 1, : ) );
            value = packRows * packColumns;
            try
                assert( value <= 50,  ...
                    message( "physmod:battery:builder:batteryclasses:InvalidNumModuleAssemblies", "50" ) );
            catch me
                throwAsCaller( me )
            end
        end

        function obj = set.CircuitConnection( obj, val )
            obj.CircuitConnectionInternal = val;
        end

        function value = get.CircuitConnection( obj )
            value = obj.CircuitConnectionInternal;
        end

        function obj = set.Name( obj, val )
            try
                assert( isvarname( val ),  ...
                    message( "physmod:battery:builder:batteryclasses:IsNotVarName" ) );
            catch me
                throwAsCaller( me )
            end
            obj.NameInternal = val;
        end

        function value = get.Name( obj )
            value = obj.NameInternal;
        end

        function obj = set.NonCellResistance( obj, val )
            obj.NonCellResistanceInternal = val;
        end

        function value = get.NonCellResistance( obj )
            value = obj.NonCellResistanceInternal;
        end

        function obj = set.AmbientThermalPath( obj, val )
            allModules = obj.getAllModules( obj.ModuleAssemblyInternal );
            allParallelAssemblies = [ allModules( : ).ParallelAssembly ];
            allCells = [ allParallelAssemblies( : ).Cell ];
            try
                assert( any( [ allCells.ThermalEffects ] ~= "omit" ) || strcmp( val, "" ),  ...
                    message( "physmod:battery:builder:batteryclasses:ThermalBCCellEffectsMismatch" ) );
            catch me
                throwAsCaller( me )
            end
            for moduleAssemblyIdx = 1:obj.TotNumModuleAssemblies
                obj.ModuleAssemblyInternal( moduleAssemblyIdx ).AmbientThermalPath = val;
            end
            obj.AmbientThermalPathInternal = val;
        end

        function value = get.AmbientThermalPath( obj )
            value = obj.AmbientThermalPathInternal;
        end

        function obj = set.CoolantThermalPath( obj, val )
            allModules = obj.getAllModules( obj.ModuleAssemblyInternal );
            allParallelAssemblies = [ allModules( : ).ParallelAssembly ];
            allCells = [ allParallelAssemblies( : ).Cell ];
            try
                assert( any( [ allCells.ThermalEffects ] ~= "omit" ) || strcmp( val, "" ),  ...
                    message( "physmod:battery:builder:batteryclasses:ThermalBCCellEffectsMismatch" ) );
            catch me
                throwAsCaller( me )
            end
            for moduleAssemblyIdx = 1:obj.TotNumModuleAssemblies
                obj.ModuleAssemblyInternal( moduleAssemblyIdx ).CoolantThermalPath = val;
            end
            obj.CoolantThermalPathInternal = val;
        end

        function value = get.CoolantThermalPath( obj )
            value = obj.CoolantThermalPathInternal;
        end

        function obj = set.BalancingStrategy( obj, val )
            for moduleAssemblyIdx = 1:obj.TotNumModuleAssemblies
                obj.ModuleAssemblyInternal( moduleAssemblyIdx ).BalancingStrategy = val;
            end
            obj.BalancingStrategyInternal = val;
        end

        function value = get.BalancingStrategy( obj )
            value = obj.BalancingStrategyInternal;
        end

        function obj = set.Position( obj, val )
            obj.PositionInternal = simscape.battery.builder.internal.Position( X = val( 1 ), Y = val( 2 ), Z = val( 3 ) );
            obj = obj.updateLayout;
        end

        function value = get.Position( obj )
            value = [ obj.PositionInternal.X, obj.PositionInternal.Y, obj.PositionInternal.Z ];
        end

        function obj = set.StackingAxis( obj, val )
            obj.StackingAxisInternal = val;
            obj = obj.updateLayout;
        end

        function value = get.StackingAxis( obj )
            value = obj.StackingAxisInternal;
        end

        function obj = set.MassFactor( obj, val )
            obj.MassFactorInternal = val;
        end

        function value = get.MassFactor( obj )
            value = obj.MassFactorInternal;
        end

        function value = get.UniqueComponents( obj )
            [ TotNumModules, moduleAssemblyVec, moduleVec ] = obj.TotNumModulesFcn( obj );
            moduleEquivalencyMatrix = ones( TotNumModules, TotNumModules );
            parAssemblyEquivalencyMatrix = ones( TotNumModules, TotNumModules );
            moduleNameEquivalencyMatrix = ones( TotNumModules, TotNumModules );
            parAssemblyNameEquivalencyMatrix = ones( TotNumModules, TotNumModules );

            ModuleKeyProperties = { 'NumSeriesAssemblies', 'ModelResolution', 'SeriesGrouping', 'ParallelGrouping',  ...
                'InterParallelAssemblyGap', 'CoolingPlate', 'NonCellResistance' };

            ParallelAssemblyKeyProperties = { 'NumParallelCells', 'Rows', 'Topology', 'ModelResolution',  ...
                'InterCellGap', 'CoolingPlate', 'NonCellResistance' };

            for moduleIdx = 1:TotNumModules
                if moduleIdx <= 10 && TotNumModules > 10
                    startDigit = "0";
                else
                    startDigit = "";
                end
                value( moduleIdx ).ModuleAssemblyID = strcat( "ModuleAssembly", string( moduleAssemblyVec( moduleIdx ) ) );%#ok<AGROW>
                value( moduleIdx ).ModuleID = strcat( "Module", startDigit, string( moduleVec( moduleIdx ) ) );%#ok<AGROW>
                value( moduleIdx ).ParallelAssemblyID = strcat( "ParallelAssembly", startDigit, string( moduleVec( moduleIdx ) ) );%#ok<AGROW>
                if moduleIdx == TotNumModules
                    moduleEquivalencyMatrix( moduleIdx, ( 1:( moduleIdx - 1 ) ) ) = 0;
                    parAssemblyEquivalencyMatrix( moduleIdx, ( 1:( moduleIdx - 1 ) ) ) = 0;
                    moduleNameEquivalencyMatrix( moduleIdx, ( 1:( moduleIdx - 1 ) ) ) = 0;
                    parAssemblyNameEquivalencyMatrix( moduleIdx, ( 1:( moduleIdx - 1 ) ) ) = 0;
                    if any( moduleEquivalencyMatrix( moduleIdx, : ) == 1 )
                        moduleEquivalencyMatrix( moduleIdx, end  ) = 1;
                    else
                        moduleEquivalencyMatrix( moduleIdx, : ) = 0;
                    end
                    if any( moduleNameEquivalencyMatrix( moduleIdx, : ) == 1 )
                        moduleNameEquivalencyMatrix( moduleIdx, end  ) = 1;
                    else
                        moduleNameEquivalencyMatrix( moduleIdx, : ) = 0;
                    end
                    if any( parAssemblyEquivalencyMatrix( moduleIdx, : ) == 1 )
                        parAssemblyEquivalencyMatrix( moduleIdx, end  ) = 1;
                    else
                        parAssemblyEquivalencyMatrix( moduleIdx, : ) = 0;
                    end
                    if any( parAssemblyNameEquivalencyMatrix( moduleIdx, : ) == 1 )
                        parAssemblyNameEquivalencyMatrix( moduleIdx, end  ) = 1;
                    else
                        parAssemblyNameEquivalencyMatrix( moduleIdx, : ) = 0;
                    end
                else
                    if moduleIdx == 1
                    else
                        moduleEquivalencyMatrix( moduleIdx, ( 1:( moduleIdx - 1 ) ) ) = 0;
                        parAssemblyEquivalencyMatrix( moduleIdx, ( 1:( moduleIdx - 1 ) ) ) = 0;
                        moduleNameEquivalencyMatrix( moduleIdx, ( 1:( moduleIdx - 1 ) ) ) = 0;
                        parAssemblyNameEquivalencyMatrix( moduleIdx, ( 1:( moduleIdx - 1 ) ) ) = 0;
                    end
                    for otherModuleIdx = ( moduleIdx + 1 ):TotNumModules
                        if isequal( obj.ModuleAssembly( moduleAssemblyVec( moduleIdx ) ).ModuleInternal( moduleVec( moduleIdx ) ).Name, obj.ModuleAssembly( moduleAssemblyVec( otherModuleIdx ) ).ModuleInternal( moduleVec( otherModuleIdx ) ).Name )
                        else
                            moduleNameEquivalencyMatrix( moduleIdx, otherModuleIdx ) = 0;
                        end
                        if isequal( obj.ModuleAssembly( moduleAssemblyVec( moduleIdx ) ).ModuleInternal( moduleVec( moduleIdx ) ).ParallelAssembly.Cell.Name, obj.ModuleAssembly( moduleAssemblyVec( otherModuleIdx ) ).ModuleInternal( moduleVec( otherModuleIdx ) ).ParallelAssembly.Cell.Name ) &&  ...
                                isequal( obj.ModuleAssembly( moduleAssemblyVec( moduleIdx ) ).ModuleInternal( moduleVec( moduleIdx ) ).ParallelAssembly.Cell.Format, obj.ModuleAssembly( moduleAssemblyVec( otherModuleIdx ) ).ModuleInternal( moduleVec( otherModuleIdx ) ).ParallelAssembly.Cell.Format ) &&  ...
                                isequal( obj.ModuleAssembly( moduleAssemblyVec( moduleIdx ) ).ModuleInternal( moduleVec( moduleIdx ) ).ParallelAssembly.Cell.Mass, obj.ModuleAssembly( moduleAssemblyVec( otherModuleIdx ) ).ModuleInternal( moduleVec( otherModuleIdx ) ).ParallelAssembly.Cell.Mass )
                        else
                            moduleEquivalencyMatrix( moduleIdx, otherModuleIdx ) = 0;
                            parAssemblyEquivalencyMatrix( moduleIdx, otherModuleIdx ) = 0;
                        end
                        for moduleFieldnamesIdx = 1:length( ModuleKeyProperties )
                            if isequal( obj.ModuleAssembly( moduleAssemblyVec( moduleIdx ) ).ModuleInternal( moduleVec( moduleIdx ) ).( ModuleKeyProperties{ moduleFieldnamesIdx } ), obj.ModuleAssembly( moduleAssemblyVec( otherModuleIdx ) ).ModuleInternal( moduleVec( otherModuleIdx ) ).( ModuleKeyProperties{ moduleFieldnamesIdx } ) )
                            else
                                moduleEquivalencyMatrix( moduleIdx, otherModuleIdx ) = 0;
                            end
                        end
                        if isequal( obj.ModuleAssembly( moduleAssemblyVec( moduleIdx ) ).ModuleInternal( moduleVec( moduleIdx ) ).ParallelAssembly.Name, obj.ModuleAssembly( moduleAssemblyVec( otherModuleIdx ) ).ModuleInternal( moduleVec( otherModuleIdx ) ).ParallelAssembly.Name )
                        else
                            parAssemblyNameEquivalencyMatrix( moduleIdx, otherModuleIdx ) = 0;
                        end
                        for parAssemblyFieldnamesIdx = 1:length( ParallelAssemblyKeyProperties )
                            if isequal( obj.ModuleAssembly( moduleAssemblyVec( moduleIdx ) ).ModuleInternal( moduleVec( moduleIdx ) ).ParallelAssembly.( ParallelAssemblyKeyProperties{ parAssemblyFieldnamesIdx } ), obj.ModuleAssembly( moduleAssemblyVec( otherModuleIdx ) ).ModuleInternal( moduleVec( otherModuleIdx ) ).ParallelAssembly.( ParallelAssemblyKeyProperties{ parAssemblyFieldnamesIdx } ) )
                            else
                                parAssemblyEquivalencyMatrix( moduleIdx, otherModuleIdx ) = 0;
                            end
                        end
                    end
                end
            end
            UniqueModuleBlockTypeIdx = 1;
            UniqueParAssemblyBlockTypeIdx = 1;
            UniqueModuleNameIdx = 1;
            UniqueParAssemblyNameIdx = 1;
            for rowIdx = 1:TotNumModules
                for columnIdx = 1:TotNumModules
                    if moduleEquivalencyMatrix( rowIdx, columnIdx ) == 1
                        if rowIdx == TotNumModules
                            moduleEquivalencyMatrix( ( end  ), columnIdx ) = 0;
                        else
                            moduleEquivalencyMatrix( ( ( rowIdx + 1 ):end  ), columnIdx ) = 0;
                        end
                        value( columnIdx ).ModuleBlockType = strcat( "ModuleType", string( UniqueModuleBlockTypeIdx ) );
                    else
                    end
                    if moduleNameEquivalencyMatrix( rowIdx, columnIdx ) == 1
                        if rowIdx == TotNumModules
                            moduleNameEquivalencyMatrix( ( end  ), columnIdx ) = 0;
                        else
                            moduleNameEquivalencyMatrix( ( ( rowIdx + 1 ):end  ), columnIdx ) = 0;
                        end
                        value( columnIdx ).ModuleUniqueName = obj.ModuleAssembly( moduleAssemblyVec( columnIdx ) ).ModuleInternal( moduleVec( columnIdx ) ).Name;
                    else
                    end
                    if parAssemblyNameEquivalencyMatrix( rowIdx, columnIdx ) == 1
                        if rowIdx == TotNumModules
                            parAssemblyNameEquivalencyMatrix( ( end  ), columnIdx ) = 0;
                        else
                            parAssemblyNameEquivalencyMatrix( ( ( rowIdx + 1 ):end  ), columnIdx ) = 0;
                        end
                        value( columnIdx ).ParallelAssemblyUniqueName = obj.ModuleAssembly( moduleAssemblyVec( columnIdx ) ).ModuleInternal( moduleVec( columnIdx ) ).ParallelAssembly.Name;
                    else
                    end
                    if parAssemblyEquivalencyMatrix( rowIdx, columnIdx ) == 1
                        if rowIdx == TotNumModules
                            parAssemblyEquivalencyMatrix( ( end  ), columnIdx ) = 0;
                        else
                            parAssemblyEquivalencyMatrix( ( ( rowIdx + 1 ):end  ), columnIdx ) = 0;
                        end
                        value( columnIdx ).ParallelAssemblyBlockType = strcat( "ParallelAssemblyType", string( UniqueParAssemblyBlockTypeIdx ) );
                    else
                    end
                end
                if any( moduleEquivalencyMatrix( rowIdx, : ) == 1 )
                    UniqueModuleBlockTypeIdx = UniqueModuleBlockTypeIdx + 1;
                else
                end
                if any( parAssemblyEquivalencyMatrix( rowIdx, : ) == 1 )
                    UniqueParAssemblyBlockTypeIdx = UniqueParAssemblyBlockTypeIdx + 1;
                else
                end
                if any( moduleNameEquivalencyMatrix( rowIdx, : ) == 1 )
                    UniqueModuleNameIdx = UniqueModuleNameIdx + 1;
                else
                end
                if any( parAssemblyNameEquivalencyMatrix( rowIdx, : ) == 1 )
                    UniqueParAssemblyNameIdx = UniqueParAssemblyNameIdx + 1;
                else
                end
            end
            TotModuleAssemblies = unique( moduleAssemblyVec );
            accumulatedTotModules = 0;
            for moduleAssemblyIdx = TotModuleAssemblies
                TotModules = moduleVec( moduleAssemblyIdx == moduleAssemblyVec );
                moduleAssemblyUniqueComponent( moduleAssemblyIdx ).Value = [ value( TotModules + accumulatedTotModules ) ];%#ok<AGROW>
                accumulatedTotModules = accumulatedTotModules + length( TotModules );
                clear C_module ia_module C_pSet ia_pSet
                [ C_module, ia_module ] = unique( [ moduleAssemblyUniqueComponent( moduleAssemblyIdx ).Value.ModuleUniqueName ] );
                [ C_pSet, ia_pSet ] = unique( [ moduleAssemblyUniqueComponent( moduleAssemblyIdx ).Value.ParallelAssemblyUniqueName ] );
                [ moduleAssemblyUniqueComponent( moduleAssemblyIdx ).Value.ModuleUniqueName ] = deal( repmat( [  ], length( moduleAssemblyUniqueComponent( moduleAssemblyIdx ).Value ), 1 ) );%#ok<AGROW>
                [ moduleAssemblyUniqueComponent( moduleAssemblyIdx ).Value.ParallelAssemblyUniqueName ] = deal( repmat( [  ], length( moduleAssemblyUniqueComponent( moduleAssemblyIdx ).Value ), 1 ) );%#ok<AGROW>
                [ moduleAssemblyUniqueComponent( moduleAssemblyIdx ).Value( ia_module ).ModuleUniqueName ] = deal( C_module{ : } );%#ok<AGROW>
                [ moduleAssemblyUniqueComponent( moduleAssemblyIdx ).Value( ia_pSet ).ParallelAssemblyUniqueName ] = deal( C_pSet{ : } );%#ok<AGROW>
            end
            value = [ moduleAssemblyUniqueComponent( : ).Value ];


            ModuleAssemblyKeyProperties = { 'InterModuleGap', 'NonCellResistance', 'CircuitConnection', 'TotNumModules' };
            moduleAssemblyEquivalencyMatrix = ones( obj.TotNumModuleAssemblies, obj.TotNumModuleAssemblies );
            moduleAssemblyNameEquivalencyMatrix = ones( obj.TotNumModuleAssemblies, obj.TotNumModuleAssemblies );
            for moduleAssemblyIdx = 1:obj.TotNumModuleAssemblies
                if moduleAssemblyIdx <= 10 && obj.TotNumModuleAssemblies > 10
                    startDigit = "0";
                else
                    startDigit = "";
                end
                if moduleAssemblyIdx == obj.TotNumModuleAssemblies
                    moduleAssemblyEquivalencyMatrix( moduleAssemblyIdx, ( 1:( moduleAssemblyIdx - 1 ) ) ) = 0;
                    moduleAssemblyNameEquivalencyMatrix( moduleAssemblyIdx, ( 1:( moduleAssemblyIdx - 1 ) ) ) = 0;
                    if any( moduleAssemblyEquivalencyMatrix( moduleAssemblyIdx, : ) == 1 )
                        moduleAssemblyEquivalencyMatrix( moduleAssemblyIdx, end  ) = 1;
                    else
                        moduleAssemblyEquivalencyMatrix( moduleAssemblyIdx, : ) = 0;
                    end
                    if any( moduleAssemblyNameEquivalencyMatrix( moduleAssemblyIdx, : ) == 1 )
                        moduleAssemblyNameEquivalencyMatrix( moduleAssemblyIdx, end  ) = 1;
                    else
                        moduleAssemblyNameEquivalencyMatrix( moduleAssemblyIdx, : ) = 0;
                    end
                else
                    if moduleAssemblyIdx == 1
                    else
                        moduleAssemblyEquivalencyMatrix( moduleAssemblyIdx, ( 1:( moduleAssemblyIdx - 1 ) ) ) = 0;
                        moduleAssemblyNameEquivalencyMatrix( moduleAssemblyIdx, ( 1:( moduleAssemblyIdx - 1 ) ) ) = 0;
                    end
                    for otherModuleAssemblyIdx = ( moduleAssemblyIdx + 1 ):obj.TotNumModuleAssemblies
                        if isequal( obj.ModuleAssembly( ( moduleAssemblyIdx ) ).Name, obj.ModuleAssembly( ( otherModuleAssemblyIdx ) ).Name )
                        else
                            moduleAssemblyNameEquivalencyMatrix( moduleAssemblyIdx, otherModuleAssemblyIdx ) = 0;
                        end
                        for moduleFieldnamesIdx = 1:length( ModuleAssemblyKeyProperties )
                            if isequal( obj.ModuleAssembly( ( moduleAssemblyIdx ) ).( ModuleAssemblyKeyProperties{ moduleFieldnamesIdx } ), obj.ModuleAssembly( ( otherModuleAssemblyIdx ) ).( ModuleAssemblyKeyProperties{ moduleFieldnamesIdx } ) )
                            else
                                moduleAssemblyEquivalencyMatrix( moduleAssemblyIdx, otherModuleAssemblyIdx ) = 0;
                            end
                        end
                        moduleAssemblyIdxModuleIndexCellArray = strfind( [ value.ModuleAssemblyID ], strcat( "ModuleAssembly", string( moduleAssemblyIdx ) ) );
                        moduleAssemblyIdxModuleIndex = find( not( cellfun( 'isempty', moduleAssemblyIdxModuleIndexCellArray ) ) );%#ok<STRCL1>

                        otherModuleAssemblyIdxModuleIndexCellArray = strfind( [ value.ModuleAssemblyID ], strcat( "ModuleAssembly", string( otherModuleAssemblyIdx ) ) );
                        otherModuleAssemblyIdxModuleIndex = find( not( cellfun( 'isempty', otherModuleAssemblyIdxModuleIndexCellArray ) ) );%#ok<STRCL1>

                        if isequal( [ value( moduleAssemblyIdxModuleIndex ).ModuleBlockType ], [ value( otherModuleAssemblyIdxModuleIndex ).ModuleBlockType ] )%#ok<FNDSB>
                        else
                            moduleAssemblyEquivalencyMatrix( moduleAssemblyIdx, otherModuleAssemblyIdx ) = 0;
                        end
                    end
                end
            end
            UniqueModuleAssemblyBlockTypeIdx = 1;
            UniqueModuleAssemblyNameIdx = 1;
            for rowIdx = 1:obj.TotNumModuleAssemblies
                for columnIdx = 1:obj.TotNumModuleAssemblies
                    if moduleAssemblyEquivalencyMatrix( rowIdx, columnIdx ) == 1
                        if rowIdx == obj.TotNumModuleAssemblies
                            moduleAssemblyEquivalencyMatrix( ( end  ), columnIdx ) = 0;
                        else
                            moduleAssemblyEquivalencyMatrix( ( ( rowIdx + 1 ):end  ), columnIdx ) = 0;
                        end
                        UniqueModuleAssemblies( columnIdx ).ModuleAssemblyBlockType = strcat( "ModuleAssemblyType", startDigit, string( UniqueModuleAssemblyBlockTypeIdx ) );%#ok<AGROW>
                    else
                    end
                    if moduleAssemblyNameEquivalencyMatrix( rowIdx, columnIdx ) == 1
                        if rowIdx == obj.TotNumModuleAssemblies
                            moduleAssemblyNameEquivalencyMatrix( ( end  ), columnIdx ) = 0;
                        else
                            moduleAssemblyNameEquivalencyMatrix( ( ( rowIdx + 1 ):end  ), columnIdx ) = 0;
                        end
                        UniqueModuleAssemblies( columnIdx ).ModuleAssemblyUniqueName = obj.ModuleAssembly( UniqueModuleAssemblyNameIdx ).Name;%#ok<AGROW>
                    else
                    end
                end
                if any( moduleAssemblyEquivalencyMatrix( rowIdx, : ) == 1 )
                    UniqueModuleAssemblyBlockTypeIdx = UniqueModuleAssemblyBlockTypeIdx + 1;
                else
                end
                if any( moduleAssemblyNameEquivalencyMatrix( rowIdx, : ) == 1 )
                    UniqueModuleAssemblyNameIdx = UniqueModuleAssemblyNameIdx + 1;
                else
                end
            end
            [ C_moduleAssembly, ia_moduleAssembly ] = unique( [ UniqueModuleAssemblies.ModuleAssemblyUniqueName ] );
            [ UniqueModuleAssemblies.ModuleAssemblyUniqueName ] = deal( repmat( [  ], length( UniqueModuleAssemblies ), 1 ) );
            [ UniqueModuleAssemblies( ia_moduleAssembly ).ModuleAssemblyUniqueName ] = deal( C_moduleAssembly{ : } );

            for moduleIdx = 1:length( value )
                value( moduleIdx ).ModuleAssemblyBlockType = UniqueModuleAssemblies( moduleAssemblyVec( moduleIdx ) ).ModuleAssemblyBlockType;
                if isempty( UniqueModuleAssemblies( moduleAssemblyVec( moduleIdx ) ).ModuleAssemblyUniqueName )
                    value( moduleIdx ).ModuleAssemblyUniqueName = value( moduleIdx ).ModuleAssemblyID;
                else
                    value( moduleIdx ).ModuleAssemblyUniqueName = UniqueModuleAssemblies( moduleAssemblyVec( moduleIdx ) ).ModuleAssemblyUniqueName;
                end
            end

        end

        function obj = set.BlockType( obj, val )
            obj.BlockType = val;
        end

        function val = get.PackagingVolume( obj )
            allParallelAssemblies = [ obj.AllModules.ParallelAssembly ];
            if any( [ allParallelAssemblies.Topology ] == "" )
                val = simscape.Value( [  ], "m^3" );
            else
                packRows = length( obj.ModuleAssemblyInternal( :, 1 ) );
                packColumns = length( obj.ModuleAssemblyInternal( 1, : ) );
                packVolume = simscape.Value( 0, "m^3" );
                for packRowsIdx = 1:packRows
                    for packColsIdx = 1:packColumns
                        moduleAssemblyRows = length( obj.ModuleAssemblyInternal( packRowsIdx, packColsIdx ).ModuleInternal( :, 1 ) );
                        moduleAssemblyColumns = length( obj.ModuleAssemblyInternal( packRowsIdx, packColsIdx ).ModuleInternal( 1, : ) );
                        for rowsIdx = 1:moduleAssemblyRows
                            for colIdx = 1:moduleAssemblyColumns
                                packVolume = packVolume + obj.ModuleAssemblyInternal( packRowsIdx, packColsIdx ).ModuleInternal( rowsIdx, colIdx ).PackagingVolume;
                            end
                        end
                    end
                end
                val = packVolume;
            end
        end

        function value = get.CumulativeMass( obj )
            packRows = length( obj.ModuleAssemblyInternal( :, 1 ) );
            packColumns = length( obj.ModuleAssemblyInternal( 1, : ) );
            packWeight = simscape.Value( 0, "kg" );
            for packRowsIdx = 1:packRows
                for packColsIdx = 1:packColumns
                    moduleAssemblyRows = length( obj.ModuleAssemblyInternal( packRowsIdx, packColsIdx ).ModuleInternal( :, 1 ) );
                    moduleAssemblyColumns = length( obj.ModuleAssemblyInternal( packRowsIdx, packColsIdx ).ModuleInternal( 1, : ) );
                    for rowsIdx = 1:moduleAssemblyRows
                        for colIdx = 1:moduleAssemblyColumns
                            packWeight = packWeight + obj.ModuleAssemblyInternal( packRowsIdx, packColsIdx ).ModuleInternal( rowsIdx, colIdx ).CumulativeMass;
                        end
                    end
                end
            end
            value = packWeight * obj.MassFactor;
        end

        function value = get.SimulationToHardwareMapping( obj )
            BatteryTypes = [ "Pack", "ModuleAssembly", "Module", "ParallelAssembly", "Cell", "Model" ];
            CellIndex = [  ];
            ParallelAssemblyIndex = [  ];
            ModuleIndex = [  ];
            ModuleAssemblyIndex = [  ];
            ModelIndex = [  ];
            numModuleAssemblies = length( obj.ModuleAssemblyInternal( :, 1 ) ) * length( obj.ModuleAssemblyInternal( 1, : ) );
            for moduleAssemblyIdx = 1:numModuleAssemblies
                ModuleAssemblyIndex = [ ModuleAssemblyIndex;moduleAssemblyIdx * ones( length( obj.ModuleAssembly( moduleAssemblyIdx ).SimulationToHardwareMapping.ModuleAssembly ), 1 ) ];%#ok<AGROW>
                numModules = length( obj.ModuleAssembly( moduleAssemblyIdx ).ModuleInternal( :, 1 ) ) * length( obj.ModuleAssembly( moduleAssemblyIdx ).ModuleInternal( 1, : ) );
                for moduleIdx = 1:numModules
                    ModuleIndex = [ ModuleIndex;moduleIdx * ones( length( obj.ModuleAssembly( moduleAssemblyIdx ).Module( moduleIdx ).SimulationToHardwareMapping.Module ), 1 ) ];%#ok<AGROW>
                    ParallelAssemblyIndex = [ ParallelAssemblyIndex;obj.ModuleAssembly( moduleAssemblyIdx ).Module( moduleIdx ).SimulationToHardwareMapping.ParallelAssembly ];%#ok<AGROW>
                    CellIndex = [ CellIndex;obj.ModuleAssembly( moduleAssemblyIdx ).Module( moduleIdx ).SimulationToHardwareMapping.Cell ];%#ok<AGROW>
                    if moduleIdx == 1 && moduleAssemblyIdx == 1
                        ModelIndex = [ ModelIndex;obj.ModuleAssembly( moduleAssemblyIdx ).Module( moduleIdx ).SimulationToHardwareMapping.Model ];%#ok<AGROW>
                    else
                        ModelIndex = [ ModelIndex;obj.ModuleAssembly( moduleAssemblyIdx ).Module( moduleIdx ).SimulationToHardwareMapping.Model + ModelIndex( end  ) ];%#ok<AGROW>
                    end
                end
            end
            SimulationToHardware( :, 1 ) = ones( length( ModuleAssemblyIndex ), 1 );
            SimulationToHardware( :, 2 ) = ModuleAssemblyIndex;
            SimulationToHardware( :, 3 ) = ModuleIndex;
            SimulationToHardware( :, 4 ) = ParallelAssemblyIndex;
            SimulationToHardware( :, 5 ) = CellIndex;
            SimulationToHardware( :, 6 ) = ModelIndex;
            value = array2table( SimulationToHardware );
            value.Properties.VariableNames = BatteryTypes;
        end

        function value = get.NumModels( obj )
            value = obj.SimulationToHardwareMapping.Model( end  );
        end

        function value = get.AllModules( obj )
            value = [ obj.ModuleAssembly( 1 ).ModuleInternal ];
            if obj.TotNumModuleAssemblies > 1
                for moduleAssemblyIdx = 2:obj.TotNumModuleAssemblies
                    if length( obj.ModuleAssembly( moduleAssemblyIdx ).ModuleInternal( 1, : ) ) > 1 || length( value( 1, : ) ) > 1
                        value = [ value, obj.ModuleAssembly( moduleAssemblyIdx ).ModuleInternal ];%#ok<AGROW>
                    else
                        value = [ value;obj.ModuleAssembly( moduleAssemblyIdx ).ModuleInternal ];%#ok<AGROW>
                    end
                end
            end
        end

    end

    methods ( Access = private )

        function obj = updateBlockTypes( obj )
            uniqueComponents = obj.UniqueComponents;
            [ TotNumModules, moduleAssemblyVec, moduleVec ] = obj.TotNumModulesFcn( obj );
            for moduleIdx = 1:TotNumModules
                obj.ModuleAssemblyInternal( moduleAssemblyVec( moduleIdx ) ).ModuleInternal( moduleVec( moduleIdx ) ).BlockType = uniqueComponents( moduleIdx ).ModuleBlockType;
                obj.ModuleAssemblyInternal( moduleAssemblyVec( moduleIdx ) ).ModuleInternal( moduleVec( moduleIdx ) ).ParallelAssembly.BlockType = uniqueComponents( moduleIdx ).ParallelAssemblyBlockType;
                if isempty( uniqueComponents( moduleIdx ).ModuleUniqueName )
                    obj.ModuleAssemblyInternal( moduleAssemblyVec( moduleIdx ) ).ModuleInternal( moduleVec( moduleIdx ) ).Name = uniqueComponents( moduleIdx ).ModuleID;
                else
                    obj.ModuleAssemblyInternal( moduleAssemblyVec( moduleIdx ) ).ModuleInternal( moduleVec( moduleIdx ) ).Name = uniqueComponents( moduleIdx ).ModuleUniqueName;
                end
                if isempty( uniqueComponents( moduleIdx ).ParallelAssemblyUniqueName )
                    obj.ModuleAssemblyInternal( moduleAssemblyVec( moduleIdx ) ).ModuleInternal( moduleVec( moduleIdx ) ).ParallelAssembly.Name = uniqueComponents( moduleIdx ).ParallelAssemblyID;
                else
                    obj.ModuleAssemblyInternal( moduleAssemblyVec( moduleIdx ) ).ModuleInternal( moduleVec( moduleIdx ) ).ParallelAssembly.Name = uniqueComponents( moduleIdx ).ParallelAssemblyUniqueName;
                end
                if isempty( uniqueComponents( moduleAssemblyVec( moduleIdx ) ).ModuleAssemblyUniqueName )
                    obj.ModuleAssemblyInternal( moduleAssemblyVec( moduleIdx ) ).Name = uniqueComponents( moduleIdx ).ModuleAssemblyID;
                else
                    obj.ModuleAssemblyInternal( moduleAssemblyVec( moduleIdx ) ).Name = uniqueComponents( moduleIdx ).ModuleAssemblyUniqueName;
                end
                obj.ModuleAssemblyInternal( moduleAssemblyVec( moduleIdx ) ).BlockType = uniqueComponents( moduleIdx ).ModuleAssemblyBlockType;
            end
        end

        function obj = updateLayout( obj )
            if ~isempty( obj.ModuleAssembly )
                try
                    assert( ~all( size( obj.ModuleAssemblyInternal ) > 1 ),  ...
                        message( "physmod:battery:builder:batteryclasses:ModuleAssemblyMatrix" ) );
                catch me
                    throwAsCaller( me )
                end
                numOfModuleAssemblies = numel( obj.ModuleAssemblyInternal );
                if strcmp( obj.StackingAxis, "Y" )
                    obj.Layout = reshape( 1:numOfModuleAssemblies, 1, numOfModuleAssemblies );
                elseif strcmp( obj.StackingAxis, "X" )
                    obj.Layout = reshape( 1:numOfModuleAssemblies, numOfModuleAssemblies, 1 );
                end
                obj = obj.updateModuleAssemblyPositions;
                obj = obj.updatePoints;
                obj = obj.updateCellNumbering;
            end
        end

        function obj = updateModuleAssemblyOriginalPositions( obj, val )
            numOfModuleAssemblies = length( val( :, 1 ) ) * length( val( 1, : ) );
            for moduleAssemblyIdx = 1:numOfModuleAssemblies
                obj.ModuleAssemblyOriginalPositions( moduleAssemblyIdx ).Position = val( moduleAssemblyIdx ).PositionInternal;
            end
        end

        function obj = updateModuleAssemblyPositions( obj )
            allParallelAssemblies = [ obj.AllModules.ParallelAssembly ];
            if any( [ allParallelAssemblies.Topology ] == "" )
            else
                NumOfModuleAssemblies = length( obj.ModuleAssemblyInternal( :, 1 ) ) * length( obj.ModuleAssemblyInternal( 1, : ) );
                if isempty( obj.PositionInternal )
                    [ packPosition.X, packPosition.Y, packPosition.Z ] = deal( 0, 0, 0 );
                else
                    packPosition = obj.PositionInternal;
                end

                [ prevModuleAssemblyExtend.X, prevModuleAssemblyExtend.Y, prevModuleAssemblyExtend.Z ] = deal( packPosition.X, packPosition.Y, packPosition.Z );
                ModuleAssemblyGap = value( convert( obj.InterModuleAssemblyGap, "m" ) );
                for moduleAssemblyIdx = 1:NumOfModuleAssemblies
                    gapFactor = double( moduleAssemblyIdx > 1 );
                    thisZ = packPosition.Z;
                    if strcmp( obj.StackingAxis, "Y" )
                        if abs( obj.ModuleAssemblyOriginalPositions( moduleAssemblyIdx ).Position.X ) > 0
                            thisX = obj.ModuleAssemblyOriginalPositions( moduleAssemblyIdx ).Position.X + packPosition.X;
                        else
                            thisX = packPosition.X;
                        end
                        thisY =  - ( ModuleAssemblyGap * gapFactor ) + prevModuleAssemblyExtend.Y;
                    elseif strcmp( obj.StackingAxis, "X" )
                        if abs( obj.ModuleAssemblyOriginalPositions( moduleAssemblyIdx ).Position.Y ) > 0
                            thisY = obj.ModuleAssemblyOriginalPositions( moduleAssemblyIdx ).Position.Y + packPosition.Y;
                        else
                            thisY = packPosition.Y;
                        end
                        thisX = ModuleAssemblyGap * gapFactor + prevModuleAssemblyExtend.X;
                    end
                    obj.ModuleAssemblyInternal( moduleAssemblyIdx ).Position = [ thisX, thisY, thisZ ];
                    prevModuleAssemblyExtend.X = value( obj.ModuleAssemblyInternal( moduleAssemblyIdx ).XExtent, "m" );
                    prevModuleAssemblyExtend.Y = value( obj.ModuleAssemblyInternal( moduleAssemblyIdx ).YExtent, "m" );
                    prevModuleAssemblyExtend.Z = value( obj.ModuleAssemblyInternal( moduleAssemblyIdx ).ZExtent, "m" );
                end
            end
        end

        function obj = updateCellNumbering( obj )
            obj.CellNumbering = [  ];
            if isempty( obj.ModuleAssemblyInternal )
            else
                if isempty( obj.ModuleAssemblyInternal( 1, 1 ).CellNumbering )
                else
                    packRows = length( obj.ModuleAssemblyInternal( :, 1 ) );
                    packColumns = length( obj.ModuleAssemblyInternal( 1, : ) );
                    moduleAssemblyIdx = 1;
                    for packRowsIdx = 1:packRows
                        for packColumnsIdx = 1:packColumns
                            ModuleAssemblyRows = length( obj.ModuleAssemblyInternal( packRowsIdx, packColumnsIdx ).ModuleInternal( :, 1 ) );
                            ModuleAssemblyColumns = length( obj.ModuleAssemblyInternal( packRowsIdx, packColumnsIdx ).ModuleInternal( 1, : ) );
                            obj.CellNumbering( moduleAssemblyIdx ).ModuleAssembly = moduleAssemblyIdx;
                            moduleIdx = 1;
                            for moduleAssemblyRowsIdx = 1:ModuleAssemblyRows
                                for moduleAssemblyColIdx = 1:ModuleAssemblyColumns
                                    obj.CellNumbering( moduleAssemblyIdx ).ModuleAssemblyNumbering( moduleIdx ).Module = moduleIdx;
                                    for parallelAssemblyIdx = 1:obj.ModuleAssemblyInternal( packRowsIdx, packColumnsIdx ).ModuleInternal( moduleAssemblyRowsIdx, moduleAssemblyColIdx ).NumSeriesAssemblies
                                        obj.CellNumbering( moduleAssemblyIdx ).ModuleAssemblyNumbering( moduleIdx ).ModuleNumbering( parallelAssemblyIdx ).ParallelAssembly = obj.ModuleAssemblyInternal( packRowsIdx, packColumnsIdx ).ModuleInternal( moduleAssemblyRowsIdx, moduleAssemblyColIdx ).CellNumbering( parallelAssemblyIdx ).ParallelAssembly;
                                        obj.CellNumbering( moduleAssemblyIdx ).ModuleAssemblyNumbering( moduleIdx ).ModuleNumbering( parallelAssemblyIdx ).Cells = obj.ModuleAssemblyInternal( packRowsIdx, packColumnsIdx ).ModuleInternal( moduleAssemblyRowsIdx, moduleAssemblyColIdx ).CellNumbering( parallelAssemblyIdx ).Cells;
                                    end
                                    moduleIdx = moduleIdx + 1;
                                end
                            end
                            moduleAssemblyIdx = moduleAssemblyIdx + 1;
                        end
                    end
                end
            end
        end


    end

    methods ( Hidden )
        function value = getExtent( obj, axisExtentName )
            allParallelAssemblies = [ obj.AllModules.ParallelAssembly ];
            if any( [ allParallelAssemblies.Topology ] == "" )
                value = simscape.Value( [  ], "m" );
            else
                packRows = length( obj.ModuleAssemblyInternal( :, 1 ) );
                packColumns = length( obj.ModuleAssemblyInternal( 1, : ) );
                moduleAssemblyExtent = ones( length( obj.ModuleAssemblyInternal( :, 1 ) ), length( obj.ModuleAssemblyInternal( 1, : ) ) );
                for packRowsIdx = 1:packRows
                    for packColsIdx = 1:packColumns
                        moduleAssemblyRows = length( obj.ModuleAssemblyInternal( packRowsIdx, packColsIdx ).ModuleInternal( :, 1 ) );
                        moduleAssemblyColumns = length( obj.ModuleAssemblyInternal( packRowsIdx, packColsIdx ).ModuleInternal( 1, : ) );
                        moduleExtent = ones( length( obj.ModuleAssemblyInternal( packRowsIdx, packColsIdx ).ModuleInternal( :, 1 ) ), length( obj.ModuleAssemblyInternal( packRowsIdx, packColsIdx ).ModuleInternal( 1, : ) ) );
                        for rowsIdx = 1:moduleAssemblyRows
                            for columnsIdx = 1:moduleAssemblyColumns
                                parallelAssemblyExtent = zeros( length( obj.ModuleAssemblyInternal( packRowsIdx, packColsIdx ).Module( rowsIdx, columnsIdx ).ParallelAssemblyPoints( 1:end  ) ), 1 );
                                for parallelAssemblyIdx = 1:length( obj.ModuleAssemblyInternal( packRowsIdx, packColsIdx ).Module( rowsIdx, columnsIdx ).ParallelAssemblyPoints )
                                    allPoints = [ obj.ModuleAssemblyInternal( packRowsIdx, packColsIdx ).ModuleInternal( rowsIdx, columnsIdx ).ParallelAssemblyPoints( parallelAssemblyIdx ).ParallelAssembly.Points ];
                                    if strcmp( axisExtentName, "YData" )
                                        parallelAssemblyExtent( parallelAssemblyIdx ) = min( min( ( [ allPoints.( axisExtentName ) ] ) ) );
                                    else
                                        parallelAssemblyExtent( parallelAssemblyIdx ) = max( max( abs( [ allPoints.( axisExtentName ) ] ) ) );
                                    end
                                end
                                if strcmp( axisExtentName, "YData" )
                                    moduleExtent( rowsIdx, columnsIdx ) = min( parallelAssemblyExtent );
                                else
                                    moduleExtent( rowsIdx, columnsIdx ) = max( parallelAssemblyExtent );
                                end
                            end
                        end
                        if strcmp( axisExtentName, "YData" )
                            moduleAssemblyExtent( packRowsIdx, packColsIdx ) = min( moduleExtent );
                        else
                            moduleAssemblyExtent( packRowsIdx, packColsIdx ) = max( moduleExtent );
                        end
                    end
                end
                if strcmp( axisExtentName, "YData" )
                    value = simscape.Value( min( moduleAssemblyExtent ), "m" );
                else
                    value = simscape.Value( max( moduleAssemblyExtent ), "m" );
                end
            end
        end

        function obj = updatePoints( obj )
            allParallelAssemblies = [ obj.AllModules.ParallelAssembly ];
            if any( [ allParallelAssemblies.Topology ] == "" )
                obj.BatteryPatchDefinition.faces = NaN;
                obj.BatteryPatchDefinition.vertices = NaN( 1, 2 );
                obj.BatteryPatchDefinition.facevertexcdata = NaN;
                obj.SimulationStrategyPatchDefinition = obj.BatteryPatchDefinition;
            else
                packRows = length( obj.ModuleAssemblyInternal( :, 1 ) );
                packColumns = length( obj.ModuleAssemblyInternal( 1, : ) );
                packPatch = struct( "faces", double.empty( 0, 4 ), "vertices", double.empty( 0, 3 ), "facevertexcdata", double.empty( 0, 1 ) );
                packSimPatch = struct( "faces", double.empty( 0, 4 ), "vertices", double.empty( 0, 3 ), "facevertexcdata", double.empty( 0, 1 ) );
                for rowsIdx = 1:packRows
                    for colIdx = 1:packColumns
                        if packColumns > 1
                            if colIdx == 1
                                maxFaceValue = 0;
                                maxSimFaceValue = 0;
                            else
                                maxFaceValue = max( packPatch.faces( : ) );
                                maxSimFaceValue = max( packSimPatch.faces( : ) );
                            end
                            packPatch.faces = [ packPatch.faces;obj.ModuleAssemblyInternal( rowsIdx, colIdx ).BatteryPatchDefinition.faces + maxFaceValue ];
                            packPatch.vertices = [ packPatch.vertices;obj.ModuleAssemblyInternal( rowsIdx, colIdx ).BatteryPatchDefinition.vertices ];
                            packPatch.facevertexcdata = [ packPatch.facevertexcdata;obj.ModuleAssemblyInternal( rowsIdx, colIdx ).BatteryPatchDefinition.facevertexcdata ];

                            packSimPatch.faces = [ packSimPatch.faces;obj.ModuleAssemblyInternal( rowsIdx, colIdx ).SimulationStrategyPatchDefinition.faces + maxSimFaceValue ];
                            packSimPatch.vertices = [ packSimPatch.vertices;obj.ModuleAssemblyInternal( rowsIdx, colIdx ).SimulationStrategyPatchDefinition.vertices ];
                            packSimPatch.facevertexcdata = [ packSimPatch.facevertexcdata;obj.ModuleAssemblyInternal( rowsIdx, colIdx ).SimulationStrategyPatchDefinition.facevertexcdata ];
                        elseif packRows == 1 && packColumns == 1
                            packPatch.faces = [ obj.ModuleAssemblyInternal( rowsIdx, colIdx ).BatteryPatchDefinition.faces ];
                            packPatch.vertices = [ obj.ModuleAssemblyInternal( rowsIdx, colIdx ).BatteryPatchDefinition.vertices ];
                            packPatch.facevertexcdata = [ obj.ModuleAssemblyInternal( rowsIdx, colIdx ).BatteryPatchDefinition.facevertexcdata ];

                            packSimPatch.faces = [ obj.ModuleAssemblyInternal( rowsIdx, colIdx ).SimulationStrategyPatchDefinition.faces ];
                            packSimPatch.vertices = [ obj.ModuleAssemblyInternal( rowsIdx, colIdx ).SimulationStrategyPatchDefinition.vertices ];
                            packSimPatch.facevertexcdata = [ obj.ModuleAssemblyInternal( rowsIdx, colIdx ).SimulationStrategyPatchDefinition.facevertexcdata ];
                        else
                        end
                    end
                    if packRows > 1
                        if rowsIdx == 1
                            maxFaceValue = 0;
                            maxSimFaceValue = 0;
                        else
                            maxFaceValue = max( packPatch.faces( : ) );
                            maxSimFaceValue = max( packSimPatch.faces( : ) );
                        end
                        packPatch.faces = [ packPatch.faces;obj.ModuleAssemblyInternal( rowsIdx, colIdx ).BatteryPatchDefinition.faces + maxFaceValue ];
                        packPatch.vertices = [ packPatch.vertices;obj.ModuleAssemblyInternal( rowsIdx, colIdx ).BatteryPatchDefinition.vertices ];
                        packPatch.facevertexcdata = [ packPatch.facevertexcdata;obj.ModuleAssemblyInternal( rowsIdx, colIdx ).BatteryPatchDefinition.facevertexcdata ];

                        packSimPatch.faces = [ packSimPatch.faces;obj.ModuleAssemblyInternal( rowsIdx, colIdx ).SimulationStrategyPatchDefinition.faces + maxSimFaceValue ];
                        packSimPatch.vertices = [ packSimPatch.vertices;obj.ModuleAssemblyInternal( rowsIdx, colIdx ).SimulationStrategyPatchDefinition.vertices ];
                        packSimPatch.facevertexcdata = [ packSimPatch.facevertexcdata;obj.ModuleAssemblyInternal( rowsIdx, colIdx ).SimulationStrategyPatchDefinition.facevertexcdata ];
                    elseif packRows == 1 && packColumns == 1
                        packPatch.faces = [ obj.ModuleAssemblyInternal( rowsIdx, colIdx ).BatteryPatchDefinition.faces ];
                        packPatch.vertices = [ obj.ModuleAssemblyInternal( rowsIdx, colIdx ).BatteryPatchDefinition.vertices ];
                        packPatch.facevertexcdata = [ obj.ModuleAssemblyInternal( rowsIdx, colIdx ).BatteryPatchDefinition.facevertexcdata ];

                        packSimPatch.faces = [ obj.ModuleAssemblyInternal( rowsIdx, colIdx ).SimulationStrategyPatchDefinition.faces ];
                        packSimPatch.vertices = [ obj.ModuleAssemblyInternal( rowsIdx, colIdx ).SimulationStrategyPatchDefinition.vertices ];
                        packSimPatch.facevertexcdata = [ obj.ModuleAssemblyInternal( rowsIdx, colIdx ).SimulationStrategyPatchDefinition.facevertexcdata ];
                    else
                    end
                end
                obj.BatteryPatchDefinition = packPatch;
                obj.SimulationStrategyPatchDefinition = packSimPatch;
            end

        end

    end

    methods ( Static, Hidden )

        function allModules = getAllModules( ModuleAssemblies )
            allModules = [  ];
            for moduleAssemblyIdx = 1:numel( ModuleAssemblies )
                if isrow( ModuleAssemblies( moduleAssemblyIdx ).Module ) && isrow( allModules )
                    allModules = [ allModules, ModuleAssemblies( moduleAssemblyIdx ).Module ];%#ok<AGROW>
                elseif isrow( ModuleAssemblies( moduleAssemblyIdx ).Module ) && isempty( allModules )
                    allModules = [ allModules;ModuleAssemblies( moduleAssemblyIdx ).Module ];%#ok<AGROW>
                elseif iscolumn( ModuleAssemblies( moduleAssemblyIdx ).Module ) && isempty( allModules )
                    allModules = [ allModules, ModuleAssemblies( moduleAssemblyIdx ).Module ];%#ok<AGROW>
                else
                    allModules = [ allModules;ModuleAssemblies( moduleAssemblyIdx ).Module ];%#ok<AGROW>
                end
            end
        end

        function [ TotNumModules, moduleAssemblyVec, moduleVec ] = TotNumModulesFcn( obj )
            TotNumModules = 0;
            for moduleAssemblyIdx = 1:obj.TotNumModuleAssemblies
                TotNumModules = TotNumModules + obj.ModuleAssembly( moduleAssemblyIdx ).TotNumModules;
            end
            moduleAssemblyVec = [  ];
            moduleVec = [  ];
            moduleInd = 1;
            moduleAssemblyInd = 1;
            TotNumModules_2 = obj.ModuleAssembly( 1 ).TotNumModules;
            for moduleIdx = 1:TotNumModules
                if moduleIdx <= TotNumModules_2
                    moduleAssemblyVec( moduleIdx ) = moduleAssemblyInd;%#ok<AGROW>
                    moduleVec( moduleIdx ) = moduleInd;%#ok<AGROW>
                    moduleInd = moduleInd + 1;
                elseif moduleIdx > TotNumModules_2
                    moduleAssemblyInd = moduleAssemblyInd + 1;
                    moduleAssemblyVec( moduleIdx ) = moduleAssemblyInd;%#ok<AGROW>
                    moduleInd = 1;
                    moduleVec( moduleIdx ) = moduleInd;%#ok<AGROW>
                    moduleInd = 1 + moduleInd;
                    TotNumModules_2 = TotNumModules_2 + obj.ModuleAssembly( moduleAssemblyInd ).TotNumModules;
                end
            end
        end
    end

    methods ( Access = protected )
        function propgrp = getPropertyGroups( ~ )
            propList = "ModuleAssembly";
            propgrp = matlab.mixin.util.PropertyGroup( propList );
        end
    end
end


