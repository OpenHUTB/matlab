classdef ReqSet < slreq.internal.BaseSet

    properties ( Dependent )
        Description;
    end


    properties ( Dependent, GetAccess = public, SetAccess = private )
        Name
        Filename
        Revision;
        Dirty;
        CustomAttributeNames;

        CreatedBy
        CreatedOn
        ModifiedBy
        ModifiedOn
    end


    methods

        function this = ReqSet( dataObject )
            this.dataObject = dataObject;
        end


        function name = get.Name( this )
            name = this.dataObject.name;
        end


        function name = get.Filename( this )
            name = this.dataObject.filepath;
        end


        function value = get.Revision( this )
            value = this.dataObject.revision;
        end


        function text = getPreSaveFcn( this )
            this.errorIfVectorOperation(  );
            text = this.dataObject.preSaveFcn;
        end


        function text = getPostLoadFcn( this )
            this.errorIfVectorOperation(  );
            text = this.dataObject.postLoadFcn;
        end


        function setPreSaveFcn( this, value )
            this.errorIfVectorOperation(  );
            value = convertStringsToChars( value );
            this.dataObject.preSaveFcn = value;
        end


        function setPostLoadFcn( this, value )
            this.errorIfVectorOperation(  );
            value = convertStringsToChars( value );
            this.dataObject.postLoadFcn = value;
        end


        function value = get.Description( this )
            value = this.dataObject.description;
        end


        function set.Description( this, value )
            value = convertStringsToChars( value );
            this.dataObject.description = value;
        end


        function value = get.CreatedBy( this )
            value = this.dataObject.createdBy;
        end


        function value = get.CreatedOn( this )
            value = this.dataObject.createdOn;
        end


        function value = get.ModifiedBy( this )
            value = this.dataObject.modifiedBy;
        end


        function value = get.ModifiedOn( this )
            value = this.dataObject.modifiedOn;
        end


        function dirty = get.Dirty( this )
            dirty = this.dataObject.dirty;
        end


        function result = children( this )
            this.errorIfVectorOperation(  );
            result = slreq.BaseItem.empty(  );
            ch = this.dataObject.getRootItems(  );
            for n = 1:length( ch )
                child = ch( n );
                if child.external
                    result( n ) = slreq.Reference( child );
                elseif child.isJustification
                    result( n ) = slreq.Justification( child );
                else
                    result( n ) = slreq.Requirement( child );
                end
            end
        end


        function importProfile( this, profileName )
            this.errorIfVectorOperation(  );
            if reqmgt( 'rmiFeature', 'SupportProfile' )
                profileName = convertStringsToChars( profileName );
                this.dataObject.importProfile( profileName );
            end
        end


        function profiles = profiles( this )
            this.errorIfVectorOperation(  );
            prfs = this.dataObject.getAllProfiles(  );
            profiles = prfs.toArray(  );
        end


        function tf = removeProfile( this, profileName )
            this.errorIfVectorOperation(  );
            profileName = convertStringsToChars( profileName );
            tf = this.dataObject.removeProfile( profileName );
        end


        function save( this, varargin )
            this.errorIfVectorOperation(  );
            isRename = false;
            if ~isempty( varargin )
                newFileName = convertStringsToChars( varargin{ 1 } );
                [ rDir, ~, rExt ] = fileparts( newFileName );
                if isempty( rExt )
                    newFileName = [ newFileName, '.slreqx' ];
                end
                if isempty( rDir )
                    newFileName = fullfile( pwd, newFileName );
                end
                slreq.uri.getPreferredPath( false );
                clp = onCleanup( @(  )slreq.uri.getPreferredPath( true ) );
                isRename = ~strcmp( newFileName, this.dataObject.filepath );
                if isRename
                    this.dataObject.filepath = newFileName;
                end
            end
            this.dataObject.save(  );
            if isRename && slreq.app.MainManager.hasEditor(  )

                dasObj = this.dataObject.getDasObject(  );
                if ~isempty( dasObj )
                    mgr = slreq.app.MainManager.getInstance(  );
                    mgr.refreshUI( dasObj );
                    dasObj.updatePropertyInspector(  );
                end
            end
        end


        function explore( this )
            this.errorIfVectorOperation(  );
            slreq.open( this );
        end


        function close( this, varargin )
            this.errorIfVectorOperation(  );
            if this.Dirty
                if nargin > 1
                    if islogical( varargin{ 1 } )
                        if varargin{ 1 }
                            this.dataObject.save(  );
                        else
                            this.dataObject.discard(  );
                            return ;
                        end
                    else
                        error( message( 'Slvnv:slreq:InvalidInputArgument' ) );
                    end
                end
                slreq.utils.closeReqSet( this.dataObject );
            else
                this.dataObject.discard(  );
            end
        end


        function discard( this )
            this.errorIfVectorOperation(  );
            this.dataObject.discard(  );
        end


        function result = find( this, varargin )

            this.errorIfVectorOperation(  );
            if isempty( this )
                result = [  ];
                return ;
            end

            if ~( isempty( varargin ) ||  ...
                    ( numel( varargin ) == 2 && strcmpi( varargin{ 1 }, 'type' ) ) )
                result = this.slreqFind( varargin{ : } );
                return ;
            end

            [ reqs, refs, justs ] = this.dataObject.getItems(  );
            if isempty( varargin )
                isType = [  ];
            else
                [ varargin{ : } ] = convertStringsToChars( varargin{ : } );
                isType = find( strcmpi( varargin, 'type' ) );
            end
            if isempty( isType )

                if ~isempty( varargin )
                    reqs = slreq.utils.filterByProperties( reqs, varargin{ : } );
                    refs = slreq.utils.filterByProperties( refs, varargin{ : } );
                    justs = slreq.utils.filterByProperties( justs, varargin{ : } );
                end
                result = [  ...
                    slreq.utils.wrapDataObjects( reqs ),  ...
                    slreq.utils.wrapDataObjects( refs ),  ...
                    slreq.utils.wrapDataObjects( justs ),  ...
                    ];
            else
                type = varargin{ isType + 1 };
                filteredVarargin = varargin;
                filteredVarargin( isType:isType + 1 ) = [  ];
                if ~any( type == '.' )
                    type = [ 'slreq.', type ];
                end
                if strcmp( type, 'slreq.Requirement' )
                    if ~isempty( filteredVarargin )
                        reqs = slreq.utils.filterByProperties( reqs, filteredVarargin{ : } );
                    end
                    result = slreq.utils.wrapDataObjects( reqs );
                elseif strcmp( type, 'slreq.Reference' )
                    if ~isempty( filteredVarargin )
                        refs = slreq.utils.filterByProperties( refs, filteredVarargin{ : } );
                    end
                    result = slreq.utils.wrapDataObjects( refs );
                elseif strcmp( type, 'slreq.Justification' )
                    if ~isempty( filteredVarargin )
                        justs = slreq.utils.filterByProperties( justs, filteredVarargin{ : } );
                    end
                    result = slreq.utils.wrapDataObjects( justs );
                else
                    error( message( 'Slvnv:slreq:APIInvalidType', type ) );
                end
            end
        end


        function result = add( this, varargin )
            this.errorIfVectorOperation(  );

            if ~isempty( this.dataObject.parent )
                error( message( 'Slvnv:slreq:SFTableNotAllowed', 'add', this.dataObject.parent ) );
            end

            if isempty( varargin )
                reqInfo = [  ];
            else
                [ varargin{ : } ] = convertStringsToChars( varargin{ : } );
                reqInfo = slreq.utils.apiArgsToReqStruct( varargin{ : } );
                slreq.BaseItem.ensureWriteableProps( reqInfo );
            end

            if any( strcmpi( varargin, 'artifact' ) )

                req = this.dataObject.addExternalRequirement( reqInfo );
            else

                req = this.dataObject.addRequirement( reqInfo );
            end
            if isempty( req )
                result = [  ];
            else
                result = slreq.utils.dataToApiObject( req );
            end
        end


        function count = importFromDocument( this, pathToDoc, varargin )
            this.errorIfVectorOperation(  );
            pathToDoc = convertStringsToChars( pathToDoc );
            if ~isempty( varargin )
                [ varargin{ : } ] = convertStringsToChars( varargin{ : } );
            end
            count = slreq.import( pathToDoc, 'ReqSet', this, 'AsReference', false, varargin{ : } );
        end


        function count = createReferences( this, docPathOrType, varargin )
            this.errorIfVectorOperation(  );
            docPathOrType = convertStringsToChars( docPathOrType );
            if ~isempty( varargin )
                [ varargin{ : } ] = convertStringsToChars( varargin{ : } );
            end
            count = slreq.import( docPathOrType, 'ReqSet', this, 'AsReference', true, varargin{ : } );
        end


        function [ status, changelist ] = updateReferences( this, artifactData )
            this.errorIfVectorOperation(  );
            artifactData = convertStringsToChars( artifactData );
            if ischar( artifactData )
                if isfile( artifactData ) && ispc(  )
                    artifactData = strrep( artifactData, filesep, '/' );
                end
                refs = this.find( 'type', 'Reference', 'Artifact', artifactData );
                if ~isempty( refs )
                    refObj = refs( 1 );
                else
                    error( message( 'Slvnv:reqmgt:NotFoundIn', artifactData, [ this.Name, '.slreqx' ] ) );
                end
            elseif isa( artifactData, 'slreq.Reference' )
                refObj = artifactData;
            else
                error( message( 'Slvnv:slreq:InvalidInputArgument' ) );
            end
            [ status, changelist ] = refObj.updateFromDocument(  );
        end


        function updateSrcFileLocation( this, storedDocName, newDocPathName )
            this.errorIfVectorOperation(  );
            storedDocNameChar = strtrim( convertStringsToChars( storedDocName ) );
            newDocPathNameChar = strtrim( convertStringsToChars( newDocPathName ) );
            this.dataObject.updateSrcArtifactUri( storedDocNameChar, newDocPathNameChar );
        end


        function updateSrcArtifactUri( this, storedDocName, newDocPathName )
            this.errorIfVectorOperation(  );
            storedArtifactUri = strtrim( convertStringsToChars( storedDocName ) );
            updatedArtifactUri = strtrim( convertStringsToChars( newDocPathName ) );
            this.dataObject.updateSrcArtifactUri( storedArtifactUri, updatedArtifactUri, false );
        end


        function names = get.CustomAttributeNames( this )

            names = this.dataObject.CustomAttributeNames;
        end


        function justification = addJustification( this, varargin )
            this.errorIfVectorOperation(  );
            if isempty( varargin )
                reqInfo = [  ];
            else
                [ varargin{ : } ] = convertStringsToChars( varargin{ : } );
                reqInfo = slreq.utils.apiArgsToReqStruct( varargin{ : } );
                slreq.BaseItem.ensureWriteableProps( reqInfo );
            end
            dataJust = this.dataObject.addJustification( reqInfo );
            justification = slreq.Justification( dataJust );
        end


        function updateImplementationStatus( this )
            this.errorIfVectorOperation(  );
            this.dataObject.updateImplementationStatus(  );
            if slreq.app.MainManager.hasEditor(  )
                slreq.app.MainManager.getInstance(  ).update(  );
            end
        end


        function updateVerificationStatus( this )
            this.errorIfVectorOperation(  );
            this.dataObject.updateVerificationStatus(  );
            if slreq.app.MainManager.hasEditor(  )
                slreq.app.MainManager.getInstance(  ).update(  );
            end
        end


        function status = runTests( this, params )
            arguments
                this slreq.ReqSet
                params.select char{ slreq.data.ResultManager.validateSelectors( params.select ) } = slreq.data.ResultManager.SELECT_RUN_ALL;
            end
            this.errorIfVectorOperation(  );
            this.dataObject.runTests( slreq.data.ResultManager.SELF_STATUS_ALL, params.select );
            this.updateVerificationStatus(  );
            status = this.getVerificationStatus( slreq.data.ResultManager.SELF_STATUS_ALL );
        end


        function status = getImplementationStatus( this, varargin )
            this.errorIfVectorOperation(  );
            rollupTypeName = slreq.analysis.ImplementationVisitor.getName(  );
            try
                status = this.dataObject.handlePublicAPICall( rollupTypeName, varargin{ : } );
            catch ex
                throwAsCaller( ex );
            end
        end


        function status = getVerificationStatus( this, varargin )
            this.errorIfVectorOperation(  );
            rollupTypeName = slreq.analysis.VerificationVisitor.getName(  );
            try
                status = this.dataObject.handlePublicAPICall( rollupTypeName, varargin{ : } );
            catch ex
                throwAsCaller( ex );
            end
        end


        function success = exportToVersion( this, targetFileName, release )
            this.errorIfVectorOperation(  );
            targetFileName = convertStringsToChars( targetFileName );
            release = convertStringsToChars( release );
            success = false;%#ok<NASGU>
            try
                verObj = slreq.utils.VersionHandler( release );
            catch ex
                throwAsCaller( ex );
            end

            targetFullFileName = slreq.uri.getNewReqSetFilePath( targetFileName, false );

            if verObj.isSLReqVersion(  )
                try
                    success = this.dataObject.save( targetFullFileName, verObj.release );
                catch ex
                    throwAsCaller( ex );
                end
            else
                error( message( 'Slvnv:slreq:NoReqSetExportToOldRelease' ) )
            end
        end


        function parentModel = getParentModel( obj )
            obj.errorIfVectorOperation(  );
            parentModel = obj.dataObject.parent;
        end
    end


    methods ( Hidden )

        function cnt = count( this, type )
            this.errorIfVectorOperation(  );
            type = convertStringsToChars( type );
            if ~any( type == '.' )
                type = [ 'slreq.', type ];
            end
            [ reqItems, refItems ] = this.dataObject.getItems(  );
            if strcmp( type, 'slreq.Requirement' )
                cnt = numel( reqItems );
            else
                cnt = numel( refItems );
            end
        end


        function rename( this, newName )
            this.errorIfVectorOperation(  );
            slreq.uri.getPreferredPath( false );
            clp = onCleanup( @(  )slreq.uri.getPreferredPath( true ) );
            this.dataObject.filepath = newName;
            if slreq.app.MainManager.hasEditor(  )

                dasObj = this.dataObject.getDasObject(  );
                if ~isempty( dasObj )
                    mgr = slreq.app.MainManager.getInstance(  );
                    mgr.refreshUI( dasObj );
                    dasObj.updatePropertyInspector(  );
                end
            end
        end
    end


    methods ( Access = private )
        function result = slreqFind( this, varargin )
            if ~isempty( varargin ) && strcmpi( varargin{ 1 }, 'type' )
                r = slreq.find( varargin{ : } );
            else
                r = slreq.find( 'type', 'Requirement', varargin{ : } );
                r = [ r, slreq.find( 'type', 'Reference', varargin{ : } ) ];
                r = [ r, slreq.find( 'type', 'Justification', varargin{ : } ) ];
            end

            if isempty( r )
                result = [  ];
            else
                result = slreq.Requirement.empty;
            end

            for i = 1:length( r )
                if r( i ).reqSet.dataObject == this.dataObject

                    result( end  + 1 ) = r( i );
                end
            end
        end
    end
end

