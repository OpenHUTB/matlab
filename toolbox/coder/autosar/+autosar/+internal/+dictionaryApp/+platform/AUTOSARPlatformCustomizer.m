classdef AUTOSARPlatformCustomizer < sl.interface.dictionaryApp.platform.AbstractPlatformCustomizer

    properties ( Access = private )
        XmlOptionsDialog autosar.internal.dictionaryApp.xmlOptions.XmlOptionsDialog;
    end

    properties ( Constant, Access = public )
        PlatformTabIds = { 'SwAddrMethodsTab' };
        PlatformKind = sl.interface.dict.mapping.PlatformMappingKind.AUTOSARClassic;
    end

    methods ( Access = public )
        function this = AUTOSARPlatformCustomizer( dictObj )

            [ islicensed, errorargs ] = autosar.api.Utils.autosarlicensed(  );
            if ~islicensed
                DAStudio.error( errorargs{ : } );
            end
            this@sl.interface.dictionaryApp.platform.AbstractPlatformCustomizer( dictObj );
        end

        function showOptions( this )
            if ~isempty( this.XmlOptionsDialog ) && this.XmlOptionsDialog.dialogIsValid(  )

                this.XmlOptionsDialog.show(  );
            else

                m3iModel =  ...
                    Simulink.AutosarDictionary.ModelRegistry.getOrLoadM3IModel(  ...
                    this.DictObj.filepath(  ) );
                this.XmlOptionsDialog =  ...
                    autosar.internal.dictionaryApp.xmlOptions.XmlOptionsDialog. ...
                    launchDialog( m3iModel, this.DictObj.filepath(  ) );
            end
        end

        function showHelp( ~ )
            helpview( fullfile( docroot, 'autosar', 'helptargets.map' ),  ...
                'autosar_shared_dictionary' );
        end

        function close( this )

            if ~isempty( this.XmlOptionsDialog )
                this.XmlOptionsDialog.close(  );
            end
        end

        function tabAdapter = getTabAdapter( this, tabId )


            tabAdapter =  ...
                autosar.internal.dictionaryApp.tab.AbstractAutosarTabAdapter.getTabAdapter(  ...
                this.DictObj, this.PlatformKind, tabId );
        end

        function platformTabs = getPlatformSpecificTabs( this )

            platformTabs =  ...
                sl.interface.dictionaryApp.tab.TabConfig.empty(  ...
                0, length( this.PlatformTabIds ) );
            for tabIdx = 1:length( this.PlatformTabIds )
                tabId = this.PlatformTabIds{ tabIdx };
                platformTabs( tabIdx ).Id = tabId;
                platformTabs( tabIdx ).Name = message( [ 'autosarstandard:sharedDictGUI:' ...
                    , tabId, 'Name' ] ).getString(  );
                platformTabs( tabIdx ).Tooltip = message( [ 'autosarstandard:sharedDictGUI:' ...
                    , tabId, 'Tooltip' ] ).getString(  );
            end
        end

        function refreshSpreadsheetList( this, listObj, changesReport )


            arguments
                this autosar.internal.dictionaryApp.platform.AUTOSARPlatformCustomizer;
                listObj( 1, 1 )sl.interface.dictionaryApp.list.List;
                changesReport( 1, 1 )M3I.ReportOfChanges;
            end

            if changesReport.getRemoved.size > 0


                deletedM3IObj = changesReport.getOldState( changesReport.getRemoved.at( 1 ) );
                if this.isM3IObjEligibleForSpreadsheetRefresh( deletedM3IObj )
                    parentTabId = this.getSpreadsheetTabIdFromM3IObj( deletedM3IObj );
                    qualifiedName = autosar.api.Utils.getQualifiedName( deletedM3IObj );
                    listObj.prepareForRefreshAfterDelete( qualifiedName, parentTabId );
                end
            elseif changesReport.getAdded.size > 0


                m3iObj = changesReport.getAdded.at( 1 );
                if this.isM3IObjEligibleForSpreadsheetRefresh( m3iObj )

                    spreadsheetTabId = this.getSpreadsheetTabIdFromM3IObj( m3iObj );
                    if ~isempty( spreadsheetTabId )
                        tabAdapter = listObj.constructTabAdapter( spreadsheetTabId );
                        qualifiedName = autosar.api.Utils.getQualifiedName( m3iObj );
                        renamedSpreadsheetNode = tabAdapter.getNode( qualifiedName );
                        entryName = qualifiedName;
                        listObj.prepareForRefreshAfterAdd( entryName, renamedSpreadsheetNode, spreadsheetTabId );
                    else

                    end
                end
            elseif changesReport.getChanged.size > 0
                for i = 1:changesReport.getChanged.size
                    m3iObj = changesReport.getChanged.at( i );
                    if this.isM3IObjEligibleForSpreadsheetRefresh( m3iObj )
                        m3iObjBeforeChange = changesReport.getOldState( m3iObj );
                        if ~strcmp( m3iObj.Name, m3iObjBeforeChange.Name )

                            spreadsheetTabId = this.getSpreadsheetTabIdFromM3IObj( m3iObj );
                            if ~isempty( spreadsheetTabId )
                                tabAdapter = listObj.constructTabAdapter( spreadsheetTabId );
                                newQualifiedName = autosar.api.Utils.getQualifiedName( m3iObj );
                                oldQualifiedName = autosar.api.Utils.getQualifiedName( m3iObjBeforeChange );
                                renamedSpreadsheetNode = tabAdapter.getNode( newQualifiedName );
                                listObj.forceUpdateTabToNodesMap( renamedSpreadsheetNode, newQualifiedName, oldQualifiedName, spreadsheetTabId )
                            end
                        else

                        end
                    end
                end
            end
        end
    end

    methods ( Access = protected )
        function registerPlatformListener( this )

            m3iModel =  ...
                Simulink.AutosarDictionary.ModelRegistry.getOrLoadM3IModel(  ...
                this.DictObj.filepath(  ) );
            autosar.ui.utils.registerListenerCB( m3iModel );
        end

        function deregisterPlatformListener( ~ )

        end
    end

    methods ( Access = private, Static )
        function spreadsheetNeedsRefresh = isM3IObjEligibleForSpreadsheetRefresh( m3iObj )


            spreadsheetNeedsRefresh = false;
            if isa( m3iObj, 'Simulink.metamodel.arplatform.common.ImmutableSwAddrMethod' )
                spreadsheetNeedsRefresh = true;
            end
        end

        function destinationTabId = getSpreadsheetTabIdFromM3IObj( m3iObj )
            classType = class( m3iObj );
            destinationTabId = '';
            switch classType
                case 'Simulink.metamodel.arplatform.common.ImmutableSwAddrMethod'
                    destinationTabId = 'SwAddrMethodsTab';
            end
        end
    end

end

