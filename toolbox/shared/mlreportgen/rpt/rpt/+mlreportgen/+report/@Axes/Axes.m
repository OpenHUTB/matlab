classdef Axes < mlreportgen.report.MATLABGraphicsContainer






































































    properties




























        SnapshotFormat = "auto"



        Source = [  ];



































        Snapshot = mlreportgen.report.FormalImage;































        Scaling = "auto"
















        Height = "6in";
















        Width = "6.5in";








        PreserveBackgroundColor = false;
    end

    properties ( Hidden )



        IsWebApp = false;
    end

    properties ( Access = private, Hidden )


        ClonedFigureFile = [  ];
    end

    properties ( Constant, Access = protected )
        ImageTemplateName = "AxesImage";
        NumberedCaptionTemplateName = "AxesNumberedCaption";
        HierNumberedCaptionTemplateName = "AxesHierNumberedCaption";
    end

    properties ( Constant, Access = private )

        SupportedWebAppFormats = [ "auto", "png", "emf", "tif", "tiff", "jpeg", "jpg", "pdf" ];
    end

    methods
        function this = Axes( varargin )
            this =  ...
                this@mlreportgen.report.MATLABGraphicsContainer( varargin{ : } );

            if isempty( this.TemplateName )
                this.TemplateName = "Axes";
            end
        end

        function impl = getImpl( this, rpt )
            arguments
                this( 1, 1 )
                rpt( 1, 1 ){ validateReport( this, rpt ) }
            end


            if isempty( this.LinkTarget )
                this.LinkTarget = mlreportgen.report.Axes.getLinkTargetID( this.Source );
            end

            impl = getImpl@mlreportgen.report.Reporter( this, rpt );
        end

        function set.Source( this, value )
            if ishghandle( value ) && value.Type == "axes"
                this.Source = value;
                createAxesClone( this );
            else
                error( message( "mlreportgen:report:error:invalidAxes" ) );
            end

        end

        function image = getSnapshotImage( this, report )











            image = getSnapshotImage@mlreportgen.report.MATLABGraphicsContainer( this, report );
        end
    end

    methods ( Access = protected )

        result = openImpl( reporter, impl, varargin )
    end

    methods ( Access = protected )

        function content = getSnapshotImageImpl( this, rpt, pageLayout )


            try
                f = figure( 'Visible', 'off' );
                delete( f );
            catch
                this.IsWebApp = true;
            end

            if this.IsWebApp


                content = getWebAppSnapshotImageImpl( this, rpt, pageLayout );
            else

                content = getSnapshotImageImpl@mlreportgen.report.MATLABGraphicsContainer( this, rpt, pageLayout );
            end
        end

        function content = getWebAppSnapshotImageImpl( this, rpt, pageLayout )



            imgformat = getImageFormat( this, rpt );

            tempImageFile = rpt.generateFileName( imgformat );
            resolutionArg = rptgen.utils.getScreenPixelsPerInch(  );

            if this.PreserveBackgroundColor
                bgColorArg = 'current';
            else
                bgColorArg = 'white';
            end

            figFile = this.getClonedFigureFile(  );
            snapShotFigure = openfig( figFile, "invisible" );
            scopedDelete = onCleanup( @(  )delete( snapShotFigure ) );

            axesHandle = snapShotFigure.Children;
            exportgraphics( axesHandle, tempImageFile,  ...
                "Resolution", resolutionArg,  ...
                "BackgroundColor", bgColorArg );
            domImage = mlreportgen.dom.Image( tempImageFile );


            [ newWidth, newHeight ] = getSnapshotDimensions( this, rpt, pageLayout, axesHandle );

            if newHeight > 0 && newWidth > 0
                domImage.Height = strcat( num2str( newHeight ), "in" );
                domImage.Width = strcat( num2str( newWidth ), "in" );
            elseif strcmp( imgformat, "emf" )

                pos = axesHandle.Position;
                origWidth = mlreportgen.utils.units.toInches( pos( 3 ), axesHandle.Units );
                origHeight = mlreportgen.utils.units.toInches( pos( 4 ), axesHandle.Units );
                domImage.Height = strcat( num2str( origHeight ), "in" );
                domImage.Width = strcat( num2str( origWidth ), "in" );
            end

            content = domImage;
        end

        function imgformat = getImageFormat( this, rpt )


            if ~this.IsWebApp
                imgformat = getImageFormat@mlreportgen.report.MATLABGraphicsContainer( this );
            else
                imgformat = this.SnapshotFormat;
                giveWarn = false;
                if ~ismember( imgformat, this.SupportedWebAppFormats )


                    giveWarn = true;
                    imgformat = "auto";
                end

                if strcmp( imgformat, "auto" )

                    if rpt.ispdf
                        imgformat = "pdf";
                    elseif rpt.isdocx && ispc
                        imgformat = "emf";
                    else
                        imgformat = "png";
                    end
                    if giveWarn
                        warning(  ...
                            message( "mlreportgen:report:warning:invalidWebAppSnapshotFormat",  ...
                            this.SnapshotFormat,  ...
                            upper( imgformat ) ) );
                    end
                end
            end
        end

        function figureFile = getClonedFigureFile( axesReporter )



            if ( ~isempty( axesReporter.Source ) && isgraphics( axesReporter.Source ) )
                createAxesClone( axesReporter );
            end

            assert( ~isempty( axesReporter.ClonedFigureFile ),  ...
                message( "mlreportgen:report:error:invalidAxes" ) );

            figureFile = axesReporter.ClonedFigureFile;
        end
    end

    methods ( Access = private )
        function figFile = createAxesClone( axesReporter )


            axesH = axesReporter.Source;

            figHandle = copyAxes( axesH );


            assert( ~isempty( figHandle.Children ),  ...
                message( "mlreportgen:report:error:invalidAxes" ) );

            scopedDelete = onCleanup( @(  )delete( figHandle ) );
            figFile = tempname + ".fig";
            hgsave( figHandle, figFile );


            deleteClonedFigureFile( axesReporter );

            axesReporter.ClonedFigureFile = figFile;
        end
    end

    methods ( Static, Hidden )
        function id = getLinkTargetID( axesHandle )


            id = "axes_" + double( axesHandle );
            id = mlreportgen.utils.normalizeLinkID( id );
        end
    end

    methods ( Static )
        function path = getClassFolder(  )


            [ path ] = fileparts( mfilename( 'fullpath' ) );
        end

        function template = createTemplate( templatePath, type )





            path = mlreportgen.report.Axes.getClassFolder(  );
            template = mlreportgen.report.ReportForm.createFormTemplate(  ...
                templatePath, type, path );
        end

        function classfile = customizeReporter( toClasspath )









            classfile = mlreportgen.report.ReportForm.customizeClass( toClasspath,  ...
                "mlreportgen.report.Axes" );
        end
    end
