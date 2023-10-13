classdef Exclusions < handle

    properties ( Access = private )
        ExcludeModelReferences
        ExcludeLibraryLinks
        ExcludeInactiveRegions
        ExcludedBlocks
        ExclusionsTableData
        ExternalFilePath
    end

    methods ( Static, Access = public )
        function clearFilterManagerForModel( modelName )
            filterService = slcheck.CloneDetectionFilterService.getInstance;
            filterService.remove( modelName );
        end
    end
    methods ( Access = public )
        function this = Exclusions( modelName, filePath )
            arguments
                modelName = ''
                filePath = ''
            end
            this = this@handle(  );
            this.ExcludeModelReferences = false;
            this.ExcludeLibraryLinks = false;
            this.ExcludeInactiveRegions = false;
            this.ExcludedBlocks = {  };
            this.ExclusionsTableData = {  };
            this.ExternalFilePath = filePath;
            this.retrieveExclusions( modelName );
        end


        function this = retrieveExclusions( this, modelName )
            if isempty( modelName )
                return ;
            end
            this.readExclusionsFromFilterService( modelName );
        end

        function filterManager = getCloneDetectionFilterManager( this, modelName )
            filterService = slcheck.CloneDetectionFilterService.getInstance;
            filterService.setExclusionsFile( this.ExternalFilePath );
            filterManager = filterService.getFilterManager( modelName );
        end


        function excludeModelReferences = getExcludeModelReferences( this )
            excludeModelReferences = this.ExcludeModelReferences;
        end

        function excludeLibraryLinks = getExcludeLibraryLinks( this )
            excludeLibraryLinks = this.ExcludeLibraryLinks;
        end

        function excludeInactiveRegions = getExcludeInactiveRegions( this )
            excludeInactiveRegions = this.ExcludeInactiveRegions;
        end

        function excludedBlocks = getExcludedBlocks( this )
            excludedBlocks = this.ExcludedBlocks;
        end

        function exclusionsTableData = getExclusionsTableData( this )
            exclusionsTableData = this.ExclusionsTableData;
        end

        function [ isExcluded ] = isBlockExcluded( this, blockSID, blockName )
            isExcluded = false;
            tableData = this.getExclusionsTableData(  );

            for ind = 1:length( tableData )
                blockDetails = tableData{ ind }{ 1 };
                if strcmpi( blockDetails.sid, blockSID ) &&  ...
                        strcmpi( blockDetails.name, blockName )
                    isExcluded = true;
                    return ;
                end
            end
        end
    end

    methods ( Access = private )

        function path = getSlxPartFilePath( this, fModelName )
            if ~this.isSLX( fModelName )
                path = '';
            else
                path = Simulink.slx.getUnpackedFileNameForPart( fModelName,  ...
                    '/advisor/exclusions.xml' );
            end
        end


        function flag = isSLX( ~, fModelName )
            [ ~, fName, ext ] = fileparts( get_param( bdroot( fModelName ), 'filename' ) );
            if isempty( fName )
                flag = true;
            else
                flag = strcmp( ext, '.slx' );
            end
        end

        function readExclusionsFromFilterService( this, modelName )
            filterManager = this.getCloneDetectionFilterManager( modelName );
            filters = filterManager.filters;

            if ~isempty( filters )
                for idx = 1:filters.Size
                    exclusionId = filters.at( idx ).filteredItem.ID;
                    switch ( exclusionId )
                        case 'InactiveRegions'
                            this.ExcludeInactiveRegions = true;
                        case 'LibraryLinks'
                            this.ExcludeLibraryLinks = true;
                        case 'ModelReference'
                            this.ExcludeModelReferences = true;
                        otherwise
                            sid = exclusionId;
                            blockFullPath = slcheck.getFullPathFromSID( sid );
                            this.ExcludedBlocks = [ this.ExcludedBlocks, { blockFullPath } ];

                            blockType = slcheck.getFilterTypeString( filters.at( idx ).type );
                            exclusionRationale = filters.at( idx ).metadata.summary;

                            if contains( lower( blockType ), { 'masktype', 'blocktype', 'stateflow', 'blockparameters' } )
                                id = struct( 'sid', sid, 'name', sid, 'link', false );
                            else
                                id = struct( 'sid', sid, 'name', blockFullPath, 'link', true );
                            end

                            this.ExclusionsTableData{ end  + 1 } = { id, blockType, exclusionRationale };
                    end
                end
            end
        end
    end
end


