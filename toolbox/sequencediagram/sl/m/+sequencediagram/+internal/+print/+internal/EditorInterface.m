classdef EditorInterface < handle

    properties ( SetAccess = immutable, GetAccess = private )
        ModelName
        SequenceDiagramName
        DebugMode
    end


    properties ( Access = private )
        EditorId = '';
        EditorUrl

        OnReadySubcription = [  ];

        CEFWindow = matlab.internal.cef.webwindow.empty;

        ErrorDuringReadyForPrint = MException.empty
        ReadyForExport = false;

        SequenceDiagramSize = [  ];

        WindowResizeFinished = false;
    end


    properties ( Hidden, Constant )
        ScreenshotEdgeMargin = 20;
        MacResizeIncrement = 100;
        MacWindowCornerRadius = 50;
    end


    methods
        function this = EditorInterface( modelName, sequenceDiagramName, debugMode )
            arguments
                modelName( 1, : )char
                sequenceDiagramName( 1, : )char
                debugMode( 1, 1 )logical = false;
            end

            this.ModelName = modelName;
            this.SequenceDiagramName = sequenceDiagramName;
            this.DebugMode = debugMode;

            this.setup();
        end


        function delete( this )
            if ~isempty( this.CEFWindow )
                this.CEFWindow.close(  );
            end

            if ~isempty( this.EditorId )
                builtin( '_destroy_sequence_diagram_editor_with_id', this.EditorId );
            end

            this.removeOnReadyListener(  );
        end


        function img = getImage( this )
            needsStitchedScreenshot = ~ismac;

            if ( needsStitchedScreenshot )
                img = this.getImageViaStitching(  );
            else
                img = this.CEFWindow.getScreenshot(  );
            end

            img = img( 1:this.SequenceDiagramSize( 2 ), 1:this.SequenceDiagramSize( 1 ), : );
        end

        function saveToPdf( this, fileName )
            this.CEFWindow.printToPDF( fileName );
        end
    end


    methods ( Access = private )

        function setup( this )
            cleanupOnReadyListener = onCleanup( @this.removeOnReadyListener );

            this.openEditor(  );
            this.waitForReady(  );
        end


        function openEditor( this )
            [ this.EditorId, this.EditorUrl ] = builtin( '_create_sequence_diagram_editor_for_print', this.ModelName, this.SequenceDiagramName, this.DebugMode );

            this.setupOnReadyListener(  );
            this.openCEFWindow(  );
        end


        function setupOnReadyListener( this )
            msgChannel = [ '/sequencediagram/editor/', this.EditorId, '/readyForPrint' ];
            this.OnReadySubcription = message.subscribe( msgChannel, @this.readyForPrintCallback );
        end


        function removeOnReadyListener( this )
            if ~isempty( this.OnReadySubcription )
                message.unsubscribe( this.OnReadySubcription );
                this.OnReadySubcription = [  ];
            end
        end


        function openCEFWindow( this )
            position = [ 1, 1, 10, 10 ];
            opts = {  ...
                'Position';position; ...
                'Origin';'TopLeft' };
            this.CEFWindow = matlab.internal.cef.webwindow( this.EditorUrl, opts{ : } );
            this.CEFWindow.Title = message( 'sequencediagram:Editor:Title' ).getString(  );
        end


        function readyForPrintCallback( this, payload )
            try
                this.testAPI_ErrorDuringReadyForPrintCallback(  );
                sizeFromClient = payload.payload.size;
                this.computeSequenceDiagramSize( sizeFromClient );
                this.resizeWindow();
            catch ex
                this.ErrorDuringReadyForPrint = ex;
            end
            this.ReadyForExport = true;
        end


        function computeSequenceDiagramSize( this, sizeFromClient )

            layoutConfig = sequencediagram.internal.core.kernel.LayoutConfig.getInstance(  );
            marginX = layoutConfig.LifelineStartX;
            marginY = layoutConfig.LifelineStartY;

            width = sizeFromClient.width + marginX;
            height = sizeFromClient.height + marginY;

            this.SequenceDiagramSize = [ width, height ];

            dpiScale = GLUE2.Util.getDpiScale;
            this.SequenceDiagramSize = this.SequenceDiagramSize * dpiScale;
        end


        function resizeWindow( this )

            requestedSize = this.SequenceDiagramSize;

            if ismac
                requestedSize( 2 ) = requestedSize( 2 ) + this.MacWindowCornerRadius;
            end
            this.setWindowSize( requestedSize );
            this.reactToMinWindowMangerSizeBug( requestedSize );
            this.retryWindowResizeIfNeeded( requestedSize );
            this.pollForWindowToBeCorrectSizeUsingScreenshot( requestedSize );
            this.setWindowSize( this.getWindowSize(  ) );
        end


        function windowSize = getWindowSize( this )
            windowPositionInLogicalPixels = this.CEFWindow.Position;
            windowSizeInLogicalPixels = windowPositionInLogicalPixels( 3:4 );

            dpiScale = GLUE2.Util.getDpiScale(  );
            windowSize = windowSizeInLogicalPixels * dpiScale;
        end


        function setWindowSize( this, newSize )

            this.CEFWindow.WindowResized = @this.windowResizedCallback;
            this.WindowResizeFinished = false;

            wmin = warning( 'off', 'cefclient:webwindow:updatePositionMinSize' );
            wmax = warning( 'off', 'cefclient:webwindow:updatePositionMaxSize' );

            try
                this.CEFWindow.setMaxSize( newSize );
                this.CEFWindow.setMinSize( newSize );
            catch EX

                if ~any( strcmp( EX.identifier, {  ...
                        'cefclient:webwindow:invalidMinSize', 'cefclient:webwindow:invalidMaxSize',  ...
                        'cefclient:webwindow:positionLessThanMinSize', 'cefclient:webwindow:positionGreaterThanMaxSize' ...
                        } ) )
                    EX.rethrow(  )
                end
            end

            warning( wmin );
            warning( wmax );

            ii = 0;
            while ~this.WindowResizeFinished && ( ii < 30 )
                pause( .1 );
                ii = ii + 1;
            end

            this.CEFWindow.WindowResized = [  ];
        end


        function clearMinMaxSizeRestrictionDueToCefBug( this )

            if GLUE2.Util.getDpiScale ~= 1
                this.CEFWindow.setMinSize( [ 10, 10 ] );
                this.CEFWindow.setMaxSize( [ 1e6, 1e6 ] );
            end
        end


        function windowResizedCallback( this, ~, ~ )
            this.WindowResizeFinished = true;
        end


        function reactToMinWindowMangerSizeBug( this, requestedSize )

            currentWindowSize = this.getWindowSize(  );
            if any( currentWindowSize > requestedSize ) && any( currentWindowSize < requestedSize )
                resizeLargerSize = max( currentWindowSize, requestedSize );
                this.setWindowSize( resizeLargerSize );
            end
        end


        function retryWindowResizeIfNeeded( this, requestedSize )

            if ismac
                resizeIncrement = this.MacResizeIncrement;
            else
                resizeIncrement = 0;
            end

            maxAttempts = 10;

            origRequestedSize = requestedSize;
            ii = 0;
            while any( this.getWindowSize(  ) < origRequestedSize ) && ( ii < maxAttempts )
                dimNeedingMoreSpace = this.getWindowSize < origRequestedSize;
                moreSpace = dimNeedingMoreSpace * resizeIncrement;
                requestedSize = requestedSize + moreSpace;
                this.setWindowSize( requestedSize );
                ii = ii + 1;
            end
        end


        function pollForWindowToBeCorrectSizeUsingScreenshot( this, requestedWindowSize )

            ii = 0;
            while any( this.getWindowSizeFromScreenshot(  ) < requestedWindowSize )

                if ii > 5
                    error( 'sequencediagram:Editor:PrintFailedWindowTooSmall',  ...
                        message( 'sequencediagram:Editor:PrintFailedWindowTooSmall' ).getString(  ) );
                end

                pause( .1 );
                ii = ii + 1;
            end
        end


        function windowSize = getWindowSizeFromScreenshot( this )
            screenshot = this.CEFWindow.getScreenshot(  );
            screenshotSize = size( screenshot );
            windowSize = [ screenshotSize( 2 ), screenshotSize( 1 ) ];
        end


        function screenSize = getScreenSize( ~ )
            screenSize = sequencediagram.internal.print.internal.EditorInterface.testAPI_SetGetScreenSize(  );

            if isempty( screenSize )
                oldUnits = get( 0, 'units' );
                set( 0, 'units', 'pixels' );
                cleanupUnits = onCleanup( @(  )set( 0, 'units', oldUnits ) );
                hgScreenSize = get( 0, 'ScreenSize' );
                actScreenSize = hgScreenSize( 3:4 );

                screenSize = actScreenSize - ( 2 * sequencediagram.internal.print.internal.EditorInterface.ScreenshotEdgeMargin );

                dpiScale = GLUE2.Util.getDpiScale;
                screenSize = screenSize * dpiScale;
            end

        end


        function img = getImageViaStitching( this )

            screenSize = this.getScreenSize(  );
            windowSize = this.getWindowSize(  );

            rawNScreenshots = this.SequenceDiagramSize ./ screenSize;
            nScreenShots = max( floor( rawNScreenshots ), [ 1, 1 ] );
            screenshotSize = min( floor( this.SequenceDiagramSize ./ nScreenShots ), screenSize );

            pixelsNotCaptured = this.SequenceDiagramSize - ( nScreenShots .* screenshotSize );
            needsExtraScreenshot = pixelsNotCaptured > 0;
            nScreenShots = nScreenShots + needsExtraScreenshot;

            imgSize = [ this.SequenceDiagramSize( 2 ), this.SequenceDiagramSize( 1 ), 3 ];
            img = zeros( imgSize, 'uint8' );

            for hScreenShot = 1:nScreenShots( 1 )
                for vScreenshot = 1:nScreenShots( 2 )
                    screenshotStartX = ( hScreenShot - 1 ) * screenshotSize( 1 ) + 1;
                    screenshotEndX = min( hScreenShot * screenshotSize( 1 ), this.SequenceDiagramSize( 1 ) );
                    screenshotStartY = ( vScreenshot - 1 ) * screenshotSize( 2 ) + 1;
                    screenshotEndY = min( vScreenshot * screenshotSize( 2 ), this.SequenceDiagramSize( 2 ) );

                    windowPosX =  - screenshotStartX + 1 + sequencediagram.internal.print.internal.EditorInterface.ScreenshotEdgeMargin;
                    windowPosY =  - screenshotStartY + 1 + sequencediagram.internal.print.internal.EditorInterface.ScreenshotEdgeMargin;

                    windowPosition = [ windowPosX, windowPosY, windowSize ];

                    dpiScale = GLUE2.Util.getDpiScale(  );
                    windowPosition = windowPosition ./ dpiScale;
                    this.clearMinMaxSizeRestrictionDueToCefBug(  );

                    this.CEFWindow.Position = windowPosition;
                    this.retryWindowResizeIfNeeded( windowSize );

                    screenshot = this.CEFWindow.getScreenshot(  );
                    img( screenshotStartY:screenshotEndY, screenshotStartX:screenshotEndX, : ) =  ...
                        screenshot( screenshotStartY:screenshotEndY, screenshotStartX:screenshotEndX, : );
                end
            end
        end


        function waitForReady( this )
            sequencediagram.internal.print.internal.EditorInterface.testAPI_ErrorDuringWaitForReady(  );

            while ~this.ReadyForExport
                pause( .1 );
            end

            if ~isempty( this.ErrorDuringReadyForPrint )
                this.ErrorDuringReadyForPrint.throwAsCaller(  );
            end
        end
    end


    methods ( Hidden, Static )
        function tf = testAPI_SetGetErrorDuringWaitForReady( varargin )
            persistent errorDuringWait;
            if isempty( errorDuringWait )
                errorDuringWait = false;
            end

            if nargin >= 1
                errorDuringWait = varargin{ 1 };
            end

            tf = errorDuringWait;
        end


        function testAPI_ErrorDuringWaitForReady(  )
            shouldError = sequencediagram.internal.print.internal.EditorInterface.testAPI_SetGetErrorDuringWaitForReady(  );
            if ( shouldError )
                error( 'SequenceDiagram:PrintEditorInterface:TestErrorDuringWait', 'Test Error' );
            end
        end


        function tf = testAPI_SetGetErrorDuringReadyForPrintCallback( varargin )

            persistent errorDuringReadyForPrint;
            if isempty( errorDuringReadyForPrint )
                errorDuringReadyForPrint = false;
            end

            if nargin >= 1
                errorDuringReadyForPrint = varargin{ 1 };
            end

            tf = errorDuringReadyForPrint;
        end


        function testAPI_ErrorDuringReadyForPrintCallback(  )
            shouldError = sequencediagram.internal.print.internal.EditorInterface.testAPI_SetGetErrorDuringReadyForPrintCallback(  );
            if ( shouldError )
                error( 'SequenceDiagram:PrintEditorInterface:TestErrorDuringReadyForPrint', 'Test Error' );
            end
        end


        function screenSize = testAPI_SetGetScreenSize( varargin )
            persistent testScreenSize;
            if nargin >= 1
                testScreenSize = varargin{ 1 };
            end

            screenSize = testScreenSize;
        end
    end
end