end

function axFig = copyAxes( hAx )

axFig = makeAxes( hAx );
copyAxesToFigure( axFig, hAx );
end


function copyAxFig = makeAxes( hAx )
copyAxFig = makeTempCanvas;

axUIPanel = getUIPanelHandle( hAx );
axFig = getFigureHandle( hAx );

if ~isempty( axUIPanel )
    orig.Units = get( axUIPanel, 'Units' );
    orig.Position = get( axUIPanel, 'position' );
    orig.Color = get( axUIPanel, 'backgroundcolor' );
else

    orig.Units = get( axFig, 'Units' );
    orig.Position = get( axFig, 'position' );
    orig.Color = get( axFig, 'color' );
end


orig.ColorMap = get( axFig, 'colormap' );
orig.InvertHardcopy = get( axFig, 'InvertHardcopy' );
orig.Renderer = get( axFig, 'Renderer' );

set( copyAxFig, orig );
end


function axFig = getFigureHandle( hAx )
axFig = get( hAx, 'parent' );
while ~isempty( axFig ) && ~strcmpi( get( axFig, 'Type' ), 'figure' )
    axFig = get( axFig, 'parent' );
end

if isempty( axFig )
    error( message( "mlreportgen:report:error:noParentFigure" ) );
end
end

function axUIPanel = getUIPanelHandle( hAx )
parent = get( hAx, 'parent' );
if strcmpi( get( parent, 'type' ), 'uipanel' )
    axUIPanel = parent;
else
    axUIPanel = [  ];
end
end

function copyAxesToFigure( axFig, allAx )
allAx = copyobj( allAx, axFig );



xTick = allAx.XTick;
yTick = allAx.YTick;
zTick = allAx.ZTick;
allAx.XTickMode = 'manual';
allAx.YTickMode = 'manual';
allAx.ZTickMode = 'manual';
allAx.XTick = xTick;
allAx.YTick = yTick;
allAx.ZTick = zTick;

set( [ allAx;axFig ], 'units', 'pixels' );
numAx = length( allAx );
extentMatrix = ones( numAx, 4 );
for i = 1:numAx
    extentMatrix( i, 1:4 ) = LocAxesExtent( allAx( i ) );
end

minExtent = min( extentMatrix, [  ], 1 );
border = 10;
axPos = get( allAx, 'Position' );
if ( numAx > 1 )
    axPos = cat( 1, axPos{ : } );
    axPos( :, 1 ) = axPos( :, 1 ) - minExtent( 1 ) + border;
    axPos( :, 2 ) = axPos( :, 2 ) - minExtent( 2 ) + border;
    axPos = num2cell( axPos, 2 );
    posID = { 'Position' };
else
    axPos( :, 1 ) = axPos( :, 1 ) - minExtent( 1 ) + border;
    axPos( :, 2 ) = axPos( :, 2 ) - minExtent( 2 ) + border;
    posID = 'Position';
end

set( allAx, posID, axPos );
maxExtent = max( extentMatrix, [  ], 1 );

figSize = maxExtent( 3:4 ) - minExtent( 1:2 ) + 2 * border;

set( axFig, 'Position', [ 20, 20, figSize ] );
end

function axExtent = LocAxesExtent( axH )
axExtent = get( axH, 'OuterPosition' );
axExtent = [ axExtent( 1:2 ), axExtent( 1:2 ) + axExtent( 3:4 ) ];
end

function h = makeTempCanvas


h = figure( 'HandleVisibility', 'off',  ...
    'IntegerHandle', 'off',  ...
    'Visible', 'off',  ...
    'CloseRequestFcn', 'set(gcbf,''Visible'',''off'')',  ...
    'NumberTitle', 'off',  ...
    'Name', 'Report Generator Temporary Drawing Canvas' );
end

