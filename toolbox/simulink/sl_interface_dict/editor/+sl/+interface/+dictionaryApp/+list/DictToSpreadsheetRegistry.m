classdef DictToSpreadsheetRegistry < handle

    properties ( Access = private )

        DictEntryUUIDToSpreadsheetEntryNameMap;
        DictEntryUUIDToParentSpreadsheetTabId;

        ListObj sl.interface.dictionaryApp.list.List;
    end

    methods ( Access = public )
        function this = DictToSpreadsheetRegistry( listObj )

            arguments
                listObj( 1, 1 )sl.interface.dictionaryApp.list.List;
            end

            this.ListObj = listObj;

            this.DictEntryUUIDToSpreadsheetEntryNameMap = containers.Map(  );
            this.DictEntryUUIDToParentSpreadsheetTabId = containers.Map(  );
        end

        function populateRegistryForNode( this, tabId, nodeName )

            dictEntry = this.ListObj.DictObj.getDDEntryObject( nodeName );
            dictEntryUUID = dictEntry.UUID;
            this.DictEntryUUIDToSpreadsheetEntryNameMap( dictEntryUUID ) = nodeName;
            this.DictEntryUUIDToParentSpreadsheetTabId( dictEntryUUID ) = tabId;
        end

        function [ dictEntryObj, spreadsheetNode, spreadsheetTabId ] = getDictEntryAndNodeObj( this, addedEntry )

            assert( height( addedEntry ) == 1, 'Only 1 entry can be added at a time to the spreadsheet' );
            dictEntryUUID = addedEntry{ 1 };
            dictEntryObj = this.findDictObjFromEntryUUID( dictEntryUUID );
            spreadsheetTabId = this.getDestinationTabIdFromDictEntry( dictEntryObj );



            destinationTabAdapter = this.ListObj.constructTabAdapter( spreadsheetTabId );
            spreadsheetNode = destinationTabAdapter.getNode( dictEntryObj.Name );


            this.DictEntryUUIDToSpreadsheetEntryNameMap( dictEntryUUID ) = spreadsheetNode.Name;
            this.DictEntryUUIDToParentSpreadsheetTabId( dictEntryUUID ) = spreadsheetTabId;
        end

        function [ nodeName, spreadsheetTabId ] = getSpreadsheetInfoFromDictUUID( this, dictEntryUUID )


            nodeName = this.DictEntryUUIDToSpreadsheetEntryNameMap( dictEntryUUID );
            spreadsheetTabId = this.DictEntryUUIDToParentSpreadsheetTabId( dictEntryUUID );
        end

        function updateDictToSpreadsheetRegistryForModifiedNode( this, modifiedEntryUUID )
            nodeNameInRegistry = this.getSpreadsheetInfoFromDictUUID( modifiedEntryUUID );
            dictEntryObj = this.findDictObjFromEntryUUID( modifiedEntryUUID );
            if ~strcmp( dictEntryObj.Name, nodeNameInRegistry )

                this.updateNodeNameForDictUUID( modifiedEntryUUID, dictEntryObj.Name );
            end
        end

        function entry = findDictObjFromEntryUUID( this, entryUUID )

            entryUUIDCell = { entryUUID };
            entry = this.ListObj.DictObj.DictImpl.DictionaryCatalog.findEntriesByUUID( entryUUIDCell );
        end
    end

    methods ( Access = private )
        function updateNodeNameForDictUUID( this, dictEntryUUID, nodeName )

            this.DictEntryUUIDToSpreadsheetEntryNameMap( dictEntryUUID ) = nodeName;
        end
    end

    methods ( Static, Access = public )
        function destinationTabId = getDestinationTabIdFromDictEntry( dictEntry )
            switch class( dictEntry )
                case 'sl.interface.dict.catalog.InterfaceEntry'
                    destinationTabId = 'InterfacesTab';
                case 'sl.interface.dict.catalog.DataTypeEntry'
                    destinationTabId = 'DataTypesTab';
                case 'sl.interface.dict.catalog.ConstantEntry'
                    destinationTabId = 'ConstantsTab';
                otherwise
                    assert( false, 'Unexpected SLDD entry type when finding destination tab id' );
            end
        end
    end
end

