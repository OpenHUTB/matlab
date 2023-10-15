classdef ( Abstract )Geometry

    properties ( Dependent )
        Height( 1, 1 ){ mustBeA( Height, [ "simscape.Value", "double" ] ) }
    end

    properties ( SetAccess = private, Hidden )



        HeightInternal( 1, 1 ){ mustBeA( HeightInternal, "simscape.Value" ),  ...
            simscape.mustBeCommensurateUnit( HeightInternal, "m" ) } = simscape.Value( 0.07, "m" )
    end

    methods
        function obj = Geometry( namedArgs )
            arguments
                namedArgs.Height( 1, 1 ){ mustBeA( namedArgs.Height, [ "simscape.Value", "double" ] ) } = simscape.Value( 0.07, "m" )
            end
            obj.Height = namedArgs.Height;
        end

        function obj = set.Height( obj, val )
            if strcmp( class( val ), "double" )
                warning( message( "physmod:battery:builder:batteryclasses:DoubleToSimscapeValueMeters" ) )
                val = simscape.Value( val, "m" );
            end
            simscape.mustBeCommensurateUnit( val, "m" )
            assert( value( val, "m" ) > 0, message( "physmod:battery:builder:batteryclasses:InvalidHeight" ) );
            assert( value( val, "m" ) < 5, message( "physmod:battery:builder:batteryclasses:LargeHeight", 5 ) );
            obj.HeightInternal = val;
        end

        function value = get.Height( obj )
            value = obj.HeightInternal;
        end

    end
end

