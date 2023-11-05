classdef HTMLViewer < handle

    properties ( Access = public )
        Input
        Visible
    end

    properties ( GetAccess = public, SetAccess = private, Hidden )
        Title
    end

    properties ( GetAccess = public, SetAccess = private, Hidden, SetObservable )
        IsOpen = false
    end

    properties ( Access = private, Hidden )
        NewTab
        ShowToolbar
        WebHandle
        IsTextHTMLInput
        ViewerID
        RequestID
        FileName
        HTMLPagePath
    end

    methods
        function close( obj )




            if matlab.htmlviewer.internal.isHTMLViewer
                matlab.htmlviewer.internal.HTMLViewerManager.getInstance(  ).close( obj.ViewerID );

                obj.delete;
            else
                obj.WebHandle.close(  );
                matlab.htmlviewer.internal.HTMLViewerManager.getInstance(  ).onWebBrowserPageCloseCompletion( obj.ViewerID );
            end
        end

        function htmlText = getHTMLText( obj )



            if matlab.htmlviewer.internal.isHTMLViewer
                htmlText = string( matlab.htmlviewer.internal.HTMLViewerManager.getInstance(  ).getHTMLText( obj.ViewerID ) );
            else
                htmlText = string( obj.WebHandle.getHtmlText(  ) );
            end
        end
    end


    methods
        function set.Input( obj, htmlInput )
            arguments
                obj
                htmlInput{ mustBeTextScalar }
            end
            obj.Input = string( matlab.htmlviewer.internal.HTMLViewerManager.getInstance(  ).validateInput( htmlInput ) );
            if matlab.htmlviewer.internal.isHTMLViewer
                obj.updateHTMLViewer(  );
            else
                obj.updateWebBrowser(  );
            end
        end

        function title = get.Title( obj )
            if matlab.htmlviewer.internal.isHTMLViewer
                title = string( matlab.htmlviewer.internal.HTMLViewerManager.getInstance(  ).getTitle( obj.ViewerID ) );
            else
                title = string( obj.WebHandle.getClientProperty( com.mathworks.widgets.desk.DTClientProperty.TITLE ) );%#ok<JAPIMATHWORKS>
            end
        end

        function visible = get.Visible( obj )
            if matlab.htmlviewer.internal.isHTMLViewer
                visible = obj.Visible;
            else
                visible = obj.WebHandle.isShowing(  );
            end
        end

        function set.Visible( obj, value )
            arguments
                obj
                value( 1, 1 )logical{ mustBeNumericOrLogical }
            end
            obj.Visible = value;
            if matlab.htmlviewer.internal.isHTMLViewer
                matlab.htmlviewer.internal.HTMLViewerManager.getInstance(  ).setVisibility( obj.ViewerID, value );%#ok<MCSUP>
            else
                obj.setWebBrowserVisibility( value );
            end
        end
    end

    methods ( Hidden )
        function obj = HTMLViewer( options )
            obj.parseInputs( options );
        end

        function open( obj )
            payload = struct(  ...
                'ViewerID', obj.ViewerID,  ...
                'RequestID', obj.RequestID,  ...
                'Input', obj.Input,  ...
                'FileName', obj.FileName,  ...
                'HTMLPagePath', obj.HTMLPagePath,  ...
                'NewTab', obj.NewTab,  ...
                'ShowToolbar', obj.ShowToolbar,  ...
                'IsTextHTMLInput', obj.IsTextHTMLInput );
            matlab.htmlviewer.internal.HTMLViewerManager.getInstance(  ).requestHTMLPageOpen( payload );
            obj.updateOnOpen(  );
        end

        function updateInputArguments( obj, options )
            options.ViewerID = obj.ViewerID;
            obj.parseInputs( options );
        end

        function updateOnClose( obj )
            obj.Visible = false;
            if obj.IsOpen
                obj.IsOpen = false;
            end
        end

        function status = isTabOpen( obj )
            if matlab.htmlviewer.internal.isHTMLViewer
                status = obj.IsOpen;
            else
                status = false;
                if ~isempty( obj.WebHandle )
                    status = obj.WebHandle.isValid(  );
                end
            end
        end
    end

    methods ( Access = private )
        function parseInputs( obj, options )
            obj.ViewerID = options.ViewerID;
            obj.RequestID = options.RequestID;
            obj.FileName = options.FileName;
            obj.HTMLPagePath = options.HTMLPagePath;
            obj.NewTab = options.NewTab;
            obj.ShowToolbar = options.ShowToolbar;
            obj.IsTextHTMLInput = options.IsTextHTMLInput;
        end

        function updateHTMLViewer( obj )
            htmlViewerInstance = matlab.htmlviewer.internal.HTMLViewerManager.getInstance(  );
            [ obj.FileName, obj.HTMLPagePath, obj.IsTextHTMLInput ] = htmlViewerInstance.addHTMLPageLocationToSecureList( obj.Input );
            if htmlViewerInstance.isClientReady(  )
                obj.open(  );
            else
                options = struct(  ...
                    'NewTab', obj.NewTab,  ...
                    'ShowToolbar', obj.ShowToolbar,  ...
                    'IsTextHTMLInput', obj.IsTextHTMLInput,  ...
                    'HTMLPagePath', obj.HTMLPagePath,  ...
                    'FileName', obj.FileName,  ...
                    'RequestID', obj.RequestID );

                htmlViewerInstance.cacheOpenRequest( obj, options );
                obj.Visible = true;
            end
        end

        function updateOnOpen( obj )
            obj.Visible = true;
            obj.IsOpen = true;
        end
    end

    methods ( Access = private )

        function updateWebBrowser( obj )
            if isempty( obj.WebHandle )
                webInputOptions = matlab.htmlviewer.internal.HTMLViewerManager.getInstance(  ).getWebInputOptions( obj.NewTab, obj.ShowToolbar );

                webWarnState = warning( "query", "MATLAB:web:BrowserOuptputArgRemovedInFutureRelease" );
                warning( "off", webWarnState.identifier );
                [ ~, obj.WebHandle ] = web( obj.Input, webInputOptions{ : } );%#ok<WEBREMOVE>

                warning( webWarnState );
                obj.Visible = true;
            else


                htmlInput = char( obj.Input );
                if startsWith( htmlInput, 'text://' )
                    obj.WebHandle.setHtmlText( htmlInput( 8:end  ) );
                else
                    obj.WebHandle.setCurrentLocation( htmlInput );
                end
            end
        end

        function setWebBrowserVisibility( obj, status )
            if status == true
                obj.WebHandle.show(  );
                obj.WebHandle.requestFocus(  );
                com.mathworks.mde.desk.MLDesktop.getInstance.showClient( obj.WebHandle, [  ], true );
            elseif status == false
                obj.WebHandle.hide(  );
            end
        end
    end
end
