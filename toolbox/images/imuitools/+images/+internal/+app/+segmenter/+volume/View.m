classdef View < handle

    properties ( Transient, SetAccess = protected, GetAccess = {  ...
            ?images.uitest.factory.Tester,  ...
            ?uitest.factory.Tester,  ...
            ?medical.internal.app.home.labeler.View } )

        Container

        Toolstrip images.internal.app.segmenter.volume.display.Toolstrip

        Slice

        Slider images.internal.app.segmenter.volume.display.Slider

        Volume

        OverviewVolume

        ROI images.internal.app.segmenter.volume.display.ROI

        Labels

        Dialog images.internal.app.segmenter.volume.display.Dialog

        Pointer images.internal.app.segmenter.volume.display.Pointer

        Key images.internal.app.segmenter.volume.display.Key

        Summary images.internal.app.segmenter.volume.display.Summary

    end




    methods




        function self = View( show3DDisplay, useWebVersion, showMetrics )

            if isempty( show3DDisplay )
                show3DDisplay = true;
            end


            wireUpToolstrip( self, show3DDisplay, useWebVersion, showMetrics );


            wireUpContainer( self, show3DDisplay, useWebVersion );

            addTabs( self.Container, self.Toolstrip.Tabs );

            open( self.Container );

            wait( self.Container );

            wireUpVolume( self, show3DDisplay, useWebVersion );
            wireUpOverviewVolume( self, show3DDisplay, useWebVersion );

            drawnow;

            wireUpLabels( self );
            wireUpSummary( self );
            wireUpSlice( self );
            wireUpSlider( self );
            wireUpROI( self );
            wireUpPointer( self );
            wireUpKey( self );
            wireUpDialog( self );

            preload( self.ROI, self.Slice.ImageHandle );

            addlistener( self.Container, 'AppResized', @( ~, ~ )updateAppPosition( self ) );

            setEmptyState( self.Toolstrip );

            drawnow;

            updateAppPosition( self );

            drawnow;

            if ~isvalid( self )
                return ;
            end

            resume( self.Container );

            updateAppPosition( self );

            self.Container.CanAppClose = true;

            if self.Container.CloseRequested
                close( self.Container );
                drawnow;
            end

        end

    end








    events



        AppCleared


        AppClosed

    end

    methods




        function enableUndoRedo( self, canUndo, canRedo )

            enableUndo( self.Container, canUndo );
            enableRedo( self.Container, canRedo );

        end

    end

    methods ( Access = protected )


        function updateAppPosition( self )

            resize( self.Labels, self.Container.LabelPosition );
            resize( self.Summary, self.Container.SummaryPosition );
            resize( self.Slider, self.Container.SliderPosition );
            resize( self.Slice, self.Container.SlicePosition );
            resize( self.Volume, self.Container.VolumePosition );
            resize( self.OverviewVolume, self.Container.OverviewPosition );

        end


        function clearApp( self )

            isCanceled = promptToSaveData( self );

            if ~isCanceled

                wait( self.Container );
                setEmptyState( self.Toolstrip );
                clear( self.Container );
                clear( self.Labels );
                clear( self.ROI );
                clear( self.Volume );
                clear( self.OverviewVolume );
                clear( self.Slice );
                clear( self.Slider );
                clear( self.Summary );
                close( self.Dialog );

                drawnow;

                if ~isvalid( self )
                    return ;
                end

                resume( self.Container );

                notify( self, 'AppCleared' );

            end

        end


        function closeApp( self )

            if ~isvalid( self )
                return ;
            end

            if ~self.Container.CanAppClose
                vetoClose( self.Container );
                return ;
            end

            isCanceled = promptToSaveData( self );

            if isCanceled && isvalid( self.Container.SliceFigure )

                vetoClose( self.Container );

            else

                approveClose( self.Container );
                closeAll( self.Dialog );
                delete( self.Toolstrip );
                notify( self, 'AppClosed' );
                delete( self );

            end

        end


        function reactToCopyPasteUpdate( self, canCopy, canPaste )

            enableCut( self.Container, canCopy );
            enableCopy( self.Container, canCopy );
            enablePaste( self.Container, canPaste );

        end


        function wireUpContainer( self, show3DDisplay, useWebVersion )

            if ~matlab.internal.lang.capability.Capability.isSupported( matlab.internal.lang.capability.Capability.LocalClient ) || useWebVersion

                self.Container = images.internal.app.segmenter.volume.display.WebContainer( show3DDisplay );
            else


                self.Container = images.internal.app.segmenter.volume.display.ToolgroupContainer( show3DDisplay );
            end

            addContainerListeners( self );

        end

        function addContainerListeners( self )

            addlistener( self.Container, 'AppClosed', @( ~, ~ )closeApp( self ) );
            addlistener( self.Container, 'AppLayoutUpdated', @( src, evt )updateLayoutState( self.Toolstrip, evt.VolumeVisible, evt.LabelVisible, evt.OverviewVisible ) );
            addlistener( self.Container, 'UndoRequested', @( ~, ~ )reactToUndoRequest( self ) );
            addlistener( self.Container, 'RedoRequested', @( ~, ~ )reactToRedoRequest( self ) );
            addlistener( self.Container, 'SaveRequested', @( ~, ~ )save( self.Toolstrip ) );
            addlistener( self.Container, 'HelpRequested', @( ~, ~ )doc( 'volumeSegmenter' ) );
            addlistener( self.Container, 'CutRequested', @( ~, ~ )cut( self.ROI ) );
            addlistener( self.Container, 'CopyRequested', @( ~, ~ )copy( self.ROI ) );
            addlistener( self.Container, 'PasteRequested', @( ~, ~ )paste( self.ROI ) );

        end

    end




    events



        SliceAtLocationRequestedForDialog



        SummaryRequestedForDialog



        InterpolateManually



        AcceptBlockAutomationResults

        AcceptAutomationResults

        ConvertAdapter

    end

    methods




        function error( self, msg )

            if isa( self.Container, 'images.internal.app.segmenter.volume.display.WebContainer' )
                webDisplayError( self.Dialog, self.Container.SliceFigure, msg, getString( message( 'images:segmenter:error' ) ) );
            else
                displayError( self.Dialog, msg, getString( message( 'images:segmenter:error' ) ) );
            end
            resume( self.Container );

        end




        function reassignLabels( self, names )

            if numel( names ) > 1

                wait( self.Container );

                name = displayFilter( self.Dialog, getLocation( self.Container ), getString( message( 'images:segmenter:reassignDialogTitle' ) ), getString( message( 'images:segmenter:reassignDialogMessage' ) ), names );

                if ~isvalid( self )
                    return ;
                end

                resume( self.Container );

                if ~isempty( name )

                    notify( self, 'RegionDrawn', images.internal.app.segmenter.volume.events.ROIEventData(  ...
                        self.ROI.ReassignmentMask,  ...
                        name,  ...
                        logical.empty,  ...
                        0 ) );

                end

            end

        end




        function customizeLabelVisibility( self, names, alpha )

            customAlpha = alpha( 2:numel( names ) + 1 );

            wait( self.Container );

            [ customAlpha, isCanceled ] = displayLabelVisiblity( self.Dialog, getLocation( self.Container ), names, customAlpha );

            if ~isvalid( self )
                return ;
            end

            resume( self.Container );

            if ~isCanceled

                alpha( 2:numel( names ) + 1 ) = customAlpha;
                notify( self, 'ShowLabelsInVolume', images.internal.app.segmenter.volume.events.ShowVolumeChangedEventData( alpha ) );

            end

        end




        function manuallyInterpolate( self )

            wait( self.Container );

            [ roi, val, mask ] = getSelection( self.ROI );

            [ pos1, pos2, idx1, idx2, val, isCanceled ] = displayRegionSelector(  ...
                self.Dialog, getLocation( self.Container ), self.Slice.Alpha,  ...
                self.Toolstrip.ContrastLimits, self.Slice.RotationState, roi, val, mask );

            if ~isvalid( self )
                return ;
            end

            resume( self.Container );

            if ~isCanceled

                deselectAll( self.ROI );
                notify( self, 'InterpolateManually', images.internal.app.segmenter.volume.events.ROIInterpolatedEventData( pos1, pos2, val, idx1, idx2 ) );

            end

        end




        function sliceAtIndexProvidedForDialog( self, vol, labels, cmap, idx, maxIdx )


            updateRegionSelector( self.Dialog, vol, labels, cmap, idx, maxIdx );

        end




        function updateDialogSummary( self, data, color )

            updateDialogSummary( self.Dialog, data, color );

        end




        function startWaitBar( self, msg )
            startWaitBar( self.Dialog,  ...
                isa( self.Container, 'images.internal.app.segmenter.volume.display.WebContainer' ),  ...
                self.Container.SliceFigure, msg );
        end




        function clearWaitBar( self )
            clearWaitBar( self.Dialog );
            resume( self.Container );
        end




        function reviewBlockedImageResults( self, bim, blabels, names, metrics, blockFileNames, useOriginalData, blockMap, r, g, b, cmap )

            wait( self.Container );
            clearWaitBar( self.Dialog );

            if ~isa( blabels, 'blockedImage' )

                categoricalLabels = blabels;
                blabels = uint8( blabels );
            end

            [ selectedBlocks, completedBlocks ] = displayBlockReviewer(  ...
                self.Dialog, getLocation( self.Container ), bim, blabels, names, metrics, blockFileNames,  ...
                self.Slice.Alpha, self.Toolstrip.ContrastLimits, useOriginalData, blockMap, r, g, b, cmap );

            if ~isvalid( self )
                return ;
            end

            if ~isa( blabels, 'blockedImage' )


                notify( self, 'AcceptAutomationResults', images.internal.app.segmenter.volume.events.AcceptResultsEventData( selectedBlocks, categoricalLabels ) );
            else
                notify( self, 'AcceptBlockAutomationResults', images.internal.app.segmenter.volume.events.AcceptResultsEventData( selectedBlocks, completedBlocks ) );
            end

            resume( self.Container );

        end




        function requestToConvertLabels( self, bim )

            if isa( self.Container, 'images.internal.app.segmenter.volume.display.WebContainer' )
                answer = webDisplayQuestion( self.Dialog, self.Container.SliceFigure,  ...
                    getString( message( 'images:segmenter:convertAdapter' ) ),  ...
                    getString( message( 'images:segmenter:convertAdapterTitle' ) ) );
            else
                answer = displayQuestion( self.Dialog, getString( message( 'images:segmenter:convertAdapter' ) ),  ...
                    getString( message( 'images:segmenter:convertAdapterTitle' ) ) );
            end

            if ~isvalid( self )
                return ;
            end

            if strcmp( answer, 'yes' )

                [ path, isCanceled ] = saveBlockedLabelsToFolder( self.Dialog );
                file = '';

                if ~isvalid( self )
                    return ;
                end

                if ~isCanceled

                    loc = fullfile( path, file );

                    notify( self, 'ConvertAdapter', images.internal.app.segmenter.volume.events.ConvertAdapterEventData( bim, loc ) );

                end

            end

            resume( self.Container );

        end

    end

    methods ( Access = protected )


        function isCanceled = promptToSaveData( self )

            if self.Toolstrip.AutoSave && ~self.Toolstrip.SaveAsRequired


                if ~isDataSaved( self.Toolstrip )
                    save( self.Toolstrip );
                end

            elseif ~isDataSaved( self.Toolstrip )

                if isa( self.Container, 'images.internal.app.segmenter.volume.display.WebContainer' )
                    answer = webDisplayQuestion( self.Dialog, self.Container.SliceFigure,  ...
                        getString( message( 'images:segmenter:saveBeforeClose' ) ),  ...
                        getString( message( 'images:segmenter:saveBeforeCloseTitle' ) ) );
                else
                    answer = displayQuestion( self.Dialog, getString( message( 'images:segmenter:saveBeforeClose' ) ),  ...
                        getString( message( 'images:segmenter:saveBeforeCloseTitle' ) ) );
                end

                if strcmp( answer, 'cancel' )

                    isCanceled = true;
                    return ;

                elseif strcmp( answer, 'yes' )

                    save( self.Toolstrip );

                    if ~isDataSaved( self.Toolstrip )
                        isCanceled = true;
                        return ;
                    end

                else

                end
            end

            isCanceled = false;

        end


        function manageAlgorithms( self )

            wait( self.Container );

            isCanceled = manageAlgorithms( self.Dialog, getLocation( self.Container ), getString( message( 'images:segmenter:manageAlgorithm' ) ) );

            if ~isvalid( self )
                return ;
            end

            resume( self.Container );

            if ~isCanceled

                refreshAlgorithms( self.Toolstrip );

            end

        end


        function addAlgorithm( self, isVolumeBased )

            wait( self.Container );

            [ isCanceled, alg ] = addAlgorithm( self.Dialog, getLocation( self.Container ), getString( message( 'images:segmenter:loadAlgorithmFile' ) ) );

            if ~isvalid( self )
                return ;
            end

            bringToFront( self.Container );
            resume( self.Container );

            if ~isCanceled

                addAlgorithm( self.Toolstrip, alg, isVolumeBased );

            end

        end

        function displayShortcuts( self )
            displayShortcuts( self.Dialog, getLocation( self.Container ) );
        end


        function wireUpDialog( self )

            self.Dialog = images.internal.app.segmenter.volume.display.Dialog(  );
            addDialogListeners( self );

        end

        function addDialogListeners( self )

            addlistener( self.Dialog, 'SliceAtLocationRequested', @( src, evt )notify( self, 'SliceAtLocationRequestedForDialog', evt ) );
            addlistener( self.Dialog, 'UpdateDialogSummary', @( src, evt )notify( self, 'SummaryRequestedForDialog', evt ) );
            addlistener( self.Dialog, 'ThrowError', @( src, evt )error( self, evt.Message ) );

        end

    end




    events



        UndoRequested



        RedoRequested

    end

    methods



    end

    methods ( Access = protected )


        function reactToKeyPress( self, evt )

            if self.ROI.IsUserDrawing

                switch evt.Key

                    case 'ctrl+'
                        zoomIn( self.Slice );
                    case 'ctrl-'
                        zoomOut( self.Slice );
                    case 'panup'
                        pan( self.Slice, 'up' );
                    case 'pandown'
                        pan( self.Slice, 'down' );
                    case 'panleft'
                        pan( self.Slice, 'left' );
                    case 'panright'
                        pan( self.Slice, 'right' );

                end

            else

                switch evt.Key

                    case 'ctrla'
                        notify( self, 'LocationSelected' );
                    case 'ctrlc'
                        copy( self.ROI );
                    case 'ctrls'
                        save( self.Toolstrip );
                    case 'ctrlv'
                        paste( self.ROI );
                    case 'ctrlx'
                        cut( self.ROI )
                    case 'ctrly'
                        reactToRedoRequest( self );
                    case 'ctrlz'
                        reactToUndoRequest( self );
                    case 'down'
                        down( self.Labels );
                    case 'up'
                        up( self.Labels );
                    case 'left'
                        if ~strcmp( self.Pointer.ActivePanel, 'EntryPanel' )
                            previous( self.Slider );
                        end
                    case 'right'
                        if ~strcmp( self.Pointer.ActivePanel, 'EntryPanel' )
                            next( self.Slider );
                        end
                    case 'delete'
                        deleteSelected( self.ROI );
                    case 'ctrl+'
                        zoomIn( self.Slice );
                    case 'ctrl-'
                        zoomOut( self.Slice );
                    case { 'return', 'escape' }
                        deselectAll( self.ROI );
                    case 'panup'
                        pan( self.Slice, 'up' );
                    case 'pandown'
                        pan( self.Slice, 'down' );
                    case 'panleft'
                        pan( self.Slice, 'left' );
                    case 'panright'
                        pan( self.Slice, 'right' );
                    case 'blockup'
                        if self.Toolstrip.UseBlockedImage
                            moveBlock( self.Slice, 'up' );
                        end
                    case 'blockdown'
                        if self.Toolstrip.UseBlockedImage
                            moveBlock( self.Slice, 'down' );
                        end
                    case 'blockleft'
                        if self.Toolstrip.UseBlockedImage
                            moveBlock( self.Slice, 'left' );
                        end
                    case 'blockright'
                        if self.Toolstrip.UseBlockedImage
                            moveBlock( self.Slice, 'right' );
                        end
                end

            end

        end


        function reactToScrollWheel( self, evt )

            switch self.Pointer.ActivePanel

                case 'VolumePanel'
                    scroll( self.Volume, evt.VerticalScrollCount );
                case 'EntryPanel'
                    scroll( self.Labels, evt.VerticalScrollCount );
                case 'SlicePanel'
                    scroll( self.Slice, evt.VerticalScrollCount );
                case 'OverviewPanel'
                    scroll( self.OverviewVolume, evt.VerticalScrollCount );

            end

        end


        function reactToSliceClick( self, clickType )

            if strcmp( clickType, 'right' )
                updateContextMenu( self.ROI );
            end

        end


        function reactToUndoRequest( self )

            deselectAll( self.ROI );
            notify( self, 'UndoRequested' )

        end


        function reactToRedoRequest( self )

            deselectAll( self.ROI );
            notify( self, 'RedoRequested' )

        end


        function wireUpKey( self )

            self.Key = images.internal.app.segmenter.volume.display.Key( self.Container.SliceFigure, self.Container.VolumeFigure, self.Container.LabelFigure, self.Container.OverviewFigure );

            addlistener( self.Key, 'KeyPressed', @( src, evt )reactToKeyPress( self, evt ) );
            addlistener( self.Key, 'ScrollWheelSpun', @( src, evt )reactToScrollWheel( self, evt ) );
            addlistener( self.Key, 'WindowClicked', @( src, evt )reactToSliceClick( self, evt.ClickType ) );

        end

    end




    events


        LabelCreated


        LabelNameEdited


        LabelDeleted


        LabelColorChanged



        LabelColorsReset



        LabelSelected

    end

    methods




        function labelNamesUpdated( self, names, color, ~, selectedIndex )

            self.Toolstrip.EligibleToSaveAsLogical = numel( names ) == 1;

            if ~self.Slice.Empty
                addTitleBarAsterisk( self.Container );
                markSaveAsDirty( self.Toolstrip );
            end

            update( self.Labels, selectedIndex, names, color );

            if isempty( names )
                displayLabelColor( self.Slice, [ 0, 0, 0 ] );
            else
                displayLabelColor( self.Slice, getCurrentColor( self.Labels ) );
            end

        end

    end

    methods ( Access = protected )


        function reactToColorChange( self, evt )

            displayLabelColor( self.Slice, evt.Color );
            notify( self, 'LabelColorChanged', evt );

        end


        function reactToLabelSelection( self, evt )

            displayLabelColor( self.Slice, evt.Color );
            notify( self, 'LabelSelected', evt )

        end


        function reactToLabelRemoved( self, label )

            if isa( self.Container, 'images.internal.app.segmenter.volume.display.WebContainer' )
                answer = webDisplayQuestion( self.Dialog, self.Container.LabelFigure,  ...
                    getString( message( 'images:segmenter:deleteLabelLong', label ) ),  ...
                    getString( message( 'images:segmenter:deleteLabelShort', label ) ) );

                drawnow;

            else
                answer = displayQuestion( self.Dialog, getString( message( 'images:segmenter:deleteLabelLong', label ) ),  ...
                    getString( message( 'images:segmenter:deleteLabelShort', label ) ) );
            end

            if strcmp( answer, 'yes' )
                removeLabel( self, label )
            end

        end

        function removeLabel( self, label )

            wait( self.Container );
            clearClipboard( self.ROI );
            notify( self, 'LabelDeleted', images.internal.app.segmenter.volume.events.LabelEventData(  ...
                label ) );
            if self.Toolstrip.UseBlockedImage
                markSaveAsClean( self );
            end

        end


        function wireUpLabels( self )

            self.Labels = images.internal.app.segmenter.volume.display.Labels( self.Container.LabelFigure, self.Container.LabelPosition );
            addLabelsListeners( self );

        end

        function addLabelsListeners( self )
            addlistener( self.Labels, 'NameChanged', @( src, evt )notify( self, 'LabelNameEdited', evt ) );
            addlistener( self.Labels, 'ColorChanged', @( src, evt )reactToColorChange( self, evt ) );
            addlistener( self.Labels, 'LabelAdded', @( ~, ~ )notify( self, 'LabelCreated' ) );
            addlistener( self.Labels, 'EntrySelected', @( src, evt )reactToLabelSelection( self, evt ) );
            addlistener( self.Labels, 'EntryRemoved', @( src, evt )reactToLabelRemoved( self, evt.Label ) );

        end

    end




    methods ( Access = protected )


        function wireUpPointer( self )

            self.Pointer = images.internal.app.segmenter.volume.display.Pointer( self.Container.SliceFigure, self.Container.VolumeFigure, self.Container.LabelFigure, self.Container.OverviewFigure );

            addlistener( self.Pointer, 'SetDrawingToolPointer', @( ~, ~ )setDrawingToolPointer( self.Pointer, self.Container.SliceFigure, self.Toolstrip.ActiveLabelingTool ) );
            addlistener( self.Pointer, 'UpdateDatatip', @( src, evt )showDatatip( self.Volume, evt.Show ) );
            addlistener( self.Pointer, 'UpdateOverviewDatatip', @( src, evt )showDatatip( self.OverviewVolume, evt.Show ) );
            addlistener( self.Pointer, 'UpdateThumbnail', @( src, evt )showThumbnail( self, evt.Show, evt.Location ) );

        end

    end




    events


        RegionDrawn


        RegionPasted




        SetPriorMask


        FillRegion

        FloodFillRegion




        LabelNamesRequested

        SliceRequested

    end

    methods




        function selectAllROIs( self, label, cmap )

            selectAll( self.ROI, label, cmap );

        end




        function sliceSelected( self, ~, label, cmap, ~ )

            if self.Key.CtrlAPressed || self.ROI.SelectAll
                selectAll( self.ROI, label, cmap );
            elseif self.Key.CtrlPressed
                select( self.ROI, label, cmap );
            else
                selectWindow( self.ROI, label, cmap );
            end

        end




        function drawLabel( self, val, color )

            switch self.Toolstrip.ActiveLabelingTool
                case 'Freehand'
                    redrawSliceWithoutLabels( self );
                    draw( self.ROI, val, color );

                case 'AssistedFreehand'
                    redrawSliceWithoutLabels( self );
                    drawAssisted( self.ROI, val, color );

                case 'Polygon'
                    redrawSliceWithoutLabels( self );
                    drawPolygon( self.ROI, val, color );

                case 'PaintBrush'
                    redrawSliceWithoutLabels( self );
                    paint( self.ROI, val, color );

                case 'Eraser'
                    paint( self.ROI, 0, [ 1, 1, 1 ] );

                case 'FillRegion'
                    fill( self.ROI, val, color );

                case 'FloodFill'
                    if isempty( self.ROI.MeanSuperpixelValues )
                        wait( self.Container );
                        notify( self, 'SliceRequested' );
                    end
                    floodFill( self.ROI, val );
                    resume( self.Container );

            end

        end




        function updateROISlice( self, img, slice )

            updateSlice( self.ROI, img, slice );

        end

    end

    methods ( Access = protected )


        function reactToBrushSelection( self, TF )

            if TF

                if strcmp( self.Toolstrip.ActiveLabelingTool, 'PaintBrush' )
                    self.ROI.BrushColor = [ 0.5, 0.5, 0.5 ];
                else
                    self.ROI.BrushColor = [ 1, 1, 1 ];
                end

            end

            self.ROI.BrushOutline = TF;

        end


        function reactToDrawingToolChange( self )

            deselectAll( self.ROI );
            deselectAxesInteraction( self.Slice );
            deselectVoxelInfo( self.Toolstrip );
            displayMode( self.Slice, self.Toolstrip.ActiveLabelingTool );

            TF = any( strcmp( self.Toolstrip.ActiveLabelingTool, { 'PaintBrush', 'Eraser' } ) );

            redrawRequired = TF ~= self.Slice.ShowOverlay;

            self.Slice.ShowOverlay = TF;

            if redrawRequired
                notify( self, 'RedrawSlice' );
            end

        end


        function reactToDrawingAborted( self )

            if self.Toolstrip.HideLabelsOnDraw
                notify( self, 'RedrawSlice' );
            end

        end


        function disableForDrawing( self )
            self.Slider.Enabled = false;
            self.Summary.Enabled = false;
            disable( self.Toolstrip );
            disable( self.Labels );
            disableQuickAccessBar( self.Container );
        end


        function enableForDrawing( self )
            self.Slider.Enabled = true;
            self.Summary.Enabled = true;
            enable( self.Toolstrip );
            enable( self.Labels );
            enableQuickAccessBar( self.Container );
        end


        function roiPasted( self, evt )

            notify( self, 'RegionPasted', evt );
            notify( self, 'SliceRequested' );

        end


        function wireUpROI( self )

            self.ROI = images.internal.app.segmenter.volume.display.ROI(  );
            addROIListeners( self );

        end

        function addROIListeners( self )

            addlistener( self.ROI, 'SetPriorMask', @( src, evt )notify( self, 'SetPriorMask', evt ) );
            addlistener( self.ROI, 'ROIUpdated', @( src, evt )notify( self, 'RegionDrawn', evt ) );
            addlistener( self.ROI, 'ROIReassigned', @( ~, ~ )notify( self, 'LabelNamesRequested' ) );
            addlistener( self.ROI, 'ROIPasted', @( src, evt )roiPasted( self, evt ) );
            addlistener( self.ROI, 'FillRegion', @( src, evt )notify( self, 'FillRegion', evt ) );
            addlistener( self.ROI, 'FloodFillRegion', @( src, evt )notify( self, 'FloodFillRegion', evt ) );
            addlistener( self.ROI, 'DrawingStarted', @( ~, ~ )disableForDrawing( self ) );
            addlistener( self.ROI, 'DrawingFinished', @( ~, ~ )enableForDrawing( self ) );
            addlistener( self.ROI, 'ROISelected', @( src, evt )enableInterpolation( self.Toolstrip, evt.NumberSelected == 1 ) );
            addlistener( self.ROI, 'AllROIsSelected', @( ~, ~ )notify( self, 'LocationSelected' ) );
            addlistener( self.ROI, 'DrawingAborted', @( ~, ~ )reactToDrawingAborted( self ) );
            addlistener( self.ROI, 'CopyPasteUpdated', @( src, evt )reactToCopyPasteUpdate( self, evt.CanCopy, evt.CanPaste ) );

        end

    end




    events



        SliceDimensionChanged


        RedrawSlice



        RedrawSliceWithoutLabels




        SliceAtLocationRequestedForThumbnail



        LabelRequested




        LocationSelected

        VoxelInfoRequested

        BlockIndexShifted

    end

    methods




        function updateSlice( self, slice, label, cmap, currentSlice, maxSlice )

            deselectAll( self.ROI );
            displaySliceNumber( self.Slice, currentSlice, maxSlice );
            update( self.Slider, currentSlice, maxSlice );
            displayAutomationRange( self.Toolstrip, currentSlice, maxSlice );
            draw( self.Slice, slice, label, cmap, self.Toolstrip.ContrastLimits );
            drawIndicator( self.Summary, currentSlice, maxSlice );
            updateBrushOutline( self.ROI );
            updateSliceIndex( self.ROI, currentSlice );
            paintBySuperpixels( self, [  ] );
        end




        function redrawSlice( self, slice, label, cmap )

            draw( self.Slice, slice, label, cmap, self.Toolstrip.ContrastLimits );
            clearBrush( self.ROI );
        end




        function sliceAtIndexProvidedForThumbnail( self, vol, labels, cmap )


            updateThumbnailDisplay( self.Slice, vol, labels, cmap, self.Toolstrip.ContrastLimits );

        end




        function updateVoxelInfo( self, loc, val )
            updateVoxelInfo( self.Slice, loc, val );
        end

    end

    methods ( Access = protected )


        function reactToImageClick( self, pos )

            self.ROI.ClickPosition = pos;

            if strcmp( self.Toolstrip.ActiveLabelingTool, 'Select' ) || self.Key.CtrlPressed
                notify( self, 'LocationSelected' );
            else
                notify( self, 'LabelRequested' );
            end

        end


        function redrawSliceWithoutLabels( self )

            if self.Toolstrip.HideLabelsOnDraw
                notify( self, 'RedrawSliceWithoutLabels' );
            end

        end


        function updateLabelOpacity( self, alpha )

            self.Slice.Alpha = single( alpha );
            self.Volume.Alpha = alpha;
            self.OverviewVolume.Alpha = alpha;

            notify( self, 'RedrawSlice' );

        end


        function reactToSliceDimensionChange( self, evt )

            clearClipboard( self.ROI );
            paintBySuperpixels( self, [  ] );
            notify( self, 'SliceDimensionChanged', evt );

        end


        function rotateSlice( self, val )

            deselectAll( self.ROI );
            paintBySuperpixels( self, [  ] );
            rotate( self.Slice, val );
            rotate( self.ROI, val );

        end

        function reactToModeChanged( self, mode )

            if strcmp( mode, '' ) && any( strcmp( self.Toolstrip.ActiveLabelingTool, { 'PaintBrush', 'Eraser' } ) )
                self.ROI.BrushOutline = true;
            else
                self.ROI.BrushOutline = false;
            end

        end


        function showThumbnail( self, TF, pos )

            if TF
                notify( self, 'SliceAtLocationRequestedForThumbnail', images.internal.app.segmenter.volume.events.SliderMovingEventData( pos, [  ] ) );
            else
                hideThumbnail( self.Slice );
            end

        end


        function wireUpSlice( self )

            self.Slice = images.internal.app.segmenter.volume.display.Slice( self.Container.SliceFigure, self.Container.SlicePosition );
            setImageColors( self.Slice, [ 0, 0, 0 ], [ 0.5, 0.5, 0.5 ] );
            addSliceListeners( self );

        end

        function addSliceListeners( self )

            addlistener( self.Slice, 'ImageClicked', @( src, evt )reactToImageClick( self, evt.IntersectionPoint ) );
            addlistener( self.Slice, 'ImageRotated', @( ~, ~ )notify( self, 'RedrawSlice' ) );
            addlistener( self.Slice, 'InteractionModeChanged', @( src, evt )reactToModeChanged( self, evt.Mode ) );
            addlistener( self.Slice, 'UpdateDatatip', @( src, evt )notify( self, 'VoxelInfoRequested', evt ) );
            addlistener( self.Slice, 'BlockIndexShifted', @( src, evt )requestToReadNextBlock( self, evt ) );

        end

    end




    events



        NextSliceRequested



        PreviousSliceRequested

    end

    methods ( Access = protected )


        function wireUpSlider( self )

            self.Slider = images.internal.app.segmenter.volume.display.Slider( self.Container.SliceFigure, self.Container.SliderPosition );

            addlistener( self.Slider, 'NextPressed', @( ~, ~ )notify( self, 'NextSliceRequested' ) );
            addlistener( self.Slider, 'PreviousPressed', @( ~, ~ )notify( self, 'PreviousSliceRequested' ) );
            addlistener( self.Slider, 'SliderMoving', @( src, evt )notify( self, 'SliceAtLocationRequested', evt ) );

        end

    end




    events



        SliceAtLocationRequested

    end

    methods




        function updateSummary( self, data, color )

            draw( self.Summary, data, color );

        end

    end

    methods ( Access = protected )


        function wireUpSummary( self )

            self.Summary = images.internal.app.segmenter.volume.display.Summary( self.Container.SliceFigure, self.Container.SummaryPosition );

            addlistener( self.Summary, 'SummaryClicked', @( src, evt )notify( self, 'SliceAtLocationRequested', evt ) );

        end

    end




    events


        LabelNamesImported



        VolumeFromWorkspaceRequested



        VolumeFromFileRequested



        BlockedImageFromFileRequested



        BlockedLabelsFromFileRequested



        VolumeFromDICOMRequested



        LabelsFromFileRequested



        LabelsFromWorkspaceRequested



        SaveToWorkspaceRequested



        SaveToFileRequested



        AutomationStarted



        AutomationStopped



        AutomationRangeUpdated



        ReadNextBlock



        ReadPreviousBlock



        ReadBlockByIndex



        InterpolateRequested



        AutomateOnAllBlocks



        RedrawBlockOverview



        RegenerateBlockOverview

        MarkBlockComplete

        RGBLimitsUpdated

        MetricsUpdated

        GroundTruthDataLoaded

        AddCustomMetric

    end

    methods




        function markSaveAsClean( self )

            setTitleBarName( self.Container, '' );
            markSaveAsClean( self.Toolstrip );

        end




        function setBlockedImageOverview( self, vol, completedBlocks, blockHistory, idx, sz, cmap, amap, sizeInBlocks )

            setBlockedImageOverview( self.OverviewVolume, vol, completedBlocks, blockHistory, idx, sz, cmap, amap, sizeInBlocks );

            resume( self.Container );


            self.Toolstrip.SaveAsLogical = false;

        end




        function showBlockedImageTab( self, TF )
            showBlockedImageTab( self.Toolstrip, TF );
            showOverview( self, TF );
            setBlockToolbarVisibility( self.Slice, TF );

            if TF
                set3DDisplayFigureName( self.Container, 'Current Block' );
                setWireframe( self.Toolstrip, true );
            else
                set3DDisplayFigureName( self.Container, '3-D Display' );
            end

        end




        function updateBlockIndex( self, idx, sz, blockCompleted )
            updateBlockIndex( self.Toolstrip, idx, sz, blockCompleted );
        end




        function blockedLabelsLoaded( self )
            self.Toolstrip.SaveAsRequired = false;
            markSaveAsClean( self.Toolstrip );
            resume( self.Container );
        end




        function updateCompletionPercentage( self, pct )
            updateCompletionPercentage( self.Toolstrip, pct );
        end




        function cleanUpAfterAutomation( self )

            clearWaitBar( self );

            self.Slider.Enabled = true;
            self.Slice.Enabled = true;
            self.Summary.Enabled = true;
            self.Key.Enabled = true;
            self.Pointer.Enabled = true;
            enableForDrawing( self );

        end




        function setAutomationRange( self, startVal, endVal )
            setAutomationRange( self.Toolstrip, startVal, endVal );
        end




        function updateRGBLimits( self, R, G, B )
            updateRGBLimits( self.Toolstrip, R, G, B );
        end




        function setSaveLocation( self, loc, saveAsMATFile )

            self.Toolstrip.SavedName = loc;
            self.Toolstrip.SaveToMATFile = saveAsMATFile;
            self.Toolstrip.SaveAsRequired = false;

            setTitleBarName( self.Container, loc );
            removeTitleBarAsterisk( self.Container );
            markSaveAsClean( self.Toolstrip );

        end




        function updateBlockMetadata( self, evt )
            updateBlockMetadata( self.Toolstrip, evt );
        end




        function groundTruthLoaded( self, TF )
            enableQualityMetrics( self.Toolstrip, TF );
        end




        function updateSliceDimension( self, sliceDimension )
            self.Toolstrip.updateSliceDimension( sliceDimension )
        end

    end

    methods ( Access = protected )


        function importLabelNames( self )

            wait( self.Container );

            name = importLabelNames( self.Dialog, getLocation( self.Container ), getString( message( 'images:segmenter:importLabelNames' ) ), getString( message( 'images:segmenter:variables' ) ) );

            if ~isvalid( self )
                return ;
            end

            if ~isempty( name )

                notify( self, 'LabelNamesImported', images.internal.app.segmenter.volume.events.LabelEventData(  ...
                    name ) );

            end

            resume( self.Container );

        end


        function requestToLoadVolumeFromWorkspace( self, isBlocked )

            isCanceled = promptToSaveData( self );

            if isCanceled
                return ;
            end

            wait( self.Container );

            [ V, isCanceled ] = openVolumeFromWorkspace( self.Dialog, getLocation( self.Container ), isBlocked );

            if ~isvalid( self )
                return ;
            end

            resume( self.Container );

            if ~isCanceled
                self.Toolstrip.SaveAsRequired = true;
                deselectAll( self.ROI );
                wait( self.Container );
                notify( self, 'VolumeFromWorkspaceRequested', images.internal.app.segmenter.volume.events.VolumeEventData( V ) );
            end

            markSaveAsClean( self );

        end


        function requestToLoadVolumeFromFile( self )

            isCanceled = promptToSaveData( self );

            if isCanceled
                return ;
            end

            [ filename, isCanceled ] = openVolumeFromFile( self.Dialog );

            bringToFront( self.Container );

            if ~isCanceled
                self.Toolstrip.SaveAsRequired = true;
                deselectAll( self.ROI );
                wait( self.Container );
                notify( self, 'VolumeFromFileRequested', images.internal.app.segmenter.volume.events.VolumeEventData( filename ) );
            end

            markSaveAsClean( self );

        end


        function requestToLoadVolumeFromBlockedImage( self )

            isCanceled = promptToSaveData( self );

            if isCanceled
                return ;
            end

            [ filename, isCanceled ] = openBlockedImageFromFile( self.Dialog );

            bringToFront( self.Container );

            if ~isCanceled
                self.Toolstrip.SaveAsRequired = true;
                deselectAll( self.ROI );
                wait( self.Container );
                notify( self, 'BlockedImageFromFileRequested', images.internal.app.segmenter.volume.events.VolumeEventData( filename ) );
            end

            markSaveAsClean( self );

        end


        function requestToLoadVolumeFromBlockedImageFolder( self )

            isCanceled = promptToSaveData( self );

            if isCanceled
                return ;
            end

            [ filename, isCanceled ] = openVolumeFromDICOM( self.Dialog );

            if ~isCanceled
                self.Toolstrip.SaveAsRequired = true;
                deselectAll( self.ROI );
                wait( self.Container );
                notify( self, 'BlockedImageFromFileRequested', images.internal.app.segmenter.volume.events.VolumeEventData( filename ) );
            end

            markSaveAsClean( self );

        end


        function requestToLoadVolumeFromDICOM( self )

            isCanceled = promptToSaveData( self );

            if isCanceled
                return ;
            end

            [ directorySelected, isCanceled ] = openVolumeFromDICOM( self.Dialog );

            if ~isCanceled
                self.Toolstrip.SaveAsRequired = true;
                deselectAll( self.ROI );
                wait( self.Container );
                notify( self, 'VolumeFromDICOMRequested', images.internal.app.segmenter.volume.events.VolumeEventData( directorySelected ) );
            end

            markSaveAsClean( self );

        end


        function requestToLoadLabelsFromWorkspace( self )

            isCanceled = promptToSaveData( self );

            if isCanceled
                return ;
            end

            wait( self.Container );

            if self.Toolstrip.UseBlockedImage
                [ V, isCanceled ] = openBlockedImageFromWorkspace( self.Dialog, getLocation( self.Container ) );
            else
                [ V, isCanceled ] = openLabelsFromWorkspace( self.Dialog, getLocation( self.Container ) );
            end

            if ~isvalid( self )
                return ;
            end

            resume( self.Container );

            if ~isCanceled
                self.Toolstrip.SaveAsRequired = true;
                setTitleBarName( self.Container, '' );
                deselectAll( self.ROI );
                wait( self.Container );
                notify( self, 'LabelsFromWorkspaceRequested', images.internal.app.segmenter.volume.events.VolumeEventData( V ) );
            end

        end


        function requestToLoadLabelsFromFile( self )

            isCanceled = promptToSaveData( self );

            if isCanceled
                return ;
            end

            if self.Toolstrip.UseBlockedImage
                [ filename, isCanceled ] = openBlockedImageFromFolder( self.Dialog );
            else
                [ filename, isCanceled ] = openLabelsFromFile( self.Dialog );
            end

            bringToFront( self.Container );

            if ~isCanceled
                self.Toolstrip.SaveAsRequired = true;
                setTitleBarName( self.Container, '' );
                deselectAll( self.ROI );
                wait( self.Container );
                if self.Toolstrip.UseBlockedImage
                    notify( self, 'BlockedLabelsFromFileRequested', images.internal.app.segmenter.volume.events.VolumeEventData( filename ) );
                else
                    notify( self, 'LabelsFromFileRequested', images.internal.app.segmenter.volume.events.VolumeEventData( filename ) );
                end
            end

        end


        function requestToReadNextBlock( self, evt )

            isCanceled = promptToSaveData( self );

            if isCanceled
                return ;
            end

            deselectAll( self.ROI );
            wait( self.Container );

            self.OverviewVolume.SelectedBlock = [  ];

            notify( self, evt.EventName, evt );

            resume( self.Container );

        end


        function requestToSaveAsToWorkspace( self )

            wait( self.Container );

            [ varname, isLogical, isCanceled ] = saveLabelsToWorkspace( self.Dialog,  ...
                getLocation( self.Container ),  ...
                self.Toolstrip.SaveAsLogical,  ...
                self.Toolstrip.EligibleToSaveAsLogical );

            if ~isvalid( self )
                return ;
            end

            resume( self.Container );

            if ~isCanceled

                if self.Toolstrip.EligibleToSaveAsLogical
                    self.Toolstrip.SaveAsLogical = isLogical;
                end

                notify( self, 'SaveToWorkspaceRequested', images.internal.app.segmenter.volume.events.SaveEventData( varname, isLogical, false ) );

            end

        end


        function requestToSaveAsToFile( self )

            wait( self.Container );

            if self.Toolstrip.UseBlockedImage
                [ path, isCanceled ] = saveBlockedLabelsToFolder( self.Dialog );
                isLogical = false;
                file = '';
            else
                [ file, path, isLogical, isCanceled ] = saveLabelsToFile( self.Dialog,  ...
                    getLocation( self.Container ),  ...
                    self.Toolstrip.SaveAsLogical,  ...
                    self.Toolstrip.EligibleToSaveAsLogical );
            end

            if ~isvalid( self )
                return ;
            end

            if ~isCanceled

                loc = fullfile( path, file );

                if self.Toolstrip.EligibleToSaveAsLogical
                    self.Toolstrip.SaveAsLogical = isLogical;
                end

                notify( self, 'SaveToFileRequested', images.internal.app.segmenter.volume.events.SaveEventData( loc, isLogical, true ) );

            end

            resume( self.Container );

        end


        function importGroundTruthData( self )

            wait( self.Container );

            [ var, isCanceled ] = importGroundTruthData( self.Dialog, getLocation( self.Container ), self.Toolstrip.UseBlockedImage );

            if ~isvalid( self )
                return ;
            end

            if ~isCanceled
                notify( self, 'GroundTruthDataLoaded', images.internal.app.segmenter.volume.events.VolumeEventData( var ) );
            end

            resume( self.Container );

        end


        function loadCustomMetric( self )

            wait( self.Container );

            [ isCanceled, metric ] = addAlgorithm( self.Dialog, getLocation( self.Container ), getString( message( 'images:segmenter:loadCustomMetric' ) ) );

            if ~isvalid( self )
                return ;
            end

            bringToFront( self.Container );
            resume( self.Container );

            if ~isCanceled
                addCustomMetric( self.Toolstrip, metric );
            end

        end


        function requestToSaveToWorkspace( self, evt )

            removeTitleBarAsterisk( self.Container );
            notify( self, 'SaveToWorkspaceRequested', evt );

        end


        function requestToSaveToFile( self, evt )

            removeTitleBarAsterisk( self.Container );
            notify( self, 'SaveToFileRequested', evt );

        end


        function reactToAutomationStart( self, evt )

            if self.Toolstrip.ApplyOnAllBlocks && self.Toolstrip.SaveAsRequired
                requestToSaveAsToFile( self );
                if self.Toolstrip.SaveAsRequired

                    cleanUpAfterAutomation( self );
                    return ;
                end
            end

            self.Slider.Enabled = false;
            self.Slice.Enabled = false;
            self.Summary.Enabled = false;
            self.Key.Enabled = false;
            self.Pointer.Enabled = false;
            disable( self.Labels );
            deselectAll( self.ROI );

            if evt.VolumeBased && ~self.Toolstrip.ApplyOnAllBlocks
                startWaitBar( self, getString( message( 'images:segmenter:waitForAutomation' ) ) );
            end

            if isa( self.Container, 'images.internal.app.segmenter.volume.display.WebContainer' )
                evt.Parent = self.Container.SliceFigure;
            end

            notify( self, 'AutomationStarted', evt );

            if ~isvalid( self )
                return ;
            end

            if self.Toolstrip.ApplyOnAllBlocks



                save( self.Toolstrip );
            end

        end


        function reactToInterpolationRequest( self )

            [ roi, val ] = getSelection( self.ROI );

            if ~isempty( roi )

                deselectAll( self.ROI );
                notify( self, 'InterpolateRequested', images.internal.app.segmenter.volume.events.ROIInterpolatedEventData( roi, [  ], val, [  ], [  ] ) );

            end

        end


        function paintBySuperpixels( self, sz )

            if isempty( sz )
                L = generateSuperpixels( self.ROI, [  ] );
                redrawRequired = ~isempty( self.Slice.SuperpixelOverlay );
                self.Slice.SuperpixelOverlay = L;
                if redrawRequired
                    deselectPaintBySuperpixels( self.Toolstrip );
                    notify( self, 'RedrawSlice' );
                end
            else
                wait( self.Container );
                notify( self, 'SliceRequested' );
                L = generateSuperpixels( self.ROI, sz );
                self.Slice.SuperpixelOverlay = L;
                notify( self, 'RedrawSlice' );
            end

            resume( self.Container );

        end


        function wireUpToolstrip( self, show3DDisplay, useWebVersion, showMetrics )

            self.Toolstrip = images.internal.app.segmenter.volume.display.Toolstrip( show3DDisplay, useWebVersion, showMetrics );
            addToolstripListeners( self );

        end

        function addToolstripListeners( self )
            addlistener( self.Toolstrip, 'ShowVolumeChanged', @( src, evt )showVolume( self, evt.Show ) );
            addlistener( self.Toolstrip, 'ShowOverviewChanged', @( src, evt )showOverview( self, evt.Show ) );
            addlistener( self.Toolstrip, 'SpatialReferencingChanged', @( src, evt )updateSpatialReferencing( self, evt.X, evt.Y, evt.Z ) );
            addlistener( self.Toolstrip, 'ColorChanged', @( src, evt )updateBackgroundColor( self, evt.Color ) );
            addlistener( self.Toolstrip, 'GradientColorChanged', @( src, evt )updateGradientColor( self, evt.Color ) );
            addlistener( self.Toolstrip, 'UseGradientChanged', @( src, evt )updateUseGradient( self, evt.Color ) );
            addlistener( self.Toolstrip, 'RenderingChanged', @( src, evt )notify( self, 'VolumeRenderingChanged', evt ) );

            addlistener( self.Toolstrip, 'AppCleared', @( ~, ~ )clearApp( self ) );
            addlistener( self.Toolstrip, 'VolumeLoadedFromWorkspace', @( ~, ~ )requestToLoadVolumeFromWorkspace( self, false ) );
            addlistener( self.Toolstrip, 'VolumeLoadedFromDICOM', @( ~, ~ )requestToLoadVolumeFromDICOM( self ) );
            addlistener( self.Toolstrip, 'VolumeLoadedFromFile', @( ~, ~ )requestToLoadVolumeFromFile( self ) );
            addlistener( self.Toolstrip, 'VolumeLoadedFromBlockedImage', @( ~, ~ )requestToLoadVolumeFromBlockedImage( self ) );
            addlistener( self.Toolstrip, 'VolumeLoadedFromBlockedImageFolder', @( ~, ~ )requestToLoadVolumeFromBlockedImageFolder( self ) );
            addlistener( self.Toolstrip, 'VolumeLoadedFromBlockedImageWorkspace', @( ~, ~ )requestToLoadVolumeFromWorkspace( self, true ) );
            addlistener( self.Toolstrip, 'LabelsLoadedFromWorkspace', @( ~, ~ )requestToLoadLabelsFromWorkspace( self ) );
            addlistener( self.Toolstrip, 'LabelsLoadedFromFile', @( ~, ~ )requestToLoadLabelsFromFile( self ) );
            addlistener( self.Toolstrip, 'LabelsSavedToWorkspace', @( src, evt )requestToSaveToWorkspace( self, evt ) );
            addlistener( self.Toolstrip, 'LabelsSavedToFile', @( src, evt )requestToSaveToFile( self, evt ) );
            addlistener( self.Toolstrip, 'LabelsSavedAsToWorkspace', @( ~, ~ )requestToSaveAsToWorkspace( self ) );
            addlistener( self.Toolstrip, 'LabelsSavedAsToFile', @( ~, ~ )requestToSaveAsToFile( self ) );
            addlistener( self.Toolstrip, 'ColorOrderRestored', @( src, evt )notify( self, 'LabelColorsReset', evt ) );
            addlistener( self.Toolstrip, 'ThreeColumnLayoutRequested', @( ~, ~ )setColumnLayout( self.Container ) );
            addlistener( self.Toolstrip, 'TwoColumnLayoutRequested', @( ~, ~ )setStackedLayout( self.Container ) );
            addlistener( self.Toolstrip, 'ShowLabelsChanged', @( src, evt )showLabels( self.Container, evt.Show ) );
            addlistener( self.Toolstrip, 'LabelOpacityChanged', @( src, evt )updateLabelOpacity( self, evt.Alpha ) );
            addlistener( self.Toolstrip, 'SliceDimensionChanged', @( src, evt )reactToSliceDimensionChange( self, evt ) );
            addlistener( self.Toolstrip, 'AutomationStarted', @( src, evt )reactToAutomationStart( self, evt ) );
            addlistener( self.Toolstrip, 'AutomationStopped', @( src, evt )notify( self, 'AutomationStopped', evt ) );
            addlistener( self.Toolstrip, 'AutomationRangeUpdated', @( src, evt )notify( self, 'AutomationRangeUpdated', evt ) );
            addlistener( self.Toolstrip, 'AutomateOnAllBlocks', @( src, evt )notify( self, 'AutomateOnAllBlocks', evt ) );
            addlistener( self.Toolstrip, 'OpenSettings', @( src, evt )displaySettings( self.Dialog, getLocation( self.Container ), evt.Settings ) );
            addlistener( self.Toolstrip, 'LabelNamesImported', @( ~, ~ )importLabelNames( self ) );
            addlistener( self.Toolstrip, 'CloseDialogs', @( ~, ~ )close( self.Dialog ) );
            addlistener( self.Toolstrip, 'ShowVoxelInfo', @( src, evt )showVoxelInfo( self.Slice, evt.EventData.NewValue ) );
            addlistener( self.Toolstrip, 'RGBLimitsUpdated', @( src, evt )notify( self, 'RGBLimitsUpdated', evt ) );
            addlistener( self.Toolstrip, 'MetricsUpdated', @( src, evt )notify( self, 'MetricsUpdated', evt ) );
            addlistener( self.Toolstrip, 'GroundTruthImportRequested', @( ~, ~ )importGroundTruthData( self ) );
            addlistener( self.Toolstrip, 'LoadCustomMetric', @( src, evt )loadCustomMetric( self ) );
            addlistener( self.Toolstrip, 'AddCustomMetric', @( src, evt )notify( self, 'AddCustomMetric', evt ) );

            addlistener( self.Toolstrip, 'BrushSelected', @( src, evt )reactToBrushSelection( self, evt.Selected ) );
            addlistener( self.Toolstrip, 'BrushSizeChanged', @( src, evt )set( self.ROI, 'BrushSize', evt.Size ) );
            addlistener( self.Toolstrip, 'PaintBySuperpixels', @( src, evt )paintBySuperpixels( self, evt.Size ) );
            addlistener( self.Toolstrip, 'LabelToolSelected', @( ~, ~ )reactToDrawingToolChange( self ) );
            addlistener( self.Toolstrip, 'InterpolateRequested', @( ~, ~ )reactToInterpolationRequest( self ) );
            addlistener( self.Toolstrip, 'InterpolateManually', @( ~, ~ )manuallyInterpolate( self ) );
            addlistener( self.Toolstrip, 'AddAlgorithm', @( src, evt )addAlgorithm( self, evt.VolumeBased ) );
            addlistener( self.Toolstrip, 'ManageAlgorithms', @( ~, ~ )manageAlgorithms( self ) );
            addlistener( self.Toolstrip, 'ErrorThrown', @( src, evt )error( self, evt.Message ) );
            addlistener( self.Toolstrip, 'ViewShortcuts', @( ~, ~ )displayShortcuts( self ) );
            addlistener( self.Toolstrip, 'RotateImage', @( src, evt )rotateSlice( self, evt.Rotation ) );
            addlistener( self.Toolstrip, 'ShowLabelsInVolume', @( src, evt )notify( self, 'ShowLabelsInVolume', evt ) );
            addlistener( self.Toolstrip, 'OrientationAxesChanged', @( src, evt )reactToOrientationAxesChange( self, evt.Show, evt.ShowWireframe ) );
            addlistener( self.Toolstrip, 'ContrastChanged', @( ~, ~ )notify( self, 'RedrawSlice' ) );
            addlistener( self.Toolstrip, 'FloodFillSensitivityChanged', @( src, evt )setFloodFillSettings( self.ROI, evt.Size, evt.Sensitivity ) );

            addlistener( self.Toolstrip, 'ReadNextBlock', @( src, evt )requestToReadNextBlock( self, evt ) );
            addlistener( self.Toolstrip, 'ReadPreviousBlock', @( src, evt )requestToReadNextBlock( self, evt ) );
            addlistener( self.Toolstrip, 'ReadBlockByIndex', @( src, evt )requestToReadNextBlock( self, evt ) );
            addlistener( self.Toolstrip, 'OverviewSettingsChanged', @( src, evt )blockOverviewSettingsUpdated( self, evt.CurrentIndex, evt.History, evt.Completed ) );
            addlistener( self.Toolstrip, 'RegenerateOverview', @( src, evt )reactToBlockOverviewRegeneration( self, evt ) );
            addlistener( self.Toolstrip, 'MarkBlockComplete', @( src, evt )notify( self, 'MarkBlockComplete', evt ) );
            addlistener( self.Toolstrip, 'MoveCurrentBlock', @( src, evt )updateSelectedBlock( self, evt.CurrentIndex ) );

        end

    end




    events



        VolumeRenderingChanged



        RedrawVolume



        ShowLabelsInVolume

    end

    methods




        function updateVolume( self, vol, labels, amapVol, cmapVol, amapLabels, cmapLabels, ~, dim )






            updateVolume( self.Volume, vol, labels, amapVol, cmapVol, amapLabels, cmapLabels );

            if ~isvalid( self )
                return ;
            end


            reset( self.Slider, size( vol, dim ) );


            reset( self.Volume );

            isRGB = size( vol, 4 ) == 3;
            enableContrastControls( self.Toolstrip, isRGB );


            if ~self.Toolstrip.UseBlockedImage
                markSaveAsClean( self );
            end
            self.Slice.Empty = false;
            self.Slider.Enabled = true;
            self.Slice.Enabled = true;
            self.Summary.Empty = false;
            self.Summary.Enabled = true;
            enable( self.Toolstrip );
            enableQuickAccessBar( self.Container );

            resume( self.Container );

        end




        function updateVolumeHeavyweight( self, vol, labels, amapVol, cmapVol, amapLabels, cmapLabels )

            updateVolumeHeavyweight( self.Volume, vol, labels, amapVol, cmapVol, amapLabels, cmapLabels );
            resume( self.Container );

        end




        function updateVolumeLightweight( self )

            addTitleBarAsterisk( self.Container );
            markSaveAsDirty( self.Toolstrip );
            markVolumeAsDirty( self.Volume );

            resume( self.Container );

        end




        function updateRGBA( self, cmapData, amapData, cmapLabels, amapLabels )
            updateRGBA( self.ROI, cmapLabels );
            updateRGBA( self.Volume, amapData, cmapData, amapLabels, cmapLabels );
            updateRGBA( self.OverviewVolume, amapData, cmapData, amapLabels, cmapLabels );
        end




        function updateSpatialReferencing( self, x, y, z )

            tform = self.Volume.Transform;

            isValid = ( isfinite( x ) && isreal( x ) && x > 0 ) &&  ...
                ( isfinite( y ) && isreal( y ) && y > 0 ) &&  ...
                ( isfinite( z ) && isreal( z ) && z > 0 );

            if isValid


                if ~isequal( tform( 1, 1 ), x ) || ~isequal( tform( 2, 2 ), y ) || ~isequal( tform( 3, 3 ), z )

                    tform( 1, 1 ) = x;
                    tform( 2, 2 ) = y;
                    tform( 3, 3 ) = z;

                    self.Volume.Transform = tform;
                    self.OverviewVolume.Transform = tform;

                end

                setSpatialReferencing( self.Toolstrip, x, y, z );

            else
                setSpatialReferencing( self.Toolstrip, tform( 1, 1 ), tform( 2, 2 ), tform( 3, 3 ) );
            end

        end

    end

    methods ( Access = protected )


        function showVolume( self, TF )

            self.Volume.Visible = TF;

            if TF
                notify( self, 'RedrawVolume' );
            end

            showVolume( self.Container, TF );

        end


        function updateBackgroundColor( self, color )

            if isempty( color )
                color = uisetcolor( self.Volume.BackgroundColor, getString( message( 'images:volumeViewer:backgroundColorButtonLabel' ) ) );
                bringToFront( self.Container );
            end

            setBackgroundColor( self.Volume, color );
            setBackgroundColor( self.OverviewVolume, color );

            setVolumeColor( self.Toolstrip, color );
            set( self.Container.VolumeFigure, 'Color', color );

        end


        function updateGradientColor( self, color )

            if isempty( color )
                color = uisetcolor( self.Volume.GradientColor, getString( message( 'images:volumeViewer:backgroundColorButtonLabel' ) ) );
                bringToFront( self.Container );
            end

            setGradientColor( self.Volume, color );
            setGradientColor( self.OverviewVolume, color );

            setGradientColor( self.Toolstrip, color );

        end


        function updateUseGradient( self, val )
            setBackgroundGradient( self.Volume, val );
            setBackgroundGradient( self.OverviewVolume, val );
        end


        function reactToOrientationAxesChange( self, TF, wireframeTF )
            setOrientationAxes( self.Volume, TF, wireframeTF );
            setOrientationAxes( self.OverviewVolume, TF, wireframeTF );
        end


        function showOverview( self, TF )

            wait( self.Container );
            showOverview( self.OverviewVolume, TF );
            showOverview( self.Container, TF );
            resume( self.Container );

        end


        function blockOverviewSettingsUpdated( self, showCurrent, showHistory, showCompleted )

            wait( self.Container );
            self.OverviewVolume.ShowCurrentBlock = showCurrent;
            self.OverviewVolume.ShowBlockHistory = showHistory;
            self.OverviewVolume.ShowCompletedBlocks = showCompleted;

            notify( self, 'RedrawBlockOverview' );

        end


        function updateSelectedBlock( self, idx )

            self.OverviewVolume.SelectedBlock = idx;
            notify( self, 'RedrawBlockOverview' );

        end


        function reactToBlockOverviewRegeneration( self, evt )

            if isa( self.Container, 'images.internal.app.segmenter.volume.display.WebContainer' )
                evt.Parent = self.Container.SliceFigure;
            else
                wait( self.Container );
            end

            notify( self, 'RegenerateBlockOverview', evt );

            showOverview( self, true );

        end


        function wireUpVolume( self, show3DDisplay, useWebVersion )

            if useWebVersion
                self.Volume = images.internal.app.segmenter.volume.display.Volume( self.Container.VolumeFigure, show3DDisplay );
            else
                self.Volume = images.internal.app.segmenter.volume.display.VolumeToolgroup( self.Container.VolumeFigure, self.Container.VolumePosition, show3DDisplay );
            end
            setTag( self.Volume, '3DDisplay' );

            setVolumeColor( self.Toolstrip, self.Volume.BackgroundColor );
            set( self.Container.VolumeFigure, 'Color', self.Volume.BackgroundColor );

            if useWebVersion
                setGradientColor( self.Toolstrip, self.Volume.GradientColor );
                setUseGradient( self.Toolstrip, self.Volume.UseGradient );
            end

            addlistener( self.Volume, 'RedrawVolume', @( ~, ~ )notify( self, 'RedrawVolume' ) );

        end


        function wireUpOverviewVolume( self, show3DDisplay, useWebVersion )

            if useWebVersion
                self.OverviewVolume = images.internal.app.segmenter.volume.display.OverviewVolume( self.Container.OverviewFigure, show3DDisplay );
            else
                self.OverviewVolume = images.internal.app.segmenter.volume.display.OverviewVolumeToolgroup( self.Container.OverviewFigure, self.Container.OverviewPosition, show3DDisplay );
            end

            setTag( self.OverviewVolume, 'OverviewVolume' );

            set( self.Container.OverviewFigure, 'Color', self.Volume.BackgroundColor );

        end

    end


    methods ( Access = ?uitest.factory.Tester )
        function objects = qeSetupMocks( self, args )
            arguments
                self
                args.Dialog
                args.Slice
                args.Toolstrip
                args.ROI
                args.Volume
                args.OverviewVolume
            end

            mocks = fieldnames( args );
            objects = cell( 1, numel( mocks ) );
            for n = 1:numel( mocks )
                switch mocks{ n }
                    case 'Dialog'
                        objects{ n } = self.Dialog;
                        self.Dialog = args.Dialog;
                        addDialogListeners( self );
                    case 'Slice'
                        objects{ n } = self.Slice;
                        self.Slice = args.Slice;
                        addSliceListeners( self );
                        preload( self.ROI, self.Slice.ImageHandle );
                    case 'ROI'
                        objects{ n } = self.ROI;
                        self.ROI = args.ROI;
                        addROIListeners( self );
                        preload( self.ROI, self.Slice.ImageHandle );
                    case 'Toolstrip'
                        objects{ n } = self.Toolstrip;
                        self.Toolstrip = args.Toolstrip;
                        addToolstripListeners( self );
                    case 'Volume'
                        objects{ n } = self.Volume;
                        self.Volume = args.Volume;
                        setTag( self.Volume, 'Volume' );
                    case 'OverviewVolume'
                        objects{ n } = self.OverviewVolume;
                        self.OverviewVolume = args.OverviewVolume;
                        setTag( self.OverviewVolume, 'OverviewVolume' );
                end
            end
        end
    end

end

