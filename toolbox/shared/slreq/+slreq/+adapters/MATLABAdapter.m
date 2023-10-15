classdef MATLABAdapter < slreq.adapters.BaseAdapter




    properties ( Constant )
        icon = fullfile( matlabroot, 'toolbox', 'shared', 'dastudio', 'resources', 'eml.png' );
    end

    methods
        function this = MATLABAdapter(  )
            this.domain = 'linktype_rmi_matlab';
        end

        function out = getIcon( this, ~, ~ )
            out = this.icon;
        end

        function tf = isResolved( this, artifact, id )%#ok<INUSL>




            isOpenInMATLABEditor = isempty( rmiut.findInEditor( artifact, true ) );
            isOpenInSTM = dig.isProductInstalled( 'Simulink Test' ) ...
                && stm.internal.isTestFileOpen( artifact );

            if isOpenInMATLABEditor || isOpenInSTM
                tf = true;
                return ;
            end

            if isempty( id )

                tf = true;
            else
                try
                    if id( 1 ) == '?'

                        tf = contains( rmiml.getText( artifact ), id( 2:end  ) );
                    else
                        if id( 1 ) == '@'
                            id( 1 ) = [  ];
                        end
                        tf = ~isempty( rmiml.getText( artifact, id ) );
                    end
                catch ex %#ok<NASGU>
                    tf = false;
                end
            end
        end

        function success = select( ~, artifactUri, id, ~ )
            success = true;
            try
                [ ~, isSTMMunit ] = rmiml.RmiMUnitData.isMUnitFile( artifactUri );
                if isSTMMunit
                    success = slreq.adapters.MATLABAdapter.navigateToTestInTestManager( artifactUri, id );
                else
                    rmicodenavigate( artifactUri, id );
                end
            catch
                success = false;
            end
        end

        function success = highlight( this, artifact, id, ~ )
            success = this.select( artifact, id, [  ] );
        end

        function str = getSummary( ~, artifact, id )


            if ~rmiut.RangeUtils.isOpenInEditor( artifact )
                str = slreq.adapters.MATLABAdapter.getDefaultLabel( artifact, id );
                return ;
            end
            [ ~, ~, fExt ] = fileparts( artifact );
            if strcmp( fExt, '.mlx' )

                str = slreq.adapters.MATLABAdapter.getDefaultLabel( artifact, id );
                return ;
            end

            id( id( 1 ) == '@' ) = [  ];
            str = strtrim( rmiml.getText( artifact, id ) );
            if numel( str ) > 50
                str = [ str( 1:50 ), '...' ];
            end
            str = strtrim( strrep( str, newline, ' ' ) );
        end

        function str = getGlobalUniqueId( ~, artifact, id )





            if nargin < 3 || isempty( id )
                str = artifact;
                return ;
            end

            if strcmp( id( 1 ), '@' )
                id = id( 2:end  );
            end

            str = sprintf( '%s:%s', artifact, id );
        end

        function str = getLinkLabel( this, artifact, id )


            str = this.getSummary( artifact, id );
        end

        function tooltip = getTooltip( ~, artifact, id )
            if ~rmiut.RangeUtils.isOpenInEditor( artifact )
                tooltip = slreq.adapters.MATLABAdapter.getDefaultLabel( artifact, id );
                return ;
            end
            [ ~, ~, fExt ] = fileparts( artifact );
            if strcmp( fExt, '.mlx' )

                tooltip = slreq.adapters.MATLABAdapter.getDefaultLabel( artifact, id );
                return ;
            end
            id( id( 1 ) == '@' ) = [  ];
            str = rmiml.getText( artifact, id );
            if numel( str ) > 50
                str = [ str( 1:50 ), '...' ];
            end
            tooltip = getString( message( 'Slvnv:reqmgt:LinkSet:updateContents:LocationInDoc', str, slreq.uri.getShortNameExt( artifact ) ) );
        end

        function apiObj = getSourceObject( this, artifact, id )
            apiObj = [  ];

            dataLinkSet = slreq.utils.getLinkSet( artifact, this.domain, false );
            if ~isempty( dataLinkSet )
                textItem = dataLinkSet.getTextItem( '' );
                dataTextRange = textItem.getRange( id );
                if ~isempty( dataTextRange )
                    apiObj = slreq.TextRange( dataTextRange );
                end
            end
        end

        function success = onClickHyperlink( this, artifact, id, ~ )
            this.select( artifact, id, [  ] );
            success = true;
        end

        function cmdStr = getClickActionCommandString( ~, artifact, id, ~ )


            [ ~, isSTMMUnit ] = rmiml.RmiMUnitData.isMUnitFile( artifact );
            if isSTMMUnit
                cmdStr = sprintf( 'slreq.adapters.MATLABAdapter.navigateToTestInTestManager(''%s'',''%s'')', artifact, id );
            else
                cmdStr = sprintf( 'rmicodenavigate(''%s'',''%s'')', artifact, id );
            end
        end

        function navCmd = getExternalNavCmd( ~, artifactUri, id )




            shortName = slreq.uri.getShortNameExt( artifactUri );
            navCmd = sprintf( 'rmicodenavigate(''%s'',''%s'')', shortName, id );
        end

        function path = getFullPathToArtifact( ~, artifact, ~ )
            path = which( artifact );
        end

        function refreshLinkOwner( ~, linkedArtifact, linkedId, oldDestInfo, newDestInfo )
            if length( oldDestInfo ) == length( newDestInfo )


                return ;
            end
            rmiml.notifyEditor( linkedArtifact, linkedId );
        end




        function artifactUri = getArtifactUriFromReq( this, dataReq )%#ok<INUSL>
            storedUri = dataReq.artifactUri;
            [ destLocation, destName, destExt ] = fileparts( storedUri );
            if isempty( destLocation ) || rmiut.isCompletePath( destLocation )
                artifactUri = storedUri;
            elseif isfile( storedUri )

                artifactUri = fullfile( pwd, storedUri );
            else


                artifactUri = [ destName, destExt ];
            end
        end

        function linkType = getDefaultLinkType( this, artifactUri, id )
            [ isMunit, isSTMMunit ] = rmiml.RmiMUnitData.isMUnitFile( artifactUri );
            if isSTMMunit &&  ...
                    this.isTestProcedureOrTestFileLevelLink( artifactUri, id )
                linkType = slreq.custom.LinkType.Verify;
            elseif reqmgt( 'rmiFeature', 'MunitSupport' ) && isMunit &&  ...
                    this.isTestProcedureOrTestFileLevelLink( artifactUri, id )
                linkType = slreq.custom.LinkType.Verify;
            else
                linkType = slreq.custom.LinkType.Relate;
            end
        end

        function postSave( ~, dataLinkSet, ~ )
            rmiml.notifyEditor( dataLinkSet.artifact, '' );


        end

        function tfArray = isHiddenLink( ~, dataLinks )




            tfArray = false( size( dataLinks ) );
            for i = 1:numel( dataLinks )
                link = dataLinks( i );






                if ~isa( link.source, 'slreq.data.TextRange' )
                    continue ;
                end

                if link.source.endPos == 0
                    tfArray( i ) = true;
                end
            end
        end

        function preSave( this, dataLinkSet )

            if ( ~dataLinkSet.dirty )
                return ;
            end
            reqData = slreq.data.ReqData.getInstance(  );
            allDataLinks = reqData.getAllLinks( dataLinkSet );
            isHidden = this.isHiddenLink( allDataLinks );
            if any( isHidden )
                hiddenIdx = find( isHidden );
                for i = length( hiddenIdx ): - 1:1
                    reqData.removeLink( allDataLinks( hiddenIdx( i ) ) );
                end
            end

            if reqmgt( 'rmiFeature', 'MLChangeTracking' )



                slreq.adapters.MATLABAdapter.updateLinkSetRangeRevisions( dataLinkSet );
            end
        end


        function [ status, revisionInfo ] = getRevisionInfo( ~, sourceObj )
            status = slreq.analysis.ChangeStatus.UnsupportedArtifact;
            revisionInfo = slreq.utils.DefaultValues.getRevisionInfo(  );
            if reqmgt( 'rmiFeature', 'MLChangeTracking' )
                status = slreq.analysis.ChangeStatus.Undecided;

                revisionInfo.uuid = sourceObj.id;





                if sourceObj.isTextRange(  )
                    storedRevision = sourceObj.getRevision(  );
                    if ~isempty( storedRevision )




                        revisionInfo.revision = storedRevision;
                    end
                end
            end
        end

    end

    methods ( Static, Access = private )


        function labelStr = getDefaultLabel( artifact, id )
            shorterName = slreq.uri.getShortNameExt( artifact );
            if isempty( id )
                labelStr = shorterName;
            else
                labelStr = getString( message( 'Slvnv:reqmgt:LinkSet:updateContents:LocationInDoc', id, shorterName ) );
            end
        end
    end

    methods ( Static )
        function success = navigateToTestInTestManager( artifact, id )
            success = false;
            if slreq.verification.TestManagerResultProvider.hasSTMLicenseAndInstallation(  )


                success = rmiml.RmiMUnitData.navigateToSTMMunitTestCase( artifact, id );
            else

                rmicodenavigate( artifact, id );
                success = true;
            end
        end

        function updateLinkSetRangeRevisions( dataLinkSet )

            textItemIds = dataLinkSet.getTextItemIds(  );
            for i = 1:length( textItemIds )
                textItem = dataLinkSet.getTextItem( textItemIds( i ) );
                textRanges = textItem.getRanges(  );
                for j = 1:length( textRanges )
                    iRange = textRanges( j );
                    iRange.revision = slreq.adapters.MATLABAdapter.getRevisionForRange( iRange.startPos, iRange.endPos, textItem );
                end
            end
        end

        
        function revision = getRevisionForRange( startPos, endPos, textItem )
            arguments
                startPos double
                endPos double
                textItem{ mustBeA( textItem, [ "slreq.data.TextItem", "slreq.datamodel.TextItem" ] ) }
            end
            textContent = rmiut.unescapeFromXml( textItem.content );
            if isa( textItem, 'slreq.data.TextItem' )
                textItemId = textItem.getEditorId(  );
            else

                dataTextItem = slreq.data.ReqData.getInstance.wrap( textItem );
                textItemId = dataTextItem.getEditorId(  );
            end

            if endPos <= 0 || endPos < startPos
                linkedContent = '';
            else
                [ startPos, endPos ] = rmiml.RmiMlData.getInstance.getExtendedBoundsIfMethod( textItemId, textContent, startPos, endPos );

                contentLength = length( textContent );
                if endPos > contentLength
                    endPos = contentLength;
                end
                linkedContent = textContent( startPos:endPos );
            end
            revision = slreq.adapters.MATLABAdapter.getHash( linkedContent );
        end

        function hash = getHash( content )

            saltedContent = "#REQTBX#" + content;

            digester = matlab.internal.crypto.BasicDigester( "Blake-2b" );
            hash = char( matlab.internal.crypto.hexEncode( digester.computeDigest( saltedContent ) ) );
        end
    end
    methods ( Access = private )
        function tf = isTestProcedureOrTestFileLevelLink( ~, artifactUri, id )

            if contains( id, '-' )
                positions = sscanf( id, '%d-%d' );
            else
                positions = slreq.idToRange( artifactUri, id );
            end

            [ procedures, isFileLevel ] = rmiml.RmiMUnitData.getTestNamesUnderRange( artifactUri, positions );
            tf = ~isempty( procedures ) || isFileLevel;
        end
    end

end



