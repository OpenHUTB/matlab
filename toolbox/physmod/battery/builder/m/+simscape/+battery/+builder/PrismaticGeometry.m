classdef PrismaticGeometry < simscape.battery.builder.internal.Geometry

    properties ( Dependent )

        Length( 1, 1 ){ mustBeA( Length, [ "simscape.Value", "double" ] ),  ...
            simscape.mustBeCommensurateUnit( Length, "m" ) }

        Thickness( 1, 1 ){ mustBeA( Thickness, [ "simscape.Value", "double" ] ),  ...
            simscape.mustBeCommensurateUnit( Thickness, "m" ) }
    end

    properties ( SetAccess = private, Hidden )



        LengthInternal( 1, 1 ){ mustBeA( LengthInternal, "simscape.Value" ),  ...
            simscape.mustBeCommensurateUnit( LengthInternal, "m" ) } = simscape.Value( 0.30, "m" )



        ThicknessInternal( 1, 1 ){ mustBeA( ThicknessInternal, "simscape.Value" ),  ...
            simscape.mustBeCommensurateUnit( ThicknessInternal, "m" ) } = simscape.Value( 0.045, "m" )
    end

    methods

        function obj = PrismaticGeometry( namedArgs )
            arguments
                namedArgs.Length( 1, 1 ){ mustBeA( namedArgs.Length, [ "simscape.Value", "double" ] ) } = simscape.Value( 0.30, "m" )
                namedArgs.Thickness( 1, 1 ){ mustBeA( namedArgs.Thickness, [ "simscape.Value", "double" ] ) } = simscape.Value( 0.045, "m" )
                namedArgs.Height( 1, 1 ){ mustBeA( namedArgs.Height, [ "simscape.Value", "double" ] ) } = simscape.Value( 0.15, "m" )
            end


            if ~pmsl_checklicense( 'simscape_battery' )
                error( message( 'physmod:battery:license:MissingLicense' ) );
            end
            obj.Length = namedArgs.Length;
            obj.Thickness = namedArgs.Thickness;
            obj.Height = namedArgs.Height;

        end

        function obj = set.Length( obj, val )
            val = obj.doubleToSimscapeValueConversion( val );
            simscape.mustBeCommensurateUnit( val, "m" )
            try
                assert( value( val, "m" ) > 0, message( "physmod:battery:builder:batteryclasses:InvalidLength" ) );
                assert( value( val, "m" ) < 5, message( "physmod:battery:builder:batteryclasses:LargeLength", "5" ) );
            catch me
                throwAsCaller( me )
            end
            obj.LengthInternal = val;
        end
        function value = get.Length( obj )
            value = obj.LengthInternal;
        end
        function obj = set.Thickness( obj, val )
            val = obj.doubleToSimscapeValueConversion( val );
            simscape.mustBeCommensurateUnit( val, "m" )
            try
                assert( value( val, "m" ) > 0, message( "physmod:battery:builder:batteryclasses:InvalidThickness" ) );
                assert( value( val, "m" ) < 0.5, message( "physmod:battery:builder:batteryclasses:LargeThickness", "0.5" ) );
            catch me
                throwAsCaller( me )
            end
            obj.ThicknessInternal = val;
        end
        function value = get.Thickness( obj )
            value = obj.ThicknessInternal;
        end
        function val = doubleToSimscapeValueConversion( ~, val )
            if isa( val, "double" )
                warning( message( "physmod:battery:builder:batteryclasses:DoubleToSimscapeValueMeters" ) )
                val = simscape.Value( val, "m" );
            end
        end
    end
end

