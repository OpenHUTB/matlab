classdef View < handle & matlab.mixin.SetGet

    properties ( Access = { ?uitest.factory.Tester, ?ViewLayer } )

        Container medical.internal.app.labeler.view.Container

        Toolstrip medical.internal.app.labeler.view.toolstrip.Toolstrip

        Pointer medical.internal.app.labeler.view.Pointer

        Key medical.internal.app.labeler.view.Key

        Dialog medical.internal.app.labeler.view.dialogs.Dialog

        Slices

        ROI

        VolumeRendering medical.internal.app.labeler.view.volumeRendering.VolumeRendering

        DataBrowser medical.internal.app.labeler.view.dataBrowser.DataBrowser

        LabelBrowser

        Publish

    end

    properties

        HasData
        DataFormat
        IsCurrentDataOblique( 1, 1 )logical = false;

    end

    properties ( Access = protected )

        HasDataInternal( 1, 1 )logical = false;
        DataFormatInternal
        SessionLocation = string.empty(  );

    end

    events

        DataFormatUpdated
        RefreshRecentSessions

    end

    methods


        function self = View( useDarkMode, varargin )


            if useDarkMode
                s = settings;
                s.matlab.appearance.MATLABTheme.TemporaryValue = 'Dark';
            end

            self.createComponents( useDarkMode, varargin{ : } );
            self.wireupComponents(  );

            addlistener( self.Container, 'AppResized', @( src, evt )self.resize(  ) );

            self.resize(  );
            drawnow

        end


        function clear( self )

            self.DataBrowser.clear(  );
            if ~isempty( self.Slices )
                self.Slices.clear(  );
                self.Slices = [  ];
            end

            if ~isempty( self.ROI )
                self.ROI.clear(  );
                self.ROI = [  ];
            end

            self.LabelBrowser.clear(  );
            self.LabelBrowser.showStartupMessage( true );

            self.Toolstrip.enableLoadOnly(  );
            self.Toolstrip.deselectPaintBySuperpixels(  );

            if ~isempty( self.VolumeRendering )
                self.VolumeRendering.clear(  );
            end
            self.Container.clearTitleBarName(  );


            self.Container.showRenderingEditor( false );
            self.Container.showPublishPanel( false );

            self.HasData = false;
            self.DataFormatInternal = [  ];

        end


        function setDataFormat( self, dataFormat )
            self.DataFormat = dataFormat;
        end

    end

    methods ( Access = protected )

        function createComponents( self, useDarkMode, varargin )


            self.Container = medical.internal.app.labeler.view.Container( useDarkMode );
            self.Toolstrip = medical.internal.app.labeler.view.toolstrip.Toolstrip(  );


            tabGroups = self.Toolstrip.TabGroup;
            self.Container.addTabGroup( tabGroups );

            self.canTheAppClose( false );
            self.Container.openApp(  );



            self.Container.wait(  );

            self.Toolstrip.enableLoadOnly(  );

            self.DataBrowser = medical.internal.app.labeler.view.dataBrowser.DataBrowser(  ...
                self.Container.DataBrowserDocument.Figure );

            self.Pointer = medical.internal.app.labeler.view.Pointer(  ...
                self.Container.TransverseDocument.Figure,  ...
                self.Container.CoronalDocument.Figure,  ...
                self.Container.SagittalDocument.Figure,  ...
                self.Container.VolumeDocument.Figure,  ...
                self.Container.LabelBrowserDocument.Figure,  ...
                self.Container.DataBrowserDocument.Figure );

            self.Key = medical.internal.app.labeler.view.Key(  ...
                self.Container.TransverseDocument.Figure,  ...
                self.Container.CoronalDocument.Figure,  ...
                self.Container.SagittalDocument.Figure,  ...
                self.Container.VolumeDocument.Figure,  ...
                self.Container.LabelBrowserDocument.Figure,  ...
                self.Container.DataBrowserDocument.Figure );

            self.Dialog = medical.internal.app.labeler.view.dialogs.Dialog( useDarkMode );
            self.LabelBrowser = medical.internal.app.labeler.view.labelBrowser.LabelBrowser( self.Container.LabelBrowserDocument.Figure );
            self.Publish = medical.internal.app.labeler.view.Publish( self.Container.PublishDocument.Figure );

        end


        function createSlices( self )

            if self.DataFormat == medical.internal.app.labeler.enums.DataFormat.Volume

                self.Slices = medical.internal.app.labeler.view.sliceView.SliceViewsVolume(  ...
                    self.Container.TransverseDocument.Figure,  ...
                    self.Container.CoronalDocument.Figure,  ...
                    self.Container.SagittalDocument.Figure );

            else

                self.Slices = medical.internal.app.labeler.view.sliceView.SliceViewsImage(  ...
                    self.Container.TransverseDocument.Figure );

            end

        end


        function createROI( self )

            if self.DataFormat == medical.internal.app.labeler.enums.DataFormat.Volume
                self.ROI = medical.internal.app.labeler.view.roi.ROIVolume(  );
            else
                self.ROI = medical.internal.app.labeler.view.roi.ROIImage(  );
            end

        end


        function createVolumeRendering( self )

            show3DDisplay = images.ui.graphics3d.internal.isViewer3DSupported(  );

            self.VolumeRendering = medical.internal.app.labeler.view.volumeRendering.VolumeRendering(  ...
                self.Container.VolumeDocument.Figure, self.Container.RenderingEditorDocument.Figure, show3DDisplay );

            if ~show3DDisplay
                self.Toolstrip.disableVolumeRendering(  );
                self.warning( getString( message( 'images:volume:webGL2NotSupported' ) ) );
            end

            color = self.VolumeRendering.getVolumeBackgroundColor(  );
            self.Toolstrip.setBackgroundColor( color );
            set( self.Container.VolumeDocument.Figure, 'Color', [ 0, 0, 0 ] );

            color = self.VolumeRendering.getVolumeGradientColor(  );
            self.Toolstrip.setGradientColor( color );

        end
    end

    methods ( Access = protected )

        function wireupComponents( self )

            addContainerListeners( self );
            addToolstripListeners( self );
            addDataBrowserListeners( self );
            addDialogListeners( self );
            addKeyListeners( self );
            addPointerListeners( self );
            addLabelsListeners( self );
            addPuslishListeners( self );

        end


        function wireupSlices( self )

            addSliceListeners( self );

        end


        function wireupROI( self )

            addROIListeners( self );

        end


        function wireupVolumeRendering( self )

            addVolumeRenderingListeners( self );

        end
    end


    methods


        function hasData = get.HasData( self )
            hasData = self.HasDataInternal;
        end

        function set.HasData( self, TF )
            self.HasDataInternal = TF;
        end


        function set.DataFormat( self, dataFormat )

            self.canTheAppClose( false );
            c = onCleanup( @(  )self.canTheAppClose( true ) );

            self.DataFormatInternal = dataFormat;

            if self.HasData
                self.clear(  );
            end

            evt = medical.internal.app.labeler.events.ValueEventData( self.DataFormatInternal );
            self.notify( 'DataFormatUpdated', evt )

            self.Container.setup( dataFormat );
            self.Toolstrip.setup( dataFormat );
            self.Publish.setup( dataFormat );


            self.createSlices(  );
            self.createROI(  );
            self.wireupSlices(  );
            self.wireupROI(  );

            if dataFormat == medical.internal.app.labeler.enums.DataFormat.Volume


                if isempty( self.VolumeRendering )
                    self.createVolumeRendering(  );
                    self.wireupVolumeRendering(  );
                end

                [ transverseIm, coronalIm, sagittalIm ] = self.Slices.getImageHandles(  );
                self.ROI.preload( transverseIm, coronalIm, sagittalIm );

            else

                sliceIm = self.Slices.getImageHandles(  );
                self.ROI.preload( sliceIm );

            end

            self.requestToRefreshRecentSessions(  );

        end

        function dataFormat = get.DataFormat( self )
            dataFormat = self.DataFormatInternal;
        end


        function set.IsCurrentDataOblique( self, TF )

            self.IsCurrentDataOblique = TF;
            self.Toolstrip.setIsCurrentDataOblique( TF );%#ok<*MCSUP>
            self.Container.setIsCurrentDataOblique( TF );
            self.Publish.setIsCurrentDataOblique( TF );

            if TF
                self.Slices.showOrientationMarkers( false );
            else
                if self.Toolstrip.ShowOrientationMarkers
                    self.Slices.showOrientationMarkers( true );
                else
                    self.Slices.showOrientationMarkers( false );
                end
            end

        end

        function isOblique = get.IsCurrentDataOblique( self )
            isOblique = self.IsCurrentDataOblique;
        end

    end









    events



        AppCleared


        AppClosed

        UndoRequested

        RedoRequested

    end

    methods


        function setBusy( self, TF )

            if TF
                self.Container.wait(  );
            else
                self.Container.resume(  );
            end

        end


        function enableUndoRedo( self, canUndo, canRedo )

            enableUndo( self.Container, canUndo );
            enableRedo( self.Container, canRedo );

        end


        function markSessionAsUnsaved( self )

            self.Container.addTitleBarAsterisk(  );
            self.Toolstrip.markSaveAsDirty(  );

        end


        function markSessionAsSaved( self )

            self.Container.removeTitleBarAsterisk(  );
            self.Toolstrip.markSaveAsClean(  );

        end


        function updateVoxelInfo( self, position, intensity, index, sliceDirection )
            self.Container.updateVoxelInfo( position, intensity, index, sliceDirection );
        end


        function setSessionLocation( self, folderPath )
            self.Container.setTitleBarName( folderPath );
            self.SessionLocation = folderPath;
        end


        function canTheAppClose( self, TF )
            self.Container.CanClose = TF;
        end

    end

    methods ( Access = protected )


        function addContainerListeners( self )

            addlistener( self.Container, 'AppClosed', @( src, evt )closeApp( self ) );
            addlistener( self.Container, 'SelectedDocumentChanged', @( src, evt )reactToSelectedDocumentChanged( self, evt.Value ) );
            addlistener( self.Container, 'UndoRequested', @( src, evt )reactToUndoRequest( self ) );
            addlistener( self.Container, 'RedoRequested', @( src, evt )reactToRedoRequest( self ) );
            addlistener( self.Container, 'HelpRequested', @( src, evt )doc( 'medicalImageLabeler' ) );

        end


        function resize( self )

            if ~isvalid( self ) || ~isvalid( self.Container.TransverseDocument.Figure )
                return
            end

            self.LabelBrowser.resize( [ 1, 1, self.Container.LabelBrowserDocument.Figure.Position( 3:4 ) ] );

            if self.DataFormat == medical.internal.app.labeler.enums.DataFormat.Volume

                if ~isempty( self.Slices ) && isvalid( self.Slices )
                    self.Slices.resize(  ...
                        self.Container.TransverseDocument.Figure.Position,  ...
                        self.Container.CoronalDocument.Figure.Position,  ...
                        self.Container.SagittalDocument.Figure.Position );
                end

            elseif self.DataFormat == medical.internal.app.labeler.enums.DataFormat.Image

                if ~isempty( self.Slices ) && isvalid( self.Slices )
                    self.Slices.resize( self.Container.TransverseDocument.Figure.Position );
                end

            end

        end


        function closeApp( self )

            if ~isvalid( self )
                return
            end

            if self.HasData
                self.requestToSaveSession(  )
            end

            self.notify( 'AppClosed' );

            delete( self.Toolstrip );
            delete( self.VolumeRendering );

        end


        function reactToRenderingEditorToggle( self, TF )
            self.Container.showRenderingEditor( TF );
        end


        function reactToPublishPanelToggle( self, TF )
            self.Container.showPublishPanel( TF );
        end


        function reactToUndoRequest( self )

            deselectAll( self.ROI );
            notify( self, 'UndoRequested' )

        end


        function reactToRedoRequest( self )

            deselectAll( self.ROI );
            notify( self, 'RedoRequested' )

        end

    end




    events

        ReadDataRequested

        CopyDataLocationRequested
        CopyLabelLocationRequested

        RemoveDataRequested
        RemoveLabelsRequested

    end

    methods


        function addToDataBrowser( self, dataName, hasLabels )
            self.DataBrowser.add( dataName, hasLabels );
        end


        function updateLabelStatus( self, dataName, hasLabels )
            self.DataBrowser.updateLabelStatus( dataName, hasLabels );
        end

    end

    methods ( Access = private )


        function addDataBrowserListeners( self )

            addlistener( self.DataBrowser, 'ReadDataRequested', @( src, evt )self.reactToReadDataRequest( evt ) );
            addlistener( self.DataBrowser, 'CopyDataLocationRequested', @( src, evt )self.notify( 'CopyDataLocationRequested', evt ) );
            addlistener( self.DataBrowser, 'CopyLabelLocationRequested', @( src, evt )self.notify( 'CopyLabelLocationRequested', evt ) );
            addlistener( self.DataBrowser, 'RemoveDataRequested', @( src, evt )self.reactToRemoveDataRequest( evt ) );
            addlistener( self.DataBrowser, 'RemoveLabelsRequested', @( src, evt )self.reactToRemoveLabelsRequest( evt ) );

        end


        function reactToReadDataRequest( self, evt )

            wait( self.Container );
            c = onCleanup( @(  )resume( self.Container ) );

            if self.Toolstrip.AutoSave
                self.requestToSaveSession(  );
            end

            self.notify( 'ReadDataRequested', evt );

            if self.Toolstrip.IsSuperPixelsActive
                sz = self.Toolstrip.getPaintBrushSize(  );
                self.paintBySuperpixels( sz, [  ] )
            end

        end


        function reactToRemoveDataRequest( self, evt )

            question = getString( message( 'medical:medicalLabeler:removeDataQuestion' ) );
            title = getString( message( 'medical:medicalLabeler:removeData' ) );
            isCanceled = self.Dialog.askQuestion( self.Container.App, question, title );

            if isCanceled
                return
            end

            self.DataBrowser.remove( evt.Value );
            self.notify( 'RemoveDataRequested', evt );

            if self.DataBrowser.NumEntries == 0

                if self.DataFormat == medical.internal.app.labeler.enums.DataFormat.Volume
                    self.newVolumeSessionRequested(  );
                else
                    self.newImageSessionRequested(  );
                end

            end

        end


        function reactToRemoveLabelsRequest( self, evt )

            question = getString( message( 'medical:medicalLabeler:removeLabelsQuestion', evt.Value ) );
            title = getString( message( 'medical:medicalLabeler:removeLabels' ) );
            isCanceled = self.Dialog.askQuestion( self.Container.App, question, title );

            if isCanceled
                return
            end

            self.notify( 'RemoveLabelsRequested', evt );

        end

    end




    events
        LabelDataLocationSet



        SliceAtIndexRequestedForDialog



        SummaryRequestedForDialog



        InterpolateManually

    end

    methods


        function error( self, msg )
            title = getString( message( 'medical:medicalLabeler:error' ) );
            self.Dialog.displayError( self.Container.App, msg, title );
        end


        function warning( self, msg )
            title = getString( message( 'medical:medicalLabeler:warning' ) );
            self.Dialog.displayWarning( self.Container.App, msg, title );
        end


        function startWaitBar( self, title, msg )

            arguments
                self
                title
                msg = ''
            end

            self.Dialog.startWaitBar( self.Container.App, title, msg );
        end


        function clearWaitBar( self )
            self.Dialog.clearWaitBar(  );
        end


        function displayShortcuts( self )
            loc = self.Container.getLocation(  );
            self.Dialog.displayShortcuts( loc );
        end


        function displayAutomationHelp( self )
            loc = self.Container.getLocation(  );
            self.Dialog.displayAutomationHelp( loc, self.DataFormat );
        end


        function manuallyInterpolate( self )

            wait( self.Container );

            sliceDir = self.Slices.LastActiveSliceDirection;
            idx = self.ROI.getSliceIndex( sliceDir );
            pixSize = self.Slices.getPixelSize( sliceDir );

            dlgLoc = self.Container.getLocation(  );

            [ roi, val, mask ] = self.ROI.getSelection( sliceDir );
            rotationState = 1;

            [ pos1, pos2, idx1, idx2, val, interpSliceDir, isCanceled ] = self.Dialog.displayRegionSelector( dlgLoc,  ...
                self.Toolstrip.getLabelOpacity(  ), im2single( self.Slices.ContrastLimits ), rotationState,  ...
                roi, val, mask, idx, self.IsCurrentDataOblique, pixSize, sliceDir );

            if ~isvalid( self )
                return ;
            end

            resume( self.Container );

            if ~isCanceled

                deselectAll( self.ROI );
                evt = images.internal.app.segmenter.volume.events.ROIInterpolatedEventData( pos1, pos2, val, idx1, idx2 );
                evt.SliceDirection = interpSliceDir;
                notify( self, 'InterpolateManually', evt );

            end

        end


        function reassignLabels( self, names, idx, sliceDir )

            if numel( names ) > 1

                wait( self.Container );

                title = getString( message( 'images:segmenter:reassignDialogTitle' ) );
                msg = getString( message( 'images:segmenter:reassignDialogMessage' ) );
                loc = self.Container.getLocation(  );
                name = self.Dialog.displayFilter( loc, title, msg, cellstr( names ) );

                if ~isvalid( self )
                    return ;
                end

                resume( self.Container );

                if ~isempty( name )

                    evt = images.internal.app.segmenter.volume.events.ROIEventData(  ...
                        self.ROI.getReassignmentMask( sliceDir ), name, logical.empty, 0 );
                    evt.SliceIdx = idx;
                    evt.SliceDirection = sliceDir;

                    notify( self, 'RegionDrawn', evt );

                end

            end

        end


        function sliceAtIndexProvidedForDialog( self, vol, labels, cmap, idx, maxIdx )


            self.Dialog.updateRegionSelector( vol, labels, cmap, idx, maxIdx );

        end


        function updateDialogSummary( self, data, color )
            self.Dialog.updateDialogSummary( data, color );
        end


        function updateDataLoadingProgessDialog( self, tempDataName )
            msg = getString( message( 'medical:medicalLabeler:importing' ) );
            msg = strcat( msg, " ", tempDataName );
            self.Dialog.updateWaitBarMessage( msg )
        end

    end

    methods ( Access = private )


        function addDialogListeners( self )

            addlistener( self.Dialog, 'BringAppToFront', @( src, evt )self.Container.bringToFront(  ) );


            addlistener( self.Dialog, 'SliceAtIndexRequested', @( src, evt )notify( self, 'SliceAtIndexRequestedForDialog', evt ) );
            addlistener( self.Dialog, 'UpdateDialogSummary', @( src, evt )notify( self, 'SummaryRequestedForDialog', evt ) );
            addlistener( self.Dialog, 'ThrowError', @( src, evt )error( self, evt.Message ) );

        end

    end




    methods ( Access = protected )


        function reactToKeyPress( self, evt )

            if ~self.HasData
                return
            end

            if self.ROI.getIsUserDrawing

                switch evt.Key

                    case 'ctrl+'
                        self.Slices.zoomIn(  );
                    case 'ctrl-'
                        self.Slices.zoomOut(  );
                    case 'panup'
                        self.Slices.pan( 'up' );
                    case 'pandown'
                        self.Slices.pan( 'down' );
                    case 'panleft'
                        self.Slices.pan( 'left' );
                    case 'panright'
                        self.Slices.pan( 'right' );

                end

            else

                switch evt.Key

                    case 'ctrla'
                        sliceDir = self.Slices.LastActiveSliceDirection;
                        idx = self.ROI.getSliceIndex( sliceDir );
                        evt = medical.internal.app.labeler.events.SliceEventData( idx, sliceDir );
                        self.notify( 'LocationSelected', evt );

                    case 'ctrlc'
                        self.ROI.copy( self.Slices.LastActiveSliceDirection );
                    case 'ctrls'
                        self.requestToSaveSession(  );
                    case 'ctrlv'
                        self.ROI.paste( self.Slices.LastActiveSliceDirection );
                    case 'ctrlx'
                        self.ROI.cut( self.Slices.LastActiveSliceDirection )
                    case 'ctrly'
                        self.reactToRedoRequest(  );
                    case 'ctrlz'
                        self.reactToUndoRequest(  );
                    case 'down'
                        self.LabelBrowser.down(  );
                    case 'up'
                        self.LabelBrowser.up(  );
                    case 'left'
                        if ~strcmp( self.Pointer.ActivePanel, 'EntryPanel' )
                            self.Slices.previousSlice( self.Slices.LastActiveSliceDirection );
                        end
                    case 'right'
                        if ~strcmp( self.Pointer.ActivePanel, 'EntryPanel' )
                            self.Slices.nextSlice( self.Slices.LastActiveSliceDirection );
                        end
                    case 'delete'
                        self.ROI.deleteSelected( self.Slices.LastActiveSliceDirection );
                    case 'ctrl+'
                        self.Slices.zoomIn(  );
                    case 'ctrl-'
                        self.Slices.zoomOut(  );
                    case { 'return', 'escape' }
                        self.ROI.deselectAll(  );
                    case 'panup'
                        self.Slices.pan( 'up' );
                    case 'pandown'
                        self.Slices.pan( 'down' );
                    case 'panleft'
                        self.Slices.pan( 'left' );
                    case 'panright'
                        self.Slices.pan( 'right' );
                    case 'windowLevelOn'
                        self.Slices.EnableWindowLevel = true;
                end

            end

        end


        function reactToKeyRelease( self, evt )

            switch evt.Key
                case 'windowLevelOff'
                    if ~isequal( self.Toolstrip.getActiveLabelingTool(  ), 'WindowLevel' )


                        self.Slices.EnableWindowLevel = false;
                    end
            end

        end


        function reactToScrollWheel( self, evt )

            switch self.Pointer.ActivePanel

                case 'EntryPanel'
                    scroll( self.LabelBrowser, evt.VerticalScrollCount );
                case 'TransverseSlicePanel'
                    scroll( self.Slices, evt.VerticalScrollCount, medical.internal.app.labeler.enums.SliceDirection.Transverse );
                case 'CoronalSlicePanel'
                    scroll( self.Slices, evt.VerticalScrollCount, medical.internal.app.labeler.enums.SliceDirection.Coronal );
                case 'SagittalSlicePanel'
                    scroll( self.Slices, evt.VerticalScrollCount, medical.internal.app.labeler.enums.SliceDirection.Sagittal );

            end

        end


        function reactToSliceMousePressed( self, clickType )

            if strcmp( clickType, 'right' )
                updateContextMenu( self.ROI );
            end

        end


        function addKeyListeners( self )

            addlistener( self.Key, 'KeyPressed', @( src, evt )reactToKeyPress( self, evt ) );
            addlistener( self.Key, 'KeyReleased', @( src, evt )reactToKeyRelease( self, evt ) );
            addlistener( self.Key, 'ScrollWheelSpun', @( src, evt )reactToScrollWheel( self, evt ) );
            addlistener( self.Key, 'SliceMousePressed', @( src, evt )reactToSliceMousePressed( self, evt.ClickType ) );

        end

    end




    events

        NewLabelDefinitionRequested
        LabelNameChanged
        LabelColorChanged
        LabelVisibilityChanged
        LabelDeleted
        LabelSelected

        UpdateLevelTraceLabel

    end

    methods


        function updateLabelDefinitions( self, labelNames, labelColors, labelVisible, selectedIdx )

            self.LabelBrowser.update( selectedIdx, labelNames, labelColors, labelVisible );


            if self.LabelBrowser.NumLabels > 0
                self.LabelBrowser.showStartupMessage( false );
                self.Toolstrip.enableSaveSession( true );
            else
                self.LabelBrowser.showStartupMessage( true );
            end

            self.reactToLabelBrowserChanges(  );

        end


        function updateLabelColor( self, cmapLabels )

            if self.HasData
                self.ROI.updateRGBA( cmapLabels );
                self.Slices.refresh(  );
                self.updateLabelVolumeColor( cmapLabels );
            end

        end


        function updateLabelAlpha( self, amapLabels )

            if self.HasData
                self.Slices.refresh(  );
                self.updateLabelVolumeAlpha( amapLabels );
            end

        end

    end

    methods ( Access = protected )


        function addLabelsListeners( self )

            addlistener( self.LabelBrowser, 'LabelAdded', @( src, evt )notify( self, 'NewLabelDefinitionRequested' ) );
            addlistener( self.LabelBrowser, 'NameChanged', @( src, evt )notify( self, 'LabelNameChanged', evt ) );
            addlistener( self.LabelBrowser, 'ColorChanged', @( src, evt )reactToColorChange( self, evt ) );
            addlistener( self.LabelBrowser, 'EntryRemoved', @( src, evt )reactToLabelRemoved( self, evt.Label ) );
            addlistener( self.LabelBrowser, 'EntrySelected', @( src, evt )reactToLabelSelection( self, evt ) );
            addlistener( self.LabelBrowser, 'BringAppToFront', @( src, evt )self.Container.bringToFront(  ) );
            addlistener( self.LabelBrowser, 'LabelVisibilityChanged', @( src, evt )reactToLabelVisibilityChanged( self, evt ) );

        end


        function reactToColorChange( self, evt )

            if self.HasData
                self.Slices.displayLabelColor( evt.Color );
            end

            notify( self, 'LabelColorChanged', evt );






        end


        function reactToLabelSelection( self, evt )

            self.notify( 'LabelSelected', evt )

            if self.HasData

                self.Slices.displayLabelColor( evt.Color );

                if self.LabelBrowser.isCurrentVisible
                    self.Toolstrip.enableDrawing(  );
                else
                    self.Toolstrip.disableDrawing(  );
                end

                self.reactToInteractionToolChange(  );

                if strcmp( 'LevelTracing', self.Toolstrip.getActiveLabelingTool(  ) )
                    self.notify( 'UpdateLevelTraceLabel' );
                end

            end

        end


        function reactToLabelRemoved( self, labelName )

            quest = getString( message( 'medical:medicalLabeler:deleteLabelDefQuestion', labelName ) );
            title = getString( message( 'medical:medicalLabeler:deleteLabelDefTitle', labelName ) );

            isCanceled = self.Dialog.askQuestion( self.Container.App, quest, title );

            if isCanceled
                return
            end

            wait( self.Container );
            c = onCleanup( @(  )resume( self.Container ) );

            if ~isempty( self.ROI )
                self.ROI.clearClipboard(  );
            end


            evt = medical.internal.app.labeler.events.ValueEventData( string( labelName ) );
            notify( self, 'LabelDeleted', evt );





        end


        function reactToLabelVisibilityChanged( self, evt )

            if self.HasData

                TF = self.LabelBrowser.isCurrentVisible(  );

                if TF
                    self.Toolstrip.enableDrawing(  );
                else
                    self.Toolstrip.disableDrawing(  );
                end

                self.reactToInteractionToolChange(  );

            end

            self.notify( 'LabelVisibilityChanged', evt )

        end


        function reactToLabelBrowserChanges( self )

            if self.HasData


                if self.LabelBrowser.NumLabels > 0

                    self.Toolstrip.enableLabelControls(  );
                    self.Toolstrip.enableDrawing(  );

                    self.Slices.displayLabelColor( self.LabelBrowser.getCurrentColor(  ) );

                else
                    self.Toolstrip.disableLabelControls(  );
                    self.Toolstrip.disableDrawing(  );

                    self.Slices.displayLabelColor( [  ] );
                end

                self.Slices.displayMode( self.Toolstrip.getActiveLabelingTool(  ) );

            else

                if self.LabelBrowser.NumLabels > 0
                    self.Toolstrip.enableExportLabelDefs(  );
                else
                    self.Toolstrip.disableExportLabelDefs(  );
                end

            end

        end

    end




    methods ( Access = protected )


        function addPointerListeners( self )

            addlistener( self.Pointer, 'SetDrawingToolPointer', @( src, evt )setDrawingToolPointer( self ) );


            addlistener( self.Pointer, 'UpdateThumbnail', @( src, evt )showThumbnail( self, evt.Show, evt.Location ) );

        end


        function setDrawingToolPointer( self )







            if ~isvalid( self ) || ~isvalid( self.Toolstrip )
                return
            end
            activeLabelingTool = self.Toolstrip.getActiveLabelingTool(  );
            self.Pointer.setPointer( self.Container.TransverseDocument.Figure, activeLabelingTool );

        end

    end




    events
        PublishRequested
    end

    methods ( Access = protected )


        function addPuslishListeners( self )

            addlistener( self.Publish, 'PublishRequested', @( src, evt )self.reactToPublishRequested( evt ) );
            addlistener( self.Publish, 'BringAppToFront', @( src, evt )self.Container.bringToFront(  ) );

        end


        function reactToPublishRequested( self, evt )



            if self.Toolstrip.AutoSave
                self.notify( 'SaveSessionRequested' );
            end

            self.startWaitBar( getString( message( 'medical:medicalLabeler:publishingImages' ) ) );
            c = onCleanup( @(  )self.clearWaitBar(  ) );

            if evt.Screenshot3D && self.DataFormat == medical.internal.app.labeler.enums.DataFormat.Volume
                volumeImgData = getframe( self.Container.VolumeDocument.Figure );
                evt.Screenshot3D = volumeImgData.cdata;
            else
                evt.Screenshot3D = [  ];
            end

            self.notify( 'PublishRequested', evt );

        end

    end




    events


        RegionDrawn


        RegionPasted




        SetPriorMask


        FillRegion

        FloodFillRegion




        LabelNamesForROIRequested

        LocationSelected

        SliceRequestedForROI

    end

    methods


        function selectAllROIs( self, label, cmap )

            selectAll( self.ROI, label, cmap );

        end


        function sliceSelected( self, label, cmap, sliceDir )

            if self.ROI.getSelectAll( sliceDir ) || self.Key.CtrlAPressed
                selectAll( self.ROI, label, cmap, sliceDir );
            elseif self.Key.CtrlPressed
                select( self.ROI, label, cmap, sliceDir );
            else
                selectWindow( self.ROI, label, cmap, sliceDir );
            end

        end


        function drawLabel( self, val, color, sliceDir )

            switch self.Toolstrip.getActiveLabelingTool(  )
                case 'Freehand'
                    redrawSliceWithoutLabels( self );
                    draw( self.ROI, val, color, sliceDir );

                case 'AssistedFreehand'
                    redrawSliceWithoutLabels( self );
                    drawAssisted( self.ROI, val, color, sliceDir );

                case 'Polygon'
                    redrawSliceWithoutLabels( self );
                    drawPolygon( self.ROI, val, color, sliceDir );

                case 'PaintBrush'
                    redrawSliceWithoutLabels( self );
                    paint( self.ROI, val, color, sliceDir );

                case 'Eraser'
                    paint( self.ROI, 0, [ 1, 1, 1 ], sliceDir );

                case 'FillRegion'
                    fill( self.ROI, val, color, sliceDir );

                case 'FloodFill'

                    val = self.ROI.getMeanSuperpixelValues( sliceDir );
                    if isempty( val )
                        wait( self.Container );
                        c = onCleanup( @(  )resume( self.Container ) );

                        sliceIdx = self.ROI.getSliceIndex( sliceDir );
                        evt = medical.internal.app.labeler.events.SliceEventData( sliceIdx, sliceDir );
                        notify( self, 'SliceRequestedForROI', evt );

                    end
                    floodFill( self.ROI, val, sliceDir );

            end

        end


        function updateROISlice( self, slice, labelSlice, sliceDir )

            updateSlice( self.ROI, slice, labelSlice, sliceDir );

        end


        function reactToLevelTraceSelection( self, TF, val, color )

            if TF
                self.ROI.startLevelTrace( val, color );
                threshold = self.Toolstrip.LevelTraceThreshold;
                self.ROI.setLevelTraceThreshold( threshold );
            else
                self.ROI.stopLevelTrace(  );
            end

        end


        function updateLevelTraceLabel( self, val, color )
            self.ROI.startLevelTrace( val, color );
        end

    end

    methods ( Access = protected )


        function addROIListeners( self )

            addlistener( self.ROI, 'SetPriorMask', @( src, evt )notify( self, 'SetPriorMask', evt ) );
            addlistener( self.ROI, 'ROIUpdated', @( src, evt )notify( self, 'RegionDrawn', evt ) );
            addlistener( self.ROI, 'ROIReassigned', @( src, evt )notify( self, 'LabelNamesForROIRequested', evt ) );
            addlistener( self.ROI, 'ROIPasted', @( src, evt )roiPasted( self, evt ) );
            addlistener( self.ROI, 'FillRegion', @( src, evt )notify( self, 'FillRegion', evt ) );
            addlistener( self.ROI, 'FloodFillRegion', @( src, evt )notify( self, 'FloodFillRegion', evt ) );
            addlistener( self.ROI, 'DrawingStarted', @( src, evt )disableForDrawing( self ) );
            addlistener( self.ROI, 'DrawingFinished', @( src, evt )enableForDrawing( self ) );
            addlistener( self.ROI, 'ROISelected', @( src, evt )enableInterpolation( self.Toolstrip, evt.NumberSelected == 1 ) );
            addlistener( self.ROI, 'AllROIsSelected', @( src, evt )notify( self, 'LocationSelected', evt ) );
            addlistener( self.ROI, 'DrawingAborted', @( src, evt )reactToDrawingAborted( self ) );

        end


        function reactToBrushSelection( self, TF )

            if TF

                if strcmp( self.Toolstrip.getActiveLabelingTool(  ), 'PaintBrush' )
                    self.ROI.setBrushColor( [ 0.5, 0.5, 0.5 ] );
                else
                    self.ROI.setBrushColor( [ 1, 1, 1 ] );
                end

            end

            self.ROI.setBrushOutline( TF );

        end


        function reactToDrawingToolSelected( self )

            if self.Toolstrip.WindowLevelEnabled
                self.Slices.EnableWindowLevel = false;
                self.Toolstrip.WindowLevelEnabled = false;
            end

            self.reactToInteractionToolChange(  );

        end




        function reactToInteractionToolChange( self )

            self.ROI.deselectAll(  );
            self.Slices.deselectAxesInteraction(  );
            self.Slices.displayMode( self.Toolstrip.getActiveLabelingTool(  ) );

            TF = any( strcmp( self.Toolstrip.getActiveLabelingTool(  ), { 'PaintBrush', 'Eraser' } ) );

            refreshRequired = TF ~= self.Slices.SuperpixelsVisible;

            self.Slices.SuperpixelsVisible = TF;

            if refreshRequired
                self.Slices.refresh(  );
            end

        end


        function reactToDrawingAborted( self )

            if self.Toolstrip.getHideLabelsOnDraw(  )
                self.Slices.refresh(  );
            end

        end


        function disableForDrawing( self )
            self.Slices.disableForDrawing(  );
            self.Toolstrip.disable(  );
            self.LabelBrowser.disable(  );
            self.Container.disableQuickAccessBar(  );
            self.DataBrowser.disable(  );
            self.Publish.disablePublish(  );
        end


        function enableForDrawing( self )
            self.Slices.enableForDrawing(  );
            self.Toolstrip.enable(  );
            self.LabelBrowser.enable(  );
            self.Container.enableQuickAccessBar(  );
            self.DataBrowser.enable(  );
            self.Publish.enablePublish(  );
        end


        function roiPasted( self, evt )

            notify( self, 'RegionPasted', evt );

            evt = medical.internal.app.labeler.events.SliceEventData( evt.SliceIdx, evt.SliceDirection );
            notify( self, 'SliceRequestedForROI', evt );

        end

    end




    events

        SliceAtIndexRequested
        SliceAtIndexRequestedForThumbnail
        RefreshSlice
        RefreshSliceWithoutLabels

        LabelRequested

        VoxelInfoRequested
        SaveSnapshot

        LabelOpacityChanged
        ContrastLimitsChanged

    end

    methods


        function initializeSlices( self, dataLimits, numSlicesTSC, pixelSpacingASC, isRGB )

            self.Slices.initialize( numSlicesTSC, pixelSpacingASC, dataLimits );
            self.Toolstrip.enableContrastControls( ~isRGB );
            self.Toolstrip.setWindowBounds( dataLimits );
            self.Publish.setNumSlices( numSlicesTSC );

            if self.DataFormat == medical.internal.app.labeler.enums.DataFormat.Image
                self.Toolstrip.InterpolationAllowed = numSlicesTSC > 1;
            end

        end


        function updateSlice( self, slice, labelSlice, labelColormap, labelVisible, currIdx, maxIdx, sliceDir )


            self.ROI.deselectAll(  );

            self.Slices.updateSlice( slice, labelSlice, labelColormap, labelVisible, currIdx, sliceDir );

            self.Toolstrip.displayAutomationRange( currIdx, maxIdx, sliceDir );
            self.ROI.updateBrushOutline(  );
            self.ROI.updateSliceIndex( currIdx, sliceDir );
            self.ROI.updateSlice( slice, labelSlice, sliceDir );

        end


        function sliceAtIndexProvidedForThumbnail( self, vol, labels, cmap, idx, maxIdx, sliceDir )


            self.Slices.updateThumbnailDisplay( vol, labels, cmap, idx, maxIdx, sliceDir );

        end


        function refreshSlice( self, slice, labelSlice, labelColormap, labelVisible, currIdx, maxIdx, sliceDir )

            self.Slices.updateSlice( slice, labelSlice, labelColormap, labelVisible, currIdx, sliceDir );
            self.ROI.clearBrush(  );

        end


        function labelsUpdated( self )

            self.Slices.refresh(  );
            if self.DataFormat == medical.internal.app.labeler.enums.DataFormat.Volume && self.Toolstrip.getShowVolume(  )
                self.VolumeRendering.markLabelVolumeAsDirty(  );
            end

        end


        function updateSummary( self, data, color, sliceDir )
            self.Slices.updateSummary( data, color, sliceDir );
        end


        function updateContrastLimits( self, contrastLimits )
            self.Slices.updateContrastLimits( contrastLimits );
            self.Toolstrip.setWindowBounds( contrastLimits );
        end

    end

    methods ( Access = private )


        function addSliceListeners( self )

            addlistener( self.Slices, 'ImageClicked', @( src, evt )reactToImageClick( self, evt.Position, evt.Index, evt.SliceDirection ) );
            addlistener( self.Slices, 'SliceAtIndexRequested', @( src, evt )self.notify( 'SliceAtIndexRequested', evt ) );
            addlistener( self.Slices, 'SliceChanged', @( src, evt )self.reactToSliceChanged( evt.Value ) );
            addlistener( self.Slices, 'RefreshSlice', @( src, evt )self.notify( 'RefreshSlice', evt ) );
            addlistener( self.Slices, 'RefreshSliceWithoutLabels', @( src, evt )self.notify( 'RefreshSliceWithoutLabels', evt ) );
            addlistener( self.Slices, 'InteractionModeChanged', @( src, evt )reactToModeChanged( self, evt.Mode ) );
            addlistener( self.Slices, 'VoxelInfoRequested', @( src, evt )self.notify( 'VoxelInfoRequested', evt ) );
            addlistener( self.Slices, 'ClearVoxelInfo', @( src, evt )self.Container.clearVoxelInfo(  ) );
            addlistener( self.Slices, 'ContrastLimitsChanged', @( src, evt )self.reactToContrastLimitsChanged( evt ) );

        end


        function reactToSelectedDocumentChanged( self, tag )

            if isempty( tag ) || isempty( self.Slices )
                return
            end

            if self.DataFormat == medical.internal.app.labeler.enums.DataFormat.Volume

                switch tag

                    case string( medical.internal.app.labeler.enums.Tag.TransverseFigure )

                        newSliceDir = medical.internal.app.labeler.enums.SliceDirection.Transverse;
                        self.Slices.LastActiveSliceDirection = newSliceDir;

                        if self.ROI.getIsUserDrawing
                            return
                        end


                        self.ROI.deselectAll( medical.internal.app.labeler.enums.SliceDirection.Sagittal );
                        self.ROI.deselectAll( medical.internal.app.labeler.enums.SliceDirection.Coronal );


                        self.ROI.clear( medical.internal.app.labeler.enums.SliceDirection.Sagittal );
                        self.ROI.clear( medical.internal.app.labeler.enums.SliceDirection.Coronal );

                    case string( medical.internal.app.labeler.enums.Tag.SagittalFigure )

                        newSliceDir = medical.internal.app.labeler.enums.SliceDirection.Sagittal;
                        self.Slices.LastActiveSliceDirection = newSliceDir;

                        if self.ROI.getIsUserDrawing
                            return
                        end


                        self.ROI.deselectAll( medical.internal.app.labeler.enums.SliceDirection.Transverse );
                        self.ROI.deselectAll( medical.internal.app.labeler.enums.SliceDirection.Coronal );


                        self.ROI.clear( medical.internal.app.labeler.enums.SliceDirection.Transverse );
                        self.ROI.clear( medical.internal.app.labeler.enums.SliceDirection.Coronal );

                    case string( medical.internal.app.labeler.enums.Tag.CoronalFigure )

                        newSliceDir = medical.internal.app.labeler.enums.SliceDirection.Coronal;
                        self.Slices.LastActiveSliceDirection = newSliceDir;

                        if self.ROI.getIsUserDrawing
                            return
                        end


                        self.ROI.deselectAll( medical.internal.app.labeler.enums.SliceDirection.Transverse );
                        self.ROI.deselectAll( medical.internal.app.labeler.enums.SliceDirection.Sagittal );


                        self.ROI.clear( medical.internal.app.labeler.enums.SliceDirection.Transverse );
                        self.ROI.clear( medical.internal.app.labeler.enums.SliceDirection.Sagittal );

                end

            end

        end


        function reactToImageClick( self, pos, idx, sliceDir )

            self.ROI.setClickPosition( pos, sliceDir );

            if strcmp( self.Toolstrip.getActiveLabelingTool(  ), 'Select' ) || self.Key.CtrlPressed
                evt = medical.internal.app.labeler.events.SliceEventData( idx, sliceDir );
                notify( self, 'LocationSelected', evt );
            else
                evt = medical.internal.app.labeler.events.ValueEventData( sliceDir );
                notify( self, 'LabelRequested', evt );
            end

        end


        function reactToSliceChanged( self, sliceDir )

            if self.Toolstrip.IsSuperPixelsActive
                sz = self.Toolstrip.getPaintBrushSize(  );
                self.paintBySuperpixels( sz, sliceDir )
            end

        end


        function reactToModeChanged( self, mode )

            currentLabelingTool = self.Toolstrip.getActiveLabelingTool(  );
            if strcmp( mode, '' ) && any( strcmp( currentLabelingTool, { 'PaintBrush', 'Eraser' } ) )
                self.ROI.setBrushOutline( true );
            else
                self.ROI.setBrushOutline( false );
            end

        end


        function redrawSliceWithoutLabels( self )

            if self.Toolstrip.getHideLabelsOnDraw(  )
                self.Slices.refreshWithoutLabels(  );
            end

        end


        function reactToLabelOpacityChange( self )

            opacity = self.Toolstrip.getLabelOpacity(  );


            self.Slices.LabelOpacity = single( opacity );

            evt = medical.internal.app.labeler.events.ValueEventData( opacity );
            self.notify( 'LabelOpacityChanged', evt )

            if self.DataFormat == medical.internal.app.labeler.enums.DataFormat.Volume && self.Toolstrip.getShowVolume(  )
                self.notify( 'RefreshLabelVolumeAlpha' );
            end

            drawnow( 'limitrate' );

        end


        function reactToContrastLimitsChanged( self, evt )

            self.Toolstrip.setWindowBounds( evt.Value );

            self.notify( 'ContrastLimitsChanged', evt );

        end


        function reactToOrientationMarkerVisibilityToggle( self, TF )
            self.Slices.showOrientationMarkers( TF );
        end


        function reactToScaleBarVisibilityToggle( self, TF )
            self.Slices.showScaleBar( TF );
            if self.DataFormat == medical.internal.app.labeler.enums.DataFormat.Volume
                self.VolumeRendering.setScaleBar( TF );
            end
        end


        function reactToDisplayConventionChanged( self, displayConvention )
            self.Slices.setDisplayConvention( displayConvention );
            notify( self, 'RedrawVolume' );
        end


        function snapshotRequested( self )

            wait( self.Container );
            c = onCleanup( @(  )resume( self.Container ) );

            switch self.DataFormat

                case medical.internal.app.labeler.enums.DataFormat.Volume

                    if self.IsCurrentDataOblique
                        sliceViewNames = [ "Direction 1", "Direction2", "Direction3", "3D Volume" ];
                    else
                        sliceViewNames = [ "Transverse", "Coronal", "Sagittal", "3D Volume" ];
                    end

                    loc = self.Container.getLocation(  );
                    [ selectedViews, filename, isCanceled ] = self.Dialog.snapshotVolumeMode( loc, sliceViewNames );

                    if isCanceled
                        return
                    else

                        sliceDirs = medical.internal.app.labeler.enums.SliceDirection.empty(  );
                        sliceIdxs = [  ];
                        snapshot3D = [  ];

                        for i = 1:length( selectedViews )

                            switch selectedViews( i )
                                case "Axial"
                                    sliceDir = medical.internal.app.labeler.enums.SliceDirection.Transverse;
                                    sliceDirs( end  + 1 ) = sliceDir;%#ok<*AGROW>
                                    sliceIdxs( end  + 1 ) = self.ROI.getSliceIndex( sliceDir );

                                case "Coronal"
                                    sliceDir = medical.internal.app.labeler.enums.SliceDirection.Coronal;
                                    sliceDirs( end  + 1 ) = sliceDir;
                                    sliceIdxs( end  + 1 ) = self.ROI.getSliceIndex( sliceDir );

                                case "Sagittal"
                                    sliceDir = medical.internal.app.labeler.enums.SliceDirection.Sagittal;
                                    sliceDirs( end  + 1 ) = sliceDir;
                                    sliceIdxs( end  + 1 ) = self.ROI.getSliceIndex( sliceDir );

                                case "Volume"



                                    if self.Toolstrip.AutoSave
                                        self.requestToSaveSession(  );
                                    else
                                        self.VolumeRendering.redraw(  );
                                    end

                                    messageShown = self.VolumeRendering.ShowMessageVolume;
                                    self.VolumeRendering.ShowMessageVolume = false;
                                    c1 = onCleanup( @(  )set( self.VolumeRendering, 'ShowMessageVolume', messageShown ) );

                                    volumeImgData = getframe( self.Container.VolumeDocument.Figure );
                                    snapshot3D = volumeImgData.cdata;
                            end

                        end

                        evt = medical.internal.app.labeler.events.SaveSnapshotEventData( filename, sliceIdxs, sliceDirs );
                        evt.Snapshot3D = snapshot3D;
                        self.notify( 'SaveSnapshot', evt );

                    end

                case medical.internal.app.labeler.enums.DataFormat.Image

                    [ filename, isCanceled ] = self.Dialog.snapshotImageSequenceMode(  );
                    if isCanceled
                        return
                    end

                    sliceDir = medical.internal.app.labeler.enums.SliceDirection.Unknown;
                    sliceIdx = self.ROI.getSliceIndex(  );
                    evt = medical.internal.app.labeler.events.SaveSnapshotEventData( filename, sliceIdx, sliceDir );
                    self.notify( 'SaveSnapshot', evt );

            end


        end


        function showVoxelInfo( self, TF )

            self.Slices.enableVoxelInfoListeners( TF );
            self.Container.showVoxelInfo( TF );

        end


        function enableWindowLevel( self, TF )

            if TF
                self.Toolstrip.deselectAllDrawingTools(  );
                self.ROI.clearBrush(  );
                self.reactToBrushSelection( false );
                self.ROI.stopLevelTrace(  );
            else
                self.Toolstrip.selectDefaultDrawingTool(  );
            end

            self.Slices.EnableWindowLevel = TF;

            self.reactToInteractionToolChange(  )

        end


        function showThumbnail( self, TF, pos )

            if TF
                switch self.Pointer.ActivePanel

                    case 'TransverseSummary'
                        sliceDir = medical.internal.app.labeler.enums.SliceDirection.Transverse;
                    case 'CoronalSummary'
                        sliceDir = medical.internal.app.labeler.enums.SliceDirection.Coronal;
                    case 'SagittalSummary'
                        sliceDir = medical.internal.app.labeler.enums.SliceDirection.Sagittal;
                    otherwise
                        self.Slices.hideThumbnail(  );

                end

                if pos > 1
                    evt = medical.internal.app.labeler.events.SliceEventData( pos, sliceDir );
                    self.notify( 'SliceAtIndexRequestedForThumbnail', evt );
                end

            else
                if ~isempty( self.Slices )
                    self.Slices.hideThumbnail(  );
                end
            end

        end
    end




    events

        ClearCurrentSession
        OpenSessionRequested
        SaveSessionRequested
        DataFromFileRequested
        VolumeFromFolderRequested
        GroundTruthFromFileRequested
        GroundTruthFromWkspRequested
        LabelDefsFromFileRequested
        ExportGroundTruthToFile
        ExportLabelDefsToFile

        ResetWindowLevel

        LevelTraceSelected
        InterpolateRequested

        PresetRenderingRequested
        UserDefinedRenderingRequested
        SaveUserDefinedRendering
        RemoveUserDefinedRendering
        ApplyRenderingToAllVolumes
        RefreshUserDefinedVolumeRenderings
        ShowLabelsInVolume
        RequestToCustomizeLabelsInVolume

        AutomationStarted
        AutomationStopped
        AutomationRangeUpdated
        AutomationDirectionUpdated

    end

    methods


        function newVolumeSessionRequested( self )

            if ~self.HasData && isequal( self.DataFormat, medical.internal.app.labeler.enums.DataFormat.Volume )
                return ;
            end

            if self.clearCurrentAppData(  )

                wait( self.Container );
                c = onCleanup( @(  )resume( self.Container ) );

                [ sessionFolder, isCanceled ] = self.Dialog.newSessionLocation( self.Container.getLocation(  ) );
                if isCanceled
                    return
                end

                self.notify( 'ClearCurrentSession' );
                self.clear(  );
                self.DataFormat = medical.internal.app.labeler.enums.DataFormat.Volume;

                evt = medical.internal.app.labeler.events.ValueEventData( sessionFolder );
                self.notify( 'LabelDataLocationSet', evt );

            end

        end


        function newImageSessionRequested( self )

            if ~self.HasData && isequal( self.DataFormat, medical.internal.app.labeler.enums.DataFormat.Image )
                return ;
            end

            if self.clearCurrentAppData(  )

                wait( self.Container );
                c = onCleanup( @(  )resume( self.Container ) );

                [ sessionFolder, isCanceled ] = self.Dialog.newSessionLocation( self.Container.getLocation(  ) );
                if isCanceled
                    return
                end

                self.notify( 'ClearCurrentSession' );
                self.clear(  );
                self.DataFormat = medical.internal.app.labeler.enums.DataFormat.Image;

                evt = medical.internal.app.labeler.events.ValueEventData( sessionFolder );
                self.notify( 'LabelDataLocationSet', evt );

            end

        end


        function reactToFirstDataAdded( self )

            self.HasData = true;

            self.Toolstrip.enableDataControls(  );

            self.Slices.Empty = false;


            self.reactToLabelBrowserChanges(  );

            if isempty( self.Slices.LastActiveSliceDirection )

                s.tag = string( medical.internal.app.labeler.enums.Tag.TransverseFigure );
                self.Container.App.SelectedChild = s;

            end

        end


        function setLabelOpacity( self, opacity )
            self.Toolstrip.setLabelOpacity( opacity );
        end


        function requestToRefreshRecentSessions( self )
            self.notify( 'RefreshRecentSessions' );
        end


        function refreshRecentSessions( self, folderpaths, dataFormats )
            self.Toolstrip.refreshRecentSessions( folderpaths, dataFormats );
        end


        function requestToRefreshUserDefinedVolumeRenderings( self )
            self.notify( 'RefreshUserDefinedVolumeRenderings' );
        end


        function disableSaveUserDefinedRenderings( self )
            self.Toolstrip.disableSaveUserDefinedRenderings(  );
        end


        function addUserDefinedRendering( self, renderingSettings )
            tags = [ renderingSettings.Tag ];
            renderingNames = [ renderingSettings.Name ];
            self.Toolstrip.addUserDefinedRendering( tags, renderingNames );
        end


        function refreshUserDefinedRenderings( self, renderingSettings )
            tags = [  ];
            renderingNames = [  ];

            if ~isempty( renderingSettings )
                tags = [ renderingSettings.Tag ];
                renderingNames = [ renderingSettings.Name ];
            end

            self.Toolstrip.refreshUserDefinedRenderings( tags, renderingNames );
        end


        function setAutomationRange( self, startVal, endVal )
            setAutomationRange( self.Toolstrip, startVal, endVal );
        end


        function setAutomationDirection( self, maxSliceIdx, sliceDir )

            currentSliceIdx = self.ROI.getSliceIndex( sliceDir );
            self.Toolstrip.setAutomationRangeBounds( currentSliceIdx, maxSliceIdx );

        end


        function cleanUpAfterAutomation( self )

            clearWaitBar( self );

            self.Slices.Enabled = true;
            self.Key.Enabled = true;
            self.Pointer.Enabled = true;
            self.enableForDrawing(  );

        end


        function setCustomRenderingPreset( self )
            preset = medical.internal.app.labeler.model.PresetRenderingOptions.CustomPreset;
            self.Toolstrip.setRenderingPreset( preset );
        end


        function importGroundTruthFromWksp( self, gTruthMed )

            title = getString( message( 'medical:medicalLabeler:importing' ) );
            msg = strcat( title, "..." );
            self.startWaitBar( title, msg );
            c = onCleanup( @(  )self.clearWaitBar(  ) );

            self.notify( 'GroundTruthFromWkspRequested', medical.internal.app.labeler.events.ValueEventData( gTruthMed ) );

        end


        function openSessionFromDirectory( self, directory )

            title = getString( message( 'medical:medicalLabeler:importing' ) );
            msg = strcat( title, "..." );
            self.startWaitBar( title, msg );
            c = onCleanup( @(  )self.clearWaitBar(  ) );

            self.clear(  );
            self.notify( 'ClearCurrentSession' );

            evt = medical.internal.app.labeler.events.ValueEventData( directory );
            self.notify( 'OpenSessionRequested', evt );

        end

    end

    methods ( Access = private )


        function addToolstripListeners( self )

            addlistener( self.Toolstrip, 'ErrorThrown', @( src, evt )self.error( evt.Message ) );


            addlistener( self.Toolstrip, 'NewVolumeSessionRequested', @( src, evt )self.newVolumeSessionRequested(  ) );
            addlistener( self.Toolstrip, 'NewImageSessionRequested', @( src, evt )self.newImageSessionRequested(  ) );
            addlistener( self.Toolstrip, 'OpenSessionRequested', @( src, evt )self.requestToOpenSession(  ) );
            addlistener( self.Toolstrip, 'OpenRecentSessionRequested', @( src, evt )self.requestToOpenRecentSession( evt.Value ) );
            addlistener( self.Toolstrip, 'SaveSessionRequested', @( src, evt )self.requestToSaveSession(  ) );
            addlistener( self.Toolstrip, 'ImportDataFromFile', @( src, evt )self.requestToImportDataFromFile(  ) );
            addlistener( self.Toolstrip, 'ImportVolumeFromFolder', @( src, evt )self.requestToImportVolumeFromDICOMFolder(  ) );
            addlistener( self.Toolstrip, 'ImportGroundTruthFromFile', @( src, evt )self.requestToImportGroundTruthFromFile(  ) );
            addlistener( self.Toolstrip, 'ImportGroundTruthFromWksp', @( src, evt )self.requestToImportGroundTruthFromWksp(  ) );
            addlistener( self.Toolstrip, 'ImportLabelDefsFromFile', @( src, evt )self.requestToImportLabelDefsFromFile(  ) );
            addlistener( self.Toolstrip, 'ShowVolume', @( src, evt )self.reactToVolumeVisibilityToggle( evt.Value ) );
            addlistener( self.Toolstrip, 'EnableWindowLevel', @( src, evt )self.enableWindowLevel( evt.Value ) );
            addlistener( self.Toolstrip, 'ResetWindowLevel', @( src, evt )self.notify( 'ResetWindowLevel' ) );
            addlistener( self.Toolstrip, 'LabelOpacityChanged', @( src, evt )self.reactToLabelOpacityChange(  ) );
            addlistener( self.Toolstrip, 'ShowVoxelInfo', @( src, evt )self.showVoxelInfo( evt.Value ) );
            addlistener( self.Toolstrip, 'ShowScaleBars', @( src, evt )reactToScaleBarVisibilityToggle( self, evt.Value ) );
            addlistener( self.Toolstrip, 'Show2DOrientationMarkers', @( src, evt )reactToOrientationMarkerVisibilityToggle( self, evt.Value ) );
            addlistener( self.Toolstrip, 'Show3DOrientationAxes', @( src, evt )reactToOrientationAxesVisibilityToggle( self, evt.Value ) );
            addlistener( self.Toolstrip, 'DisplayConventionChanged', @( src, evt )self.reactToDisplayConventionChanged( evt.Value ) );
            addlistener( self.Toolstrip, 'ViewShortcuts', @( src, evt )displayShortcuts( self ) );
            addlistener( self.Toolstrip, 'LayoutChangeRequested', @( src, evt )self.Container.setLayout( evt.Value ) );
            addlistener( self.Toolstrip, 'SnapshotRequested', @( src, evt )snapshotRequested( self ) );
            addlistener( self.Toolstrip, 'ShowPublishPanel', @( src, evt )self.reactToPublishPanelToggle( evt.Value ) );
            addlistener( self.Toolstrip, 'ExportGroundTruthToFile', @( src, evt )self.exportGroundTruthToFile(  ) );
            addlistener( self.Toolstrip, 'ExportLabelDefsToFile', @( src, evt )self.exportLabelDefsToFile(  ) );


            addlistener( self.Toolstrip, 'BrushSelected', @( src, evt )reactToBrushSelection( self, evt.Selected ) );
            addlistener( self.Toolstrip, 'BrushSizeChanged', @( src, evt )setBrushSize( self.ROI, evt.Size ) );
            addlistener( self.Toolstrip, 'LevelTraceSelected', @( src, evt )notify( self, 'LevelTraceSelected', evt ) );
            addlistener( self.Toolstrip, 'LevelTraceThresholdChanged', @( src, evt )setLevelTraceThreshold( self.ROI, evt.Value ) );
            addlistener( self.Toolstrip, 'PaintBySuperpixels', @( src, evt )paintBySuperpixels( self, evt.Size, [  ] ) );
            addlistener( self.Toolstrip, 'LabelToolSelected', @( src, evt )reactToDrawingToolSelected( self ) );
            addlistener( self.Toolstrip, 'InterpolateRequested', @( src, evt )reactToInterpolationRequest( self ) );
            addlistener( self.Toolstrip, 'InterpolateManually', @( src, evt )manuallyInterpolate( self ) );
            addlistener( self.Toolstrip, 'FloodFillSensitivityChanged', @( src, evt )setFloodFillSettings( self.ROI, evt.Size, evt.Sensitivity ) );


            addlistener( self.Toolstrip, 'AutomationStarted', @( src, evt )reactToAutomationStart( self, evt ) );
            addlistener( self.Toolstrip, 'AutomationStopped', @( src, evt )notify( self, 'AutomationStopped', evt ) );
            addlistener( self.Toolstrip, 'AutomationRangeUpdated', @( src, evt )notify( self, 'AutomationRangeUpdated', evt ) );
            addlistener( self.Toolstrip, 'AutomationDirectionUpdated', @( src, evt )notify( self, 'AutomationDirectionUpdated', evt ) );
            addlistener( self.Toolstrip, 'ManageAlgorithms', @( src, evt )manageAlgorithms( self ) );
            addlistener( self.Toolstrip, 'AddAlgorithm', @( src, evt )addAlgorithm( self, evt.VolumeBased ) );
            addlistener( self.Toolstrip, 'OpenSettings', @( src, evt )displaySettings( self.Dialog, getLocation( self.Container ), evt.Settings ) );
            addlistener( self.Toolstrip, 'CloseDialogs', @( src, evt )close( self.Dialog ) );
            addlistener( self.Toolstrip, 'ViewAutomationHelp', @( src, evt )displayAutomationHelp( self ) );


            addlistener( self.Toolstrip, 'RenderingEditorToggled', @( src, evt )self.reactToRenderingEditorToggle( evt.Value ) );
            addlistener( self.Toolstrip, 'PresetRenderingRequested', @( src, evt )self.notify( 'PresetRenderingRequested', evt ) );
            addlistener( self.Toolstrip, 'UserDefinedRenderingRequested', @( src, evt )self.notify( 'UserDefinedRenderingRequested', evt ) );
            addlistener( self.Toolstrip, 'SaveRenderingRequested', @( src, evt )self.saveRenderingRequested(  ) );
            addlistener( self.Toolstrip, 'ManageRenderingRequested', @( src, evt )self.manageCustomRenderingRequested( evt.Names, evt.Tags ) );
            addlistener( self.Toolstrip, 'ApplyRenderingToAllVolumes', @( src, evt )self.applyRenderingToAllVolumesRequested(  ) );
            addlistener( self.Toolstrip, 'BackgroundGradientToggled', @( src, evt )reactToBackgroundGradientToggle( self, evt.Value ) );
            addlistener( self.Toolstrip, 'BackgroundColorChangeRequested', @( src, evt )self.requestToChangeVolumeBackgroundColor(  ) );
            addlistener( self.Toolstrip, 'GradientColorChangeRequested', @( src, evt )self.requestToChangeVolumeGradientColor(  ) );
            addlistener( self.Toolstrip, 'RestoreBackgroundRequested', @( src, evt )self.restoreVolumeBackgroundRequested(  ) );

        end


        function TF = clearCurrentAppData( self )

            TF = true;
            if self.HasData || self.LabelBrowser.NumLabels > 0


                self.requestToSaveSession(  );

                question = getString( message( 'medical:medicalLabeler:newSessionQuestion' ) );
                title = getString( message( 'medical:medicalLabeler:removeData' ) );
                isCanceled = self.Dialog.askQuestion( self.Container.App, question, title );

                if isCanceled
                    TF = false;
                end

            end

        end


        function requestToOpenRecentSession( self, directory )

            if isequal( directory, self.SessionLocation )

                return
            end

            if self.clearCurrentAppData(  )
                self.openSessionFromDirectory( directory );
            end

        end


        function requestToOpenSession( self )

            if self.clearCurrentAppData(  )

                [ directory, isCanceled ] = self.Dialog.openSession(  );
                self.Container.bringToFront(  );

                if isCanceled || isequal( directory, self.SessionLocation )

                    return
                end

                self.openSessionFromDirectory( directory );

            end

        end


        function requestToSaveSession( self )

            self.startWaitBar( getString( message( 'medical:medicalLabeler:savingSession' ) ) );
            c = onCleanup( @(  )self.clearWaitBar(  ) );
            notify( self, 'SaveSessionRequested' );

        end


        function requestToImportDataFromFile( self )

            switch self.DataFormat
                case medical.internal.app.labeler.enums.DataFormat.Volume
                    [ filename, isCanceled ] = self.Dialog.importVolumeFromFile(  );

                case medical.internal.app.labeler.enums.DataFormat.Image
                    [ filename, isCanceled ] = self.Dialog.importImageSequenceFromFile(  );

            end

            self.Container.bringToFront(  );

            if ~isCanceled

                title = getString( message( 'medical:medicalLabeler:importing' ) );
                msg = strcat( title, "..." );
                self.startWaitBar( title, msg );
                c = onCleanup( @(  )self.clearWaitBar(  ) );

                self.notify( 'DataFromFileRequested', medical.internal.app.labeler.events.ValueEventData( filename ) );

            end

        end


        function requestToImportVolumeFromDICOMFolder( self )

            [ directory, isCanceled ] = self.Dialog.importVolumeFromDICOMFolder(  );
            self.Container.bringToFront(  );

            if ~isCanceled

                title = getString( message( 'medical:medicalLabeler:importing' ) );
                msg = strcat( title, "..." );
                self.startWaitBar( title, msg );
                c = onCleanup( @(  )self.clearWaitBar(  ) );

                evt = medical.internal.app.labeler.events.ValueEventData( directory );
                self.notify( 'VolumeFromFolderRequested', evt );

            end

        end


        function requestToImportGroundTruthFromFile( self )

            [ filename, isCanceled ] = self.Dialog.importGroundTruthFromFile(  );
            self.Container.bringToFront(  );

            if ~isCanceled

                title = getString( message( 'medical:medicalLabeler:importing' ) );
                msg = strcat( title, "..." );
                self.startWaitBar( title, msg );
                c = onCleanup( @(  )self.clearWaitBar(  ) );

                self.notify( 'GroundTruthFromFileRequested', medical.internal.app.labeler.events.ValueEventData( filename ) );

            end

        end


        function requestToImportGroundTruthFromWksp( self )

            loc = self.Container.getLocation(  );
            [ gTruthMed, isCanceled ] = self.Dialog.importGroundTruthFromWksp( loc );

            if ~isCanceled
                self.importGroundTruthFromWksp( gTruthMed );
            end

        end


        function requestToImportLabelDefsFromFile( self )

            [ filename, isCanceled ] = self.Dialog.importLabelDefsFromFile(  );
            self.Container.bringToFront(  );

            if ~isCanceled

                wait( self.Container );
                c = onCleanup( @(  )resume( self.Container ) );

                self.notify( 'LabelDefsFromFileRequested', medical.internal.app.labeler.events.ValueEventData( filename ) );

            end

        end


        function exportGroundTruthToFile( self )

            wait( self.Container );
            c = onCleanup( @(  )resume( self.Container ) );

            [ filename, isCanceled ] = self.Dialog.exportGroundTruthToFile(  );
            self.Container.bringToFront(  );

            if isCanceled
                return
            end

            if self.Toolstrip.AutoSave
                self.notify( 'SaveSessionRequested' );
            end

            evt = medical.internal.app.labeler.events.ValueEventData( filename );
            self.notify( 'ExportGroundTruthToFile', evt );

        end


        function exportLabelDefsToFile( self )

            wait( self.Container );
            c = onCleanup( @(  )resume( self.Container ) );

            [ filename, isCanceled ] = self.Dialog.exportLabelDefsToFile(  );
            self.Container.bringToFront(  );

            if isCanceled
                return
            end

            if self.Toolstrip.AutoSave
                self.notify( 'SaveSessionRequested' );
            end

            evt = medical.internal.app.labeler.events.ValueEventData( filename );
            self.notify( 'ExportLabelDefsToFile', evt );

        end


        function saveRenderingRequested( self )

            wait( self.Container );
            c = onCleanup( @(  )resume( self.Container ) );

            loc = self.Container.getLocation(  );
            [ renderingName, isCanceled ] = self.Dialog.saveRendering( loc );

            if isCanceled
                return
            end

            [ renderingStyle, colorCP, alphaCP ] = self.VolumeRendering.getRendering(  );
            tag = strcat( renderingName, '_', matlab.lang.internal.uuid );

            renderingInfo.Tag = tag;
            renderingInfo.Name = renderingName;
            renderingInfo.RenderingStyle = renderingStyle;
            renderingInfo.ColorControlPoints = colorCP;
            renderingInfo.AlphaControlPoints = alphaCP;

            evt = medical.internal.app.labeler.events.ValueEventData( renderingInfo );
            self.notify( 'SaveUserDefinedRendering', evt );


            self.Toolstrip.addUserDefinedRendering( tag, renderingName );


            self.Toolstrip.setRenderingPreset( tag );

        end


        function manageCustomRenderingRequested( self, names, tags )

            wait( self.Container );
            c = onCleanup( @(  )resume( self.Container ) );

            loc = self.Container.getLocation(  );
            [ removeRenderingTags, isCanceled ] = self.Dialog.manageCustomRendering( loc, names, tags );

            if isCanceled
                return
            end

            for idx = 1:length( removeRenderingTags )
                self.Toolstrip.removeUserDefinedRendering( removeRenderingTags( idx ) );
            end

            evt = medical.internal.app.labeler.events.ValueEventData( removeRenderingTags );
            self.notify( 'RemoveUserDefinedRendering', evt );

        end


        function applyRenderingToAllVolumesRequested( self )

            title = getString( message( 'medical:medicalLabeler:applyRenderingToAllDlgTitle' ) );
            question = getString( message( 'medical:medicalLabeler:applyRenderingToAllQuestion' ) );
            isCanceled = self.Dialog.askQuestion( self.Container.App, question, title );

            if isCanceled
                return
            end

            self.notify( 'ApplyRenderingToAllVolumes' );

        end


        function reactToAutomationStart( self, evt )

            self.Slices.Enabled = false;
            self.Key.Enabled = false;
            self.Pointer.Enabled = false;
            self.LabelBrowser.disable(  );
            self.DataBrowser.disable(  );
            self.ROI.deselectAll(  );

            if evt.VolumeBased
                self.startWaitBar( getString( message( 'images:segmenter:waitForAutomation' ) ) );
            end

            evt.Parent = self.Container.TransverseDocument.Figure;

            self.notify( 'AutomationStarted', evt );

            if ~isvalid( self )
                return ;
            end

        end


        function addAlgorithm( self, isVolumeBased )

            wait( self.Container );
            c = onCleanup( @(  )resume( self.Container ) );

            loc = self.Container.getLocation(  );
            [ isCanceled, alg ] = self.Dialog.addAlgorithm( loc, getString( message( 'images:segmenter:loadAlgorithmFile' ) ) );

            if ~isvalid( self )
                return ;
            end

            self.Container.bringToFront(  );

            if ~isCanceled
                self.Toolstrip.addAlgorithm( alg, isVolumeBased );
            end

        end


        function manageAlgorithms( self )

            wait( self.Container );
            c = onCleanup( @(  )resume( self.Container ) );

            loc = self.Container.getLocation(  );
            isCanceled = self.Dialog.manageAlgorithms( loc, getString( message( 'images:segmenter:manageAlgorithm' ) ) );

            if ~isvalid( self )
                return ;
            end

            if ~isCanceled
                self.Toolstrip.refreshAlgorithms(  );
            end

        end


        function paintBySuperpixels( self, sz, sliceDir )

            if isempty( sliceDir )

                switch self.DataFormat
                    case medical.internal.app.labeler.enums.DataFormat.Volume
                        sliceDir = [  ...
                            medical.internal.app.labeler.enums.SliceDirection.Transverse,  ...
                            medical.internal.app.labeler.enums.SliceDirection.Coronal,  ...
                            medical.internal.app.labeler.enums.SliceDirection.Sagittal
                            ];

                    case medical.internal.app.labeler.enums.DataFormat.Image
                        sliceDir = medical.internal.app.labeler.enums.SliceDirection.Unknown;

                end

            end

            for i = 1:length( sliceDir )

                if isempty( sz )

                    L = self.ROI.generateSuperpixels( [  ], sliceDir( i ) );
                    redrawRequired = ~isempty( self.Slices.getSuperpixelOverlay( sliceDir( i ) ) );
                    self.Slices.setSuperpixelOverlay( L, sliceDir( i ) );

                    if redrawRequired

                        self.Toolstrip.deselectPaintBySuperpixels(  );

                        sliceIdx = self.ROI.getSliceIndex( sliceDir( i ) );
                        evt = medical.internal.app.labeler.events.SliceEventData( sliceIdx, sliceDir( i ) );
                        self.notify( 'RefreshSlice', evt );

                    end

                else


                    sliceIdx = self.ROI.getSliceIndex( sliceDir( i ) );
                    evt = medical.internal.app.labeler.events.SliceEventData( sliceIdx, sliceDir( i ) );
                    self.notify( 'SliceRequestedForROI', evt );

                    L = self.ROI.generateSuperpixels( sz, sliceDir( i ) );
                    self.Slices.setSuperpixelOverlay( L, sliceDir( i ) );

                    self.notify( 'RefreshSlice', evt );

                end

            end

        end


        function reactToInterpolationRequest( self )

            sliceDir = self.Slices.LastActiveSliceDirection;
            [ roi, val ] = getSelection( self.ROI, sliceDir );

            if ~isempty( roi )

                deselectAll( self.ROI, self.Slices.LastActiveSliceDirection );

                currSliceIdx = self.ROI.getSliceIndex( sliceDir );

                evt = images.internal.app.segmenter.volume.events.ROIInterpolatedEventData( roi, [  ], val, currSliceIdx, [  ] );
                evt.SliceDirection = sliceDir;
                notify( self, 'InterpolateRequested', evt );

            end

        end
    end




    events

        RefreshLabelVolumeAlpha
        RedrawVolume

        RefreshLabels3D

        VolumeRenderingStyleChanged
        AlphaControlPtsUpdated
        ColorControlPtsUpdated

    end

    methods


        function updateVolume( self, vol, labels, tform, volumeBounds, axesLabels )

            showVolume = self.Toolstrip.getShowVolume(  );
            if showVolume

                self.VolumeRendering.updateVolume( vol, tform, volumeBounds );
                self.VolumeRendering.updateLabels( labels );
                self.VolumeRendering.setOrientationAxesLabels( axesLabels );

                self.VolumeRendering.setVolumeVisiblity( true );

            end

        end


        function updateLabels( self, labels )

            showVolume = self.Toolstrip.getShowVolume(  );
            if showVolume
                self.VolumeRendering.updateLabels( labels );
            end

        end


        function setVolumeRendering( self, renderingPreset, renderer, volAlphaCP, volColorCP )

            showVolume = self.Toolstrip.getShowVolume(  );
            if showVolume
                self.Toolstrip.setRenderingPreset( renderingPreset );
                self.VolumeRendering.setVolumeRendering( renderer, volAlphaCP, volColorCP );
            end

        end


        function updateLabelVolumeColor( self, labelColormap )
            self.VolumeRendering.updateLabelColor( labelColormap )
        end


        function updateLabelVolumeAlpha( self, labelAlphamap )
            labelOpacity = self.Toolstrip.getLabelOpacity(  );
            labelAlphamap = labelOpacity * labelAlphamap;
            self.VolumeRendering.updateLabelAlpha( labelAlphamap )
        end

    end

    methods ( Access = protected )


        function addVolumeRenderingListeners( self )

            addlistener( self.VolumeRendering, 'WarningThrown', @( src, evt )self.warning( evt.Message ) );
            addlistener( self.VolumeRendering, 'RefreshLabels3D', @( src, evt )self.notify( 'RefreshLabels3D' ) );

            addlistener( self.VolumeRendering, 'VolumeRenderingStyleChanged', @( src, evt )self.notify( 'VolumeRenderingStyleChanged', evt ) );
            addlistener( self.VolumeRendering, 'AlphaControlPtsUpdated', @( src, evt )self.notify( 'AlphaControlPtsUpdated', evt ) );
            addlistener( self.VolumeRendering, 'ColorControlPtsUpdated', @( src, evt )self.notify( 'ColorControlPtsUpdated', evt ) );
            addlistener( self.VolumeRendering, 'RedrawVolume', @( src, evt )self.notify( 'RedrawVolume' ) );
            addlistener( self.VolumeRendering, 'BringAppToFront', @( src, evt )self.Container.bringToFront(  ) );

        end


        function requestToChangeVolumeBackgroundColor( self )

            color = uisetcolor( self.VolumeRendering.getVolumeBackgroundColor(  ),  ...
                getString( message( 'images:volumeViewer:backgroundColorButtonLabel' ) ) );

            self.Container.bringToFront(  );

            self.Toolstrip.setBackgroundColor( color );
            self.VolumeRendering.setVolumeBackgroundColor( color );
            set( self.Container.VolumeDocument.Figure, 'Color', color );

        end


        function requestToChangeVolumeGradientColor( self )

            color = uisetcolor( self.VolumeRendering.getVolumeBackgroundColor(  ),  ...
                getString( message( 'images:volumeViewer:backgroundColorButtonLabel' ) ) );

            self.Container.bringToFront(  );

            self.Toolstrip.setGradientColor( color );
            self.VolumeRendering.setVolumeGradientColor( color );
            set( self.Container.VolumeDocument.Figure, 'Color', color );

        end


        function reactToBackgroundGradientToggle( self, TF )
            self.VolumeRendering.setBackgroundGradient( TF );
        end


        function restoreVolumeBackgroundRequested( self )

            self.VolumeRendering.restoreVolumeBackground(  );


            useGradient = self.VolumeRendering.getBackgroundGradient(  );
            backgroundColor = self.VolumeRendering.getVolumeBackgroundColor(  );
            gradientColor = self.VolumeRendering.getVolumeGradientColor(  );
            self.Toolstrip.setVolumeBackgroundSettings( useGradient, backgroundColor, gradientColor );

        end


        function reactToVolumeVisibilityToggle( self, TF )



            if TF
                wait( self.Container );
                c = onCleanup( @(  )resume( self.Container ) );
            end



            TFRenderingEditor = self.Toolstrip.getShowRenderingEditor(  );
            self.Container.showRenderingEditor( TF & TFRenderingEditor )



            if TF && self.HasData
                self.VolumeRendering.redraw(  );
            end


            self.VolumeRendering.setVolumeVisiblity( TF );


            self.Publish.enable3DScreenshot( TF );

        end


        function reactToOrientationAxesVisibilityToggle( self, TF )
            self.VolumeRendering.setOrientationAxes( TF );
        end

    end

end
