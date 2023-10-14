function [ A, R, attrib ] = readBasemapImage( basemap,  ...
    latlimOrMapCenter, lonlimOrZoomLevel, zoomLevelOrImageSize )

arguments
    basemap( 1, 1 )string{ mustBeBasemap }
    latlimOrMapCenter( 1, 2 ){ mustBeNumeric, mustBeReal, mustBeFinite }
    lonlimOrZoomLevel{ mustBeNumeric, mustBeReal, mustBeFinite } = 25
    zoomLevelOrImageSize{ mustBeNumeric, mustBeReal, mustBeFinite } = [  ]
end

defaultImageSize = [ 1024, 1024 ];
maxZoomLevel = 25;

selector = matlab.graphics.chart.internal.maps.BaseLayerSelector;
reader = selectReader( selector, basemap );
basemap = reader.TileSetMetadata.TileSetName;

try
    if length( lonlimOrZoomLevel ) > 1


        latlim = latlimOrMapCenter;
        lonlim = lonlimOrZoomLevel;

        if isempty( zoomLevelOrImageSize )
            zoomLevel = maxZoomLevel;
        else
            zoomLevel = zoomLevelOrImageSize;
        end


        [ xWorldLimits, yWorldLimits, zoomLevel ] = geographicToWorld(  ...
            reader, latlim, lonlim, zoomLevel );
    else



        mapCenter = latlimOrMapCenter;
        zoomLevel = lonlimOrZoomLevel;

        if isempty( zoomLevel )
            zoomLevel = maxZoomLevel;
        end

        if isempty( zoomLevelOrImageSize )
            rasterSize = defaultImageSize;
        else
            rasterSize = zoomLevelOrImageSize;
        end



        [ xWorldLimits, yWorldLimits, zoomLevel ] = mapCenterToWorld(  ...
            reader, mapCenter, zoomLevel, rasterSize );
    end


    [ A, R ] = readBasemapImageFromWorldLimits( reader,  ...
        xWorldLimits, yWorldLimits, zoomLevel );


    [ latlim, lonlim ] = wmercinv( R.XWorldLimits, R.YWorldLimits );
    attrib = readAttribution(  ...
        selector, reader, basemap, latlim, lonlim, zoomLevel );
    if strlength( attrib ) > 0
        attribImage = makeAttribImage( A, attrib );
        if any( size( A ) < size( attribImage ) )

            min1 = min( size( attribImage, 1 ), size( A, 1 ) );
            min2 = min( size( attribImage, 2 ), size( A, 2 ) );
            attribImage = attribImage( 1:min1, 1:min2, : );
        end
        A = addAttribtionImage( A, attribImage );
    end
catch e
    throw( e )
end
end


function [ xWorldLimits, yWorldLimits, zoomLevel ] = mapCenterToWorld(  ...
    reader, mapCenter, zoomLevel, rasterSize )



arguments
    reader
    mapCenter( 1, 2 )double{ mustBeFinite, mustBeReal }
    zoomLevel( 1, 1 )double{ mustBeInRange( zoomLevel, 0, 25 ) } = 25
    rasterSize( 1, 2 )double{ mustBeInRange( rasterSize, 64, 2048 ), mustBeInteger } = 1024
end

mustBeInRange( mapCenter( 1 ),  - 90, 90 )
mapCenter( 2 ) = wrapTo180( mapCenter( 2 ) );
zoomLevel = round( zoomLevel );

tsRef = matlab.graphics.chart.internal.maps.WebMercatorTileSetReference;
tsRef.ZoomLevel = zoomLevel;
if rasterSize( 1 ) > tsRef.TileSetSize( 1 )
    rasterSize( 1 ) = tsRef.TileSetSize( 1 );
end
if rasterSize( 2 ) > tsRef.TileSetSize( 2 )
    rasterSize( 2 ) = tsRef.TileSetSize( 2 );
end
maxImageSize = rasterSize;

if mapCenter( 1 ) < tsRef.LatitudeLimits( 1 )
    mapCenter( 1 ) = tsRef.LatitudeLimits( 1 );
end

if mapCenter( 1 ) > tsRef.LatitudeLimits( 2 )
    mapCenter( 1 ) = tsRef.LatitudeLimits( 2 );
end

[ xWorldLimits, yWorldLimits ] = limitsFromCenterAndZoom(  ...
    mapCenter, zoomLevel, rasterSize );

