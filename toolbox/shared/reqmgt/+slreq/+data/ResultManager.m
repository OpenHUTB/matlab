classdef ResultManager < handle







    properties ( Access = protected )
        resultsCache;
        resultTimestampCache;
        resultReasonCache;
        providerRegistry;
    end

    properties ( Constant )
        SELF_STATUS_SELF = 'self';
        SELF_STATUS_ALL = 'all';

        SELECT_RUN_ALL = "all";
        SELECT_RUN_FAILED = "failed";
        SELECT_RUN_UNEXECUTED = "unexecuted";
    end

    methods ( Access = private )

        function this = ResultManager(  )
            this.resultsCache = containers.Map(  );
            this.resultTimestampCache = containers.Map(  );
            this.resultReasonCache = containers.Map(  );
            this.providerRegistry = slreq.verification.LinkResultProviderRegistry.getInstance(  );
        end
    end


    methods ( Static )
        function singleObj = getInstance(  )
            mlock;
            persistent singleton;
            if isempty( singleton ) || ~isvalid( singleton )
                singleton = slreq.data.ResultManager(  );
            end
            singleObj = singleton;
        end

        function links = getHierarchicalLinksForRequirement( req, selfStatus )
            arguments
                req
                selfStatus = slreq.data.ResultManager.SELF_STATUS_ALL
            end


            if strcmp( selfStatus, slreq.data.ResultManager.SELF_STATUS_SELF )
                links = getLinks( req );
            else
                links = getLinksInHierarchy( req );
            end

            function links = getLinksInHierarchy( parent )

                links = getLinks( parent );
                reqChildren = parent.children;
                for child = 1:length( reqChildren )
                    links = [ links, getLinksInHierarchy( reqChildren( child ) ) ];%#ok<AGROW> since recursive function
                end
            end

            function links = getLinks( parent )
                if isa( parent, 'slreq.das.Requirement' ) || isa( parent, 'slreq.data.Requirement' )
                    links = parent.getLinks( 'Verify' );
                else

                    links = [  ];
                end
            end
        end

        function validateSelfStatus( selfStatus )
            if ~strcmp( selfStatus, slreq.data.ResultManager.SELF_STATUS_SELF ) ...
                    && ~strcmp( selfStatus, slreq.data.ResultManager.SELF_STATUS_ALL )
                eid = 'Slvnv:slreq_verification:RunTestInvalidSelfOption';
                msg = message( eid ).getString(  );
                throwAsCaller( MException( eid, msg ) );
            end
        end

        function validateSelectors( selectors )
            selectors = lower( strtrim( string( selectors ) ) );
            validSelectors = ismember( selectors,  ...
                [ slreq.data.ResultManager.SELECT_RUN_ALL,  ...
                slreq.data.ResultManager.SELECT_RUN_FAILED,  ...
                slreq.data.ResultManager.SELECT_RUN_UNEXECUTED ] );
            if ~all( validSelectors )
                eid = 'Slvnv:slreq_verification:RunTestInvalidSelector';
                firstInvalidSelector = find( ~validSelectors, 1 );
                msg = message( eid, selectors( firstInvalidSelector ) ).getString(  );
                throwAsCaller( MException( eid, msg ) );
            end
        end
    end


    methods
        function [ resultStatus, reason ] = getResult( this, links )


            resultStatus = repmat( slreq.verification.ResultStatus.Unknown, 1, length( links ) );






            rStruct = struct( 'type', '', 'message', '' );
            reason = repmat( rStruct, 1, length( links ) );

            upToDate = false( 1, length( links ) );

            for i = 1:length( links )
                link = links( i );
                linkID = this.getLinkID( link );

                if ( this.resultsCache.isKey( linkID ) )
                    result = this.resultsCache( linkID );
                    resultTS = this.resultTimestampCache( linkID );
                    reason( i ) = this.resultReasonCache( linkID );
                    if ~this.isStaleResult( link, resultTS )
                        resultStatus( i ) = result;
                        upToDate( i ) = true;
                        continue ;
                    end
                end
            end



            notupdated = ( upToDate == false );
            linksToUpdate = links( notupdated );
            updateResults = resultStatus( notupdated );
            updateReasons = reason( notupdated );


            [ providerTable, providerlinkindexes ] = this.generateProviderTable( linksToUpdate );
            if isempty( providerTable )
                return ;
            end
            for j = 1:length( providerTable )
                provider = providerTable( j ).provider;
                thisProviderLinks = providerTable( j ).links;
                [ thisResultStatus, thisResultTimestamp, thisReason ] = provider.getResult( thisProviderLinks );


                this.updateCache( thisProviderLinks, thisResultStatus, thisResultTimestamp, thisReason );


                isNotUnkown = ( thisResultStatus ~= slreq.verification.ResultStatus.Unknown );
                isStale = this.isStaleResult( thisProviderLinks, thisResultTimestamp, provider );


                thisResultStatus( isNotUnkown & isStale ) = slreq.verification.ResultStatus.Stale;


                updateResults( providerlinkindexes == j ) = thisResultStatus;
                updateReasons( providerlinkindexes == j ) = thisReason;
            end
            resultStatus( notupdated ) = updateResults;
            reason( notupdated ) = updateReasons;
        end

        function status = runVerification( this, links, tedhandle, selector )


            arguments
                this slreq.data.ResultManager
                links( 1, : )
                tedhandle = [  ]
                selector string{ slreq.data.ResultManager.validateSelectors( selector ) } = slreq.data.ResultManager.SELECT_RUN_ALL;
            end


            links = this.filterLinks( links, selector );




            status = false( 1, length( links ) );
            [ providerTable, providerlinkindexes ] = this.generateProviderTable( links );
            if isempty( providerTable )
                return ;
            end
            for j = 1:length( providerTable )
                provider = providerTable( j ).provider;
                thisProviderLinks = providerTable( j ).links;
                startlistener = addlistener( provider, 'verificationStarted', @( t, ed )this.markVerificationStatus( t, ed, tedhandle ) );
                endlistener = addlistener( provider, 'verificationFinished', @( t, ed )this.markVerificationStatus( t, ed, tedhandle ) );

                [ thisRunSuccess, thisResultStatus, thisResultTimestamp, thisReason ] = provider.runTest( thisProviderLinks );



                this.updateCache( thisProviderLinks( thisRunSuccess ) ...
                    , thisResultStatus( thisRunSuccess ) ...
                    , thisResultTimestamp( thisRunSuccess ) ...
                    , thisReason( thisRunSuccess ) );

                status( providerlinkindexes == j ) = thisRunSuccess;
                delete( startlistener );
                delete( endlistener );
            end
        end

        function markVerificationStatus( ~, ~, eventdata, tedhandle )
            if isempty( tedhandle )
                return ;
            end
            sourceItems = eventdata.eventObj.items;
            statuses = eventdata.eventObj.status;
            for i = 1:length( sourceItems )
                tedhandle.markVerificationStatus( sourceItems( i ), statuses( i ) );
            end
        end

        function navigate( this, link )






            resultProvider = this.providerRegistry.getResultProvider( link );



            if ~isempty( resultProvider )
                resultProvider.navigate( link );
            end

        end

        function resetCache( this )
            this.resultsCache.remove( this.resultsCache.keys(  ) );
            this.resultTimestampCache.remove( this.resultTimestampCache.keys(  ) );
            this.resultReasonCache.remove( this.resultReasonCache.keys(  ) );
        end
    end


    methods ( Access = protected )

        function tf = isStaleResult( this, links, resultTimestamp, resultProvider )
            tf = true( 1, length( links ) );
            for i = 1:length( links )


                resultts = resultTimestamp( i );
                if isnat( resultts )

















                    tf( i ) = false;
                    continue ;
                end

                if nargin < 4
                    resultProvider = this.providerRegistry.getResultProvider( links( i ) );
                end
                if ~isempty( resultProvider )
                    sourcets = resultProvider.getSourceTimestamp( links( i ) );
                    tf( i ) = ( resultts < sourcets );
                end
            end
        end

        function linkID = getLinkID( ~, linkOrSourceItemObj )
            if isa( linkOrSourceItemObj, 'slreq.data.Link' )
                if linkOrSourceItemObj.isExternalVerificationLink(  )


                    linkID = linkOrSourceItemObj.dest.getUuid(  );
                else


                    linkID = linkOrSourceItemObj.source.getUuid(  );
                end
            else

                linkID = linkOrSourceItemObj.getUuid(  );
            end
        end

        function updateCache( this, links, resultStatus, resultTimestamp, reason )

            for i = 1:length( links )
                link = links( i );
                linkSrcID = this.getLinkID( link );
                if ~isnat( resultTimestamp( i ) )




                    this.resultsCache( linkSrcID ) = resultStatus( i );
                    this.resultTimestampCache( linkSrcID ) = resultTimestamp( i );
                    this.resultReasonCache( linkSrcID ) = reason( i );
                end
            end
        end

        function [ providerTable, providerlinkindexes ] = generateProviderTable( this, linksOrSourceItems )
            if isa( linksOrSourceItems, 'slreq.data.Link' )
                [ providerTable, providerlinkindexes ] = this.generateProviderLinkTable( linksOrSourceItems );
            elseif isa( linksOrSourceItems, 'slreq.data.SourceItem' ) || isa( linksOrSourceItems, 'cell' )
                [ providerTable, providerlinkindexes ] = this.generateProviderSourceTable( linksOrSourceItems );
            else
                providerTable = [  ];
                providerlinkindexes = [  ];
            end
        end

        function [ providerTable, providerlinkindexes ] = generateProviderLinkTable( this, reqlinks )
            providers = arrayfun( @( x )this.providerRegistry.getResultProvider( x ), reqlinks, 'UniformOutput', false );



            emptyLinks = cellfun( @isempty, providers );
            providers( emptyLinks ) = [  ];

            reqlinks( emptyLinks ) = [  ];


            [ ~, uniqueclassindices, providerlinkindexes ] = unique( cellfun( @( x )this.getProviderIdentifier( x ), providers, 'UniformOutput', false ), 'stable' );
            uniqueProviders = providers( uniqueclassindices );

            providerTable = repmat( struct( 'provider', '', 'links', '' ), 1, length( uniqueProviders ) );
            for i = 1:length( uniqueProviders )
                providerTable( i ).provider = uniqueProviders{ i };
                providerTable( i ).links = reqlinks( providerlinkindexes == i );
            end
        end

        function identifier = getProviderIdentifier( ~, provider )
            identifier = '';
            if ~isempty( provider )
                identifier = provider.getIdentifier;
            end
        end

        function [ providerTable, providerlinkindexes ] = generateProviderSourceTable( this, sourceItems )
            if isa( sourceItems, 'cell' )
                providers = cellfun( @( x )this.providerRegistry.getResultProvider( x ), sourceItems, 'UniformOutput', false );
            else
                providers = arrayfun( @( x )this.providerRegistry.getResultProvider( x ), sourceItems, 'UniformOutput', false );
            end


            nonVerifLinks = cellfun( @isempty, providers );
            providers( nonVerifLinks ) = [  ];

            sourceItems( nonVerifLinks ) = [  ];


            [ ~, uniqueclassindices, providerlinkindexes ] = unique( cellfun( @( x )this.getProviderIdentifier( x ), providers, 'UniformOutput', false ), 'stable' );
            uniqueProviders = providers( uniqueclassindices );

            providerTable = repmat( struct( 'provider', '', 'links', '' ), 1, length( uniqueProviders ) );
            for i = 1:length( uniqueProviders )
                providerTable( i ).provider = uniqueProviders{ i };
                if isa( sourceItems, 'cell' )



                    providerTable( i ).links = cellfun( @( x )x, sourceItems( providerlinkindexes == i ) );
                else
                    providerTable( i ).links = sourceItems( providerlinkindexes == i );
                end
            end
        end

        function links = filterLinks( this, linksOrSourceItems, selectors )
            selectors = lower( strtrim( string( selectors ) ) );
            if ~isa( linksOrSourceItems, 'slreq.data.Link' ) || any( ismember( selectors, this.SELECT_RUN_ALL ) )



                links = linksOrSourceItems;
                return ;
            end
            resultStatus = this.getResult( linksOrSourceItems );
            linkSelector = false( size( resultStatus ) );
            for i = 1:numel( selectors )
                selector = selectors( i );
                switch selector
                    case this.SELECT_RUN_FAILED
                        selectorFn = @( status )status == slreq.verification.ResultStatus.Fail;
                    case this.SELECT_RUN_UNEXECUTED
                        selectorFn = @( status )status == slreq.verification.ResultStatus.Unknown ...
                            || status == slreq.verification.ResultStatus.Stale;
                    otherwise


                        assert( false, 'Invalid Selector' );
                end
                linkSelector = linkSelector | arrayfun( selectorFn, resultStatus );
            end

            links = linksOrSourceItems( linkSelector );
        end
    end
    methods
        function [ hasProducts, reason ] = hasNecessaryVerificationProducts( this, verifitems )


            hasProducts = isempty( verifitems );
            reason = [  ];
            if isa( verifitems, 'slreq.data.Link' )
                providerTable = this.generateProviderLinkTable( verifitems );
            else
                providerTable = this.generateProviderSourceTable( verifitems );
            end
            unavailableproducts = {  };
            for i = 1:length( providerTable )
                if isa( providerTable( i ).provider, 'slreq.verification.SldvResultProvider' )
                    if slreq.verification.SldvResultProvider.hasSLDVLicenseAndInstallation(  )
                        hasProducts = hasProducts | true;
                    else
                        unavailableproducts = [ unavailableproducts, { 'Simulink Design Verifier' } ];%#ok<AGROW>
                    end
                end
                if isa( providerTable( i ).provider, 'slreq.verification.TestManagerResultProvider' ) ...
                        || isa( providerTable( i ).provider, 'slreq.verification.TestManagerMUnitResultProvider' ) ...
                        || isa( providerTable( i ).provider, 'slreq.verification.TestStepResultProvider' )
                    if slreq.verification.TestManagerResultProvider.hasSTMLicenseAndInstallation(  )
                        hasProducts = hasProducts | true;
                    else
                        unavailableproducts = [ unavailableproducts, { 'Simulink Test' } ];%#ok<AGROW>
                    end
                end
                if isa( providerTable( i ).provider, 'slreq.verification.MATLABTestResultProvider' )
                    hasProducts = hasProducts | true;
                end
            end
            if ~isempty( unavailableproducts )
                reason.unavailableproducts = unavailableproducts;
            end
        end

    end

end

