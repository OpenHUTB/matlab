classdef ( Abstract )HookedMixin < handle

    properties ( Access = private )
        Dispatchers( 1, 1 )dictionary = dictionary( string.empty(  ), function_handle.empty(  ) )
    end

    methods ( Access = protected, Sealed )

        function hook = createHook( this, alias, opts )
            arguments
                this( 1, 1 )
                alias( 1, 1 )string{ mustBeValidVariableName( alias ) }
                opts.Name( 1, 1 )string = alias
                opts.Logger coderapp.internal.log.Logger{ mustBeScalarOrEmpty( opts.Logger ) }
            end

            assert( ~this.Dispatchers.isKey( alias ), 'Hook with alias "%s" already registered on this object', alias );
            hookArgs = namedargs2cell( opts );
            [ hook, this.Dispatchers( alias ) ] = coderapp.internal.util.Hook.create( hookArgs{ : } );
        end


        function varargout = invokeHook( this, alias, hookArgs )
            arguments
                this( 1, 1 )
                alias( 1, 1 )string
            end
            arguments( Repeating )
                hookArgs
            end

            dispatcher = this.Dispatchers( alias );
            if nargout == 0
                feval( dispatcher, hookArgs{ : } );
            else
                [ varargout{ 1:nargout } ] = feval( dispatcher, hookArgs{ : } );
            end
        end
    end
end