zoomLevelMax = getMaxZoomLevel( reader, xWorldLimits, yWorldLimits, zoomLevel );
while zoomLevel > zoomLevelMax
    zoomLevel = zoomLevelMax;
    [ xWorldLimits, yWorldLimits ] = limitsFromCenterAndZoom(  ...
        mapCenter, zoomLevel, maxImageSize );
    zoomLevelMax = getMaxZoomLevel( reader,  ...
        xWorldLimits, yWorldLimits, zoomLevel );
end
end


function [ xWorldLimits, yWorldLimits, zoomLevel ] = geographicToWorld(  ...
    reader, latlim, lonlim, zoomLevel )


arguments
    reader
    latlim( 1, 2 )double{ mustBeInRange( latlim,  - 90, 90 ), mustBeNondecreasingLimits }
    lonlim( 1, 2 )double{ mustBeReal, mustBeFinite }
    zoomLevel( 1, 1 )double{ mustBeInRange( zoomLevel, 0, 25 ) }
end

if diff( lonlim <= 0 )
    lonlim = map.internal.unwrapLongitudeLimits( lonlim );
end
rasterSize = [ 2048, 2048 ];

tsRef = matlab.graphics.chart.internal.maps.WebMercatorTileSetReference;
if latlim( 1 ) < tsRef.LatitudeLimits( 1 )
    latlim( 1 ) = tsRef.LatitudeLimits( 1 );
end

if latlim( 2 ) > tsRef.LatitudeLimits( 2 )
    latlim( 2 ) = tsRef.LatitudeLimits( 2 );
end

minZoomLevel = 0;
[ xWorldLimits, yWorldLimits, zoomLevel ] = fitlimits(  ...
    latlim, lonlim, rasterSize, minZoomLevel, zoomLevel );

zoomLevelMax = getMaxZoomLevel( reader, xWorldLimits, yWorldLimits, zoomLevel );
if zoomLevel > zoomLevelMax
    zoomLevel = zoomLevelMax;
    [ xWorldLimits, yWorldLimits, zoomLevel ] = fitlimits(  ...
        latlim, lonlim, rasterSize, minZoomLevel, zoomLevel );
end
end


function zoomLevel = getMaxZoomLevel( reader, xWorldLimits, yWorldLimits, zoomLevel )




zoomLevel = min( reader.TileSetMetadata.MaxZoomLevel, zoomLevel );

tsRef = matlab.graphics.chart.internal.maps.WebMercatorTileSetReference;
tsRef.ZoomLevel = zoomLevel;

tileColIndex = xWorldToTileIndex( tsRef, xWorldLimits );
tileRowIndex = yWorldToTileIndex( tsRef, yWorldLimits );

maxZoomLevel = readMaxZoomLevel( reader, tileColIndex, tileRowIndex, zoomLevel );
zoomLevel = min( zoomLevel, maxZoomLevel );
end


function [ xWorldLimits, yWorldLimits ] = limitsFromCenterAndZoom(  ...
    mapCenter, zoomLevel, rasterSize )


[ xcenter, ycenter ] = wmercfwd( mapCenter( 1 ), mapCenter( 2 ) );
pixelsPerDataXY = scaleFromZoomLevel( zoomLevel );
[ xWorldLimits, yWorldLimits ] = limitsFromCenterAndScale(  ...
    xcenter, ycenter, pixelsPerDataXY, rasterSize );
end


function [ xWorldLimits, yWorldLimits ] = limitsFromCenterAndScale(  ...
    xcenter, ycenter, pixelsPerDataXY, rasterSize )





pixelWidthInDataX = rasterSize( 2 ) / pixelsPerDataXY;
pixelHeightInDataY = rasterSize( 1 ) / pixelsPerDataXY;
xWorldLimits = xcenter + [  - 0.5, 0.5 ] * pixelWidthInDataX;
yWorldLimits = ycenter + [  - 0.5, 0.5 ] * pixelHeightInDataY;
end


function [ xWorldLimits, yWorldLimits, zoomLevel ] = fitlimits(  ...
    latlim, lonlim, rasterSize, minZoomLevel, maxZoomLevel )










[ yWorldLimits, zlat ] = yWorldLimitsAndZoomFromLatitudeLimits(  ...
    latlim, rasterSize( 1 ) );
