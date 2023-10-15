classdef NameOrIndex

    properties
        Value
    end

    methods
        function obj = NameOrIndex( value )
            arguments
                value = uint32( 1 )
            end
            import simscape.ui.internal.NameOrIndex
            if isnumeric( value ) && isempty( value )
                obj = repmat( NameOrIndex, size( value ) );
                return
            end
            obj.Value = value;
        end

        function obj = set.Value( obj, value )
            arguments
                obj( 1, 1 )
                value
            end
            if isnumeric( value )
                obj.Value = lIndex( value );
            else
                obj.Value = lName( value );
            end
        end
        function disp( obj )
            if isscalar( obj )
                builtin( 'disp', obj );
            else
                s = strjoin( string( num2cell( size( obj ) ) ), 'x' );
                fprintf( '%s NameOrIndex array with elements:\n', s );
                disp( ' ' );
                out = arrayfun( @( i )i.Value, obj, 'UniformOutput', false );%#ok<NASGU>
                str = evalc( 'disp(out)' );
                str = strrep( str, '{', '' );
                str = strrep( str, '}', '' );
                disp( str );
            end
        end
    end
end

function str = lName( v )
arguments
    v( 1, 1 )string{ mustBeNonzeroLengthText }
end
str = v;
end

function val = lIndex( v )
arguments
    v( 1, 1 )uint32{ mustBePositive }
end
val = v;
end


