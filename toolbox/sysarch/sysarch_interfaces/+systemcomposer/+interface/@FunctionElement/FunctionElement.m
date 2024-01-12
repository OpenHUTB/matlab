classdef FunctionElement < systemcomposer.interface.Element

    properties
        Interface
        Name
        FunctionPrototype
        FunctionArguments
        Asynchronous
    end


    methods ( Hidden )
        function this = FunctionElement( impl )
            narginchk( 1, 1 );
            if ~isa( impl, 'systemcomposer.architecture.model.swarch.FunctionElement' )
                error( 'systemcomposer:API:FunctionElementInvalidInput', message( 'SystemArchitecture:API:FunctionElementInvalidInput' ).getString );
            end
            this@systemcomposer.interface.Element( impl );
            impl.cachedWrapper = this;
        end
    end


    methods ( Static, Hidden )
        function incheck( inval )
            persistent p
            if isempty( p )
                p = inputParser;
                addRequired( p, 'elementAttribute', @( x )ischar( x ) && ~isempty( x ) );
            end
            parse( p, inval );
        end


        function incheckDescription( inval )
            persistent pDescription
            if isempty( pDescription )
                pDescription = inputParser;
                addRequired( pDescription, 'elementAttribute', @( x )ischar( x ) || isstring( x ) );
            end
            parse( pDescription, inval );
        end


        function incheckAsynchronous( inval )
            persistent p
            if isempty( p )
                p = inputParser;
                addRequired( p, 'elementAttribute', @( x )islogical( x ) && ~isempty( x ) );
            end
            parse( p, inval );
        end
    end


    methods
        function interface = get.Interface( this )
            interface = this.getWrapperForImpl( this.getImpl(  ).getInterface(  ), 'systemcomposer.interface.ServiceInterface' );
        end


        function name = get.Name( this )
            name = this.getImpl(  ).getName(  );
        end


        function prototype = get.FunctionPrototype( this )
            prototype = this.getImpl(  ).getFunctionPrototype(  );
        end


        function args = get.FunctionArguments( this )
            implArguments = this.getImpl(  ).getFunctionArguments(  );
            args = systemcomposer.interface.FunctionArgument.empty( numel( implArguments ), 0 );
            for i = 1:numel( implArguments )
                args( i ) = systemcomposer.internal.getWrapperForImpl( implArguments( i ), 'systemcomposer.interface.FunctionArgument' );
            end
        end


        function synchronicity = get.Asynchronous( this )
            synchronicity = this.getImpl(  ).getAsynchronous(  );
        end


        function argument = getFunctionArgument( this, argName )
            arguments
                this( 1, 1 )systemcomposer.interface.FunctionElement
                argName{ mustBeTextScalar }
            end

            argumentImpl = this.getImpl(  ).getFunctionArgument( argName );
            if ( isempty( argumentImpl ) )
                argument = systemcomposer.interface.FunctionArgument.empty(  );
            else
                argument = systemcomposer.internal.getWrapperForImpl( argumentImpl, 'systemcomposer.interface.FunctionArgument' );
            end
        end


        function setName( this, name )
            systemcomposer.interface.FunctionElement.incheck( name );

            isModelContext = isempty( this.Interface.Dictionary.ddConn );
            sourceName = this.Interface.Dictionary.getSourceName;
            systemcomposer.BusObjectManager.RenameInterfaceElement(  ...
                sourceName, isModelContext, this.Interface.Name, this.Name, name );
        end


        function setFunctionPrototype( this, prototype )
            arguments
                this( 1, 1 )systemcomposer.interface.FunctionElement
                prototype{ mustBeTextScalar }
            end
            this.setElementProperty( 'Prototype', prototype );
        end


        function setAsynchronous( this, isAsync )
            arguments
                this( 1, 1 )systemcomposer.interface.FunctionElement
                isAsync{ mustBeNumericOrLogical }
            end
            systemcomposer.interface.FunctionElement.incheckAsynchronous( isAsync );
            this.setElementProperty( 'Asynchronous', isAsync );
        end


        function destroy( ~ )
        end
    end


    methods ( Access = private )
        function setElementProperty( this, propName, propVal )

            isModelContext = isempty( this.Interface.Dictionary.ddConn );
            sourceName = this.Interface.Dictionary.getSourceName;
            systemcomposer.BusObjectManager.SetFunctionElementProperty(  ...
                sourceName, isModelContext, this.Interface.Name, this.Name,  ...
                propName, propVal );
        end

    end
end


