classdef DecoratedException < MException

    properties ( SetAccess = immutable )
        ErrorDef
    end

    properties
        IsInternal( 1, 1 )logical
        UiMessage coderapp.internal.util.Message{ mustBeScalarOrEmpty }
        DocRef coderapp.internal.util.DocRef{ mustBeScalarOrEmpty }
        CustomData = codergui.internal.undefined(  )
    end

    properties ( SetAccess = private )
        DebugCause MException
    end

    properties ( Access = private )
        CustomProperties( 1, 1 )struct
    end

    methods

        function this = DecoratedException( errorDef, varargin )
            arguments
                errorDef( 1, 1 )coderapp.internal.error.ErrorEnumerable
            end
            arguments( Repeating )
                varargin
            end

            this@MException( errorDef.ErrorId, '%s', errorDef.getMessageText( varargin{ : } ) );
            this.ErrorDef = errorDef;
            this.IsInternal = errorDef.IsInternal;
        end


        function this = setCustomProperty( this, prop, value )
            arguments
                this( 1, 1 )
            end
            arguments( Repeating )
                prop( 1, 1 )string{ mustBeValidVariableName }
                value
            end

            for i = 1:numel( prop )
                this.CustomProperties.( prop{ i } ) = value{ i };
            end
        end


        function value = getCustomProperty( this, prop )
            arguments
                this( 1, 1 )
                prop( 1, 1 )string{ mustBeValidVariableName }
            end

            if this.hasCustomProperty( prop )
                value = this.CustomProperties.( prop );
            end
        end


        function yes = hasCustomProperty( this, prop )
            arguments
                this( 1, 1 )
                prop string{ mustBeValidVariableName }
            end

            yes = isfield( this.CustomProperties, prop );
        end


        function this = withInternal( this, internal )
            arguments
                this( 1, 1 )
                internal( 1, 1 )logical = true
            end

            this.IsInternal = internal;
        end


        function this = withUiMessage( this, uiMessage )
            arguments
                this( 1, 1 )
                uiMessage coderapp.internal.util.Message{ mustBeScalarOrEmpty }
            end

            this.UiMessage = uiMessage;
        end


        function this = withDocRef( this, docRef )
            arguments
                this( 1, 1 )
                docRef coderapp.internal.util.DocRef{ mustBeScalarOrEmpty }
            end

            this.DocRef = docRef;
        end


        function this = withCustomData( this, customData )
            arguments
                this( 1, 1 )
                customData
            end

            this.CustomData = customData;
        end


        function this = withCause( this, cause )
            arguments
                this( 1, 1 )
                cause MException{ mustBeScalarOrEmpty }
            end

            if isempty( cause )
                return
            end
            if coderapp.internal.error.isInternal( cause )
                this.DebugCause( end  + 1 ) = cause;
            else
                this = this.addCause( this, cause );
            end
        end
    end

    methods ( Static )

        function derived = strip( exception )
            arguments
                exception( 1, 1 )MException
            end
            derived = coderapp.internal.error.toException( exception, NoStack = true );
        end
    end
end