[ xWorldLimits, zlon ] = xWorldLimitsAndZoomFromLongitudeLimits(  ...
    lonlim, rasterSize( 2 ) );
actualZoomLevel = max( minZoomLevel, min( maxZoomLevel, min( [ zlon, zlat ] ) ) );
zoomLevel = round( actualZoomLevel );




if zoomLevel > actualZoomLevel
    pixelsPerDataXY = scaleFromZoomLevel( zoomLevel );
    if fix( ( pixelsPerDataXY * diff( xWorldLimits ) ) ) > rasterSize( 2 ) ...
            || fix( ( pixelsPerDataXY * diff( yWorldLimits ) ) ) > rasterSize( 1 )
        zoomLevel = zoomLevel - 1;
    end
end
end


function [ yWorldLimits, zoomLevel ] = yWorldLimitsAndZoomFromLatitudeLimits(  ...
    latlim, numPixelsInY )





yWorldLimits = lat2y( latlim );
inflim = isinf( yWorldLimits );
yWorldLimits( inflim ) = sign( yWorldLimits( inflim ) ) * realmax;
pixelsPerDataY = numPixelsInY / diff( yWorldLimits );
zoomLevel = targetZoomLevel( pixelsPerDataY );
end


function [ xWorldLimits, zoomLevel ] = xWorldLimitsAndZoomFromLongitudeLimits(  ...
    lonlim, numPixelsInX )





if diff( lonlim ) <= 0
    lonlim = map.internal.unwrapLongitudeLimits( lonlim );
end
xWorldLimits = lon2x( lonlim );
pixelsPerDataX = numPixelsInX / diff( xWorldLimits );
zoomLevel = targetZoomLevel( pixelsPerDataX );
end


function scale = scaleFromZoomLevel( zoom )



N = getPixelsPerTileDimension(  );
scale = ( N * 2 ^ zoom ) / getCircumference;
end


function z = targetZoomLevel( pixelsPerDataXY )



N = getPixelsPerTileDimension(  );
z = log2( getCircumference * pixelsPerDataXY / N );
end


function [ xWebMercator, yWebMercator ] = wmercfwd( lat, lon )


wmerc = projcrs( 3857 );
[ xWebMercator, yWebMercator ] = projfwd( wmerc, lat, lon );
end


function [ lat, lon ] = wmercinv( xWebMercator, yWebMercator )


wmerc = projcrs( 3857 );
[ lat, lon ] = projinv( wmerc, xWebMercator, yWebMercator );
end


function xWebMercator = lon2x( lon )




wgs84 = wgs84Ellipsoid;
radius = wgs84.SemimajorAxis;
xWebMercator = radius * deg2rad( lon );
end


function yWebMercator = lat2y( lat )




lat( lat( : ) <  - 90 ) =  - 90;
lat( lat( : ) > 90 ) = 90;
wgs84 = wgs84Ellipsoid;
radius = wgs84.SemimajorAxis;
yWebMercator = radius * atanh( sind( lat ) );
end


function c = getCircumference(  )




wgs84 = wgs84Ellipsoid;
radius = wgs84.SemimajorAxis;
piR = pi * radius;
c = 2 * piR;
end


function N = getPixelsPerTileDimension(  )



N = 256;
end


function [ A, R ] = readBasemapImageFromWorldLimits(  ...
    reader, xWorldLimits, yWorldLimits, zoomLevel )


tsRef = matlab.graphics.chart.internal.maps.WebMercatorTileSetReference;
tsRef.ZoomLevel = zoomLevel;
pixelsPerDataXY = scaleFromZoomLevel( zoomLevel );

if zoomLevel <= 3
    tileRowIndex = tsRef.TileRowLimits;
    tileColIndex = tsRef.TileColumnLimits;
    xTileWorld = tsRef.XWorldLimits;
    yTileWorld = tsRef.YWorldLimits;
    xcenter = sum( xWorldLimits ) / 2;
    numPixels = xcenter * pixelsPerDataXY;

    tileBoundaryA = readMapTiles( reader, tileRowIndex, tileColIndex, zoomLevel );

    if xcenter ~= 0
        tileBoundaryA = circshift( tileBoundaryA,  - round( numPixels ), 2 );
        xTileWorld = xTileWorld + xcenter;
    end
