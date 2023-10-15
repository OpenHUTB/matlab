classdef ( Sealed )Cell < simscape.battery.builder.internal.Battery

    properties ( Dependent )







        Geometry{ mustBeA( Geometry, [ "simscape.battery.builder.PouchGeometry",  ...
            "simscape.battery.builder.PrismaticGeometry",  ...
            "simscape.battery.builder.CylindricalGeometry", "double" ] ) }


        CellModelOptions simscape.battery.builder.CellModelBlock



        Mass( 1, 1 ){ mustBeA( Mass, [ "simscape.Value", "double" ] ) }



        StackingAxis( 1, 1 )string{ mustBeMember( StackingAxis,  ...
            [ "X", "Y" ] ) }



        Position( 1, 3 )double{ mustBeReal, mustBeFinite }

        Name( 1, 1 )string
    end

    properties ( Dependent, SetAccess = protected )


        PackagingVolume( 1, 1 ){ mustBeA( PackagingVolume, "simscape.Value" ),  ...
            simscape.mustBeCommensurateUnit( PackagingVolume, "m^3" ) }


        CumulativeMass( 1, 1 ){ mustBeA( CumulativeMass, "simscape.Value" ),  ...
            simscape.mustBeCommensurateUnit( CumulativeMass, "kg" ) }


        NumModels( 1, 1 )double{ mustBeInteger }
    end
    properties ( Dependent, SetAccess = protected, Hidden )


        SimulationToHardwareMapping( :, : )uint16{ mustBeInteger }
    end
    properties ( SetAccess = private, Hidden )







        GeometryInternal{ mustBeA( GeometryInternal, [ "simscape.battery.builder.PouchGeometry",  ...
            "simscape.battery.builder.PrismaticGeometry",  ...
            "simscape.battery.builder.CylindricalGeometry",  ...
            "double" ] ) }


        ModelOptionsInternal( 1, 1 )simscape.battery.builder.CellModelBlock ...
            = simscape.battery.builder.CellModelBlock;



        MassInternal( 1, 1 ){ mustBeA( MassInternal, "simscape.Value" ),  ...
            simscape.mustBeCommensurateUnit( MassInternal, "kg" ) } = simscape.Value( 0.1, "kg" )



        StackingAxisInternal( 1, 1 )string ...
            { mustBeMember( StackingAxisInternal,  ...
            [ "X", "Y" ] ) } = "Y"



        PositionInternal( :, 1 )simscape.battery.builder.internal.Position ...
            = simscape.battery.builder.internal.Position( X = 0, Y = 0, Z = 0 )

        NameInternal( 1, 1 )string


        Layout



        Center( :, 1 )simscape.battery.builder.internal.Position ...
            = simscape.battery.builder.internal.Position( X = 0, Y = 0, Z = 0 )


        Color simscape.battery.builder.internal.StateVariable


        Points( :, 1 )simscape.battery.builder.internal.Points

        Elements


        BatteryPatchDefinition( :, 1 )

        SimulationStrategyPatchDefinition( :, 1 )
    end

    properties ( Dependent, SetAccess = private )

        Format( 1, 1 )string{ mustBeMember( Format, [ "Pouch", "Prismatic",  ...
            "Cylindrical", "" ] ) }




        ThermalEffects( 1, : )simscape.enum.thermaleffects
    end

    properties ( Constant )

        Type = "Cell"
    end

    methods
        function obj = Cell( namedArgs )
            arguments
                namedArgs.Geometry{ mustBeA( namedArgs.Geometry, [ "simscape.battery.builder.PouchGeometry",  ...
                    "simscape.battery.builder.PrismaticGeometry",  ...
                    "simscape.battery.builder.CylindricalGeometry", "double" ] ) } = [  ]
                namedArgs.CellModelOptions( 1, 1 )simscape.battery.builder.CellModelBlock ...
                    = simscape.battery.builder.CellModelBlock
                namedArgs.Mass( 1, 1 ){ mustBeA( namedArgs.Mass, [ "simscape.Value", "double" ] ) } = simscape.Value( 0.1, "kg" )
                namedArgs.Position( 1, 3 )double{ mustBeReal, mustBeFinite } = [ 0, 0, 0 ]
                namedArgs.StackingAxis( 1, 1 )string{ mustBeMember( namedArgs.StackingAxis, [ "X", "Y" ] ) } = "Y"
                namedArgs.Name( 1, 1 )string = "Cell1"
            end

            if ~pmsl_checklicense( 'simscape_battery' )
                error( message( 'physmod:battery:license:MissingLicense' ) );
            end

            obj = obj.updateColor;

            obj.Geometry = namedArgs.Geometry;
            obj.CellModelOptions = namedArgs.CellModelOptions;
            obj.Mass = namedArgs.Mass;
            obj.Position = namedArgs.Position;
            obj.StackingAxis = namedArgs.StackingAxis;
            obj.Name = namedArgs.Name;
            obj = obj.updateLayout;
        end

        function obj = set.Geometry( obj, val )

            try
                assert( ( any( contains( superclasses( val ), "simscape.battery.builder.internal.Geometry" ) ) || isempty( val ) ),  ...
                    message( "physmod:battery:builder:batteryclasses:InvalidCellGeometry" ) );
            catch me
                throwAsCaller( me )
            end

            obj.GeometryInternal = val;

            obj = obj.updateElements;


            obj = obj.updateLayout;
        end

        function value = get.Geometry( obj )
            value = obj.GeometryInternal;
        end

        function value = get.ThermalEffects( obj )
            value = obj.CellModelOptions.BlockParameters.thermal_port;
        end

        function obj = set.Name( obj, val )
            obj.NameInternal = val;
        end

        function value = get.Name( obj )
            value = obj.NameInternal;
        end

        function obj = set.CellModelOptions( obj, val )
            obj.ModelOptionsInternal = val;
        end

        function value = get.CellModelOptions( obj )
            value = obj.ModelOptionsInternal;
        end

        function obj = set.Mass( obj, val )
            if isa( val, "double" )
                warning( message( "physmod:battery:builder:batteryclasses:DoubleToSimscapeValueKilogram" ) )
                val = simscape.Value( val, "kg" );
            end
            simscape.mustBeCommensurateUnit( val, "kg" )
            try
                assert( value( val, "kg" ) > 0,  ...
                    message( "physmod:battery:builder:batteryclasses:InvalidMass" ) );
                assert( value( val, "kg" ) < 100,  ...
                    message( "physmod:battery:builder:batteryclasses:LargeMass", 100 ) );
            catch me
                throwAsCaller( me )
            end
            obj.MassInternal = val;
        end

        function value = get.Mass( obj )
            value = obj.MassInternal;
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

        function val = get.SimulationStrategyPatchDefinition( obj )
            val = obj.BatteryPatchDefinition;
        end

        function value = get.Format( obj )

            switch class( obj.Geometry )
                case "simscape.battery.builder.CylindricalGeometry"
                    value = "Cylindrical";
                case "simscape.battery.builder.PouchGeometry"
                    value = "Pouch";
                case "simscape.battery.builder.PrismaticGeometry"
                    value = "Prismatic";
                otherwise
                    value = "";
            end
        end

        function val = get.PackagingVolume( obj )
            if isempty( obj.XExtent )
                val = simscape.Value( [  ], "m^3" );
            else
                thesePoints = [ obj.Points ];
                [ X, Y, Z ] = deal( max( [ thesePoints.XData ], [  ], "all" ) - min( [ thesePoints.XData ], [  ], "all" ),  ...
                    min( [ thesePoints.YData ], [  ], "all" ) - max( [ thesePoints.YData ], [  ], "all" ),  ...
                    max( [ thesePoints.ZData ], [  ], "all" ) - min( [ thesePoints.ZData ], [  ], "all" ) );
                val = simscape.Value( abs( X * Y * Z ), "m^3" );
            end
        end

        function value = get.CumulativeMass( obj )
            value = obj.Mass;
        end

        function value = get.SimulationToHardwareMapping( ~ )
            BatteryTypes = [ "Cell", "Model" ];
            SimulationToHardware( :, 1 ) = 1;
            SimulationToHardware( :, 2 ) = 1;
            value = array2table( SimulationToHardware );
            value.Properties.VariableNames = BatteryTypes;
        end

        function value = get.NumModels( obj )
            value = obj.SimulationToHardwareMapping.Model( end  );
        end

    end

    methods ( Hidden )
        function value = getExtent( obj, axisExtentName )
            if isempty( obj.Points )
                value = simscape.Value( [  ], "m" );
            else
                allPoints = [ obj( 1:end  ).Points ];
                if strcmp( axisExtentName, "YData" )
                    value = simscape.Value( min( min( ( [ allPoints.( axisExtentName ) ] ) ) ), "m" );
                else
                    value = simscape.Value( max( max( abs( [ allPoints.( axisExtentName ) ] ) ) ), "m" );
                end
            end
        end
    end
    methods ( Access = private )
        function obj = updateElements( obj )


            if isempty( obj.Format )
                obj.Elements = [  ];
            else
                obj.Elements = [  ];
                switch obj.Format
                    case "Cylindrical"
                        obj.Elements.Radii = 2;
                        obj.Elements.Circumference = 24;
                        obj.Elements.Height = 1;
                    case { "Pouch";"Prismatic" }
                        obj.Elements.Length = 1;
                        obj.Elements.Thickness = 1;
                        obj.Elements.Height = 1;
                end
            end
        end

        function obj = updateColor( obj )
            obj.Color = simscape.battery.builder.internal.StateVariable(  );
        end

        function obj = updateLayout( obj )

            obj.Layout = 1;

            obj = obj.updateCenter;

            obj = obj.updatePoints;
        end

        function obj = updateCenter( obj )
            if isempty( obj.Elements ) ...
                    || isempty( obj.Geometry )
                return
            end

            switch obj.Format
                case "Cylindrical"
                    cellRadius = value( obj.Geometry.Radius, "m" );
                    cellDiameter = 2 * cellRadius;
                    locationXOdd = cellRadius + ( 0:cellDiameter:cellDiameter );
                    locationY =  - ( cellRadius + ( 0:cellDiameter:cellDiameter ) );
                    [ thisX, thisY, thisZ ] = deal( locationXOdd( 1 ), locationY( 1 ), 0 );
                case { "Pouch";"Prismatic" }
                    cellLength = value( obj.Geometry.Length, "m" );
                    cellThickness = value( obj.Geometry.Thickness, "m" );
                    if obj.StackingAxis == "X"
                        locationXOdd = ( cellThickness / 2 + ( 0:cellThickness:cellThickness ) );
                        locationY =  - ( cellLength / 2 + ( 0:cellLength:cellLength ) );
                    else
                        locationXOdd = cellLength / 2 + ( 0:cellLength:cellLength );
                        locationY =  - ( cellThickness / 2 + ( 0:cellThickness:cellThickness ) );
                    end
                    [ thisX, thisY, thisZ ] = deal( locationXOdd( 1 ), locationY( 1 ), 0 );
            end
            obj.Center = simscape.battery.builder.internal.Position( X = thisX + obj.PositionInternal.X,  ...
                Y = thisY + obj.PositionInternal.Y, Z = thisZ + obj.PositionInternal.Z );
        end

        function obj = updatePoints( obj )

            if isempty( obj.Elements ) ...
                    || isempty( obj.Geometry ) ...
                    || isempty( obj.Center )

                X = NaN( 2, 1 );
                Y = NaN( 2, 1 );
                Z = NaN( 2, 2 );
                C = NaN( 2, 2 );
                obj.BatteryPatchDefinition = surf2patch( X, Y, Z, C );
                return
            end
            switch obj.Format
                case "Cylindrical"


                    [ obj.Points, obj.BatteryPatchDefinition ] = obj.CylindricalGeometryPatchDefinition;
                case "Pouch"


                    [ obj.Points, obj.BatteryPatchDefinition ] = obj.PouchGeometryPatchDefinition;
                case "Prismatic"


                    [ obj.Points, obj.BatteryPatchDefinition ] = obj.PrismaticGeometryPatchDefinition;
            end
        end
    end

    methods ( Access = protected )

        function propgrp = getPropertyGroups( ~ )
            propList = [ "Geometry", "CellModelOptions", "Mass" ];
            propgrp = matlab.mixin.util.PropertyGroup( propList );
        end
    end
end



