classdef AbstractAutosarTabAdapter < sl.interface.dictionaryApp.tab.AbstractTabAdapter

    properties ( Abstract, Constant, Access = protected )
        Category;
    end

    properties ( SetAccess = immutable, GetAccess = protected )
        AutosarAPIObj autosar.api.getAUTOSARProperties;
        M3IModel Simulink.metamodel.foundation.Domain;
    end

    methods ( Static, Access = public )
        function tabAdapter = getTabAdapter( dictObj, platformKind, tabId )
            arguments
                dictObj( 1, 1 )Simulink.interface.Dictionary;
                platformKind( 1, 1 )sl.interface.dict.mapping.PlatformMappingKind;
                tabId( 1, : )char;
            end
            assert( platformKind ==  ...
                sl.interface.dict.mapping.PlatformMappingKind.AUTOSARClassic,  ...
                'Unexpected platform' );
            switch tabId
                case 'SwAddrMethodsTab'
                    tabAdapter =  ...
                        autosar.internal.dictionaryApp.tab.SwAddrMethodsTabAdapter(  ...
                        dictObj );
                otherwise
                    assert( false, 'Unexpected Tab' );
            end
        end
    end

    methods ( Access = public )
        function deleteEntry( this, selectedNode )
            entryName = selectedNode.getPropValue( 'Name' );
            arNode = this.getNode( entryName );
            entryQName =  ...
                autosar.api.Utils.getQualifiedName( arNode.getM3IObject(  ) );
            this.AutosarAPIObj.delete( entryQName );
        end

        function copy( this, nodesToCopy )



            for nodeIdx = 1:length( nodesToCopy )
                curNode = nodesToCopy{ nodeIdx };
                assert( this.canPaste( curNode ), 'Unexpected node type' );

                newName = sl.interface.dictionaryApp.utils.getUniqueName(  ...
                    curNode.Name, this.getEntryShortNames(  ) );
                srcObj = curNode.getM3IObject(  );
                this.addEntryForSourceObj( newName, srcObj );
            end
        end
    end

    methods ( Access = protected )
        function this = AbstractAutosarTabAdapter( dictObj )
            slddFilePath = dictObj.filepath(  );
            this.AutosarAPIObj = autosar.api.getAUTOSARProperties( slddFilePath );
            this.M3IModel =  ...
                Simulink.AutosarDictionary.ModelRegistry.getOrLoadM3IModel(  ...
                slddFilePath );
        end

        function entryNames = getEntryNames( this )
            entryNames = this.AutosarAPIObj.find( [  ], this.Category,  ...
                'PathType', 'FullyQualified' );
        end

        function entryNames = getEntryShortNames( this )
            entryNames = this.AutosarAPIObj.find( [  ], this.Category,  ...
                'PathType', 'PartiallyQualified' );
        end

        function defaultName = getDefaultEntryName( this )

            protectedNames = this.getEntryNames(  );

            for ii = 1:length( protectedNames )
                tokens = strsplit( protectedNames{ ii }, '/' );
                protectedNames{ ii } = tokens{ end  };
            end
            defaultName = sl.interface.dictionaryApp.tab.AbstractTabAdapter. ...
                calcUniqueName( this.DefaultEntryName, protectedNames );
        end
    end
end



