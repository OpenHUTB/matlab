classdef Dictionary < systemcomposer.interface.Element




    properties ( SetAccess = private )
        Interfaces
        Profiles
    end

    properties ( Hidden, SetAccess = private, Dependent = true )
        References
    end

    properties ( Hidden, SetAccess = private )
        ddConn
    end

    methods ( Hidden )
        function this = Dictionary( impl )
            narginchk( 1, 1 );
            if ~isa( impl, 'systemcomposer.architecture.model.interface.InterfaceCatalog' )
                error( 'systemcomposer:API:InterfaceDictionaryInvalidInput', message( 'SystemArchitecture:API:InterfaceDictionaryInvalidInput' ).getString );
            end
            this@systemcomposer.interface.Element( impl );

            if ( impl.getStorageContext(  ) == systemcomposer.architecture.model.interface.Context.DICTIONARY )
                this.ddConn = Simulink.data.dictionary.open( [ impl.getStorageSource, '.sldd' ] );
            end
        end
    end

    methods

        function interface = addInterface( this, interfaceName, varargin )








            persistent p
            if isempty( p )
                p = inputParser;
                addRequired( p, 'interfaceName', @( x )( ischar( x ) && ~isempty( x ) || isstring( x ) && ~isequal( x, "" ) ) );
                addParameter( p, 'SimulinkBus', Simulink.Bus, @( x )isa( x, 'Simulink.Bus' ) );
            end
            parse( p, interfaceName, varargin{ : } );

            sourceName = this.getSourceName;
            isModelContext = isempty( this.ddConn );

            if ~isModelContext && sl.interface.dict.api.isInterfaceDictionary( this.ddConn.filepath )
                idictAPI = Simulink.interface.dictionary.open( this.ddConn.filepath );
                idictAPI.addDataInterface( interfaceName, varargin{ : } );
            else
                if nargin > 2
                    busObjectToUse = varargin{ 2 };
                    systemcomposer.BusObjectManager.AddInterface( sourceName, isModelContext, convertStringsToChars( interfaceName ), busObjectToUse );
                else
                    systemcomposer.BusObjectManager.AddInterface( sourceName, isModelContext, convertStringsToChars( interfaceName ) );
                end
            end

            catalogImpl = this.getImpl(  );
            interfaceImpl = catalogImpl.getPortInterface( interfaceName );

            interface = this.getWrapperForImpl( interfaceImpl );
        end

        function interface = addPhysicalInterface( this, interfaceName, SimulinkConnBus )
            arguments
                this systemcomposer.interface.Dictionary
                interfaceName{ mustBeTextScalar }
                SimulinkConnBus{ mustBeA( SimulinkConnBus, 'Simulink.ConnectionBus' ) } = Simulink.ConnectionBus.empty;
            end
            sourceName = this.getSourceName;
            isModelContext = isempty( this.ddConn );
            if ~isempty( SimulinkConnBus )
                systemcomposer.BusObjectManager.AddPhysicalInterface( sourceName, isModelContext, convertStringsToChars( interfaceName ), SimulinkConnBus );
            else
                systemcomposer.BusObjectManager.AddPhysicalInterface( sourceName, isModelContext, convertStringsToChars( interfaceName ) );
            end

            catalogImpl = this.getImpl(  );
            interfaceImpl = catalogImpl.getPortInterface( interfaceName );

            interface = this.getWrapperForImpl( interfaceImpl, 'systemcomposer.interface.PhysicalInterface' );
        end

        function interface = addServiceInterface( this, interfaceName )
            arguments
                this systemcomposer.interface.Dictionary
                interfaceName{ mustBeTextScalar }
            end
            sourceName = this.getSourceName;
            isModelContext = isempty( this.ddConn );

            systemcomposer.BusObjectManager.AddServiceInterface( sourceName, isModelContext, convertStringsToChars( interfaceName ) );

            catalogImpl = this.getImpl(  );
            interfaceImpl = catalogImpl.getPortInterface( interfaceName );

            interface = this.getWrapperForImpl( interfaceImpl, 'systemcomposer.interface.ServiceInterface' );
        end

        function interface = addValueType( this, valueTypeName, options )

            arguments
                this systemcomposer.interface.Dictionary
                valueTypeName{ mustBeTextScalar }
                options.DataType{ mustBeTextScalar } = 'double'
                options.Dimensions{ mustBeTextScalar } = '1'
                options.Units{ mustBeTextScalar } = ''
                options.Complexity{ mustBeMember( options.Complexity, { 'real', 'complex', 'auto' } ) } = 'real'
                options.Minimum{ mustBeTextScalar } = '[]'
                options.Maximum{ mustBeTextScalar } = '[]'
                options.Description{ mustBeTextScalar } = ''
            end

            sourceName = this.getSourceName;
            isModelContext = isempty( this.ddConn );
            systemcomposer.BusObjectManager.AddAtomicInterface( sourceName, isModelContext, valueTypeName, options );

            catalogImpl = this.getImpl(  );
            interfaceImpl = catalogImpl.getPortInterface( valueTypeName );

            interface = this.getWrapperForImpl( interfaceImpl, 'systemcomposer.ValueType' );
        end

        function removeInterface( this, interfaceName )




            sourceName = this.getSourceName;
            isModelContext = isempty( this.ddConn );
            systemcomposer.BusObjectManager.DeleteInterface( sourceName, isModelContext, interfaceName );
        end

        function interface = getInterface( this, interfaceName, nameValArgs )








            arguments
                this
                interfaceName{ mustBeTextScalar }
                nameValArgs.ReferenceDictionary{ mustBeTextScalar }
            end

            catalogImpl = this.getImpl(  );
            if isfield( nameValArgs, 'ReferenceDictionary' )
                interfaceImpl = catalogImpl.getPortInterfaceInClosureByName(  ...
                    nameValArgs.ReferenceDictionary, interfaceName );
            else
                interfaceImpl = catalogImpl.getPortInterface( interfaceName );
            end

            if isempty( interfaceImpl )
                interface = systemcomposer.interface.DataInterface.empty(  );
            else
                interface = this.getWrapperForImpl( interfaceImpl );
            end
        end

        function interfaces = get.Interfaces( this )
            catalogImpl = this.getImpl(  );
            catalogImplInterfaces = catalogImpl.getPortInterfacesInClosure(  );
            interfaces = systemcomposer.interface.DataInterface.empty( numel( catalogImplInterfaces ), 0 );
            for i = 1:numel( catalogImplInterfaces )
                interfaces( i ) = this.getWrapperForImpl( catalogImplInterfaces( i ) );
            end
        end

        function profArray = get.Profiles( this )
            profimplArray = this.getImpl.getProfiles;

            profimplArray = profimplArray( ~[ profimplArray.isMathWorksProfile ] );
            profArray = systemcomposer.profile.Profile.empty;
            for i = 1:numel( profimplArray )
                profArray( i ) = systemcomposer.profile.Profile.wrapper( profimplArray( i ) );
            end
        end

        function flag = isEmpty( this )

            flag = isempty( getInterfaceNamesInClosure( this ) );
        end

        function interfaceNames = getInterfaceNames( this )



            catalogImpl = this.getImpl(  );
            interfaceNames = catalogImpl.getPortInterfaceNamesInClosure(  );
        end

        function save( this )



            catalogImpl = this.getImpl(  );
            storageContext = 'Model';
            if ( catalogImpl.getStorageContext(  ) == systemcomposer.architecture.model.interface.Context.DICTIONARY )
                storageContext = 'Dictionary';
            end
            systemcomposer.InterfaceEditor.saveInterfaces( catalogImpl.getStorageSource(  ), storageContext );
        end

        function saveToDictionary( this, dictionaryName, varargin )




            catalogImpl = this.getImpl(  );
            if ( catalogImpl.getStorageContext(  ) == systemcomposer.architecture.model.interface.Context.DICTIONARY )

                ex = MException( message( 'SystemArchitecture:API:SaveToDDInvalidInDDContext',  ...
                    dictionaryName, catalogImpl.getStorageSource(  ) ) );
                throw( ex );
            end

            persistent p
            if isempty( p )
                p = inputParser;
                addRequired( p, 'dictionaryName', @( x )~isempty( x ) && ( ischar( x ) || ( isstring( x ) && ( numel( x ) == 1 ) ) ) );
                addParameter( p, 'CollisionResolutionOption', systemcomposer.interface.CollisionResolution.USE_DICTIONARY, @( x )isa( x, 'systemcomposer.interface.CollisionResolution' ) );
            end
            parse( p, dictionaryName, varargin{ : } );

            try
                sharedDDConn = systemcomposer.internal.openOrCreateSimulinkDataDictionary( dictionaryName );
            catch ex
                throwAsCaller( ex );
            end


            interfaceCollisionResolution = systemcomposer.architecture.model.interface.CollisionResolution.UNSPECIFIED;
            if ( nargin > 2 )
                switch ( varargin{ 2 } )
                    case systemcomposer.interface.CollisionResolution.USE_MODEL
                        interfaceCollisionResolution = systemcomposer.architecture.model.interface.CollisionResolution.REPLACE_DST;
                    case systemcomposer.interface.CollisionResolution.USE_DICTIONARY
                        interfaceCollisionResolution = systemcomposer.architecture.model.interface.CollisionResolution.KEEP_DST;
                end
            end


            systemcomposer.InterfaceEditor.saveInterfacesToExistingDD(  ...
                catalogImpl.getStorageSource(  ),  ...
                'Model',  ...
                catalogImpl.getStorageSource(  ),  ...
                sharedDDConn.filepath(  ),  ...
                interfaceCollisionResolution );
        end

        function applyProfile( this, pHdl )

            try
                systemcomposer.profile.Profile.load( pHdl );
            catch ex
                throw( ex );
            end
            catalogImpl = this.getImpl(  );
            catalogImpl.addProfile( pHdl );
        end

        function removeProfile( this, pHdl )

            catalogImpl = this.getImpl(  );
            catalogImpl.removeProfile( pHdl );
        end

        function refs = get.References( this )
            refs = this.ddConn.DataSources;
        end

        function destroy( this )
            if ( ~isempty( this.ddConn ) )
                this.ddConn.close(  );
            end
        end

        function addReference( this, refDictionaryName, collisionResolutionOption )

            arguments
                this( 1, 1 )systemcomposer.interface.Dictionary
                refDictionaryName{ mustBeTextScalar }
                collisionResolutionOption{ mustBeMember( collisionResolutionOption, { 'KeepTop', 'KeepReference', 'Unspecified' } ) } = 'Unspecified'
            end

            if ( ischar( refDictionaryName ) )
                refDictionaryName = string( refDictionaryName );
            end
            if ( ~endsWith( refDictionaryName, ".sldd" ) )
                refDictionaryName = refDictionaryName + ".sldd";
            end

            systemcomposer.InterfaceEditor.addReferenceDD( this.ddConn.filepath(  ), refDictionaryName, collisionResolutionOption );
        end

        function removeReference( this, refDictionaryName )







            persistent p
            if isempty( p )
                p = inputParser;
                addRequired( p, 'refDictionaryName', @( x )( ( ischar( x ) && ~isempty( x ) ) || ( isstring( x ) && ( x ~= "" ) ) ) );
            end
            parse( p, refDictionaryName );

            if ( ischar( refDictionaryName ) )
                refDictionaryName = string( refDictionaryName );
            end
            if ( ~endsWith( refDictionaryName, ".sldd" ) )
                refDictionaryName = refDictionaryName + ".sldd";
            end

            systemcomposer.InterfaceEditor.removeReferenceDD( this.ddConn.filepath(  ), refDictionaryName );
        end

    end

    methods ( Hidden )
        function name = getSourceName( this )
            modelId = systemcomposer.services.proxy.ModelIdentifier.getModelIdentifier( this.MFModel );
            name = modelId.URI;
        end
    end

end


