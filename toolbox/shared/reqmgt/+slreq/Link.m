






































































































































classdef Link < handle



    properties ( Access = private, Transient )
        dataObject
    end

    properties ( Dependent )
        Type
        Description
        Keywords
        Rationale
    end

    properties ( Dependent, GetAccess = public, SetAccess = private )
        CreatedOn
        CreatedBy
        ModifiedOn
        ModifiedBy
        Revision
        SID
        Comments
    end

    methods ( Static )
        function obj = loadobj( ~ )
            obj = slreq.Link.empty(  );
            rmiut.warnNoBacktrace( 'Slvnv:slreq:illegalDataForMATFile', class( obj ) );
        end
    end
    methods
        function sobj = saveobj( obj )
            rmiut.warnNoBacktrace( 'Slvnv:slreq:illegalDataForMATFile', class( obj ) );
            sobj = obj;
        end
    end

    methods ( Hidden, Access = ?slreq.data.ReqData )
        function d = getDataObj( this )
            d = this.dataObject;
        end
    end

    methods

        function this = Link( dataObject )
            this.dataObject = dataObject;
        end

        function value = get.Type( this )
            value = this.dataObject.type;
        end
        function set.Type( this, value )
            value = convertStringsToChars( value );
            this.dataObject.type = value;
        end

        function value = get.Description( this )
            value = this.dataObject.description;
        end
        function set.Description( this, value )
            value = convertStringsToChars( value );
            this.dataObject.description = value;
        end

        function value = get.Keywords( this )
            value = this.dataObject.keywords;
        end
        function set.Keywords( this, value )
            value = convertStringsToChars( value );
            this.dataObject.keywords = value;
        end

        function value = get.Rationale( this )
            value = this.dataObject.rationale;
        end
        function set.Rationale( this, value )
            value = convertStringsToChars( value );
            this.dataObject.rationale = value;
        end

        function value = get.CreatedOn( this )
            value = this.dataObject.createdOn;
        end
        function value = get.CreatedBy( this )
            value = this.dataObject.createdBy;
        end
        function value = get.ModifiedOn( this )
            value = this.dataObject.modifiedOn;
        end
        function value = get.ModifiedBy( this )
            value = this.dataObject.modifiedBy;
        end
        function value = get.Revision( this )
            value = this.dataObject.revision;
        end

        function sid = get.SID( this )
            sid = this.dataObject.sid;
        end

        function value = get.Comments( this )

            value = struct( 'CommentedBy', {  }, 'CommentedOn', {  }, 'CommentedRevision', {  }, 'Text', {  } );
            comments = this.dataObject.comments;
            for n = 1:length( comments )
                value( n ) = struct(  ...
                    'CommentedBy', comments( n ).CommentedBy,  ...
                    'CommentedOn', comments( n ).Date,  ...
                    'CommentedRevision', comments( n ).CommentedRevision,  ...
                    'Text', comments( n ).Text );
            end
        end

        function apiObj = linkSet( this )
            this.errorIfVectorOperation(  );
            dataObj = this.dataObject.getLinkSet(  );
            apiObj = slreq.utils.dataToApiObject( dataObj );
        end

        function tf = isResolved( this )
            tf = this.isResolvedSource(  ) && this.isResolvedDestination(  );
        end

        function tf = isResolvedSource( this )
            this.errorIfVectorOperation(  );
            srcInfo = slreq.utils.resolveSrc( this.dataObject );
            if isfield( srcInfo, 'range' )
                id = slreq.utils.getLongIdFromShortId( srcInfo.parent, srcInfo.id );
            else
                id = srcInfo.id;
            end
            tf = slreq.utils.isValidItem( srcInfo.domain, srcInfo.artifact, id );
        end

        function tf = isResolvedDestination( this )
            this.errorIfVectorOperation(  );
            tf = slreq.utils.hasValidDest( this.dataObject );
        end

        function remove( this )
            this.errorIfVectorOperation(  );
            dataObj = this.dataObject;



            [ srcAdapter, srcArtifactUri, srcArtifactId ] = dataObj.source.getAdapter(  );

            dataObj.remove(  );
            this.dataObject = [  ];



            srcAdapter.refreshLinkOwner( srcArtifactUri, srcArtifactId, rmi.createEmptyReqs( 1 ), [  ] );

        end

        function src = source( this )
            this.errorIfVectorOperation(  );
            src = slreq.utils.resolveSrc( this.dataObject );
        end

        function dest = destination( this )
            this.errorIfVectorOperation(  );
            destDataObj = this.dataObject.dest;
            if isempty( destDataObj )
                dest = [  ];
            else
                dest = destDataObj.toStruct(  );
            end
        end

        function refInfo = getReferenceInfo( this )
            this.errorIfVectorOperation(  );
            refInfo = struct( 'domain', this.dataObject.destDomain,  ...
                'artifact', this.dataObject.destUri,  ...
                'id', this.dataObject.destId );


        end

        function thisComment = addComment( this, text )
            this.errorIfVectorOperation(  );
            if ~( ischar( text ) || isstring( text ) )
                error( message( 'Slvnv:slreq:InvalidInputType' ) );
            end
            comment = this.dataObject.addComment;
            comment.Text = text;
            thisComment = this.Comments( end  );
        end

        function setSource( this, newSrc )
            this.errorIfVectorOperation(  );
            dataLink = this.dataObject;
            try
                srcInfo = slreq.utils.resolveSrc( newSrc );
                if isa( newSrc, 'slreq.Reference' )
                    srcInfo.artifact = newSrc.reqSet.Filename;
                    srcInfo.id = num2str( newSrc.SID );
                end

                dataLink.updateSource( srcInfo );
            catch ex
                me = MException( message( 'Slvnv:slreq:APIFailedToSetSource' ) );
                mec = me.addCause( ex );
                throwAsCaller( mec );
            end
        end

        function setDestination( this, newDst )
            this.errorIfVectorOperation(  );
            dataLink = this.dataObject;
            try
                dstInfo = slreq.utils.resolveDest( newDst );
                dataLink.updateDestination( dstInfo );
            catch ex
                me = MException( message( 'Slvnv:slreq:APIFailedToSetDestination' ) );
                mec = me.addCause( ex );
                throwAsCaller( mec );
            end
        end

        function value = getAttribute( this, name )
            this.errorIfVectorOperation(  );
            name = convertStringsToChars( name );
            if strcmp( name, 'dataObject' )

                error( message( 'Slvnv:slreq:NoSuchAttribute' ) );
            elseif this.dataObject.hasRegisteredAttribute( name )


                try
                    value = this.dataObject.getAttribute( name, true );
                catch ex

                    throwAsCaller( ex )
                end
            elseif this.dataObject.hasStereotypeAttribute( name )
                try
                    value = this.dataObject.getStereotypeAttr( name, true );
                catch ex

                    error( message( 'Slvnv:slreq:NoSuchAttribute' ) );
                end
            elseif any( strcmp( name, { 'source', 'destination', 'Keywords', 'Description', 'Rationale', 'Type', 'SID' } ) )


                value = this.( name );
            else
                error( message( 'Slvnv:slreq:NoSuchAttribute' ) );
            end
        end

        function setAttribute( this, name, value )
            this.errorIfVectorOperation(  );
            name = convertStringsToChars( name );
            value = convertStringsToChars( value );
            if strcmp( name, 'dataObject' )

                error( message( 'Slvnv:slreq:NoSuchAttribute' ) );
            elseif this.dataObject.hasRegisteredAttribute( name )


                try
                    this.dataObject.setAttributeWithTypeCheck( name, value );
                catch ex

                    throwAsCaller( ex )
                end
            elseif this.dataObject.hasStereotypeAttribute( name )
                try
                    this.dataObject.setStereotypeAttr( name, value );
                catch ex

                    throwAsCaller( ex )
                end
            elseif any( strcmp( name, { 'Keywords', 'Description', 'Rationale', 'Type' } ) )
                this.( name ) = value;
            else
                error( message( 'Slvnv:slreq:NoSuchAttribute' ) );
            end
        end



        function value = hasChangedSource( this )



            this.errorIfVectorOperation(  );







            value = this.dataObject.sourceChangeStatus.isFail(  );
        end



        function value = hasChangedDestination( this )


            this.errorIfVectorOperation(  );

            value = this.dataObject.destinationChangeStatus.isFail(  );
        end



        function changeInformation = getChangeInformation( this )


            outputsize = length( this );
            changeInformation = struct( 'source', repmat( { [  ] }, 1, outputsize ),  ...
                'destination', repmat( { [  ] }, 1, outputsize ) );
            ct = slreq.analysis.ChangeTracker.getInstance;
            for index = 1:length( this )
                dataLink = this( index ).dataObject;
                if dataLink.sourceChangeStatus.isUndecided ||  ...
                        dataLink.destinationChangeStatus.isUndecided

                    ct.refreshLink( dataLink )
                end

                src.status = dataLink.sourceChangeStatus.toInteger(  );
                src.storedRevision = dataLink.linkedSourceRevision;
                src.storedTimestamp = slreq.utils.getDataTimeObjFromPTime( dataLink.linkedSourceTimeStamp );
                src.actualRevision = dataLink.currentSourceRevision;
                src.actualTimestamp = slreq.utils.getDataTimeObjFromPTime( dataLink.currentSourceTimeStamp );

                dst.status = dataLink.destinationChangeStatus.toInteger(  );
                dst.storedRevision = dataLink.linkedDestinationRevision;
                dst.storedTimestamp = slreq.utils.getDataTimeObjFromPTime( dataLink.linkedDestinationTimeStamp );
                dst.actualRevision = dataLink.currentDestinationRevision;
                dst.actualTimestamp = slreq.utils.getDataTimeObjFromPTime( dataLink.currentDestinationTimeStamp );
                changeInformation( index ).source = src;
                changeInformation( index ).destination = dst;
            end
        end


        function clearChangeIssues( this, comment, target )
            arguments
                this
                comment = slreq.analysis.ChangeTrackingClearVisitor.MACRO_UPDATE_INFO;
                target{ mustBeMember( target, [ "All", "Source", "Destination" ] ) } = "All";
            end

            comment = convertStringsToChars( comment );
            target = convertStringsToChars( target );
            clearSrc = true;
            clearDst = true;

            if strcmp( target, 'Source' )
                clearDst = false;
            elseif strcmp( target, 'Destination' )
                clearSrc = false;
            end


            ct = slreq.analysis.ChangeTracker.getInstance;
            for index = 1:length( this )
                cDataLink = this( index ).dataObject;
                if cDataLink.sourceChangeStatus.isUndecided ||  ...
                        cDataLink.destinationChangeStatus.isUndecided
                    ct.refreshLink( cDataLink )
                end

                if clearSrc
                    ct.clearLinkedSourceIssues( cDataLink, comment );
                end

                if clearDst
                    ct.clearLinkedDestinationIssues( cDataLink, comment );
                end
            end

        end

        function tf = isFilteredIn( this )
            tf = false( 0, length( this ) );
            for i = 1:length( this )
                tf( i ) = this( i ).dataObject.isFilteredIn;
            end
        end
    end

    methods ( Access = private )
        function errorIfVectorOperation( this )
            if numel( this ) > 1
                error( message( 'Slvnv:slreq:MethodOnlyForScalar' ) );
            end
        end
    end

    methods ( Hidden )

        function propValue = getInternalAttribute( this, propName )
            propValue = this.dataObject.getProperty( propName );
        end
        function setInternalAttribute( this, propName, propValue )




            this.dataObject.setProperty( propName, propValue )
        end

        function generateTraceDiagram( this )

            this.errorIfVectorOperation(  );
            slreq.internal.tracediagram.utils.generateTraceDiagram( this.dataObject );
        end
    end
end

