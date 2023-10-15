classdef ImportToDictionaryHelper < handle




    properties ( Access = private )
        InterfaceDictAPI Simulink.interface.Dictionary
    end

    methods
        function this = ImportToDictionaryHelper( dictName )
            this.InterfaceDictAPI = Simulink.interface.dictionary.open( dictName );
        end
    end
    methods
        function importFromBaseWks( this, conflictResolutionPolicy )
            arguments
                this
                conflictResolutionPolicy{ mustBeMember( conflictResolutionPolicy, { 'KeepDictionary', 'OverrideDictionary' } ) } = 'KeepDictionary'
            end

            baseWSVars = evalin( 'base', 'whos' );
            for i = 1:length( baseWSVars )
                name = baseWSVars( i ).name;
                value = evalin( 'base', name );
                this.importVarToDict( name, value, conflictResolutionPolicy );
            end
        end

        function importFromMATFile( this, matFileName, conflictResolutionPolicy )
            arguments
                this
                matFileName{ mustBeTextScalar, mustBeNonzeroLengthText }
                conflictResolutionPolicy{ mustBeMember( conflictResolutionPolicy, { 'KeepDictionary', 'OverrideDictionary' } ) } = 'KeepDictionary'
            end

            matFileVars = load( matFileName );
            matFileVarsFieldNames = fieldnames( matFileVars );

            for i = 1:length( matFileVarsFieldNames )
                name = matFileVarsFieldNames{ i };
                value = getfield( matFileVars, name );%#ok<GFLD>
                this.importVarToDict( name, value, conflictResolutionPolicy );
            end
        end
    end

    methods ( Access = private )
        function importVarToDict( this, name, value, conflictResolutionPolicy )
            if isa( value, 'Simulink.ValueType' ) ||  ...
                    isa( value, 'Simulink.AliasType' ) ||  ...
                    isa( value, 'Simulink.Bus' )
                if this.checkCanBeImported( name, conflictResolutionPolicy )
                    if isprop( value, 'HeaderFile' )

                        value.DataScope = 'Auto';
                        value.HeaderFile = '';
                    end
                    if isa( value, 'Simulink.Bus' )
                        this.InterfaceDictAPI.addDataInterface( name, "SimulinkBus", value );
                    else
                        this.InterfaceDictAPI.getSLDDConn(  ).assignin( name, value );
                    end
                end
            end
        end

        function canImport = checkCanBeImported( this, name, conflictResolutionPolicy )
            entryExists = this.InterfaceDictAPI.getDesignDataContents.checkEntryExists( name );
            if entryExists
                switch ( conflictResolutionPolicy )
                    case 'OverrideDictionary'
                        canImport = true;
                    case 'KeepDictionary'
                        canImport = false;
                    otherwise
                        assert( false, 'Unexpected policy: %s', conflictResolutionPolicy );
                end
            else
                canImport = true;
            end

            if ~canImport
                warning( message( 'interface_dictionary:api:ImportCollision',  ...
                    this.InterfaceDictAPI.DictionaryFileName, name ) );
            end
        end
    end
end

