classdef ( Hidden, Sealed )Model < autosar.arch.Composition

    properties ( Hidden, Dependent = true )

        CompositionName
    end

    properties ( SetAccess = private, Dependent = true )


        Interfaces( 0, : )Simulink.interface.dictionary.PortInterface
    end

    methods ( Hidden, Access = protected )
        function propgrp = getPropertyGroups( this )

            proplist = { 'Name', 'SimulinkHandle', 'Components',  ...
                'Compositions', 'Ports', 'Connectors', 'Interfaces' };
            if ~isempty( this.find( 'Adapter' ) )
                proplist{ end  + 1 } = 'Adapters';
            end
            propgrp = matlab.mixin.util.PropertyGroup( proplist );
        end

        function p = getParent( ~ )

            p = [  ];
        end
    end

    methods ( Hidden, Static )
        function this = create( slModel )

            this = autosar.arch.Model( slModel );
        end
    end

    methods ( Hidden, Access = private )
        function this = Model( slModel )



            autosar.api.Utils.autosarlicensed( true );


            if ~is_simulink_handle( slModel )

                [ ~, slModel ] = fileparts( slModel );

                slModelH = get_param( slModel, 'Handle' );
            else
                slModelH = slModel;
            end


            if ~Simulink.internal.isArchitectureModel( slModelH, 'AUTOSARArchitecture' )
                DAStudio.error( 'autosarstandard:api:NotAUTOSARArchitectureModel',  ...
                    getfullname( slModelH ) );
            end


            this@autosar.arch.Composition( slModelH );
        end
    end

    methods

        function open( this )

            open_system( this.SimulinkHandle );
        end

        function save( this, newName )


            if nargin < 2
                newName = '';
            end





            drawnow;

            save_system( this.SimulinkHandle, newName, 'SaveDirtyReferencedModels', true );
        end

        function close( this, optCloseArg )




            narginchk( 1, 2 );
            if nargin == 1
                close_system( this.SimulinkHandle );
            else
                validatestring( optCloseArg, { 'Force' } );
                close_system( this.SimulinkHandle, 0 );
            end
        end

        function name = get.CompositionName( this )

            try
                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>
                m3iComp = autosar.api.Utils.m3iMappedComponent( this.SimulinkHandle );
                name = m3iComp.Name;
            catch ME
                autosar.mm.util.MessageReporter.throwException( ME );
            end
        end

        function set.CompositionName( this, newName )


            try
                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                autosar.composition.pi.PropertyHandler.setPropertyValue(  ...
                    this.SimulinkHandle, 'ComponentName', newName );


                this.refreshPropertyInspector(  );
            catch ME
                autosar.mm.util.MessageReporter.throwException( ME );
            end
        end

        function setXmlOptions( this, prop, val )







            try
                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>
                arProps = autosar.api.getAUTOSARProperties(  ...
                    getfullname( this.SimulinkHandle ) );
                arProps.set( 'XmlOptions', prop, val );
            catch ME
                autosar.mm.util.MessageReporter.throwException( ME );
            end
        end

        function val = getXmlOptions( this, prop )







            try
                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                arProps = autosar.api.getAUTOSARProperties(  ...
                    getfullname( this.SimulinkHandle ) );
                val = arProps.get( 'XmlOptions', prop );
            catch ME
                autosar.mm.util.MessageReporter.throwException( ME );
            end
        end

        function importFromARXML( this, arxmlInput, compositionQName, varargin )











































            try
                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>


                this.checkValidSimulinkHandle(  );


                if ~autosar.composition.Utils.isEmptyBlockDiagram( this.SimulinkHandle )
                    DAStudio.error( 'autosarstandard:importer:FailedToImportFromARXML',  ...
                        getfullname( this.SimulinkHandle ) );
                end

                if isa( arxmlInput, 'arxml.importer' )
                    importerObj = arxmlInput;
                else

                    importerObj = arxml.importer( arxmlInput );
                end
                importerObj.getComponentNames(  );


                okToPushNags = false;
                this.importCompositionFromARXML( importerObj, compositionQName, okToPushNags, varargin{ : } );
            catch ME
                autosar.mm.util.MessageReporter.throwException( ME );
            end
        end

        function interfaces = get.Interfaces( this )
            this.checkValidSimulinkHandle(  );

            interfaces = Simulink.interface.dictionary.PortInterface.empty;


            interfaceDicts = SLDictAPI.getTransitiveInterfaceDictsForModel( this.SimulinkHandle );
            for i = 1:length( interfaceDicts )
                idict = interfaceDicts{ i };
                idictAPI = Simulink.interface.dictionary.open( idict );
                interfaces = [ interfaces, idictAPI.Interfaces ];%#ok<AGROW>
            end
        end
    end

    methods ( Hidden )
        function linkDictionary( this, interfaceDictName )

            arguments
                this
                interfaceDictName{ mustBeTextScalar, mustBeNonzeroLengthText }
            end


            ddConn = Simulink.data.dictionary.open( interfaceDictName );
            if ~sl.interface.dict.api.isInterfaceDictionary( ddConn.filepath )
                DAStudio.error( 'interface_dictionary:api:InvalidInterfaceDictionary',  ...
                    ddConn.filepath );
            end

            if ~endsWith( interfaceDictName, '.sldd' )
                interfaceDictName = [ interfaceDictName, '.sldd' ];
            end


            [ isLinkedToInterfaceDict, currentInterfaceDicts ] =  ...
                Simulink.interface.dictionary.internal.DictionaryClosureUtils.isModelLinkedToInterfaceDict(  ...
                this.SimulinkHandle );
            if isLinkedToInterfaceDict
                for dictIdx = 1:length( currentInterfaceDicts )
                    currentInterfaceDict = currentInterfaceDicts{ dictIdx };
                    currentDDConn = Simulink.interface.dictionary.open( currentInterfaceDict );
                    if strcmp( currentDDConn.filepath(  ), ddConn.filepath(  ) )
                        modelName = getfullname( this.SimulinkHandle );
                        disp( message( 'interface_dictionary:api:ModelIsAlreadyLinkedToDict',  ...
                            modelName, interfaceDictName ).getString );
                        return ;
                    end
                end
            end

            interfaceDict = Simulink.interface.dictionary.open( ddConn.filepath );
            if ~interfaceDict.hasPlatformMapping( 'AUTOSARClassic' )
                autosar.validation.AutosarUtils.reportErrorWithFixit(  ...
                    'autosarstandard:interface_dictionary:InterfaceDictHasNoAUTOSARClassicMapping',  ...
                    ddConn.filepath );
            end


            set_param( this.SimulinkHandle, 'DataDictionary', interfaceDictName );
        end

        function unlinkDictionary( this )

            set_param( this.SimulinkHandle, 'DataDictionary', '' );
        end

        function destroy( this )
            DAStudio.error( 'autosarstandard:api:DestroyNotSupportedForRootArchModel',  ...
                getfullname( this.SimulinkHandle ) );
        end
    end
end



