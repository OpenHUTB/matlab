classdef ( Sealed )LogLevel < uint8

    enumeration
        All( 0 )
        Trace( 40 )
        Debug( 80 )
        Info( 120 )
        Warn( 160 )
        Error( 200 )
        Fatal( 240 )
        Off( 255 )
    end

    methods ( Static )
        function level = toLevel( arg, nearest )
            arguments
                arg{ mustBeA( arg, [ "string", "char", "uint8", "uint32", "int32", "double" ] ) }
                nearest( 1, 1 )logical = false
            end

            if isa( arg, 'coderapp.internal.log.LogLevel' )
                level = arg;
                return
            elseif isnumeric( arg )
                levels = enumeration( 'coderapp.internal.log.LogLevel' );
                level = levels( levels == arg );
                if isempty( level )
                    if nearest
                        level = levels( find( levels >= arg, 1, 'last' ) );
                    else
                        level = uint8( arg );
                    end
                end
            else
                level = coderapp.internal.log.LogLevel( arg );
            end
        end
    end
end


