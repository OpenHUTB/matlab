classdef ReqRoot < slreq.das.BaseObject

    properties
        reqData;
        reqDataChangeListener;
        otherArtifactChangeListerners = {  };

    end

    methods ( Static, Hidden )

        function c = count( op )
            arguments
                op = 'get'
            end

            mlock;
            persistent counter;
            if isempty( counter )
                counter = 0;
            end
            switch op
                case 'inc'
                    counter = counter + 1;
                case 'dec'
                    counter = counter - 1;
            end
            c = counter;
        end
    end

    methods

        function this = ReqRoot( view )
            this@slreq.das.BaseObject(  );
            this.childrenCreated = false;

            this.view = view;
            this.reqData = slreq.data.ReqData.getInstance(  );
            this.reqDataChangeListener = this.reqData.addlistener( 'ReqDataChange', @this.onReqDataChange );
            if dig.isProductInstalled( 'Simulink Test' ) && contains( path, [ 'toolbox', filesep, 'stm', filesep, 'stm' ] )
                this.otherArtifactChangeListerners{ 1 } = sltest.internal.Events.getInstance.addlistener( 'SimulationCompleted', @this.onSimulationCompleted );
                this.otherArtifactChangeListerners{ 2 } = sltest.internal.Events.getInstance.addlistener( 'TestFileOpened', @this.onTestFileOpened );

            end

            this.syncWithRepository(  );

            this.notifyViewChange( true );

            assert( this.count(  ) == 0, 'duplicated ReqRoot created' );
            this.count( 'inc' );
        end

        function delete( this )
            this.count( 'dec' );

            delete( this.reqDataChangeListener );
            for n = 1:length( this.otherArtifactChangeListerners )
                delete( this.otherArtifactChangeListerners{ n } );
            end

            this.reqDataChangeListener = [  ];
            this.otherArtifactChangeListerners = {  };
        end
    end

    methods ( Static )




        function name = promptForReqSetFile( defaultName )
            dialogTitle = getString( message( 'Slvnv:slreq:NewRequirementSetLocation' ) );
            filterSpec = { '*.slreqx', 'Requirement Set Files (*.slreqx)';
                '*.*', 'All Files (*.*)' };
            [ filename, pathName, filterIndex ] = uiputfile( filterSpec, dialogTitle, defaultName );
            if filterIndex > 0
                name = [ pathName, filename ];
            else
                name = '';
            end
        end

        function reqSet = createAndSaveReqSet( name )


            reqData = slreq.data.ReqData.getInstance;
            try




                reqSet = reqData.createAndSaveReqSet( name );

            catch ex
                errordlg( ex.message,  ...
                    getString( message( 'Slvnv:slreq:Error' ) ) );
                if exist( 'reqSet', 'var' ) == 1
                    reqData.discardReqSet( reqSet );%#ok<NODEF>
                end

                reqSet = slreq.data.RequirementSet.empty(  );
            end
        end
    end

    methods
        function ch = getChildren( this, ~ )
            if ~this.childrenCreated
                this.childrenCreated = true;
                if isempty( this.children )

                    childReqs = [  ];
                    if ~isempty( this.dataModelObj )
                        childReqs = this.dataModelObj.children;
                    end
                    for i = 1:numel( childReqs )

                        reqDasObj = slreq.das.Requirement(  );
                        reqDasObj.postConstructorProcess( childReqs( i ), this, this.view, this.eventListener );
                        this.addChildObject( reqDasObj );
                    end
                end
            end

            ch = this.children;
        end

        function ch = getHierarchicalChildren( this )
            ch = this.getChildren( this );
        end

        function onSimulationCompleted( this, ~, ~ )
            mgr = slreq.app.MainManager.getInstance;
            allViewers = mgr.getAllViewers;
            if mgr.isVerificationStatusEnabled( allViewers )


                this.refreshVerificationStatus(  );
                mgr.update( true );
            end
        end

        function onTestFileOpened( ~, ~, data )
            mgr = slreq.app.MainManager.getInstance;
            mgr.refreshUIOnArtifactLoad( data.FilePath );
        end

        function reqSetDasObj = addRequirementSet( this, name )
            if nargin == 1
                name = '';
            end
            this.reqDataChangeListener.Enabled = false;
            reqSet = slreq.das.ReqRoot.createAndSaveReqSet( name );
            this.reqDataChangeListener.Enabled = true;
            if isempty( reqSet )



                reqSetDasObj = [  ];
            else
                reqSetDasObj = slreq.das.RequirementSet( reqSet, this, this.view, this.reqDataChangeListener );
                this.addChildObject( reqSetDasObj );



                this.notifyViewChange( true );
            end
        end

        function reqSetDasObj = loadRequirementSet( this, filePath, resolveProfile, profChecker, profNs )
            if nargin == 2
                resolveProfile = false;
            end


            this.reqDataChangeListener.Enabled = false;

            try
                [ ~, ~, fExt ] = fileparts( filePath );
                if strcmpi( fExt, '.slx' )
                    mdlHandle = load_system( filePath );
                    reqsetName = slreq.data.ReqData.getInstance.getSfReqSet( mdlHandle );
                    if ~isempty( reqsetName )
                        reqSet = slreq.data.ReqData.getInstance.getReqSet( reqsetName );
                    else

                        reqSet = [  ];
                    end
                else
                    reqSet = this.reqData.loadReqSet( filePath,  ...
                        [  ], resolveProfile, profChecker, profNs );
                end
            catch ex

                this.reqDataChangeListener.Enabled = true;


                rethrow( ex );
            end

            this.reqDataChangeListener.Enabled = true;
            if isempty( reqSet )


                reqSetDasObj = slreq.das.RequirementSet.empty(  );
                return ;
            end

            reqSetDasObj = reqSet.getDasObject(  );
            if isempty( reqSetDasObj )
                reqSetDasObj = slreq.das.RequirementSet( reqSet, this, this.view, this.reqDataChangeListener );
                this.addChildObject( reqSetDasObj );
            end


            if ~isempty( this.view.spreadsheetManager )
                this.view.spreadsheetManager.updateDisplayedReqSet(  );
            end

            if ~isempty( this.view.markupManager )
                this.view.markupManager.updateMarkupOnReqSetLoaded( reqSetDasObj );
            end
        end

        function discardReqSet( this )%#ok<MANU>
        end



        function discardAll( this )%#ok<MANU>
        end

        function showSuggestion( this, suggestionId, suggestionText )
            reqEditor = this.view.requirementsEditor;

            if isempty( reqEditor )
                return ;
            end
            reqEditor.ShowSuggestion = true;
            reqEditor.SuggestionId = suggestionId;
            reqEditor.SuggestionReason = suggestionText;
            reqEditor.showNotification(  );
        end



        function suggestionText = getSuggestion( this )
            reqEditor = this.view.requirementsEditor;
            suggestionText = reqEditor.SuggestionReason;
        end

        function onReqDataChange( this, ~, eventInfo )
            slreq.utils.assertValid( this );

            objToBeSelected = [  ];














            localDataRefreshed = false;

            doNotify = true;

            switch eventInfo.type
                case { 'ReqSet Created', 'ReqSet Loaded' }
                    reqSet = eventInfo.eventObj;
                    slreq.utils.assertValid( reqSet );
                    if ~any( strcmp( reqSet.filepath, { 'default.slreqx', 'clipboard.slreqx', 'slinternal_scratchpad.slreqx' } ) )
                        dasReqSet = slreq.das.RequirementSet( reqSet,  ...
                            this,  ...
                            this.view,  ...
                            this.reqDataChangeListener );
                        this.addChildObject( dasReqSet );

                        if ~isempty( this.view.spreadsheetManager )
                            this.view.spreadsheetManager.updateDisplayedReqSet(  );
                        end

                        if ~isempty( this.view.markupManager )
                            this.view.markupManager.updateMarkupOnReqSetLoaded( dasReqSet );
                        end

                        localDataRefreshed = true;
                        mgr = slreq.app.MainManager.getInstance;


                        if ~mgr.isAnalysisDeferred
                            allViewers = mgr.getAllViewers;
                            if strcmp( eventInfo.type, 'ReqSet Loaded' )




                                if isempty( dasReqSet ) && mgr.isChangeInformationEnabled( allViewers )
                                    ctmgr = mgr.changeTracker;
                                    ctmgr.refresh(  );
                                end
                            end


                            if mgr.isImplementationStatusEnabled( allViewers )
                                this.refreshImplementationStatus( dasReqSet );
                            end

                            if mgr.isVerificationStatusEnabled( allViewers )
                                this.refreshVerificationStatus( dasReqSet );
                            end
                        end
                        detectionMgr = slreq.dataexchange.UpdateDetectionManager.getInstance(  );
                        detected = detectionMgr.checkUpdatesForAllArtifacts(  );
                        if detected


                            dasReqSet.updateImportNodeIcons(  );
                        end

                    end

                case 'ReqSet Discarded'


                    localDataRefreshed = true;


                    mgr = slreq.app.MainManager.getInstance;
                    allViewers = mgr.getAllViewers;
                    if mgr.isChangeInformationEnabled( allViewers )
                        ctmgr = mgr.changeTracker;
                        ctmgr.refresh(  );
                    end


                case 'Before ReqSet Discarded'






                    dataReqSet = eventInfo.eventObj;
                    dasReqSet = dataReqSet.getDasObject(  );
                    index = this.findObjectIndex( dasReqSet );
                    if ~isempty( dasReqSet )


                        if slreq.app.MainManager.hasEditor(  )
                            this.view.clearSelectedObjectsUponDeletion( dasReqSet );
                            this.view.markupManager.updateMarkupOnReqSetDiscarded( dasReqSet );
                        end
                        dasReqSet.discardAll(  );
                    end

                    if index > 0




                        this.children( index ) = [  ];
                    end


                    localDataRefreshed = true;


                    doNotify = false;
                case { 'ReqSetDirtied', 'ReqSetUndirtied' }

                    dataReqSet = eventInfo.eventObj;
                    dasReqSet = dataReqSet.getDasObject(  );
                    if ~isempty( dasReqSet )
                        mgr = slreq.app.MainManager.getInstance;
                        mgr.refreshUI( dasReqSet );
                    end

                    return ;

                case 'Set Prop Update'
                    dataObj = eventInfo.eventObj;
                    dasObj = dataObj.getDasObject(  );
                    needToNotifyView = false;
                    if ~isempty( dasObj )



                        mgr = slreq.app.MainManager.getInstance;
                        allViewers = mgr.getAllViewers;
                        if mgr.isChangeInformationEnabled( allViewers )

                            [ inlinks, outlinks ] = dataObj.getLinks;
                            if ~isempty( inlinks ) || ~isempty( outlinks )
                                ctmgr = mgr.changeTracker;
                                ctmgr.refreshReq( dasObj );
                                needToNotifyView = true;
                            end
                        end

                        [ affectImp, affectVer ] = dataObj.doesChangeImpactRollupStatus( eventInfo );

                        refreshImp = affectImp && mgr.isImplementationStatusEnabled( allViewers );
                        refreshVer = affectVer && mgr.isVerificationStatusEnabled( allViewers );
                        needToNotifyView = needToNotifyView || refreshImp || refreshVer;

                        if strcmpi( eventInfo.PropName, 'isHierarchicalJustification' )



                            [ ~, outDataLinks ] = dataObj.getLinks;
                            slreq.analysis.BaseRollupAnalysis.refreshRollupStatusForLinks( outDataLinks, refreshImp, refreshVer );
                        else
                            if refreshImp
                                dataObj.updateImplementationStatus(  );
                            end
                            if refreshVer
                                dataObj.updateVerificationStatus(  );
                            end
                        end

                        if any( strcmp( eventInfo.PropName, { 'Unlocked', 'pendingDetectionStatus' } ) )
                            dasObj.setDisplayIcon(  );
                        end

                        mgr.refreshUI( dasObj );
                    end



                    if isa( dasObj, 'slreq.das.Requirement' )
                        markups = dasObj.Markups;
                        for i = 1:length( markups )
                            markups( i ).update(  );
                        end
                    end
                    if needToNotifyView


                        this.notifyViewChange( true );
                    elseif ~isempty( dasObj )

                        dasObj.updatePropertyInspector( eventInfo );
                    end



                    this.view.badgeManager.updateBadge( dasObj );
                    return ;

                case 'Requirement Added'
                    req = eventInfo.eventObj;
                    reqSet = req.getReqSet(  );
                    dasReqSet = reqSet.getDasObject(  );
                    if ~isempty( dasReqSet )
                        dasReqSet.addChild( req );
                    end
                    mgr = slreq.app.MainManager.getInstance;
                    allViewers = mgr.getAllViewers;


                    localDataRefreshed = true;
                    if mgr.isImplementationStatusEnabled( allViewers )
                        req.updateImplementationStatus(  );
                    end

                    if mgr.isVerificationStatusEnabled( allViewers )
                        req.updateVerificationStatus(  );
                    end

                case 'Justification Added'
                    req = eventInfo.eventObj;
                    reqSet = req.getReqSet(  );
                    dasReqSet = reqSet.getDasObject(  );
                    if ~isempty( dasReqSet )
                        parentDasObj = req.parent.getDasObject(  );
                        if isempty( parentDasObj )


                            dasReqSet.addChild( req.parent );
                        else

                            dasReqSet.addChild( req );
                        end
                    end

                    mgr = slreq.app.MainManager.getInstance;
                    allViewers = mgr.getAllViewers;
                    localDataRefreshed = true;


                    if mgr.isImplementationStatusEnabled( allViewers )

                        req.updateImplementationStatus(  );
                    end

                    if mgr.isVerificationStatusEnabled( allViewers )
                        req.updateVerificationStatus(  );
                    end

                case 'Requirement Pasted'
                    req = eventInfo.eventObj;
                    if isa( req, 'slreq.data.Requirement' )
                        reqSet = req.getReqSet;
                    elseif isa( req, 'slreq.data.RequirementSet' )
                        reqSet = req;
                    else

                    end
                    parentDas = req.getDasObject(  );

                    reqSet.updateHIdx(  );
                    if ~isempty( parentDas )
                        addedReq = this.recAddDasObjctsIfNeeded( parentDas, req );

                        if ~isempty( this.view.getCurrentView ) && ~isempty( addedReq )
                            objToBeSelected = addedReq( 1 );
                        end

                        mgr = slreq.app.MainManager.getInstance;
                        allViewers = mgr.getAllViewers;
                        localDataRefreshed = true;
                        if mgr.isChangeInformationEnabled( allViewers )



                            ctmgr = mgr.changeTracker;
                            ctmgr.refreshReq( addedReq );
                        end

                        if mgr.isImplementationStatusEnabled( allViewers )


                            req.updateImplementationStatus(  );
                        end

                        if mgr.isVerificationStatusEnabled( allViewers )

                            req.updateVerificationStatus(  );
                        end
                    end
                case 'Requirement Deleted'
                    eventData = eventInfo.eventObj;
                    dasObj = eventData.dasObj;
                    parent = [  ];
                    if ~isempty( dasObj )
                        parent = dasObj.parent;

                        if ~isempty( parent )






                            parent.removeChildObject( dasObj, false );
                        end
                    end



                    dasObjList = eventData.dasObjList;
                    for index = 1:length( dasObjList )
                        cObj = dasObjList{ index };
                        cObj.delete(  );
                    end

                    mgr = slreq.app.MainManager.getInstance;
                    allViewers = mgr.getAllViewers;



                    localDataRefreshed = true;

                    if mgr.isImplementationStatusEnabled( allViewers )

                        if ~isempty( parent )
                            parent.dataModelObj.updateImplementationStatusForStatsOnly;
                        end
                    end

                    if mgr.isVerificationStatusEnabled( allViewers )
                        if ~isempty( parent )
                            parent.dataModelObj.updateVerificationStatusForStatsOnly;
                        end
                    end


                case 'BeforeDeleteRequirement'
                    eventData = eventInfo.eventObj;
                    uuids = eventData.uuids;
                    this.view.markupManager.destroyMarkupsByUuids( uuids );

                    dasObjs = eventData.dasObjs;


                    for n = 1:length( dasObjs )
                        this.view.clearSelectedObjectsUponDeletion( dasObjs{ n } );
                    end


                    mgr = slreq.app.MainManager.getInstance;
                    eemgr = mgr.externalEditorManager;
                    if ~isempty( eemgr )
                        eemgr.deleteExternalEditorForReqs( dasObjs );
                    end

                    allViewers = mgr.getAllViewers;
                    if mgr.isChangeInformationEnabled( allViewers )

                        ctmgr = mgr.changeTracker;
                        for index = 1:length( dasObjs )
                            cDasObj = dasObjs{ index };
                            if isa( cDasObj, 'slreq.das.Requirement' )
                                ctmgr.refreshReqToBeDeleted( cDasObj );
                            end
                        end
                    end

                    for index = 1:length( dasObjs )
                        cDasObj = dasObjs{ index };




                        cDasObj.releaseDataObj(  );
                    end


                    return ;

                case 'Requirements Moved'
                    movedDataReqs = eventInfo.eventObjs;
                    sz = numel( movedDataReqs );
                    affectImp = false;
                    affectVer = false;
                    affectedDataObjs = {  };
                    affectedDataObjsForStats = {  };
                    for i = 1:sz
                        movedDataReq = movedDataReqs{ i };
                        dasMovedReq = movedDataReq.getDasObject(  );
                        if ~isempty( dasMovedReq )
                            dasMovedReq.onDataReqMove(  );
                            if isempty( dasMovedReq.parent )




                                this.view.clearSelectedObjectsUponDeletion( dasMovedReq );
                            elseif ~isempty( this.view.getCurrentView )
                                objToBeSelected = dasMovedReq;
                            end
                            markups = dasMovedReq.Markups;
                            for n = 1:length( markups )
                                markups( n ).update(  );
                            end
                        end


                        singleEventInfo = eventInfo.getChangeEvent( i );
                        [ affectImp, affectVer, affectedDataObjs, affectedDataObjsForStats ] = checkChangeImpectRollupStatus(  ...
                            movedDataReq, singleEventInfo, affectImp, affectVer, affectedDataObjs, affectedDataObjsForStats );
                    end
                    mgr = slreq.app.MainManager.getInstance;
                    allViewers = mgr.getAllViewers;

                    if affectImp && mgr.isImplementationStatusEnabled( allViewers )
                        for index = 1:length( affectedDataObjs )
                            affectedDataObjs{ index }.updateImplementationStatus(  );
                        end

                        for index = 1:length( affectedDataObjsForStats )
                            affectedDataObjsForStats{ index }.updateImplementationStatusForStatsOnly(  );
                        end
                    end

                    if affectVer && mgr.isVerificationStatusEnabled( allViewers )
                        for index = 1:length( affectedDataObjs )
                            affectedDataObjs{ index }.updateVerificationStatus(  );
                        end

                        for index = 1:length( affectedDataObjsForStats )
                            affectedDataObjsForStats{ index }.updateVerificationStatusForStatsOnly(  );
                        end
                    end
                    localDataRefreshed = true;
                case 'Requirement Moved'
                    movedDataReq = eventInfo.eventObj;

                    dasMovedReq = movedDataReq.getDasObject(  );
                    if ~isempty( dasMovedReq )
                        dasMovedReq.onDataReqMove(  );
                        if isempty( dasMovedReq.parent )




                            this.view.clearSelectedObjectsUponDeletion( dasMovedReq );
                        elseif ~isempty( this.view.getCurrentView )
                            objToBeSelected = dasMovedReq;
                        end
                        markups = dasMovedReq.Markups;
                        for n = 1:length( markups )
                            markups( n ).update(  );
                        end
                    end



                    [ affectImp, affectVer, affectedDataObjs, affectedDataObjsForStats ] = movedDataReq.doesChangeImpactRollupStatusWhenMoving( eventInfo );



                    mgr = slreq.app.MainManager.getInstance;
                    allViewers = mgr.getAllViewers;

                    if affectImp && mgr.isImplementationStatusEnabled( allViewers )
                        for index = 1:length( affectedDataObjs )
                            affectedDataObjs{ index }.updateImplementationStatus(  );
                        end

                        for index = 1:length( affectedDataObjsForStats )
                            affectedDataObjsForStats{ index }.updateImplementationStatusForStatsOnly(  );
                        end
                    end

                    if affectVer && mgr.isVerificationStatusEnabled( allViewers )
                        for index = 1:length( affectedDataObjs )
                            affectedDataObjs{ index }.updateVerificationStatus(  );
                        end

                        for index = 1:length( affectedDataObjsForStats )
                            affectedDataObjsForStats{ index }.updateVerificationStatusForStatsOnly(  );
                        end
                    end
                    localDataRefreshed = true;

                case 'Requirement Shifted'





                    req = eventInfo.eventObj.req;
                    offset = eventInfo.eventObj.offset;
                    dasObj = req.getDasObject(  );

                    parent = dasObj.parent;
                    currentIndex = parent.findObjectIndex( dasObj );
                    parent.swapChildrenObject( currentIndex, currentIndex + offset );
                    if ~isempty( this.view.getCurrentView )
                        objToBeSelected = dasObj;
                    end






                    localDataRefreshed = true;

                case 'Requirement AddedAfter'
                    req = eventInfo.eventObj;
                    if isempty( req.parent )
                        parentData = req.getReqSet;
                    else
                        parentData = req.parent;
                    end
                    parentDas = parentData.getDasObject(  );
                    reqDasObj = slreq.das.Requirement(  );
                    reqDasObj.postConstructorProcess( req, parentDas, this.view, this.reqDataChangeListener );
                    eventDas = req.getDasObject(  );
                    assert( ~isempty( eventDas ), 'das cannot be empty for insertion' );
                    parentDas.insertChildObject( reqDasObj );

                    mgr = slreq.app.MainManager.getInstance;
                    allViewers = mgr.getAllViewers;



                    localDataRefreshed = true;
                    if mgr.isImplementationStatusEnabled( allViewers )
                        req.updateImplementationStatus(  );
                    end

                    if mgr.isVerificationStatusEnabled( allViewers )
                        req.updateVerificationStatus(  );
                    end

                case 'Requirements Changed'













                    localDataRefreshed = true;
                case 'CustomAttributeModified'

                    modInfo = eventInfo.eventObj;
                    if ~strcmp( modInfo.prevName, modInfo.newName )

                        if ~isempty( this.view.requirementsEditor )
                            this.view.requirementsEditor.updateColumnOnCustomAttributeNameChange( modInfo.prevName, modInfo.newName );
                        end
                        if ~isempty( this.view.spreadsheetManager )
                            this.view.spreadsheetManager.updateColumnOnCustomAttributeNameChange( modInfo.prevName, modInfo.newName );
                        end
                    end



                    localDataRefreshed = true;
                case 'CustomAttributeRemoved'

                    modInfo = eventInfo.eventObj;
                    if ~isempty( this.view.requirementsEditor )
                        this.view.requirementsEditor.updateColumnOnCustomAttributeRemoval( modInfo.removedName );
                    end
                    if ~isempty( this.view.spreadsheetManager )
                        this.view.spreadsheetManager.updateColumnOnCustomAttributeRemoval( modInfo.removedName );
                    end



                    localDataRefreshed = true;
                case 'Pre Requirement Deleted'


                    return ;

                otherwise
                    error( 'Unsupported event type %s', eventInfo.type );
            end
            if doNotify
                this.notifyViewChange( localDataRefreshed );
            end

            if ~isempty( objToBeSelected )


                this.view.getCurrentView.setSelectedObject( objToBeSelected )
            end
        end


        function icon = getDisplayIcon( this )%#ok<MANU>
            icon = slreq.gui.IconRegistry.instance.folder;
        end

        function label = getDisplayLabel( this )%#ok<MANU>
            label = 'Requirement Set files';
        end

        function refreshImplementationStatus( this, reqSets )

            mgr = slreq.app.MainManager.getInstance;

            if nargin < 2
                reqSets = this.children;
            end
            for n = 1:length( reqSets )
                if mgr.isAnalysisDeferred
                    mgr.showDeferredAnalysisNotification(  );
                    return ;
                end

                cReqSet = reqSets( n );
                if isa( cReqSet, 'slreq.das.RequirementSet' )
                    cReqSet = reqSets( n ).dataModelObj;
                end
                cReqSet.updateImplementationStatus(  );
            end
        end

        function refreshVerificationStatus( this, reqSets )

            mgr = slreq.app.MainManager.getInstance;

            if nargin < 2
                reqSets = this.children;
            end
            for n = 1:length( reqSets )
                if mgr.isAnalysisDeferred
                    mgr.showDeferredAnalysisNotification(  );
                    return ;
                end

                cReqSet = reqSets( n );
                if isa( cReqSet, 'slreq.das.RequirementSet' )
                    cReqSet = reqSets( n ).dataModelObj;
                end

                cReqSet.updateVerificationStatus(  );
            end
        end

        function out = getAvailableAttributes( this )



            builtInAttr = slreq.utils.getBuiltinAttributeList( 'req' );

            customAttr = slreq.utils.getCustomAttributeList( this.children );
            out = [ builtInAttr, customAttr ];
        end

        function dlgstruct = getDialogSchema( this )
            dlgstruct = slreq.gui.OnRampDialog( this );
        end

        function count = ensureDasTrees( this )


            count = 0;
            dataReqSets = this.reqData.getLoadedReqSets(  );
            for i = 1:numel( dataReqSets )
                dataReqSet = dataReqSets( i );
                if this.reqData.isReservedReqSetName( dataReqSet.name )
                    continue ;
                elseif isempty( dataReqSet.getDasObject(  ) )
                    eventData = struct( 'type', 'ReqSet Loaded', 'eventObj', dataReqSet );
                    this.onReqDataChange( '', eventData );
                    count = count + 1;
                end
            end
        end

        function stopObj = pauseUpdatesFromSTMEvents( this )


            stopObj = [  ];




            for i = 1:length( this.otherArtifactChangeListerners )
                l = this.otherArtifactChangeListerners{ i };
                if strcmp( l.EventName, 'SimulationCompleted' ) && any( isa( l.Source, 'sltest.internal.Events' ) )
                    setListenerEnabled( l, false );
                    stopObj = onCleanup( @(  )setListenerEnabled( l, true ) );
                    return ;
                end
            end

            function setListenerEnabled( listenerObj, val )
                listenerObj.Enabled = val;
            end
        end

        function dasReqSet = addSLReqSet( this, slReqSet )
            dasReqSet = slreq.das.RequirementSet( slReqSet, this,  ...
                this.view,  ...
                this.reqDataChangeListener );
            this.addChildObject( dasReqSet );
        end
    end

    methods ( Access = private )

        function syncWithRepository( this )
            this.children = slreq.das.RequirementSet.empty(  );

            reqSets = this.reqData.getLoadedReqSets(  );
            for i = 1:numel( reqSets )
                if strcmp( reqSets( i ).name, 'default' )


                else
                    this.addChildObject( slreq.das.RequirementSet( reqSets( i ),  ...
                        this, this.view, this.reqDataChangeListener ) );
                end
            end
        end

        function added = recAddDasObjctsIfNeeded( this, parentDas, reqDataObj )
            added = slreq.das.Requirement.empty(  );

            reqDasObj = reqDataObj.getDasObject(  );
            if isempty( reqDasObj )
                reqDasObj = slreq.das.Requirement(  );
                reqDasObj.postConstructorProcess( reqDataObj, parentDas, this.view, this.reqDataChangeListener );
                idx = parentDas.dataModelObj.indexOf( reqDataObj );
                parentDas.insertChildObjectAt( reqDasObj, idx );
                added( end  + 1 ) = reqDasObj;
            end




            objChildren = reqDataObj.children;
            for n = 1:length( objChildren )
                added = [ added, this.recAddDasObjctsIfNeeded( reqDasObj, objChildren( n ) ) ];%#ok<AGROW>
            end
        end
    end
end



function [ affectImp, affectVer, affectedDataObjs, affectedDataObjsForStats ] = checkChangeImpectRollupStatus(  ...
    movedDataReq, eventInfo, affectImp, affectVer, affectedDataObjs, affectedDataObjsForStats )
[ newAffectImp, newAffectVer, newAffectedDataObjs, newAffectedDataObjsForStats ] = movedDataReq.doesChangeImpactRollupStatusWhenMoving( eventInfo );
affectImp = affectImp || newAffectImp;
affectVer = affectVer || newAffectVer;

for i = 1:numel( newAffectedDataObjsForStats )
    affected = newAffectedDataObjsForStats{ i };

    if ~any( cellfun( @( x )strcmp( x.getUuid(  ), affected.getUuid(  ) ), affectedDataObjsForStats ) )
        affectedDataObjsForStats{ end  + 1 } = affected;%#ok<AGROW>
    end
end

for i = 1:numel( newAffectedDataObjs )
    affected = newAffectedDataObjs{ i };
    if ~any( cellfun( @( x )strcmp( x.getUuid(  ), affected.getUuid(  ) ), affectedDataObjs ) )
        affectedDataObjs{ end  + 1 } = affected;%#ok<AGROW>
    end
end
end
