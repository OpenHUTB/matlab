classdef ARClassicPlatformSLDDListener<handle





    properties(Access=private)
        DictImpl sl.interface.dict.InterfaceDictionary
DictionaryM3IModel
    end

    methods(Static)
        function observeChanges(dictImpl,report)

            observer=autosar.dictionary.internal.ARClassicPlatformSLDDListener(dictImpl);
            observer.observeSLDDChanges(report);
        end
    end

    methods
        function this=ARClassicPlatformSLDDListener(dictImpl)
            this.DictImpl=dictImpl;
            ddFilePath=dictImpl.getDictionaryFilePath();
            assert(this.DictImpl.MappingManager.hasMappingFor(...
            sl.interface.dict.mapping.PlatformMappingKind.AUTOSARClassic),...
            'should not have called AUTOSAR platform listener');
            this.DictionaryM3IModel=Simulink.AutosarDictionary.ModelRegistry.getOrLoadM3IModel(...
            ddFilePath);
        end

        function observeSLDDChanges(this,report)
            this.observeDeleted(report.EntryDeleted);
            this.observeAdded(report.EntryAdded);
            this.observeModified(report.EntryModified);
        end
    end

    methods(Access=private)
        function observeDeleted(this,deletedEntries)
            if isempty(deletedEntries)
                return
            end


            deletedUUIDs=deletedEntries(:,1);

            autosarMapping=this.DictImpl.MappingManager.getMappingFor(...
            sl.interface.dict.mapping.PlatformMappingKind.AUTOSARClassic);
            mappingEntries=autosarMapping.findMappingEntriesByUUID(deletedUUIDs);


            platformElmIds=[];
            for idx=1:numel(mappingEntries)
                mappedEntry=mappingEntries(idx);
                if isempty(mappedEntry.MappedTo)

                    continue;
                end
                platformElmIds{end+1}=mappedEntry.MappedTo.EntryIdentifier;%#ok<AGROW>
            end


            if~isempty(platformElmIds)
                tran=M3I.Transaction(this.DictionaryM3IModel);
                for elmIdx=1:length(platformElmIds)
                    m3iObj=M3I.getObjectById(platformElmIds{elmIdx},this.DictionaryM3IModel);
                    if m3iObj.isvalid()
                        m3iObj.destroy();
                    end
                end
                tran.commit;
            end


            arrayfun(@(x)x.destroy,mappingEntries);
        end

        function observeAdded(this,addedEntries)
            this.processAddedOrModifiedEntries(addedEntries);
        end

        function observeModified(this,modifiedEntries)
            this.processAddedOrModifiedEntries(modifiedEntries);
        end

        function processAddedOrModifiedEntries(this,entries)


            if isempty(entries)
                return
            end


            dictAPI=Simulink.interface.dictionary.open(this.DictImpl.getDictionaryFilePath);
            ddConn=dictAPI.getSLDDConn();
            platformSyncer=dictAPI.getPlatformMappingSyncer(...
            sl.interface.dict.mapping.PlatformMappingKind.AUTOSARClassic);


            entriesUUIDs=entries(:,1);


            catalogEntries=this.DictImpl.DictionaryCatalog.findEntriesByUUID(entriesUUIDs);

            for entryIdx=1:numel(catalogEntries)
                catalogEntry=catalogEntries(entryIdx);
                entryName=ddConn.getEntryNameByUUID(catalogEntry.DDEntryUUID);
                if isa(catalogEntry,'sl.interface.dict.catalog.InterfaceEntry')
                    platformSyncer.syncInterface(entryName);
                elseif isa(catalogEntry,'sl.interface.dict.catalog.DataTypeEntry')
                    platformSyncer.syncDataType(entryName);
                elseif isa(catalogEntry,'sl.interface.dict.catalog.ConstantEntry')
                    platformSyncer.syncConstant(entryName);
                else
                    assert(false,'Unexpected entry added to the dictionary: %s',...
                    entryName);
                end
            end
        end
    end
end


