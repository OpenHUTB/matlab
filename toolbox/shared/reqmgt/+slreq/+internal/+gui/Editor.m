classdef Editor < handle





    properties ( Access = private )
        studioWindow;
        closeListener;
        activateListener;
        treeComp;
        spreadsheetLoading;
        propsComp;
        notificationComp;
        note;
        currentSelectedObj;
        isSleeping = false;
    end

    properties ( Access = {  ...
            ?slreq.app.CallbackHandler,  ...
            ?slreq.das.ReqRoot,  ...
            ?slreq.gui.Toolbar,  ...
            ?slrequdd.viewmanager,  ...
            ?slreq.gui.ColumnSelector,  ...
            ?slreq.das.ReqLinkBase,  ...
            ?slreq.das.RollupStatus,  ...
            ?slreq.app.MainManager,  ...
            ?slreq.gui.LinkDetails,  ...
            ?slreq.gui.getContextMenuItems,  ...
            ?slreq.app.ChangeTracker,  ...
            ?slreq.app.ViewSettingsManager,  ...
            ?slreq.app.ViewManager,  ...
            ?slreq.gui.View,  ...
            ?slreq.internal.gui.ViewForDDGDlg } )

        appmgr;
        isReqView = true;
        reqColumns = slreq.app.MainManager.DefaultRequirementColumns;
        linkColumns = slreq.app.MainManager.DefaultLinkColumns;
        Buttons;
        Menus;
        ShowSuggestion = false;
        SuggestionReason = '';
        SuggestionId = '';
        reqSortInfo = struct( 'Col', '', 'Order', false );
        linkSortInfo = struct( 'Col', '', 'Order', false );
        reqColumnWidths;
        linkColumnWidths;

        displayComment = true;

        displayImplementationStatus = false;

        displayVerificationStatus = false



        displayChangeInformation = false;
        displayCodeTraceability = false;


        selectionStatus = slreq.gui.SelectionStatus.None;
    end

    properties ( Dependent )
        Columns;
    end

    properties ( Constant )

        sourceID = 'standalone';
        ConfigPath = fullfile( matlabroot, 'toolbox', 'shared', 'reqmgt', 'editorPlugin' );
    end

    methods ( Access = public )
        function this = Editor( reqappmgr )

            this.appmgr = reqappmgr;
            this.currentSelectedObj = slreq.das.ReqLinkBase.empty(  );
            this.note = slreq.internal.gui.EditorBanner;
            this.spreadsheetLoading = 0;
            constructUI( this );
        end

        function out = getViewSettingID( this )
            out = this.sourceID;
        end

        function tf = isVisible( this )
            tf = false;

            studio = this.getStudio;
            if ~isempty( studio )
                tf = studio.isStudioVisible;
            end
        end

        function st = getStudio( this )
            st = [  ];
            if ~isempty( this.studioWindow ) && isvalid( this.studioWindow )
                st = this.studioWindow.getStudio(  );
            end
        end

        function tf = isReqViewActive( this )
            tf = this.isReqView;
        end

        function delete( this )
            if ~isempty( this.studioWindow ) && isvalid( this.studioWindow )


                delete( this.closeListener );
                this.close(  );
            end
        end

        function show( this )
            this.studioWindow.show;
        end

        function open( this )



            if isempty( this.studioWindow ) || ~isvalid( this.treeComp )
                constructUI( this );
                this.appmgr.updateRollupStatusAndChangeInformationIfNeeded( { this } );
            end
            this.studioWindow.show;
            this.update(  );


            this.appmgr.setLastOperatedView( this );
        end

        function simulateUIClose( this )

            this.studioWindow.close(  );
        end

        function close( this, evt )%#ok<INUSD>






            this.spreadsheetLoading =  - 1000;
            if ~isempty( this.studioWindow )
                this.appmgr.getViewSettingsManager.saveViewSettingsFor( this );

                if nargin < 2
                    if ~isempty( this.studioWindow ) && isvalid( this.studioWindow )
                        this.studioWindow.close(  );
                    end






                else

                    for i = length( this.appmgr.reqRoot.children ): - 1:1
                        eachReqSet = this.appmgr.reqRoot.children( i );
                        if ~isempty( eachReqSet.dataModelObj.parent )
                            continue ;
                        end
                        if eachReqSet.Dirty ...
                                && ~this.appmgr.spreadsheetManager.isOpenedInAnySpreadSheet( eachReqSet )
                            response = questdlg( {  ...
                                getString( message( 'Slvnv:slreq:UiClosingReqSetUnsaved', eachReqSet.Name ) ),  ...
                                getString( message( 'Slvnv:slreq:UiClosingReqSetOptions', [ eachReqSet.Name, '.slreqx' ] ) ) },  ...
                                getString( message( 'Slvnv:slreq:UnsavedRequirementsData' ) ),  ...
                                getString( message( 'Slvnv:slreq:UiClosingSaveNow' ) ),  ...
                                getString( message( 'Slvnv:slreq:UiClosingDiscard' ) ),  ...
                                getString( message( 'Slvnv:slreq:UiClosingAskMeLater' ) ),  ...
                                getString( message( 'Slvnv:slreq:UiClosingSaveNow' ) ) );
                            if ~isempty( response )
                                if strcmp( response, getString( message( 'Slvnv:slreq:UiClosingSaveNow' ) ) )
                                    eachReqSet.saveRequirementSet(  );
                                elseif strcmp( response, getString( message( 'Slvnv:slreq:UiClosingDiscard' ) ) )
                                    eachReqSet.discard(  );
                                end
                            end
                        end
                    end
                end
            end
            if this.appmgr.getLastOperatedView == this
                this.appmgr.setLastOperatedView( [  ] );
            end
            if this.appmgr.getCurrentObject == this.currentSelectedObj
                this.appmgr.setSelectedObject( [  ] );
            end
            this.note.reasonStack = {  };
            this.note.idStack = {  };
        end

        function tf = enableClearIssues( this )
            tf = false;
            if isempty( this.currentSelectedObj ) ...
                    || isa( this.currentSelectedObj( 1 ), 'slreq.das.Requirement' ) ...
                    || isa( this.currentSelectedObj( 1 ), 'slreq.das.RequirementSet' )
                return ;
            end

            for n = 1:length( this.currentSelectedObj )
                if isa( this.currentSelectedObj( n ), 'slreq.das.LinkSet' )
                    if this.currentSelectedObj( n ).NumberOfChangedSource > 0 ...
                            || this.currentSelectedObj( 1 ).NumberOfChangedDestination > 0
                        tf = true;
                        break ;
                    end
                else

                    if this.currentSelectedObj( n ).hasChangedIssue
                        tf = true;
                        break ;
                    end
                end
            end
        end

        function tf = isNotificationVisible( this )
            tf = ~isempty( this.notificationComp ) && this.notificationComp.isVisible;
        end

        function dismissNotificationBanner( this, suggestionId )
            arguments
                this
                suggestionId = this.note.suggestionId
            end
            if ~this.isNotificationVisible
                return ;
            end
            this.ShowSuggestion = false;
            this.studioWindow.hideComponent( this.notificationComp );



            if strcmp( suggestionId, 'Slvnv:slreq:NoLinkDependencies' ) ...
                    || strcmp( suggestionId, 'Slvnv:slreq:NoLinkDependenciesMLPath' )
                slreq.linkmgr.LinkSetManager.onBannerLinkClick( 'clear' );
            end


            if ~isempty( this.note.reasonStack )
                this.ShowSuggestion = true;
                this.SuggestionId = this.note.idStack{ 1 };
                this.SuggestionReason = this.note.reasonStack{ 1 };
                this.showNotification(  )

                this.note.reasonStack( 1 ) = [  ];
                this.note.idStack( 1 ) = [  ];
            end
        end

        function showNotficationInMessageBanner( this, notificationId, msgId, varargin )
            if this.isNotificationVisible && ~isempty( this.note.suggestionreason ) && ~isempty( this.note.suggestionId )
                this.note.reasonStack{ end  + 1 } = this.note.suggestionreason;
                this.note.idStack{ end  + 1 } = this.note.suggestionId;
            end

            this.ShowSuggestion = true;
            this.SuggestionId = notificationId;
            this.SuggestionReason = getString( message( msgId, varargin{ : } ) );
            this.showNotification(  )

        end

        function removeNotificationBanner( this, notificationId )
            this.dismissNotificationBanner( notificationId );
        end


        function showNotification( this )
            if this.ShowSuggestion
                this.note.suggestionreason = this.SuggestionReason;
                this.note.suggestionId = this.SuggestionId;
            else
                lsm = slreq.linkmgr.LinkSetManager.getInstance;


                if lsm.hasPendingBannerMessage( this )
                    this.ShowSuggestion = true;
                    bannerMessages = lsm.getPendingBannerMessage( this );


                    this.note.suggestionId = bannerMessages{ 1 }.Identifier;

                    this.note.suggestionreason = bannerMessages{ 1 }.getString(  );
                end
            end
            if this.ShowSuggestion && ~isempty( this.studioWindow ) && isvalid( this.studioWindow )



                dlg = this.getBannerDlg(  );
                for n = 1:length( dlg )
                    dlg( n ).refresh;
                end
                this.studioWindow.showComponent( this.notificationComp );
            end
            this.ShowSuggestion = false;
            this.SuggestionReason = '';
            this.SuggestionId = '';
        end

        function showFilter( this )
            this.treeComp.toggleFilter(  );
        end

        function update( this )
            if ~isempty( this.propsComp ) && ~isempty( this.currentSelectedObj ) && all( isvalid( this.currentSelectedObj ) )
                dlgs = this.getDialog(  );
                slreq.internal.gui.ViewForDDGDlg.refreshDDGDialogs( dlgs );

            end
            this.updateToolstrip(  );
        end

        function refreshUI( this, obj )
            if isempty( this.treeComp )
                return ;
            end

            if isempty( this.currentSelectedObj )
                this.setSelectedObject( [  ] );
            end
            if nargin > 1
                this.treeComp.update( { obj } );
            else
                this.spreadsheetLoading = this.spreadsheetLoading + 1;
                this.treeComp.update(  );
            end
        end

        function c = disableUIwithCleanup( this )


        end


        function updateToolbar( this )
        end

        function updateToolstrip( this )
            if isempty( this.studioWindow )
                return ;
            end

            if ( ~isempty( this.currentSelectedObj ) )


                if ~( all( isvalid( this.currentSelectedObj ) ) )

                    return ;
                end
                if this.selectionStatus == slreq.gui.SelectionStatus.None

                    return
                end
            else
                this.selectionStatus = slreq.gui.SelectionStatus.None;
            end

            typeChain = { 'base' };
            if reqmgt( 'rmiFeature', 'FilteredView' )
                typeChain{ end  + 1 } = 'productionWidgets';
                typeChain{ end  + 1 } = 'filteredViewWidgets';
            else
                typeChain{ end  + 1 } = 'productionWidgets';
            end
            if dig.isProductInstalled( 'Embedded Coder' )
                typeChain{ end  + 1 } = 'codeTraceWidget';
            end
            if ( dig.isProductInstalled( 'Simulink Check' ) )
                typeChain{ end  + 1 } = 'enableModelTestingDB';
            else
                typeChain{ end  + 1 } = 'disableModelTestingDB';
            end

            if this.isReqView
                typeChain{ end  + 1 } = 'noSelectionReqView';
            else
                typeChain{ end  + 1 } = 'noSelectionLinkView';
            end

            slreq.utils.assertValid( this.currentSelectedObj );
            [ isInternalReq, isExternal, isJustification ] =  ...
                slreq.app.CallbackHandler.getDasRequirementType( this.currentSelectedObj );
            if ~isempty( this.currentSelectedObj )
                currentObj = this.currentSelectedObj( 1 );
            else
                currentObj = slreq.das.BaseObject.empty(  );
            end
            currentObjects = this.getCurrentSelection;
            delReqLinkEnabled =  ...
                isa( currentObj, 'slreq.das.Link' ) ...
                || isInternalReq ...
                || isJustification ...
                || ( isExternal && currentObj.dataModelObj.isImportRootItem(  ) );

            clearIssuesEnabled = this.enableClearIssues(  );

            isMultiSelection = numel( currentObjects ) > 1;
            if isMultiSelection
                isSiblings = currentObjects.isSiblings(  );
            else
                isSiblings = true;
            end
            enableCut = isSiblings && ( isInternalReq || isJustification );
            if enableCut
                typeChain{ end  + 1 } = 'enableCut';
            else
                typeChain{ end  + 1 } = 'disableCut';
            end
            enableCopy = isSiblings && isa( currentObj, 'slreq.das.Requirement' );
            if enableCopy
                typeChain{ end  + 1 } = 'enableCopy';
            else
                typeChain{ end  + 1 } = 'disableCopy';
            end
            enablePaste = slreq.app.CallbackHandler.isPasteAllowed( currentObjects );
            if enablePaste
                typeChain{ end  + 1 } = 'enablePaste';
            else
                typeChain{ end  + 1 } = 'disablePaste';
            end

            function addLinkTypeChain(  )
                typeChain{ end  + 1 } = 'enableLink';
            end

            function addSingleReqSelectionTypeChain(  )
                addLinkTypeChain(  );
                dataModelObj = this.currentSelectedObj.dataModelObj;
                isReqSetSlxBacked = false;
                if isa( dataModelObj, 'slreq.data.Requirement' )
                    isReqSetSlxBacked = ~isempty( dataModelObj.getReqSet(  ).parent );
                end
                if this.currentSelectedObj.isJustification
                    typeChain{ end  + 1 } = 'justificationSelected';
                elseif isReqSetSlxBacked
                    typeChain{ end  + 1 } = 'sfBackedReqSelected';
                elseif isExternal
                    typeChain{ end  + 1 } = 'externalReqSelected';
                    if isa( this.currentSelectedObj.parent, 'slreq.das.RequirementSet' )
                        typeChain{ end  + 1 } = 'importNodeSelected';
                    end
                else
                    typeChain{ end  + 1 } = 'reqSelected';
                end


                if ~this.currentSelectedObj.canPromote( this )
                    if this.isSortDisabled
                        typeChain{ end  + 1 } = 'disablePromote';
                    else
                        typeChain{ end  + 1 } = 'disablePromoteForSort';
                    end
                end
                if ~this.currentSelectedObj.canDemote( this )
                    if this.isSortDisabled
                        typeChain{ end  + 1 } = 'disableDemote';
                    else
                        typeChain{ end  + 1 } = 'disableDemoteForSort';
                    end
                end
                if ~delReqLinkEnabled
                    typeChain{ end  + 1 } = 'disableReqDelete';
                end

                enableAddJustification = false;
                parentDas = this.currentSelectedObj.parent;
                if isa( parentDas, 'slreq.das.Requirement' ) && parentDas.isJustification
                    enableAddJustification = true;
                elseif isa( parentDas, 'slreq.das.RequirementSet' ) && isJustification
                    enableAddJustification = true;
                end
                if enableAddJustification
                    typeChain{ end  + 1 } = 'enableAddJustification';
                end

                typeChain{ end  + 1 } = 'enableSaveSelectedReqSet';
                typeChain{ end  + 1 } = 'enableExportToReqIF';
                typeChain{ end  + 1 } = 'enableExportToPrevious';
            end

            switch this.selectionStatus
                case slreq.gui.SelectionStatus.None

                case slreq.gui.SelectionStatus.Single
                    switch class( this.currentSelectedObj )
                        case 'slreq.das.Requirement'
                            addSingleReqSelectionTypeChain(  );
                        case 'slreq.das.Link'
                            typeChain{ end  + 1 } = 'linkSelected';
                            if ~delReqLinkEnabled
                                typeChain{ end  + 1 } = 'disableLinkDelete';
                            end
                            if clearIssuesEnabled
                                typeChain{ end  + 1 } = 'enableClearIssues';
                            else
                                typeChain{ end  + 1 } = 'disableClearIssues';
                            end
                        case 'slreq.das.RequirementSet'
                            if isempty( this.currentSelectedObj.dataModelObj.parent )
                                typeChain{ end  + 1 } = 'reqSetSelected';
                            else
                                typeChain{ end  + 1 } = 'slxreqSetSelected';
                            end
                            typeChain{ end  + 1 } = 'enableSaveSelectedReqSet';
                            typeChain{ end  + 1 } = 'enableExportToReqIF';
                            typeChain{ end  + 1 } = 'enableExportToPrevious';

                            typeChain{ end  + 1 } = 'enableAddJustification';
                        case 'slreq.das.LinkSet'
                            typeChain{ end  + 1 } = 'linkSetSelected';
                            if clearIssuesEnabled
                                typeChain{ end  + 1 } = 'enableClearIssues';
                            else
                                typeChain{ end  + 1 } = 'disableClearIssues';
                            end
                    end
                case slreq.gui.SelectionStatus.MultiSiblings
                    firstObj = this.currentSelectedObj( 1 );
                    switch class( firstObj )
                        case 'slreq.das.Requirement'
                            typeChain{ end  + 1 } = 'multiReqsSelected';
                            if ~delReqLinkEnabled || firstObj.RequirementSet.isBackedBySlx(  )
                                typeChain{ end  + 1 } = 'disableReqDelete';
                            end
                            addLinkTypeChain(  );
                        case 'slreq.das.Link'
                            typeChain{ end  + 1 } = 'multiLinksSelected';
                            if ~delReqLinkEnabled
                                typeChain{ end  + 1 } = 'disableLinkDelete';
                            end
                            if clearIssuesEnabled
                                typeChain{ end  + 1 } = 'enableClearIssues';
                            else
                                typeChain{ end  + 1 } = 'disableClearIssues';
                            end
                        case 'slreq.das.RequirementSet'
                            typeChain{ end  + 1 } = 'enableSaveSelectedReqSet';
                            typeChain{ end  + 1 } = 'multiReqSetsSelected';
                        case 'slreq.das.LinkSet'
                            typeChain{ end  + 1 } = 'multiLinkSetsSelected';
                            if clearIssuesEnabled
                                typeChain{ end  + 1 } = 'enableClearIssues';
                            else
                                typeChain{ end  + 1 } = 'disableClearIssues';
                            end
                    end
                case slreq.gui.SelectionStatus.MultiNonSiblings
                    switch class( this.currentSelectedObj( 1 ) )
                        case 'slreq.das.Requirement'
                            typeChain{ end  + 1 } = 'multiReqsSelected';
                            typeChain{ end  + 1 } = 'disableReqDelete';
                            addLinkTypeChain(  );
                        case 'slreq.das.Link'
                            typeChain{ end  + 1 } = 'multiLinksSelected';
                        case 'slreq.das.RequirementSet'
                            typeChain{ end  + 1 } = 'multiReqSetsSelected';
                        case 'slreq.das.LinkSet'
                            typeChain{ end  + 1 } = 'multiLinkSetsSelected';
                    end
                case slreq.gui.SelectionStatus.Heterogeneous
                    switch class( this.currentSelectedObj( 1 ) )
                        case 'slreq.das.Requirement'
                            typeChain{ end  + 1 } = 'multiReqsSelected';
                            addLinkTypeChain(  );
                        case 'slreq.das.Link'
                            typeChain{ end  + 1 } = 'multiLinksSelected';
                        case 'slreq.das.RequirementSet'
                            typeChain{ end  + 1 } = 'multiReqSetsSelected';
                        case 'slreq.das.LinkSet'
                            typeChain{ end  + 1 } = 'multiLinkSetsSelected';
                    end
            end


            if this.displayImplementationStatus
                typeChain{ end  + 1 } = 'implementationOn';
            else
                typeChain{ end  + 1 } = 'implementationOff';
            end
            if this.displayVerificationStatus
                typeChain{ end  + 1 } = 'verificationOn';
            else
                typeChain{ end  + 1 } = 'verificationOff';
            end
            if this.displayChangeInformation
                typeChain{ end  + 1 } = 'changeInfoOn';
            else
                typeChain{ end  + 1 } = 'changeInfoOff';
            end

            if this.displayComment
                typeChain{ end  + 1 } = 'commentsOn';
            else
                typeChain{ end  + 1 } = 'commentsOff';
            end
            if this.displayCodeTraceability
                typeChain{ end  + 1 } = 'codeTraceabilityOn';
            else
                typeChain{ end  + 1 } = 'codeTraceabilityOff';
            end


            view = this.appmgr.viewManager.getCurrentView(  );
            if view.isHierarchy
                typeChain{ end  + 1 } = 'filterViewNotFlat';
            else
                typeChain{ end  + 1 } = 'filterViewFlat';
            end
            if view.isFilteredOnly
                typeChain{ end  + 1 } = 'filteredOnly';
            else
                typeChain{ end  + 1 } = 'filteredFull';
            end


            ctx = this.studioWindow.getContextObject(  );
            ctx.TypeChain = typeChain;
        end

        function setUIBlock( this, block )
            if ~isempty( this.treeComp ) && isvalid( this.treeComp )
                if block
                    this.studioWindow.disable;
                else
                    this.studioWindow.enable;
                end
            end
        end

        function setUISleep( this, toSleep )


            ed = DAStudio.EventDispatcher;
            if ~this.isSleeping && toSleep
                ed.broadcastEvent( 'MESleepEvent' );
                this.isSleeping = true;
            elseif this.isSleeping && ~toSleep
                ed.broadcastEvent( 'MEWakeEvent' );
                this.isSleeping = false;
            else


            end
        end

        function menu = createContextMenu( this, items )

            actionManager = DAStudio.ActionManager;
            menu = actionManager.createPopupMenu( this.studioWindow );
            numGroups = numel( items );
            acceptedFields = { 'name', 'tag', 'accel', 'icon', 'enabled', 'callback', 'toggleaction', 'on', 'visible' };
            for i = 1:numGroups
                numItems = numel( items{ i } );
                for j = 1:numItems
                    thisItem = items{ i }( j );
                    if isfield( thisItem, 'items' )
                        if ~isempty( thisItem.items )

                            sub = actionManager.createPopupMenu( this.studioWindow );
                            for k = 1:length( thisItem.items )
                                sub = addItem( sub, actionManager, this, thisItem.items( k ), acceptedFields );
                            end
                            menu.addSubMenu( sub, thisItem.name );

                        else
                            menu = addItem( menu, actionManager, this, thisItem, acceptedFields );
                        end
                    else
                        menu = addItem( menu, actionManager, this, thisItem, acceptedFields );
                    end
                end
                if i < numGroups
                    menu.addSeparator(  );
                end
            end

            function menu = addItem( menu, actionManager, this, thisMenuItem, acceptedFields )
                menuTags2Remember = { 'ReqLink:BaseShowComment',  ...
                    'ReqLink:BaseShowImplementationStatus',  ...
                    'ReqLink:BaseShowVerificationStatus',  ...
                    'ReqLink:BaseShowChangeInformation' };
                action = actionManager.createAction( this.studioWindow );
                for kk = 1:length( acceptedFields )
                    thisField = acceptedFields{ kk };
                    if isfield( thisMenuItem, thisField )
                        if strcmp( thisField, 'name' )
                            action.Text = thisMenuItem.( thisField );
                        else
                            action.( thisField ) = thisMenuItem.( thisField );
                        end
                    end
                end

                if ismember( thisMenuItem.tag, menuTags2Remember )
                    parsing = strsplit( thisMenuItem.tag, ':' );
                    this.Menus.( parsing{ 2 } ) = action;
                end
                menu.addMenuItem( action );
            end
        end

        function obj = getCurrentSelection( this )
            obj = this.currentSelectedObj;



            if numel( obj ) > 1 && isa( obj, 'slreq.das.Requirement' )

                obj = slreq.das.Requirement.sortByIndex( obj );
            end
        end

        function setSelectedObject( this, thisObj )
            if isempty( this.treeComp )





                return
            end

            if ~isempty( thisObj )
                if isa( thisObj, 'slreq.das.Requirement' ) ...
                        || isa( thisObj, 'slreq.das.RequirementSet' )
                    if ~this.isReqView
                        this.switchView;
                    end
                elseif isa( thisObj, 'slreq.das.Link' ) ...
                        || isa( thisObj, 'slreq.das.LinkSet' )
                    if this.isReqView
                        this.switchView;
                    end
                end
            end

            this.treeComp.view( thisObj );


            this.currentSelectedObj = thisObj;

            this.appmgr.setSelectedObject( this.currentSelectedObj );
        end

        function stat = getSelectionStatus( this )
            stat = this.selectionStatus;
        end

        function r = getRoot( this )
            if this.isReqView
                r = this.appmgr.reqRoot;
            else
                r = this.appmgr.linkRoot;
            end
        end

        function clearCurrentObj( this, clearObj, forceClear )

            if nargin < 3
                forceClear = false;
            end




            if forceClear ...
                    || ( isempty( this.currentSelectedObj ) && isempty( clearObj ) ) ...
                    || any( arrayfun( @( e )isequal( e, clearObj ), this.currentSelectedObj ) )
                this.currentSelectedObj = slreq.das.ReqLinkBase.empty(  );
                this.selectionStatus = slreq.gui.SelectionStatus.None;
            end
        end

        function toggleOnImplementationStatus( this )
            if ~contains( this.reqColumns, 'Implemented' )
                this.reqColumns = [ this.reqColumns, { 'Implemented' } ];
                if this.isReqViewActive
                    this.Columns = this.reqColumns;
                end
            end
            this.appmgr.reqRoot.refreshImplementationStatus(  );
            this.displayImplementationStatus = true;

            this.update(  );
        end


        function toggleOffImplementationStatus( this )
            this.displayImplementationStatus = false;

            newReqCols = this.reqColumns;
            idx = strcmp( newReqCols, 'Implemented' );
            newReqCols( idx ) = [  ];
            this.reqColumns = newReqCols;
            if this.isReqViewActive
                this.Columns = this.reqColumns;
            end
            this.update(  );
        end


        function toggleOnVerificationStatus( this )
            if ~contains( this.reqColumns, 'Verified' )
                this.reqColumns = [ this.reqColumns, { 'Verified' } ];
                if this.isReqViewActive
                    this.Columns = this.reqColumns;
                end
            end
            this.appmgr.reqRoot.refreshVerificationStatus(  );
            this.displayVerificationStatus = true;

            this.update(  );
        end


        function toggleOffVerificationStatus( this )
            this.displayVerificationStatus = false;

            newReqCols = this.reqColumns;
            idx = strcmp( newReqCols, 'Verified' );
            newReqCols( idx ) = [  ];
            this.reqColumns = newReqCols;
            if this.isReqViewActive
                this.Columns = this.reqColumns;
            end
            this.update(  );
        end





        function toggleOnChangeInformation( this )
            this.displayChangeInformation = true;
            this.appmgr.showChangeInformation( this );
            this.update(  );

            if this.isReqView
                id = 'Slvnv:slreq:ChangeInfoSuggestion';
                this.showNotficationInMessageBanner( id, id );

                this.updateToolstrip(  );
            end




            mgr = slreq.app.MainManager.getInstance;
            mgr.refreshUI(  );
        end


        function toggleOffChangeInformation( this )
            if ~( this.displayImplementationStatus || this.displayVerificationStatus )
                this.dismissNotificationBanner(  );
            end
            this.displayChangeInformation = false;
            this.appmgr.hideChangeInformation( this );
            this.update(  );
            this.updateToolstrip(  );



            mgr = slreq.app.MainManager.getInstance;
            mgr.refreshUI(  );
        end

        function updateColumnOnCustomAttributeNameChange( this, origName, newName )

            reqData = slreq.data.ReqData.getInstance(  );
            reqSetsWithThisAttr = reqData.getReqSetsThatHaveCustomAttribute( origName );
            if ~isempty( reqSetsWithThisAttr )


                return ;
            end
            matchIdx = strcmp( this.reqColumns, origName );
            if any( matchIdx )


                this.reqColumns{ matchIdx } = newName;
                this.Columns = this.reqColumns;
            end
        end

        function updateColumnOnCustomAttributeRemoval( this, attrName )

            reqData = slreq.data.ReqData.getInstance(  );
            reqSetsWithThisAttr = reqData.getReqSetsThatHaveCustomAttribute( attrName );
            if ~isempty( reqSetsWithThisAttr )


                return ;
            end
            matchIdx = strcmp( this.reqColumns, attrName );
            if any( matchIdx )


                this.reqColumns( matchIdx ) = [  ];
                this.Columns = this.reqColumns;
            end
        end

        function resetViewSettings( this )
            this.reqColumns = slreq.app.MainManager.DefaultRequirementColumns;
            this.linkColumns = slreq.app.MainManager.DefaultLinkColumns;
            this.displayChangeInformation = slreq.app.MainManager.DefaultDisplayChangeInformation;
            this.reqSortInfo = struct( 'Col', '', 'Order', false );
            this.linkSortInfo = struct( 'Col', '', 'Order', false );
            if ~isempty( this.studioWindow )
                this.updateSorting( 'clear' );
                if ~this.isReqView
                    this.switchView;
                end
                this.Columns = this.Columns;
            end
        end

        function tf = isSortDisabled( this )
            if this.isReqView
                sortInfo = this.reqSortInfo;
            else
                sortInfo = this.linkSortInfo;
            end

            tf = isempty( sortInfo.Col );
        end

        function expand( this, currentObj )
            this.treeComp.expand( currentObj, false );
        end

        function expandAll( this, currentObj )
            this.treeComp.expand( currentObj, true );
        end

        function collapseAll( this, currentObj )


            this.treeComp.collapse( currentObj, true );
        end

        function restoreViewSettings( this )

            viewSettings = this.appmgr.getViewSettingsManager.getViewSettings( this );
            if isempty( viewSettings )
                this.treeComp.clearSort(  );
                return ;
            end
            this.reqColumns = viewSettings.reqColumns;
            this.linkColumns = viewSettings.linkColumns;
            if isfield( viewSettings, 'reqSortInfo' )
                this.reqSortInfo = viewSettings.reqSortInfo;
                this.linkSortInfo = viewSettings.linkSortInfo;
            end

            if viewSettings.isReqView
                currentSortInfo = this.reqSortInfo;
            else
                currentSortInfo = this.linkSortInfo;
            end

            if this.isReqView ~= viewSettings.isReqView
                this.switchView(  );
            end

            if isfield( viewSettings, 'displayChangeInformation' )
                this.displayChangeInformation = viewSettings.displayChangeInformation;
            end

            hasJSONColumSetting = false;
            if isfield( viewSettings, 'reqColumnWidths' ) ...
                    && ~isempty( viewSettings.reqColumnWidths )
                hasJSONColumSetting = true;
                this.reqColumnWidths = viewSettings.reqColumnWidths;
            end

            if isfield( viewSettings, 'linkColumnWidths' ) ...
                    && ~isempty( viewSettings.linkColumnWidths )
                hasJSONColumSetting = true;
                this.linkColumnWidths = viewSettings.linkColumnWidths;
            end

            this.treeComp.setColumns( this.Columns, currentSortInfo.Col, '', currentSortInfo.Order );

            function colWidthNSort = addSort( colWidth, sortInfo )
                if isempty( sortInfo.Col )
                    colWidthNSort = colWidth;
                else
                    p = jsondecode( colWidth );
                    p.sortcolumn = sortInfo.Col;
                    p.sortorderascending = sortInfo.Order;
                    colWidthNSort = jsonencode( p );
                end
            end
            if hasJSONColumSetting
                if this.isReqView && ~isempty( this.reqColumnWidths )
                    this.treeComp.setColumns( addSort( this.reqColumnWidths, currentSortInfo ) );
                end
                if ~this.isReqView && ~isempty( this.linkColumnWidths )
                    this.treeComp.setColumns( addSort( this.linkColumnWidths, currentSortInfo ) );
                end
            end

            if any( contains( this.reqColumns, 'Verified' ) )
                this.displayVerificationStatus = true;

            end

            if any( contains( this.reqColumns, 'Implemented' ) )
                this.displayImplementationStatus = true;

            end
            this.updateToolstrip(  );

            function str = convSortOrderBool2Str( in )


                if in
                    str = 'Asc';
                else
                    str = 'Desc';
                end
            end
        end



        function refreshRollupStatusIfNecessary( this )
            if this.displayVerificationStatus
                this.appmgr.reqRoot.refreshVerificationStatus(  );
            end

            if this.displayImplementationStatus
                this.appmgr.reqRoot.refreshImplementationStatus(  );
            end
        end


        function [ reqWidth, linkWidth ] = getColumnWidths( this )
            reqWidth = '';
            linkWidth = '';
            if isempty( this.treeComp ) || ~isvalid( this.treeComp )
                return ;
            end
            cWidth = this.treeComp.getColumnWidths(  );
            if this.isReqView
                this.reqColumnWidths = cWidth;
            else
                this.linkColumnWidths = cWidth;
            end
            reqWidth = this.reqColumnWidths;
            linkWidth = this.linkColumnWidths;
        end

        function [ width, height ] = getSpreadSheetSize( this )
            if isempty( this.treeComp ) || ~isvalid( this.treeComp )
                width =  - 1;
                height =  - 1;
                return ;
            end

            try
                sz = this.treeComp.getSize(  );
                width = sz( 1 );
                height = sz( 2 );
            catch
                width =  - 1;
                height =  - 1;
            end

        end

        function setSpreadSheetSize( this, w, h )
            if isempty( this.treeComp ) || ~isvalid( this.treeComp )
                return ;
            end

            try

                this.treeComp.setSize( w, h );
            catch
            end
        end

        function currentWidth = getCurrentColumnWidths( this )
            currentWidth = '';
            if ~ishandle( this.treeComp )
                return ;
            end
            currentWidth = this.treeComp.getColumnWidths(  );
        end

        function restoreColumnWidth( this, prevColWidths )
            currentColWidths = this.modelExplorer.getColumnWidths;
            newColWidths = slreq.app.ViewSettingsManager.revertShownColWidth( currentColWidths, prevColWidths );
            if ~isempty( newColWidths )

            end
        end

        function dlg = getDialog( this, dasObj )
            if nargin > 1 && ~isempty( dasObj )
                dlgs = DAStudio.ToolRoot.getOpenDialogs( dasObj );
            else
                if isempty( this.currentSelectedObj )
                    dlgs = DAStudio.ToolRoot.getOpenDialogs( this.getRoot(  ) );
                else
                    dlgs = DAStudio.ToolRoot.getOpenDialogs( this.currentSelectedObj );
                end
            end

            dlg = [  ];
            for index = 1:length( dlgs )
                if strcmp( dlgs( index ).DialogTag, 'slreq_propertyinspector_#?#standalone#?#' )
                    dlg = dlgs( index );
                    break ;
                end
            end
        end

        function dlg = getBannerDlg( this )
            dlg = findDDGByTag( 'req_editor_button_dlg' );
        end

    end

    methods ( Access = private )
        function json = handleHeaderContextMenuRequest( this, comp, header )
            f1 = 'label';
            f2 = 'checkable';
            f3 = 'command';
            f4 = 'tag';

            v1 = { getString( message( 'Slvnv:slreq:CustomAttributesDotDotDot' ) ),  ...
                getString( message( 'Slvnv:slreq:ClearSort' ) ) };
            v2 = { false, false };
            v3 = { 'slreq.toolstrip.selectColumns',  ...
                'slreq.internal.gui.Editor.sortColumnCallback(''clear'')' };
            v4 = { 'slreq_SelectAttributes', 'slreq_ClearSort' };

            json = struct( f1, v1, f2, v2, f3, v3, f4, v4 );
        end

        function onSpreadSheetLoadingComplete( this, compTag, dlg )
        end

        function result = handleContextMenuRequest( this, comp, sel )







            sp = this.treeComp;

            menu = DAStudio.UI.Widgets.Menu;
            [ ~, ~, currentBDRoot ] = slreq.utils.DAStudioHelper.getCurrentBDHandle(  );


            rootHandle = 0;
            if ~isempty( currentBDRoot )
                rootHandle = ( get_param( currentBDRoot, 'Handle' ) );
            end
            menuItem = sel.getContextMenuItems( 'standalone' );
            result = slreq.gui.ContextMenuBuilder.createActions( menuItem );
        end
    end

    methods ( Access = private )
        function onClick( this, selectedObj, selectedProp )
            disp( 'onClick' );
            disp( selectedObj );
            disp( selectedProp );
            this.propsComp.updateSource( '', selectedObj{ 1 } );
        end

        function windowActivatedCB( this, cbinfo )
            this.appmgr.setLastOperatedView( this );
        end

        function windowClosedCB( this, window, eventData )

            this.close( eventData );

            this.studioWindow = [  ];
            this.treeComp = [  ];
            this.notificationComp = [  ];
            this.currentSelectedObj = slreq.das.ReqLinkBase.empty(  );
            this.selectionStatus = slreq.gui.SelectionStatus.None;
            this.propsComp = [  ];
        end

        function setTreeTitle( this )
            if ~isempty( this.treeComp ) && isvalid( this.treeComp )
                vm = this.appmgr.viewManager;
                if ~vm.isVanillaActive(  )
                    this.treeComp.setTitle( [ 'Filter: ', vm.getCurrentView(  ).getLabel( false ) ] );
                else
                    this.treeComp.setTitle( '' );
                end
            end
        end

        function constructUI( this )




            needRefresh = ~slreq.app.MainManager.hasEditor;

            if ~isempty( this.studioWindow ) && isvalid( this.studioWindow )
                this.studioWindow.delete(  );
            end

            confObj = studio.WindowConfiguration;
            confObj.Title = getString( message( 'Slvnv:slreq:RequirementsEditor' ) );
            confObj.Icon = fullfile( matlabroot, 'toolbox', 'shared', 'reqmgt', 'icons', 'requirementsView.png' );
            confObj.ToolstripConfigurationName = 'slreqEditor';
            confObj.ToolstripConfigurationPath = slreq.internal.gui.Editor.ConfigPath;
            confObj.ToolstripName = 'slreqEditorToolStrip';
            confObj.Tag = 'mwRequirementsToolkitEditorWindow';

            confObj.ToolstripContext = 'slreq.internal.gui.EditorContext';
            sw = studio.Window( confObj );

            st = sw.getStudio;
            studioEvents = struct(  ...
                'name', { 'WindowActivatedEvents' },  ...
                'handler', { @this.windowActivatedCB },  ...
                'id', { [  ] } );

            for i = 1:numel( studioEvents )
                svc = st.getService( studioEvents( i ).name );
                studioEvents( i ).id = svc.registerServiceCallback( studioEvents( i ).handler );
            end



            this.closeListener = addlistener( sw, 'Closed', @this.windowClosedCB );


            this.spreadsheetLoading = 0;
            ssComp = GLUE2.SpreadSheetComponent( 'RequirementsSpreadsheet' );
            this.treeComp = ssComp;
            this.treeComp.onLoadingComplete = @this.onSpreadSheetLoadingComplete;
            ssComp.enableHierarchicalView( true );
            ssComp.setAcceptedMimeTypes( slreq.das.Requirement.getMimeTypes(  ) );
            ssComp.HideTitle = false;
            app = slreq.app.MainManager.getInstance;
            ssComp.UserMoveable = false;
            ssComp.UserFloatable = false;
            sw.addComponent( this.treeComp, 'left' );
            if isempty( this.appmgr.reqRoot.children ) && ~isempty( this.appmgr.linkRoot.children )


                root = this.appmgr.linkRoot;
                this.isReqView = false;
                this.treeComp.setMinimizeTabTitle( getString( message( 'Slvnv:slreq:Links' ) ) );
                this.Columns = this.linkColumns;
            else
                root = this.appmgr.reqRoot;
                this.isReqView = true;
                this.treeComp.setMinimizeTabTitle(  ...
                    getString( message( 'Slvnv:slreq:Requirements' ) ) );
                this.Columns = this.reqColumns;
            end

            this.spreadsheetLoading = this.spreadsheetLoading + 1;
            this.treeComp.setSource( root );
            this.setTreeTitle(  );

            this.propsComp = GLUE2.PropertyInspectorComponent( "Inspector" );
            this.propsComp.HideTitle = true;
            this.propsComp.updateSource( '', root );
            this.propsComp.UserMoveable = false;
            this.propsComp.UserFloatable = false;
            sw.addComponent( this.propsComp, 'center' );


            ssComp.onContextMenuRequest = @this.handleContextMenuRequest;
            ssComp.onHeaderContextMenuRequest = @this.handleHeaderContextMenuRequest;







            this.notificationComp = GLUE2.DDGComponent( 'banner' );
            this.notificationComp.AllowMinimize = false;
            this.notificationComp.HideTitle = true;
            this.notificationComp.UserMoveable = false;
            sw.addComponent( this.notificationComp, 'top' );

            this.notificationComp.updateSource( this.note );

            this.studioWindow = sw;

            sw.show;
            this.dismissNotificationBanner(  );



            this.showNotification(  );


            ssComp.setDragCursor( 'move', slreq.gui.IconRegistry.instance.reqDragIconMoving );
            ssComp.setDragCursor( 'copy', slreq.gui.IconRegistry.instance.reqDragIconLinking );


            ssComp.onDrag = @slreq.internal.gui.Editor.onDrag;
            ssComp.onDrop = @slreq.internal.gui.Editor.onDrop;

            ssComp.onSelectionChange = @this.onListSelectionChanged;
            ssComp.onSortChange = @this.handleSortChange;

            this.restoreViewSettings(  );




            if needRefresh






            else
                this.refreshRollupStatusIfNecessary(  );
            end

            this.update(  );
        end

        function result = onListSelectionChanged( this, comp, sel, handler )
            [ this.currentSelectedObj, this.selectionStatus ] = slreq.gui.SelectionStatus.getCurrentSelectionAndType( sel );

            if slreq.gui.SelectionStatus.isDragNDropLinkingAllowed( this )

                this.currentSelectedObj( 1 ).updateMimeData( this.currentSelectedObj );
                if numel( this.currentSelectedObj ) > 1
                    for n = 2:length( this.currentSelectedObj )
                        this.currentSelectedObj( n ).updateMimeData( [  ] );
                    end
                end
                this.treeComp.setMimeInfo( this.currentSelectedObj( 1 ), slreq.das.Requirement.getMimeType(  ), this.currentSelectedObj( 1 ).mimeData );
            end

            this.appmgr.setSelectedObject( this.currentSelectedObj );


            if isempty( sel )
                this.propsComp.updateSource( '', this.getRoot );
            else
                oDlg = this.getDialog( sel{ end  } );
                if isempty( oDlg )
                    this.propsComp.updateSource( '', sel{ end  } );
                else
                    if numel( sel ) == 1





                        this.propsComp.updateSource( '', sel{ end  } );
                    end
                    slreq.internal.gui.ViewForDDGDlg.refreshDDGDialogs( oDlg );
                end
            end

            this.updateToolstrip(  );

            result = true;
        end

        function handleSortChange( this, src, col, order )
            if this.isReqView
                this.reqSortInfo.Col = col;
                this.reqSortInfo.Order = order;
            else
                this.linkSortInfo.Col = col;
                this.linkSortInfo.Order = order;
            end
            this.update(  );
        end

        function applyViewChanges( this )



            if this.isReqView
                currentSortInfo = this.reqSortInfo;
            else
                currentSortInfo = this.linkSortInfo;
            end
            if isempty( currentSortInfo.Col )

                this.treeComp.clearSort(  );
            else
                this.treeComp.enableSort(  );
                this.treeComp.SortColumn = currentSortInfo.Col;
                this.treeComp.SortOrder = convSortOrderBool2Str( currentSortInfo.Order );
            end

            if any( contains( this.Columns, 'Verified' ) )
                if ~isempty( this.appmgr.reqRoot.children ) ...
                        && this.appmgr.reqRoot.children( 1 ).getSelfStatus( 'Verification' ) == slreq.analysis.Status.Unset

                    this.appmgr.reqRoot.refreshVerificationStatus(  );
                end
                this.displayVerificationStatus = true;

            end

            if any( contains( this.Columns, 'Implemented' ) )
                if ~isempty( this.appmgr.reqRoot.children ) ...
                        && this.appmgr.reqRoot.children( 1 ).getSelfStatus( 'Implementation' ) == slreq.analysis.Status.Unset

                    this.appmgr.reqRoot.refreshImplementationStatus(  );
                end
                this.displayImplementationStatus = true;

            end
            this.updateToolstrip(  );


            if this.isReqView && ~isempty( this.reqColumnWidths )
                this.treeComp.setColumns( this.reqColumnWidths );
            end
            if ~this.isReqView && ~isempty( this.linkColumnWidths )
                this.treeComp.setColumns( this.linkColumnWidths );
            end

            function str = convSortOrderBool2Str( in )


                if in
                    str = 'Asc';
                else
                    str = 'Desc';
                end
            end
        end

        function updateSorting( this, action )


            switch action
                case 'enable'
                    this.treeComp.enableSort;
                case 'disable'
                    this.treeComp.disableSort;
                case 'clear'
                    this.treeComp.clearSort;
            end
            this.updateToolstrip(  );
        end

    end

    methods
        function reDraw( this )
            reqdata = slreq.data.ReqData.getInstance;
            allreqsets = reqdata.getLoadedReqSets;

            for i = 1:length( allreqsets )
                das = allreqsets( i ).getDasObject(  );
                das.childrenCreated = false;
                das.children = [  ];
            end

            this.refreshUI(  );
        end


        function switchToCurrentView( this )
            if isempty( this.treeComp )
                return ;
            end

            view = this.appmgr.viewManager.getCurrentView;
            if isempty( view )
                error( 'view cannot be empty' );
            end

            this.treeComp.setMinimizeTabTitle( view.name );
            settings = view.getDisplaySettings(  );

            this.reqColumns = settings.reqColumns;
            this.linkColumns = settings.linkColumns;
            this.reqColumnWidths = settings.reqColumnWidths;
            this.linkColumnWidths = settings.linkColumnWidths;
            if settings.reqActive


                columToUpdate = settings.reqColumnWidths;
            else


                columToUpdate = settings.linkColumnWidths;
            end
            this.isReqView = settings.reqActive;




            this.setTreeTitle(  );
            this.treeComp.setSource( this.getRoot(  ) );
            this.treeComp.update(  );
            this.propsComp.updateSource( '', this.getRoot(  ) );

            function [ toAdd, toRemove ] = columnDiff( col, colWidth )
                if isempty( col )
                    return ;
                end
                oldCols = {  };
                if ~isempty( colWidth )
                    colStruct = jsondecode( colWidth );
                    oldCols = { colStruct.columns.name };
                end

                toAdd = setdiff( col, oldCols );
                toRemove = setdiff( oldCols, col );
            end

            if ~isempty( columToUpdate )
                this.treeComp.setColumns( columToUpdate );
                [ toAdd, toRemove ] = columnDiff( this.Columns, columToUpdate );
                for n = 1:length( toRemove )
                    this.treeComp.removeColumn( toRemove{ n } );
                end
                for n = 1:length( toAdd )
                    this.treeComp.addColumn( toAdd{ n } );
                end
            else
                this.treeComp.setColumns( this.Columns, '', '', false );
            end


            this.setSpreadSheetSize( settings.spreadsheetWidth, settings.spreadsheetHeight );


            this.currentSelectedObj = slreq.das.BaseObject.empty(  );
            this.updateToolstrip(  );
        end


        function switchView( this )
            if this.isReqView
                this.treeComp.setMinimizeTabTitle( getString( message( 'Slvnv:slreq:Links' ) ) );
                this.getColumnWidths(  );
                columToUpdate = this.linkColumnWidths;
            else
                this.treeComp.setMinimizeTabTitle( getString( message( 'Slvnv:slreq:Requirements' ) ) );
                this.getColumnWidths(  );
                columToUpdate = this.reqColumnWidths;
            end
            this.isReqView = ~this.isReqView;




            this.spreadsheetLoading = this.spreadsheetLoading + 1;
            this.treeComp.setSource( this.getRoot(  ) );
            this.propsComp.updateSource( '', this.getRoot(  ) );

            function [ toAdd, toRemove ] = columnDiff( col, colWidth )
                if isempty( col )
                    return ;
                end
                oldCols = {  };
                if ~isempty( colWidth )
                    colStruct = jsondecode( colWidth );
                    oldCols = { colStruct.columns.name };
                end

                toAdd = setdiff( col, oldCols );
                toRemove = setdiff( oldCols, col );
            end


            if ~isempty( columToUpdate )
                this.treeComp.setColumns( columToUpdate );
                [ toAdd, toRemove ] = columnDiff( this.Columns, columToUpdate );
                for n = 1:length( toRemove )
                    this.treeComp.removeColumn( toRemove{ n } );
                end
                for n = 1:length( toAdd )
                    this.treeComp.addColumn( toAdd{ n } );
                end
            else
                this.treeComp.setColumns( this.Columns, '', '', false );
            end


            this.currentSelectedObj = slreq.das.BaseObject.empty(  );




            this.updateToolstrip(  );
        end
    end

    methods
        ...
            ...
            ...
            ...
            ...
            ...
            ...
            ...
            ...
            ...

        function col = get.Columns( this )
            if this.isReqView
                col = this.reqColumns;
            else
                col = this.linkColumns;
            end
        end
        function set.Columns( this, newCols )
            vm = slreq.app.MainManager.getInstance.viewManager;
            if this.isReqView
                this.treeComp.setColumns( newCols, this.reqSortInfo.Col, '', this.reqSortInfo.Order );
                this.reqColumns = newCols;
            else
                this.treeComp.setColumns( newCols, this.linkSortInfo.Col, '', this.linkSortInfo.Order );
                this.linkColumns = newCols;
            end
            this.spreadsheetLoading = this.spreadsheetLoading + 1;
            this.treeComp.update;
        end

        function setDisplayComment( this, tf )
            if this.displayComment == tf
                return ;
            end
            this.displayComment = tf;
            this.update(  );
        end
    end

    methods ( Static )
        function addNewReqSet(  )
            appmgr = slreq.app.MainManager.getInstance(  );
            reqSetDas = appmgr.callbackHandler.addNewReqSet(  );
            view = appmgr.requirementsEditor;
            view.setSelectedObject( reqSetDas );
            view.update(  );
        end

        function importReqSet(  )
            slreq.import.ui.dlg_mgr(  );
        end

        function openReqSet(  )
            appmgr = slreq.app.MainManager.getInstance(  );
            appmgr.callbackHandler.openReqSet(  );
        end

        function saveAsReqSet(  )
            appmgr = slreq.app.MainManager.getInstance(  );
            reqeditor = appmgr.requirementsEditor(  );
            currentReqSet = reqeditor.getCurrentSelection;
            if isa( currentReqSet, 'slreq.das.Requirement' )
                currentReqSet = currentReqSet.RequirementSet;
            end
            if isa( currentReqSet, 'slreq.das.RequirementSet' )
                appmgr.callbackHandler.saveReqLinkSet( currentReqSet, true );
            end
        end


        function saveReqLinkSet(  )
            appmgr = slreq.app.MainManager.getInstance(  );
            view = appmgr.requirementsEditor;
            dlg = view.getDialog(  );
            if ~isempty( dlg )




                dlg.apply(  );
            end
            currentObj = view.getCurrentSelection(  );
            if ~isempty( currentObj )
                appmgr.callbackHandler.saveReqLinkSet( currentObj );
            end
        end

        function saveAllReqLinkSet(  )
            appmgr = slreq.app.MainManager.getInstance(  );
            view = appmgr.requirementsEditor;
            currentObj = view.getCurrentSelection(  );
            appmgr.callbackHandler.saveAllReqLinkSet( currentObj );
        end

        function exportToPreviousReqSet(  )
            appmgr = slreq.app.MainManager.getInstance(  );
            view = appmgr.requirementsEditor;
            currentObj = view.getCurrentSelection(  );
            appmgr.callbackHandler.exportToPreviousReqSet( currentObj );
        end

        function exportToReqIF(  )
            appmgr = slreq.app.MainManager.getInstance(  );
            view = appmgr.requirementsEditor;
            currentObj = view.getCurrentSelection(  );
            appmgr.callbackHandler.exportToReqIF( currentObj );
        end


        function closeReqLinkSet(  )
            appmgr = slreq.app.MainManager.getInstance(  );
            view = appmgr.requirementsEditor;
            currentObj = view.getCurrentSelection(  );
            if ~isempty( currentObj )
                appmgr.callbackHandler.closeReqLinkSet( currentObj );
            end
        end

        function addReq(  )
            appmgr = slreq.app.MainManager.getInstance(  );
            view = appmgr.requirementsEditor;
            currentObj = view.getCurrentSelection(  );
            if isa( currentObj, 'slreq.das.Requirement' )
                reqDas = appmgr.callbackHandler.addRequirementAfter( currentObj );
            elseif isa( currentObj, 'slreq.das.RequirementSet' )
                reqDas = appmgr.callbackHandler.addChildRequirement( currentObj );
            else
                return ;
            end
            view.setSelectedObject( reqDas );
        end

        function delReqLink(  )
            appmgr = slreq.app.MainManager.getInstance(  );
            view = appmgr.requirementsEditor;
            currentObj = view.getCurrentSelection(  );
            appmgr.callbackHandler.delReqLink( currentObj );
        end

        function cutItem(  )
            appmgr = slreq.app.MainManager.getInstance(  );
            view = appmgr.requirementsEditor;
            currentObj = view.getCurrentSelection(  );
            if isa( currentObj, 'slreq.das.Requirement' )
                slreq.app.CallbackHandler.cutItem( currentObj );
            end
        end

        function copyItem(  )
            appmgr = slreq.app.MainManager.getInstance(  );
            view = appmgr.requirementsEditor;
            currentObj = view.getCurrentSelection(  );
            if isa( currentObj, 'slreq.das.Requirement' )
                slreq.app.CallbackHandler.copyItem( currentObj );
            end
        end

        function pasteItem(  )
            appmgr = slreq.app.MainManager.getInstance(  );
            view = appmgr.requirementsEditor;
            currentObj = view.getCurrentSelection(  );
            if isa( currentObj, 'slreq.das.Requirement' ) || isa( currentObj, 'slreq.das.RequirementSet' )
                slreq.app.CallbackHandler.pasteItem( currentObj );
            end
        end

        function promoteReq(  )
            appmgr = slreq.app.MainManager.getInstance(  );
            view = appmgr.requirementsEditor;
            currentObj = view.getCurrentSelection(  );
            appmgr.callbackHandler.promote( currentObj );
        end

        function demoteReq(  )
            appmgr = slreq.app.MainManager.getInstance(  );
            view = appmgr.requirementsEditor;
            currentObj = view.getCurrentSelection(  );
            appmgr.callbackHandler.demote( currentObj );
        end

        function showCode(  )
            appmgr = slreq.app.MainManager.getInstance(  );
            view = appmgr.requirementsEditor;
            if view.displayCodeTraceability
                appmgr.disableCodeTraceability(  );
            else
                appmgr.enableCodeTraceability(  );
            end
            view.displayCodeTraceability = ~view.displayCodeTraceability;
            view.update(  );
        end

        function refreshAll(  )
            appmgr = slreq.app.MainManager.getInstance(  );
            slreq.app.CallbackHandler.onRefreshAll( appmgr.requirementsEditor );
        end

        function requirementsView(  )
            appmgr = slreq.app.MainManager.getInstance(  );
            view = appmgr.requirementsEditor;
            if ~view.isReqView
                view.switchView;
            end
        end

        function linksView(  )
            appmgr = slreq.app.MainManager.getInstance(  );
            view = appmgr.requirementsEditor;
            if view.isReqView
                view.switchView;
            end
        end

        function allow = onDrag( ~, source, destination, location, action )
            appmgr = slreq.app.MainManager.getInstance(  );
            allow = appmgr.callbackHandler.onDrag( source, destination, location, action );
        end

        function onDrop( ~, source, destination, location, action )
            appmgr = slreq.app.MainManager.getInstance(  );
            appmgr.callbackHandler.onDrop( source, destination, location, action );
        end



        function selectObjectByUuid( uuid )
            appmgr = slreq.app.MainManager.getInstance(  );
            view = appmgr.requirementsEditor;
            if isempty( view ) || isvalid( view )
                appmgr.openRequirementsEditor(  );
                view = appmgr.requirementsEditor;
            end
            dasObj = slreq.utils.findDASbyUUID( uuid );
            if ~isempty( dasObj )
                view.show(  );
                view.setSelectedObject( dasObj );
            end
        end


        function generateReport(  )
            reqdata = slreq.data.ReqData.getInstance;
            allreqsets = reqdata.getLoadedReqSets;
            mgr = slreq.app.MainManager.getInstance;
            reqroot = mgr.reqRoot;
            slreq.report.utils.openOptionDlg( allreqsets, reqroot.children );
        end



        function generateRTMX(  )
            slreq.report.rtmx.utils.generateRTMX(  );
        end



        function generateTraceDiagram( selectedItem )
            dataObj = selectedItem.dataModelObj;
            slreq.internal.tracediagram.utils.generateTraceDiagram( dataObj );
        end

        function addJustification(  )
            appmgr = slreq.app.MainManager.getInstance(  );
            view = appmgr.requirementsEditor;
            currentObj = view.getCurrentSelection(  );
            appmgr.callbackHandler.addJustification( currentObj );
        end

        function sortColumnCallback( sortAction )
            appmgr = slreq.app.MainManager.getInstance(  );
            view = appmgr.requirementsEditor;
            view.updateSorting( sortAction );
        end

        function openHelpAuthorReq(  )
            helpview( fullfile( docroot, 'slrequirements', 'helptargets.map' ), 'authorreqs_editor' );
        end

        function openHelpSLReq(  )
            helpview( fullfile( docroot, 'slrequirements', 'helptargets.map' ), 'slreqLandingPageID' );
        end
    end
end
