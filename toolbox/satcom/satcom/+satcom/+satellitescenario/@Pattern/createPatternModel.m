function patternModel = createPatternModel( patternData, NameValueArgs )


R36
patternData
NameValueArgs.Resolution = "high"
NameValueArgs.Size = 50
NameValueArgs.Colormap = jet
NameValueArgs.ColorLimits = [  - 1, 1 ]
end 
patternSize = NameValueArgs.Size;
cmap = NameValueArgs.Colormap;
colorLimits = NameValueArgs.ColorLimits;

r = patternData.r;
az = patternData.az;
el = patternData.el;


[ X, Y, Z, r2 ] = formatDataForPlot( az, el, r );


[ ~, maxInd ] = max( r2( : ) );
maxXYZ = [ X( maxInd ), Y( maxInd ), Z( maxInd ) ];
distToBoresight = sqrt( maxXYZ( 1 ) .^ 2 + maxXYZ( 2 ) .^ 2 + maxXYZ( 3 ) .^ 2 );
scaleFactor = patternSize / distToBoresight;


[ tri, xyzData ] = surf2patch( X, Y, Z, 'triangles' );


rVec = r2( : );
minr = min( rVec );
maxr = max( rVec );

normR = rVec + abs( minr );
normR = normR / maxr;
minColor = colorLimits( 1 );
maxColor = colorLimits( 2 );

diff = maxColor - minColor;
normR = normR * diff;
normR = normR + minColor;


rColorsTriangles = normR( tri );
rColorsTriangles = rColorsTriangles';
CData = rColorsTriangles;


cmin = min( CData( : ) );
cmax = max( CData( : ) );



if ( cmin == cmax )
cmin = cmin - 1;
cmax = cmax + 1;
end 
m = size( cmap, 1 );
colormapInd = fix( ( CData - cmin ) / ( cmax - cmin ) * m ) + 1;
colormapInd( colormapInd > m ) = m;
colormapInd( colormapInd < 1 ) = 1;
imgRGB = ind2rgb( colormapInd, cmap );


tri = tri';
indices = tri( : );


xyzData = xyzData * scaleFactor;



numIndices = numel( indices );
numVertices = size( xyzData, 1 );
imgRGB = reshape( imgRGB, numIndices, 3 );
vColors = zeros( numVertices, 3 );
for i = 1:numIndices
idx = indices( i );
color = imgRGB( i, : );
vColors( idx, : ) = color;
end 

vColors = rfprop.internal.ColorUtils.srgb2lin( vColors );


tempxyzData = fillmissing( xyzData, 'constant', 0 );


T = reshape( indices, 3, [  ] )';
TR = triangulation( T, tempxyzData );




TR = struct( "Points", xyzData, "ConnectivityList", TR.ConnectivityList,  ...
"faceNormal", TR.faceNormal );


patternModel = globe.internal.Geographic3DModel( TR,  ...
'VertexColors', vColors,  ...
'EnableLighting', false );
end 

function [ X, Y, Z, r2 ] = formatDataForPlot( az, el, r )
phi1 = az;
theta1 = 90 - el;
[ theta, phi ] = meshgrid( theta1, phi1 );
MagE1 = r';
[ offset, maxE1 ] = bounds( MagE1( : ) );
rRange = maxE1 - offset;
if ( rRange == 0 )




offset = 1;
end 
MagE = reshape( MagE1, length( phi1 ), length( theta1 ) );
r2 = MagE - offset;
[ X, Y, Z ] = psph2cart( phi, theta, r2 ./ max( max( r2 ) ) );
end 

function [ X, Y, Z ] = psph2cart( phi, theta, r )

Z = r .* cosd( theta );
X = r .* sind( theta ) .* cosd( phi );
Y = r .* sind( theta ) .* sind( phi );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpZs538Z.p.
% Please follow local copyright laws when handling this file.