else
    if any( xWorldLimits < tsRef.XWorldLimits( 1 ) )


        xWorldLimits = xWorldLimits + diff( tsRef.XWorldLimits );
    end

    tileColIndex = xWorldToTileCol( tsRef, xWorldLimits );
    tileRowIndex = yWorldToTileRow( tsRef, yWorldLimits );

    tcsave = tileColIndex;
    if any( tileColIndex > 2 ^ zoomLevel )
        tileColIndex = mod( tileColIndex, 2 ^ zoomLevel );
    end
    requiresShift = ~isequal( tcsave, tileColIndex );

    tileColIndex = [ floor( tileColIndex( 1 ) ), ceil( tileColIndex( 2 ) ) ];
    tileRowIndex = [ ceil( tileRowIndex( 1 ) ), floor( tileRowIndex( 2 ) ) ];
    tileRowIndex = [ min( tileRowIndex ), max( tileRowIndex ) ];

    tileRowIndex( tileRowIndex < 0 ) = 0;
    tileRowIndex( tileRowIndex > ( tsRef.TileRowLimits( 2 ) - 1 ) ) = tsRef.TileRowLimits( 2 ) - 1;
    tileColIndex( tileColIndex < 0 ) = 0;
    tileColIndex( tileColIndex > ( tsRef.TileColumnLimits( 2 ) - 1 ) ) = tsRef.TileColumnLimits( 2 ) - 1;

    tileBoundaryA = readMapTiles( reader, tileRowIndex, tileColIndex, zoomLevel );
    tileRowIndex = tileRowIndex + [ 0, 1 ];
    tileRowIndex( 1 ) = max( tileRowIndex( 1 ), 0 );
    tileRowIndex( 2 ) = min( tileRowIndex( 2 ), tsRef.TileRowLimits( 2 ) );

    if requiresShift
        tileColIndex = [ floor( tcsave( 1 ) ), ceil( tcsave( 2 ) ) ];
    end
    tileColIndex = tileColIndex + [ 0, 1 ];

    if ~requiresShift
        tileColIndex( 2 ) = min( tileColIndex( 2 ), tsRef.TileColumnLimits( 2 ) );
    end
    xTileWorld = tileColToXWorld( tsRef, tileColIndex );
    yTileWorld = tileRowToYWorld( tsRef, tileRowIndex );
end

xTileWorld = [ min( xTileWorld ), max( xTileWorld ) ];
yTileWorld = [ min( yTileWorld ), max( yTileWorld ) ];
tileBoundaryR = maprefcells( xTileWorld, yTileWorld, size( tileBoundaryA ) );
tileBoundaryR.ColumnsStartFrom = 'north';

















[ xi, yi ] = worldToIntrinsic( tileBoundaryR, xWorldLimits, yWorldLimits );


xi = [ min( xi ), max( xi ) ];
yi = [ max( yi ), min( yi ) ];





if abs( diff( xi ) ) > 1
    xi = xi + [ .5,  - .5 ];
end

if abs( diff( yi ) ) > 1
    yi = yi + [  - .5, .5 ];
end


col = round( xi );
row = round( yi );


numCols = size( tileBoundaryA, 2 );
numRows = size( tileBoundaryA, 1 );
col( 1 ) = min( max( col( 1 ), 1 ), numCols );
col( 2 ) = min( max( col( 2 ), 1 ), numCols );
row( 1 ) = min( max( row( 1 ), 1 ), numRows );
row( 2 ) = min( max( row( 2 ), 1 ), numRows );


A = tileBoundaryA( row( 2 ):row( 1 ), col( 1 ):col( 2 ), : );




xi = col + [  - .5, .5 ];
yi = row + [ .5,  - .5 ];
[ xw, yw ] = intrinsicToWorld( tileBoundaryR, xi, yi );
xw = [ min( xw ), max( xw ) ];
yw = [ min( yw ), max( yw ) ];


R = maprefcells( xw, yw, size( A ), "ColumnsStartFrom", "north" );
R.ProjectedCRS = projcrs( 3857 );
end


function attrib = readAttribution(  ...
    selector, reader, basemap, latlim, lonlim, zoomLevel )


if matches( basemap, selector.BaseLayers )

    dr = matlab.graphics.chart.internal.maps.DynamicAttributionReader(  ...
        reader.TileSetMetadata );
    attrib = readDynamicAttribution( dr, latlim, lonlim, zoomLevel );
else

    meta = reader.TileSetMetadata;
    attrib = meta.Attribution;
