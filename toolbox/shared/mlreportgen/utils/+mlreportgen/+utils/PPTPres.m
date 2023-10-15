classdef PPTPres < mlreportgen.utils.internal.OfficeDoc































    properties ( Constant, Hidden )
        FileExtensions = [ ".pptx", ".pptm", ".potx", ".ppt" ];
    end

    methods
        function this = PPTPres( fileName )






            this = this@mlreportgen.utils.internal.OfficeDoc( fileName );
        end

        function show( this )




            import mlreportgen.utils.internal.executeRPC

            hNETObj = netobj( this );
            try
                executeRPC( @(  )showNETObj( hNETObj ) );
            catch

                hPPTs = executeRPC( @(  )hNETObj.Application.Presentations );
                executeWithRetries( this, @(  )closeNETObj( hNETObj, false ) );
                hNETObj = executeRPC( @(  )openPPTNETObj( hPPTs, this.FileName, true ) );
                resetNETObj( this, hNETObj );
            end
            flush( this, 0 );
        end

        function hide( this )





            hNETObj = netobj( this );
            if isVisible( this )
                executeWithRetries( this, @(  )hideNETObj( hNETObj ) );
                flush( this, 0 );
            end
        end

        function tf = close( this, closeFlag )










            arguments
                this
                closeFlag logical = true;
            end

            import mlreportgen.utils.internal.waitFor
            import mlreportgen.utils.internal.executeRPC

            if isOpen( this )
                hNETObj = netobj( this );


                hApp = executeWithRetries( this, @(  )hNETObj.Application );
                hPresentationsNETObj = executeWithRetries( this, @(  )hApp.Presentations );
                nPPTs = executeWithRetries( this, @(  )hPresentationsNETObj.Count );


                closeTF = executeWithRetries( this, @(  )closeNETObj( hNETObj, closeFlag ) );
                countTF = waitFor( @(  )( executeRPC( @(  )hPresentationsNETObj.Count ) < nPPTs ) );
                tf = ( closeTF && countTF );

                if tf

                    nFinalPPTs = executeRPC( @(  )hPresentationsNETObj.Count );
                    if ( nFinalPPTs == 0 )
                        executeRPC( @(  )minimizedAppNETObj( hApp ) );
                    end

                    clearNETObj( this );
                else
                    flush( this );
                end
            end
        end

        function pdfFullPath = exportToPDF( this, varargin )









            if isempty( varargin )
                [ fPath, fName ] = fileparts( this.FileName );
                pdfFile = fullfile( fPath, fName + ".pdf" );
            else
                pdfFile = varargin{ 1 };
            end

            pdfFullPath = string( mlreportgen.utils.internal.canonicalPath( pdfFile ) );
            if isfile( pdfFullPath )
                delete( pdfFullPath );
            end

            hNETObj = netobj( this );
            executeWithRetries( this, @(  )hNETObj.ExportAsFixedFormat(  ...
                pdfFullPath,  ...
                Microsoft.Office.Interop.PowerPoint.PpFixedFormatType.ppFixedFormatTypePDF,  ...
                Microsoft.Office.Interop.PowerPoint.PpFixedFormatIntent.ppFixedFormatIntentPrint ) );
            mlreportgen.utils.internal.waitFor( @(  )isfile( pdfFullPath ) );
            flush( this );
        end

        function tf = isReadOnly( this )





            hNetObj = netobj( this );
            tf = executeWithRetries( this,  ...
                @(  )( hNetObj.ReadOnly == Microsoft.Office.Core.MsoTriState.msoTrue ) );
        end

        function tf = isSaved( this )





            hNetObj = netobj( this );
            tf = executeWithRetries( this,  ...
                @(  )( hNetObj.Saved == Microsoft.Office.Core.MsoTriState.msoTrue ) );
        end

        function tf = isVisible( this )




            hNETObj = netobj( this );
            tf = mlreportgen.utils.internal.executeRPC( @(  )isVisibleNETObj( hNETObj ) );
        end
    end

    methods ( Static, Access = protected )
        function hNETObj = createNETObj( fullFilePath )
            import mlreportgen.utils.internal.executeRPC


            pptc = mlreportgen.utils.PPTPres.controller(  );
            start( pptc );


            papp = app( pptc );
            hAppNETObj = netobj( papp );
            hPPTs = executeRPC( @(  )hAppNETObj.Presentations );


            hNETObj = executeRPC( @(  )findPPTNETObj( hPPTs, fullFilePath ) );
            if isempty( hNETObj )
                hNETObj = executeRPC( @(  )openPPTNETObj( hPPTs, fullFilePath ) );
            end
        end

        function flushNETObj( hNETObj )
            if ( hNETObj.Windows.Count > 0 )
                hWin = hNETObj.Windows.Item( 1 );
                if ( hWin.WindowState ~= Microsoft.Office.Interop.PowerPoint.PpWindowState.ppWindowMinimized )
                    hWin.Activate(  );
                end
            end
            hNETObj.FullName;
        end

        function hController = controller(  )
            hController = mlreportgen.utils.internal.PPTController.instance(  );
        end
    end
