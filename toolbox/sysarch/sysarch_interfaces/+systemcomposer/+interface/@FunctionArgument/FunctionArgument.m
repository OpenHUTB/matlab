classdef FunctionArgument < systemcomposer.interface.Element

    properties ( SetAccess = private )
        Interface
        Element
        Name
        Type
        Dimensions
        Description
    end


    methods ( Hidden )
        function this = FunctionArgument( impl )
            narginchk( 1, 1 );
            if ~isa( impl, 'systemcomposer.architecture.model.swarch.FunctionArgument' )
                error( 'systemcomposer:API:FunctionArgumentInvalidInput', message( 'SystemArchitecture:API:FunctionArgumentInvalidInput' ).getString );
            end
            this@systemcomposer.interface.Element( impl );
            impl.cachedWrapper = this;
        end


        function setTypeFromString( this, typeStr )

            model = this.Interface.Model;
            if ~isempty( model )
                dict = model.getImpl.getPortInterfaceCatalog;
            else
                dict = this.Interface.getImpl(  ).getCatalog(  );
            end
            [ typeObjOrName, isShared ] = systemcomposer.internal.getTypeFromString( typeStr, dict );
            if isShared
                this.setType( typeObjOrName );
            elseif ( ~this.getImpl(  ).hasOwnedType(  ) )
                this.createOwnedType( 'DataType', typeObjOrName );
            else
                this.Type = typeObjOrName;
                this.setElementProperty( 'Type', typeObjOrName );
            end
        end
    end


    methods ( Static, Hidden )
        function incheck( inval )
            persistent p
            if isempty( p )
                p = inputParser;
                addRequired( p, 'elementAttribute', @( x )( ischar( x ) && ~isempty( x ) || isstring( x ) && ~isequal( x, "" ) ) );
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
    end


    methods
        function interface = get.Interface( this )
            interface = this.getWrapperForImpl( this.getImpl(  ).getFunctionElement(  ).getInterface(  ), 'systemcomposer.interface.ServiceInterface' );
        end


        function interface = get.Element( this )
            interface = this.getWrapperForImpl( this.getImpl(  ).getFunctionElement(  ), 'systemcomposer.interface.FunctionElement' );
        end


        function name = get.Name( this )
            name = this.getImpl(  ).getName(  );
        end


        function setName( this, name )
            systemcomposer.interface.FunctionArgument.incheck( name );

            isModelContext = isempty( this.Interface.Dictionary.ddConn );
            sourceName = this.Interface.Dictionary.getSourceName;
            systemcomposer.BusObjectManager.RenameInterfaceElement(  ...
                sourceName, isModelContext, this.Interface.Name, this.Element.Name, this.Name, name );
        end


        function type = get.Type( this )
            type = systemcomposer.internal.getWrapperForImpl( this.getImpl(  ).getTypeAsInterface(  ) );
        end

        function setType( this, type )
            arguments
                this( 1, 1 )systemcomposer.interface.FunctionArgument
                type( 1, 1 ){ mustBeA( type, [ "systemcomposer.ValueType",  ...
                    "systemcomposer.interface.DataInterface" ] ) }
            end

            if isa( type, 'systemcomposer.ValueType' )
                typeStr = [ 'ValueType: ', type.Name ];
            else
                typeStr = [ 'Bus: ', type.Name ];
            end

            this.setElementProperty( 'Type', typeStr );
        end


        function type = createOwnedType( this, nameValuePairs )
            arguments
                this( 1, 1 )systemcomposer.interface.FunctionArgument
                nameValuePairs.DataType{ mustBeTextScalar } = 'double'
                nameValuePairs.Dimensions{ mustBeTextScalar } = '1'
                nameValuePairs.Complexity{ mustBeTextScalar } = 'real'
                nameValuePairs.Units{ mustBeTextScalar } = ''
                nameValuePairs.Minimum{ mustBeTextScalar } = '[]'
                nameValuePairs.Maximum{ mustBeTextScalar } = '[]'
            end

            this.setElementProperty( 'Type', nameValuePairs.DataType );
            this.setDimensions( nameValuePairs.Dimensions );
            this.setUnits( nameValuePairs.Units );
            this.setComplexity( nameValuePairs.Complexity );
            this.setMinimum( nameValuePairs.Minimum );
            this.setMaximum( nameValuePairs.Maximum );
            type = this.Type;
        end


        function dimensions = get.Dimensions( this )
            dimensions = this.getImpl(  ).getDimensions(  );
        end


        function setDimensions( this, dimensions )
            systemcomposer.interface.FunctionArgument.incheck( dimensions );
            this.setElementProperty( 'Dimensions', dimensions );
        end


        function setUnits( this, units )
            arguments
                this( 1, 1 )systemcomposer.interface.FunctionArgument
                units{ mustBeTextScalar }
            end
            this.setElementProperty( 'Units', units );
        end


        function setComplexity( this, complexity )
            p = inputParser;
            validComplexities = { 'real', 'complex', 'auto' };
            addRequired( p, 'complexity', @( x )any( validatestring( x, validComplexities ) ) );
            parse( p, complexity );
            systemcomposer.interface.FunctionArgument.incheck( complexity );
            this.setElementProperty( 'Complexity', complexity );
        end


        function setMinimum( this, minimum )
            systemcomposer.interface.FunctionArgument.incheck( minimum );
            this.setElementProperty( 'Minimum', minimum );
        end


        function setMaximum( this, maximum )
            systemcomposer.interface.FunctionArgument.incheck( maximum );
            this.setElementProperty( 'Maximum', maximum );
        end


        function description = get.Description( this )
            description = this.getImpl(  ).getDescription(  );
        end


        function setDescription( this, description )
            systemcomposer.interface.FunctionArgument.incheckDescription( description );
            this.setElementProperty( 'Description', description );
        end


        function destroy( ~ )
        end
    end


    methods ( Access = private )
        function setElementProperty( this, propName, propVal )
            isModelContext = isempty( this.Interface.Dictionary.ddConn );
            sourceName = this.Interface.Dictionary.getSourceName;
            systemcomposer.BusObjectManager.SetFunctionArgumentProperty(  ...
                sourceName, isModelContext, this.Interface.Name, this.Element.Name, this.Name,  ...
                propName, propVal );
        end
    end

end