end
end


function attribImage = makeAttribImage( A, attrib )


color = get( groot, 'FactoryFigureColor' );
hfig = figure( 'Visible', 'off', 'Color', color );
cleanObj = onCleanup( @(  )close( hfig ) );
ax = axes( hfig );
ax.XAxis.Visible = 'off';
ax.YAxis.Visible = 'off';
ax.Units = 'pixels';
ax.Position( 3 ) = size( A, 2 );
ax.Position( 4 ) = size( A, 1 );
fontSize = 8;
txt = attributionTextDisplay( ax, attrib, fontSize );

attribImage = snapshot( ax, txt );
if any( size( A ) < size( attribImage ) )
    delete( txt )
    fontSize = 6;
    txt = attributionTextDisplay( ax, attrib, fontSize );
    attribImage = snapshot( ax, txt );
end
end


function A = snapshot( ax, txt )


extent = ceil( txt.Extent( 3:4 ) + 2 * txt.Margin );
rect = [ 1, 1, extent ];
frame = getframe( ax, rect );
if ~isscalar( txt.String ) &&  ...
        matlab.internal.editor.figure.FigureUtils.isEditorFigure( ax.Parent )


    extent = ceil( txt.Extent( 3:4 ) + 2 * txt.Margin );
    rect = [ 1, 1, extent ];
    frame = getframe( ax, rect );
end
A = frame.cdata;
end


function A = addAttribtionImage( A, attribImage )



sizeB = size( attribImage );
sizeA = size( A );
m = sizeA( 1 ) - sizeB( 1 ) + 1:sizeA( 1 );
n = sizeA( 2 ) - sizeB( 2 ) + 1:sizeA( 2 );
A( m, n, : ) = attribImage;
end


function txt = attributionTextDisplay( ax, attrib, fontSize )




colorDataRGBA = uint8( [ 50, 50, 50, 255 ]' );
backgroundColor = [ 1, 1, 1 ];
backgroundAlpha = 0.65;
backgroundRGBA = uint8( 255 * [ backgroundColor, backgroundAlpha ]' );


txt = matlab.graphics.primitive.Text;
txt.Visible = 'off';
txt.Color = colorDataRGBA;
txt.BackgroundColor = backgroundRGBA;
txt.HorizontalAlignment = 'left';
txt.VerticalAlignment = 'bottom';
txt.FontName = get( groot, 'DefaultGeoaxesFontName' );
txt.FontSize = fontSize;
txt.Margin = 2;
txt.PickableParts = 'none';
txt.Layer = 'front';
txt.Clipping = 'on';
txt.String = attrib;


txt.Parent = ax;
positionText( txt )
txt.Visible = 'on';
end


function positionText( txt )



layout = GetLayoutInformation( txt.Parent );
numChars = 60;
widthInChars = min( layout.PlotBox( 3 ), numChars );
txt.Parent.Units = 'char';
axWidthInChars = txt.Parent.Position( 3 );
axWidthInChars = axWidthInChars + 2;
widthInChars = min( axWidthInChars, widthInChars );
txt.Parent.Units = 'pixels';
charFontSize = get( groot, 'FactoryUiControlFontSize' );
widthInSizedChars = widthInChars * charFontSize / txt.FontSize;
availableWidthInChars = round( widthInSizedChars / 2 );


attrib = txt.String;
attrib = string(  ...
    matlab.internal.display.printWrapped(  ...
    char( join( attrib ) ), availableWidthInChars ) );
attrib = convertStringsToChars( splitlines( attrib( : ) ) );



attrib( end  ) = [  ];
txt.String = attrib;

txt.Units = 'pixels';
txt.Position( 1:2 ) = txt.Margin;
end


function mustBeBasemap( basemap )


basemapNames = matlab.graphics.chart.internal.maps.basemapNames(  );
try
    validatestring( basemap, basemapNames, "readBasemapImage", "basemap" );
catch e

    if ~( ( ischar( basemap ) || isstring( basemap ) ) && ~isempty( basemap ) ...
            && ~any( ismissing( basemap ) ) ...
            && ~isempty( which( basemap + "_configuration.xml" ) ) )
        throw( e )
    end
end
end


function mustBeNondecreasingLimits( limits )

if limits( 2 ) < limits( 1 )
    error( message( 'map:validators:mustBeNondecreasingLimits' ) )
end
end