end

function hNETObj = findPPTNETObj( hPPTs, fullFilePath )
hNETObj = [  ];
nPPTs = hPPTs.Count;
for i = 1:nPPTs
    hPPT = hPPTs.Item( i );
    if strcmpi( string( hPPT.FullName ), fullFilePath )
        hNETObj = hPPT;
        break ;
    end
end
end

function hNETObj = openPPTNETObj( hPPTs, fullFilePath, withWindow )
arguments
    hPPTs
    fullFilePath
    withWindow = false
end


f = Microsoft.Office.Core.MsoTriState.msoFalse;
t = Microsoft.Office.Core.MsoTriState.msoTrue;
nPPTs = hPPTs.Count;

if withWindow
    msoWithWindow = t;
else
    msoWithWindow = f;
end

hNETObj = hPPTs.Open( fullFilePath,  ...
    f,  ...
    f,  ...
    msoWithWindow );
success = mlreportgen.utils.internal.waitFor( @(  )( hPPTs.Count == ( nPPTs + 1 ) ) );
if ~success
    error( message( "mlreportgen:utils:error:timedOutOpenFile", fullFilePath ) );
end
end

function tf = isVisibleNETObj( hNETObj )
hWinNETObjs = hNETObj.Windows;
if ( hWinNETObjs.Count > 0 )
    hWinNETObj = hWinNETObjs.Item( 1 );
    tf = ( hWinNETObj.WindowState ~= Microsoft.Office.Interop.PowerPoint.PpWindowState.ppWindowMinimized );
else
    tf = false;
end
end

function showNETObj( hNETObj )
if ( hNETObj.Windows.Count == 0 )
    hNETObj.Application.Visible = Microsoft.Office.Core.MsoTriState.msoTrue;
    hNETObj.NewWindow(  );
end

hWin = hNETObj.Windows.Item( 1 );
hWin.Activate(  );

eMinimize = Microsoft.Office.Interop.PowerPoint.PpWindowState.ppWindowMinimized;
eNormal = Microsoft.Office.Interop.PowerPoint.PpWindowState.ppWindowNormal;
if ( hWin.WindowState == eMinimize )
    hWin.WindowState = eNormal;
end

hApp = hNETObj.Application;
mlreportgen.utils.internal.bringWindowToFront( hApp.HWND );
mlreportgen.utils.internal.bringWindowToFront( hWin.HWND );
end

function tf = closeNETObj( hNETObj, closeFlag )
tf = false;
if ( ~closeFlag || ( hNETObj.Saved == Microsoft.Office.Core.MsoTriState.msoTrue ) )
    hNETObj.Close(  );
    tf = true;
end
end

function minimizedAppNETObj( hApp )
hApp.WindowState = Microsoft.Office.Interop.PowerPoint.PpWindowState.ppWindowMinimized;
end

function hideNETObj( hNETObj )
if ( hNETObj.Windows.Count > 0 )
    hWin = hNETObj.Windows.Item( 1 );
    ppWindowMinimized = Microsoft.Office.Interop.PowerPoint.PpWindowState.ppWindowMinimized;
    hWin.WindowState = ppWindowMinimized;
    mlreportgen.utils.internal.waitFor( @(  )( hWin.WindowState == ppWindowMinimized ) );
end
end

