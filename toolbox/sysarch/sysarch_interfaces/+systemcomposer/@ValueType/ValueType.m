classdef ValueType < systemcomposer.base.StereotypableElement & systemcomposer.base.BaseElement

    properties ( Dependent = true )
        Name
        DataType
        Dimensions
        Units
        Complexity
        Minimum
        Maximum
        Description
    end


    properties ( Dependent = true, SetAccess = private )
        Owner
    end


    properties ( GetAccess = private, SetAccess = private )
        ParameterOwner
    end


    properties ( Hidden, SetAccess = private )
        Type
    end


    properties ( Dependent = true, SetAccess = private )
        Model
    end


    methods ( Hidden )
        function this = ValueType( impl, varargin )
            narginchk( 1, 2 );
            if ~isa( impl, 'systemcomposer.architecture.model.interface.ValueTypeInterface' ) && ~isa( impl, 'systemcomposer.internal.parameter.ParameterDefinition' )
                error( 'systemcomposer:API:ValueTypeInvalidInput', message( 'SystemArchitecture:API:ValueTypeInvalidInput' ).getString );
            end
            this@systemcomposer.base.BaseElement( impl );
            impl.cachedWrapper = this;
            if isa( impl, 'systemcomposer.internal.parameter.ParameterDefinition' )
                if isa( varargin{ 1 }, 'systemcomposer.arch.Architecture' )
                    this.ParameterOwner = varargin{ 1 };
                end
            end
        end


        function setType( this, type )
            this.setDataType( type );
        end


        function setTypeFromString( this, typeStr )
            this.setDataType( typeStr );
        end


        function tf = isAnonymous( this )
            tf = this.getImpl.isAnonymous(  );
        end
    end


    methods

        function m = get.Model( this )
            if isa( this.getImpl, 'systemcomposer.architecture.model.interface.ValueTypeInterface' )

                m = systemcomposer.arch.Model.empty;
                if ( this.getImpl.isAnonymous )

                    containerModel = mf.zero.getModel( this.getImpl );
                    zcModel = systemcomposer.architecture.model.SystemComposerModel.getSystemComposerModel( containerModel );
                    modelName = zcModel.getName;
                    if bdIsLoaded( modelName )
                        m = get_param( modelName, 'SystemComposerModel' );
                    end
                else
                    catalog = this.getImpl(  ).getCatalog(  );
                    catalogOwnerName = catalog.getStorageSource;
                    if ( catalog.getStorageContext == systemcomposer.architecture.model.interface.Context.MODEL ) ...
                            && bdIsLoaded( catalogOwnerName )
                        m = get_param( catalogOwnerName, 'SystemComposerModel' );
                    end
                end
            else
                if ~isempty( this.Owner )
                    m = get_param( this.Owner.SimulinkModelHandle, 'SystemComposerModel' );
                end
            end
        end


        function owner = get.Owner( this )
            if isa( this.getImpl, 'systemcomposer.architecture.model.interface.ValueTypeInterface' )
                if this.getImpl.isAnonymous
                    if ~isempty( this.getImpl.p_AnonymousUsage )
                        owner = systemcomposer.internal.getWrapperForImpl( this.getImpl.p_AnonymousUsage.p_Port );
                        return ;
                    elseif ~isempty( this.getImpl.p_OwningDataElement )
                        owner = systemcomposer.internal.getWrapperForImpl( this.getImpl.p_OwningDataElement );
                        return ;
                    end
                end
                owner = systemcomposer.internal.getWrapperForImpl( this.getImpl.getCatalog );
            else
                owner = this.ParameterOwner;
            end
        end


        function name = get.Name( this )
            name = this.getImpl(  ).getName(  );
        end


        function set.Name( this, name )
            this.setName( name );
        end


        function setName( this, name )
            arguments
                this systemcomposer.ValueType
                name{ mustBeTextScalar }
            end

            this.setImplProperty( 'Name', name );
        end


        function type = get.Type( this )
            type = this.DataType;
        end


        function type = get.DataType( this )
            if isa( this.getImpl, 'systemcomposer.architecture.model.interface.ValueTypeInterface' )
                type = this.getImpl(  ).p_Type;
            else
                type = this.getImpl.getBaseType;
            end
        end


        function set.DataType( this, type )
            this.setDataType( type );
        end


        function setDataType( this, type )
            arguments
                this systemcomposer.ValueType
                type{ mustBeTextScalar }
            end

            this.setImplProperty( 'Type', type );
        end


        function dimensions = get.Dimensions( this )
            if isa( this.getImpl, 'systemcomposer.architecture.model.interface.ValueTypeInterface' )
                dimensions = this.getImpl(  ).p_Dimensions;
            else
                dimsVec = this.getImpl.getDimensions';
                if isscalar( dimsVec )
                    dimensions = num2str( dimsVec );
                else
                    dimensions = sprintf( '[%s]', num2str( dimsVec ) );
                end
            end
        end


        function set.Dimensions( this, dimensions )
            this.setDimensions( dimensions );
        end


        function setDimensions( this, dimensions )
            arguments
                this systemcomposer.ValueType
                dimensions{ mustBeTextScalar }
            end
            this.setImplProperty( 'Dimensions', dimensions );
        end


        function units = get.Units( this )
            if isa( this.getImpl, 'systemcomposer.architecture.model.interface.ValueTypeInterface' )
                units = this.getImpl(  ).p_Units;
            else
                units = this.getImpl.defaultValue.units;
                if isempty( units )
                    units = this.getImpl.getUnit;
                end
            end
        end


        function set.Units( this, units )
            this.setUnits( units );
        end


        function setUnits( this, units )
            arguments
                this systemcomposer.ValueType
                units{ mustBeTextScalar }
            end

            this.setImplProperty( 'Units', units );
        end


        function complexity = get.Complexity( this )
            if isa( this.getImpl, 'systemcomposer.architecture.model.interface.ValueTypeInterface' )
                complexity = this.getImpl(  ).p_Complexity;
            else
                complexity = 'real';
            end
        end


        function set.Complexity( this, complexity )
            this.setComplexity( complexity );
        end


        function setComplexity( this, complexity )
            arguments
                this systemcomposer.ValueType
                complexity{ mustBeMember( complexity, { 'real', 'complex', 'auto' } ) }
            end
            this.setImplProperty( 'Complexity', complexity );
        end


        function minimum = get.Minimum( this )
            if isa( this.getImpl, 'systemcomposer.architecture.model.interface.ValueTypeInterface' )
                minimum = this.getImpl(  ).p_Minimum;
            else
                if isprop( this.getImpl.ownedType, 'min' )
                    minimum = num2str( this.getImpl.ownedType.min );
                else
                    minimum = "";
                end
            end
        end


        function set.Minimum( this, minimum )
            this.setMinimum( minimum );
        end


        function setMinimum( this, minimum )
            arguments
                this systemcomposer.ValueType
                minimum{ mustBeTextScalar }
            end

            this.setImplProperty( 'Minimum', minimum );
        end


        function maximum = get.Maximum( this )
            if isa( this.getImpl, 'systemcomposer.architecture.model.interface.ValueTypeInterface' )
                maximum = this.getImpl(  ).p_Maximum;
            else
                if isprop( this.getImpl.ownedType, 'max' )
                    maximum = num2str( this.getImpl.ownedType.max );
                else
                    maximum = "";
                end
            end
        end


        function set.Maximum( this, maximum )
            this.setMaximum( maximum );
        end


        function setMaximum( this, maximum )
            arguments
                this systemcomposer.ValueType
                maximum{ mustBeTextScalar }
            end

            this.setImplProperty( 'Maximum', maximum );
        end


        function description = get.Description( this )
            description = '';
            if isa( this.getImpl, 'systemcomposer.architecture.model.interface.ValueTypeInterface' )
                description = this.getImpl(  ).getDescription;
            end
        end


        function set.Description( this, description )
            this.setDescription( description );
        end


        function setDescription( this, description )
            arguments
                this systemcomposer.ValueType
                description{ mustBeTextScalar }
            end
            this.setImplProperty( 'Description', description );
        end


        function destroy( this )
            if isa( this.getImpl, 'systemcomposer.architecture.model.interface.ValueTypeInterface' )
                if ( this.getImpl.isAnonymous(  ) )
                    error( 'Cannote destroy anonymous' );
                end
                isModelContext = isempty( this.Owner.ddConn );
                sourceName = this.Owner.getSourceName;
                systemcomposer.BusObjectManager.DeleteInterface( sourceName,  ...
                    isModelContext, this.Name );
            else
                this.Owner.removeParameter( this.Name );
            end
        end
    end


    methods ( Access = private )
        function setImplProperty( this, propName, propVal )
            if isa( this.getImpl, 'systemcomposer.architecture.model.interface.ValueTypeInterface' )
                setSLProperty( this, propName, propVal );
            else
                setSLParameter( this, propName, propVal );
            end
        end


        function setSLProperty( this, propName, propVal )
            if strcmpi( propName, 'name' )
                if ( this.getImpl.isAnonymous(  ) && ~isempty( propVal ) )
                    error( 'SystemArchitecture:API:InvalidRenameOpOnAnonymousInterface', message( 'SystemArchitecture:API:InvalidRenameOpOnAnonymousInterface' ).getString );
                end

                isModelContext = isempty( this.Owner.ddConn );
                sourceName = this.Owner.getSourceName;
                systemcomposer.BusObjectManager.RenameInterface(  ...
                    sourceName, isModelContext, this.Name, propVal );
            else
                if isa( this.Owner, 'systemcomposer.interface.DataElement' )
                    this.Owner.setElementProperty( propName, propVal );
                    return ;
                end

                if ( this.getImpl.isAnonymous )
                    port = this.getImpl.p_AnonymousUsage.p_Port;
                    systemcomposer.AnonymousInterfaceManager.SetSLPortProperty( port, propName, propVal );
                else
                    isModelContext = isempty( this.Owner.ddConn );
                    sourceName = this.Owner.getSourceName;
                    systemcomposer.BusObjectManager.SetAtomicInterfaceProperty(  ...
                        sourceName, isModelContext, this.Name,  ...
                        propName, propVal );
                end
            end
        end


        function setSLParameter( this, propName, propVal )
            blockOrModelHandle = this.ParameterOwner.SimulinkHandle;
            if strcmp( propName, 'Type' )
                propName = 'DataType';
            elseif strcmp( propName, 'Dimensions' )
                propVal = eval( propVal );
            end
            systemcomposer.internal.parameters.arch.sync.updateSimulinkParameter( blockOrModelHandle, this.Name, propName, propVal );
            systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdroot( blockOrModelHandle ) );

        end
    end

end

