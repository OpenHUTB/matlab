classdef Geometry < handle

properties ( Constant )
AvailablePrimitives = { 'arrow', 'box', 'cone', 'cylinder', 'checker',  ...
'extrusion', 'icosphere', 'plane', 'prism', 'pyramid', 'revolution',  ...
'sphere', 'surf', 'terrain', 'tile', 'torus', 'triad', 'tube',  ...
'voxel' };
end 


methods ( Static )

function [ V, N, F, T, C ] = arrow( ASize, Segments, Axis )

R36
ASize( 1, 3 )double = [ 1, 1, 1 ]
Segments( 1, 1 )double = 9
Axis( 1, 1 )double = 3
end 

[ V, N, F, T, C ] = sim3d.utils.Geometry.revolution( [  - 0.5, 0;0.2, 0.25;0.2, 0.5;0.5, 0 ], Segments, false, false );

if Axis == 3
V = V .* ASize;
else 
V = circshift( V, [ 0, Axis ] ) .* ASize;
N = circshift( N, [ 0, Axis ] );
end 
end 


function [ V, N, F, T, C ] = box( ASize )

R36
ASize( 1, 3 )double = [ 1, 1, 1 ]
end 

V = repmat( ( [ 0, 0, 0;1, 0, 0;1, 1, 0;0, 1, 0;0, 0, 1;1, 0, 1;1, 1, 1;0, 1, 1 ] - 0.5 ) .* ASize, [ 3, 1 ] );

N = [ 0, 0,  - 1;0, 0,  - 1;0, 0,  - 1;0, 0,  - 1;0, 0, 1;0, 0, 1;0, 0, 1;0, 0, 1; ...
 - 1, 0, 0;1, 0, 0;1, 0, 0; - 1, 0, 0; - 1, 0, 0;1, 0, 0;1, 0, 0; - 1, 0, 0; ...
0,  - 1, 0;0,  - 1, 0;0, 1, 0;0, 1, 0;0,  - 1, 0;0,  - 1, 0;0, 1, 0;0, 1, 0 ];

T = [ 0, 0;1, 0;1, 1;0, 1;0, 1;1, 1;1, 0;0, 0; ...
1, 1;0, 1;1, 1;0, 1;1, 0;0, 0;1, 0;0, 0; ...
0, 1;1, 1;0, 1;1, 1;0, 0;1, 0;0, 0;1, 0 ];

F = [ 0, 2, 3;0, 1, 2;16, 20, 21;21, 17, 16;9, 13, 10;10, 13, 14;18, 22, 19;19, 22, 23;11, 15, 8;8, 15, 12;4, 7, 5;5, 7, 6 ];

C = [  ];
end 


function [ V, N, F, T, C ] = cone( ASize, Segments, Axis )

R36
ASize( 1, 3 )double = [ 1, 1, 1 ]
Segments( 1, 1 )double = 24
Axis( 1, 1 )double = 3
end 

[ V, N, F, T, C ] = sim3d.utils.Geometry.revolution( [  - 0.5, 0.5;0.5, 0 ], Segments, true, false );

if Axis == 3
V = V .* ASize;
else 
V = circshift( V, [ 0, Axis ] ) .* ASize;
N = circshift( N, [ 0, Axis ] );
end 
end 


function [ V, N, F, T, C ] = cylinder( ASize, Segments, Axis )

R36
ASize( 1, 3 )double = [ 1, 1, 1 ]
Segments( 1, 1 )double = 24
Axis( 1, 1 )double = 3
end 

[ V, N, F, T, C ] = sim3d.utils.Geometry.revolution( [  - 0.5, 0.5;0.5, 0.5 ], Segments, true, true );

if Axis == 3
V = V .* ASize;
else 
V = circshift( V, [ 0, Axis ] ) .* ASize;
N = circshift( N, [ 0, Axis ] );
end 
end 


function [ V, N, F, T, C ] = checker( ASize, Segments, Color1, Color2 )

R36
ASize( 1, 3 )double = [ 1, 1, 1 ]
Segments( 1, 2 )double = [ 10, 10 ]
Color1( 1, 3 )double = [ 0, 0, 0 ]
Color2( 1, 3 )double = [ 1, 1, 1 ]
end 

sx = ASize( 1 ) / Segments( 1 );
sy = ASize( 2 ) / Segments( 2 );
[ v, n, f, t ] = sim3d.utils.Geometry.box( [ sx, sy, ASize( 3 ) ] );
V = [  ];
N = [  ];
F = [  ];
T = [  ];
C = [  ];
cx = ASize( 1 ) / 2 + sx / 2;
cy = ASize( 2 ) / 2 + sy / 2;
Color1 = repmat( Color1, size( v, 1 ), 1 );
Color2 = repmat( Color2, size( v, 1 ), 1 );
for i = 1:Segments( 2 )
for j = 1:Segments( 1 )
V = vertcat( V, v + [ sx * j - cx, sy * i - cy, 0 ] );
N = vertcat( N, n );
F = vertcat( F, f );
f = f + length( v );
T = vertcat( T, t );
if mod( i, 2 )
if mod( j, 2 )
C = vertcat( C, Color1 );
else 
C = vertcat( C, Color2 );
end 
else 
if mod( j, 2 )
C = vertcat( C, Color2 );
else 
C = vertcat( C, Color1 );
end 
end 
end 
end 
end 


function [ V, N, F, T, C ] = extrusion( Spine, Scale, Profile, BeginCap, EndCap )

R36
Spine
Scale = 1
Profile = 16
BeginCap( 1, 1 )logical = true
EndCap( 1, 1 )logical = true
end 

V = [  ];
N = [  ];
F = [  ];
T = [  ];
C = [  ];

if size( Spine, 1 ) < 2
return 
end 
if size( Spine, 1 ) ~= size( Scale, 1 )
Scale = ones( size( Spine, 1 ), 3 ) * Scale( 1 );
else 
if size( Scale, 2 ) == 1
Scale = repmat( Scale, [ 1, 3 ] );
else 
Scale = [ ones( size( Scale, 1 ), 1 ), Scale( :, [ 1, 2 ] ) ];
end 
end 

if BeginCap
bcShift = Spine( 2, : ) - Spine( 1, : );
Scale = [ 1, 0, 0;Scale( 1, : );Scale ];
Spine = [ Spine( 1, : ) - 2 * bcShift;Spine( 1, : ) - bcShift;Spine ];
end 
if EndCap
ecShift = Spine( end , : ) - Spine( end  - 1, : );
Scale = [ Scale;Scale( end , : );1, 0, 0 ];
Spine = [ Spine;Spine( end , : ) + ecShift;Spine( end , : ) + 2 * ecShift ];
end 

if length( Profile ) == 1

Segments = Profile;
a = linspace( 0, 360, Segments + 1 )';
v0 = [ a * 0, cosd( a ), sind( a ) ];
n0 = v0;
t0 = [ a / 360, v0( :, 1 ) ];
else 

Segments = size( Profile, 1 ) - 1;
v0 = [ Profile( :, 1 ) * 0, Profile( :, 1:2 ) ];
n0 = diff( v0 );
n0( end  + 1, : ) = v0( 1, : ) - v0( end , : );
for i = 1:Segments + 1
n0( i, : ) = [ 0, n0( i, 3 ),  - n0( i, 2 ) ] / norm( n0( i, : ) );
end 
t0 = [ linspace( 0, 1, Segments + 1 )', v0( :, 1 ) ];
end

f = ( 0:Segments - 1 )';
f0 = [ f, f + Segments + 2, f + 1;f, f + Segments + 1, f + Segments + 2 ];

nS = size( Spine, 1 );
if ~BeginCap && ~EndCap
tY = linspace( 0, 1, nS );
elseif ~BeginCap && EndCap
tY = [ linspace( 0, 1, nS - 2 ), 1, 1 ];
elseif BeginCap && ~EndCap
tY = [ 0, 0, linspace( 0, 1, nS - 2 ) ];
elseif BeginCap && EndCap
tY = [ 0, 0, linspace( 0, 1, nS - 4 ), 1, 1 ];
end 

Ptot = Spine( 1, : );
for i = 2:nS
P = Spine( i, : ) - Spine( i - 1, : );
p = P / norm( P );
Z =  - atan2( p( 2 ), p( 1 ) ) * 180 / pi;
Y = atan2( p( 3 ), sqrt( p( 1 ) ^ 2 + p( 2 ) ^ 2 ) ) * 180 / pi;
X = 0;
R = sim3d.internal.Math.rot321( [ X, Y, Z ] );
Ptot = Ptot + P;
V = vertcat( V, v0 .* Scale( i, : ) * R + Ptot );
N = vertcat( N, n0 * R );
F = vertcat( F, f0 );
f0 = f0 + Segments + 1;
T = vertcat( T, t0 + [ 0, tY( i ) ] );
end 

lp = Segments + 1;
V = [ ( V( 1:lp, : ) - Spine( 2, : ) ) .* Scale( 1, : ) ./ Scale( 2, : ) + Spine( 1, : );V ];
N = [ N( 1:lp, : );N ];
T = [ t0;T ];

if BeginCap
V( 1:lp * 2, : ) = V( 1:lp * 2, : ) + bcShift;
V( 1:lp, : ) = V( 1:lp, : ) + bcShift;
N( 1:lp * 2, : ) = zeros( lp * 2, 3 ) - bcShift;
end 
if EndCap
V( end  - lp * 2 + 1:end , : ) = V( end  - lp * 2 + 1:end , : ) - ecShift;
V( end  - lp + 1:end , : ) = V( end  - lp + 1:end , : ) - ecShift;
N( end  - lp * 2 + 1:end , : ) = zeros( lp * 2, 3 ) + ecShift;
end 
end 


function [ V, N, F, T, C ] = icosphere( ASize, Subdivision, Axis )

R36
ASize( 1, 3 )double = [ 1, 1, 1 ]
Subdivision( 1, 1 )double = 1
Axis( 1, 1 )double = 3
end

fi = ( 1 + sqrt( 5 ) ) / 2;
V = [ 0,  + 1,  + fi;0,  + 1,  - fi;0,  - 1,  + fi;0,  - 1,  - fi ];
V = [ V;circshift( V, [ 0,  - 1 ] );circshift( V, [ 0,  - 2 ] ) ];

F = [ 1, 9, 3;9, 6, 3;6, 8, 3;8, 10, 3;10, 1, 3; ...
7, 2, 5;5, 2, 11;11, 2, 4;4, 2, 12;12, 2, 7; ...
1, 7, 5;5, 9, 1;9, 5, 11;11, 6, 9;6, 11, 4; ...
4, 8, 6;8, 4, 12;12, 10, 8;10, 12, 7;7, 1, 10 ] - 1;

for j = 2:Subdivision
N = length( F );
F2 = zeros( 4 * N, 3 );
V2 = zeros( 3 * N, 3 );
off = length( V );
for i = 1:N
f1 = F( i, : ) + 1;
v1 = V( f1, : );
v2 = [ mean( v1( [ 1, 2 ], : ) );mean( v1( [ 2, 3 ], : ) );mean( v1( [ 1, 3 ], : ) ) ];
id = ( i * 3 - 2 ):i * 3;
V2( id, : ) = v2;
k = off + i * 3;
f12 = [ f1, ( k - 2 ):k ];
f2 = [ f12( 1 ), f12( 4 ), f12( 6 );f12( 4 ), f12( 2 ), f12( 5 );f12( 6 ), f12( 5 ), f12( 3 );f12( 6 ), f12( 4 ), f12( 5 ) ];
id = ( i * 4 - 3 ):i * 4;
F2( id, : ) = f2 - 1;
end 
F = F2;
V = [ V;V2 ];
end 

V = V ./ sqrt( sum( V .^ 2, 2 ) );
N = V;

T = [ ( atan2( N( :, 2 ), N( :, 1 ) ) + pi ) / ( 2 * pi ), acos( N( :, 3 ) ) / pi ];

if Axis == 3
V = V .* ASize / 2;
else 
V = circshift( V, [ 0, Axis ] ) .* ASize / 2;
N = circshift( N, [ 0, Axis ] );
end 

C = [  ];
end 


function [ V, N, F, T, C ] = plane( ASize, Axis, BothSides )

R36
ASize( 1, 3 )double = [ 1, 1, 1 ]
Axis( 1, 1 )double = 3
BothSides( 1, 1 )logical = true
end 

if BothSides
V = [ 0, 0, 0;1, 0, 0;1, 1, 0;0, 1, 0;0, 0, 0;1, 0, 0;1, 1, 0;0, 1, 0 ] - [ 0.5, 0.5, 0 ];
N = [ 0, 0, 1;0, 0, 1;0, 0, 1;0, 0, 1;0, 0,  - 1;0, 0,  - 1;0, 0,  - 1;0, 0,  - 1 ];
T = [ 0, 1;1, 1;1, 0;0, 0;0, 1;1, 1;1, 0;0, 0 ];
F = [ 0, 3, 2;0, 2, 1;4, 6, 7;4, 5, 6 ];
else 
V = [ 0, 0, 0;1, 0, 0;1, 1, 0;0, 1, 0 ] - [ 0.5, 0.5, 0 ];
N = [ 0, 0, 1;0, 0, 1;0, 0, 1;0, 0, 1 ];
T = [ 0, 1;1, 1;1, 0;0, 0 ];
F = [ 0, 3, 2;0, 2, 1 ];
end 

if Axis ~= 3
V = circshift( V, [ 0, Axis ] );
N = circshift( N, [ 0, Axis ] );
end 
V = V .* ASize;

C = [  ];
end 


function [ V, N, F, T, C ] = terrain( ASize, Height, Axis, PlanarNormals )

R36
ASize( 1, 3 )double = [ 1, 1, 1 ]
Height( :, : )double = [ 0, 0;0, 0 ]
Axis( 1, 1 )double = 3
PlanarNormals( 1, 1 )logical = false
end 

x = linspace( 0, 1, size( Height, 2 ) );
y = linspace( 0, 1, size( Height, 1 ) );
[ gx, gy ] = meshgrid( x, y );
V = [ gx( : ) - 0.5, gy( : ) - 0.5, Height( : ) ];

F = delaunay( gx, gy );
F = F( :, [ 1, 3, 2 ] );

if PlanarNormals
N = repmat( [ 0, 0, 1 ], [ size( V, 1 ), 1 ] );
else 
tr = triangulation( F, V );
N =  - tr.vertexNormal;
end 
F = F - 1;

T = [ gx( : ), gy( : ) ];

if Axis ~= 3
V = circshift( V, [ 0, Axis ] );
N = circshift( N, [ 0, Axis ] );
end 
V = V .* ASize;

C = [  ];
end 


function [ V, N, F, T, C ] = prism( ASize, Peak, Axis )

R36
ASize( 1, 3 )double = [ 1, 1, 1 ]
Peak( 1, 1 )double = 0.5
Axis( 1, 1 )double = 3
end 

V = [ 0, 0, 0;1, 0, 0;Peak, 0, 1;
1, 0, 0;1, 1, 0;Peak, 1, 1;Peak, 0, 1;
1, 1, 0;0, 1, 0;Peak, 1, 1;
0, 1, 0;0, 0, 0;Peak, 0, 1;Peak, 1, 1;
0, 0, 0;1, 0, 0;1, 1, 0;0, 1, 0 ] - 0.5;

N = [ 0,  - 1, 1;0,  - 1, 1;0,  - 1, 1;
1, 0, 1;1, 0, 1;1, 0, 1;1, 0, 1;
0, 1, 1;0, 1, 1;0, 1, 1;
 - 1, 0, 1; - 1, 0, 1; - 1, 0, 1; - 1, 0, 1;
0, 0,  - 1;0, 0,  - 1;0, 0,  - 1;0, 0,  - 1 ];

T = [ 0, 0;1, 0;0.5, 1;
0, 0;1, 0;1, 1;0, 1;
0, 0;1, 0;0.5, 1;
0, 0;1, 0;1, 1;0, 1;
0, 0;1, 0;1, 1;0, 1 ];

F = [ 0, 2, 1;3, 5, 4;3, 6, 5;7, 9, 8;10, 12, 11;10, 13, 12;14, 15, 17;17, 15, 16 ];

if Axis ~= 3
V = circshift( V, [ 0, Axis ] ) .* ASize;
N = circshift( N, [ 0, Axis ] );
else 
V = V .* ASize;
end 

C = [  ];
end 


function [ V, N, F, T, C ] = pyramid( ASize, Axis )

R36
ASize( 1, 3 )double = [ 1, 1, 1 ]
Axis( 1, 1 )double = 3
end 

V = [ 0, 0, 0;1, 0, 0;0.5, 0.5, 1;
1, 0, 0;1, 1, 0;0.5, 0.5, 1;
1, 1, 0;0, 1, 0;0.5, 0.5, 1;
0, 1, 0;0, 0, 0;0.5, 0.5, 1;
0, 0, 0;1, 0, 0;1, 1, 0;0, 1, 0 ] - 0.5;

N = [ 0,  - 1, 1;0,  - 1, 1;0,  - 1, 1;
1, 0, 1;1, 0, 1;1, 0, 1;
0, 1, 1;0, 1, 1;0, 1, 1;
 - 1, 0, 1; - 1, 0, 1; - 1, 0, 1;
0, 0,  - 1;0, 0,  - 1;0, 0,  - 1;0, 0,  - 1 ];

T = [ 0, 0;1, 0;0.5, 1;
0, 0;1, 0;0.5, 1;
0, 0;1, 0;0.5, 1;
0, 0;1, 0;0.5, 1;
0, 0;1, 0;1, 1;0, 1 ];

F = [ 0, 2, 1;3, 5, 4;6, 8, 7;9, 11, 10;12, 13, 15;15, 13, 14 ];

if Axis ~= 3
V = circshift( V, [ 0, Axis ] ) .* ASize;
N = circshift( N, [ 0, Axis ] );
else 
V = V .* ASize;
end 

C = [  ];
end 


function [ V, N, F, T, C ] = revolution( ZX, Segments, beginCap, endCap )

R36
ZX
Segments
beginCap( 1, 1 )logical = false
endCap( 1, 1 )logical = false
end 

if beginCap
ZX = [ ZX( 1, : ) .* [ 1, 0 ];ZX( 1, : );ZX ];
end 
if endCap
ZX = [ ZX;ZX( end , : );ZX( end , : ) .* [ 1, 0 ] ];
end 

v = [ ZX( :, 2 ), ZX( :, 2 ) * 0, ZX( :, 1 ) ];

dv = diff( v );
n = [ dv( 1, : );dv( 1:end  - 1, : ) + dv( 2:end , : );dv( end , : ) ];
n = [ n( :, 3 ), n( :, 2 ),  - n( :, 1 ) ];
n = n ./ sqrt( sum( n .^ 2, 2 ) );

lv = cumsum( sqrt( sum( dv .^ 2, 2 ) ) );
lv = [ 0;lv / lv( end  ) ];
t = [ lv * 0, 1 - lv ];

r = size( n, 1 );
f = [ 0:r - 2;1:r - 1;r:2 * r - 2 ]';
f = [ f;f + [ r, 0, 1 ] ];

nv = size( v, 1 );
nf = size( f, 1 );
V = zeros( nv * Segments, 3 );
V( 1:nv, : ) = v;
N = zeros( nv * Segments, 3 );
N( 1:nv, : ) = n;
T = zeros( nv * Segments, 2 );
T( 1:nv, : ) = t;
F = zeros( nf * Segments, 3 );
i = 0;
for alfa = [ 1:Segments - 1, 0 ] * 2 * pi / Segments
i = i + 1;
s = sin( alfa );
c = cos( alfa );
M = [ c, s, 0; - s, c, 0;0, 0, 1 ];
V( nv * i + 1:nv * i + nv, : ) = v * M;
N( nv * i + 1:nv * i + nv, : ) = n * M;
T( nv * i + 1:nv * i + nv, : ) = t + [ i / Segments, 0 ];
F( nf * i - nf + 1:nf * i, : ) = f + ( i - 1 ) * r;
end 

Fm = F + 1;
v1 = V( Fm( :, 1 ), : );
v2 = V( Fm( :, 2 ), : );
v3 = V( Fm( :, 3 ), : );
b12 = sum( abs( v1 - v2 ), 2 ) < 0.001;
b23 = sum( abs( v2 - v3 ), 2 ) < 0.001;
b31 = sum( abs( v3 - v1 ), 2 ) < 0.001;
b = or( or( b12, b23 ), b31 );
F( b, : ) = [  ];

C = [  ];
end 


function [ V, N, F, T, C ] = sphere( ASize, Segments, Axis )

R36
ASize( 1, 3 )double = [ 1, 1, 1 ]
Segments( 1, 1 )double = 24
Axis( 1, 1 )double = 3
end 

a = linspace( 0, 180, Segments )';
z =  - cosd( a ) * 0.5;
x = sind( a ) * 0.5;
[ V, N, F, T, C ] = sim3d.utils.Geometry.revolution( [ z, x ], Segments, false, false );

if Axis == 3
V = V .* ASize;
else 
V = circshift( V, [ 0, Axis ] ) .* ASize;
N = circshift( N, [ 0, Axis ] );
end 
end 


function [ V, N, F, T, C ] = surf( X, Y, Z )

V = [ X( : ), Y( : ), Z( : ) ];

minx = min( V( :, 1 ) );
maxx = max( V( :, 1 ) );
miny = min( V( :, 2 ) );
maxy = max( V( :, 2 ) );
T = [ ( X( : ) - minx ) / ( maxx - minx ), ( Y( : ) - miny ) / ( maxy - miny ) ];

R = size( X, 1 );
r = R - 1;
p = ( 1:r )';

F = [  ];
for i = 1:size( X, 2 ) - 1
f1 = [ p, p + 1, p + R ] + R * ( i - 1 );
f2 = [ p + R, p + 1, p + R + 1 ] + R * ( i - 1 );
F = vertcat( F, f1, f2 );
end 
F = F - 1;

TR = triangulation( F + 1, V );
N =  - vertexNormal( TR );

C = [  ];
end 


function [ V, N, F, T, C ] = tile( ASize, Axis )
R36
ASize( 1, 3 )double = [ 1, 1, 1 ]
Axis( 1, 1 )double = 3
end 

V = [ 0, 0, 0;1, 0, 0;1, 1, 0;0, 1, 0;0, 0, 0;1, 0, 0;1, 1, 0;0, 1, 0 ] - 0.5;

N = [ 0, 0, 1;0, 0, 1;0, 0, 1;0, 0, 1;0, 0,  - 1;0, 0,  - 1;0, 0,  - 1;0, 0,  - 1 ];

T = [ 0, 1;1, 1;1, 0;0, 0;0, 1;1, 1;1, 0;0, 0 ];

F = [ 0, 3, 2;0, 2, 1;4, 6, 7;4, 5, 6 ];

if Axis ~= 3
V = circshift( V, [ 0, Axis ] );
N = circshift( N, [ 0, Axis ] );
end 
V = V .* ASize;
V = V - [ 0, 0, 0.001 ];

C = [  ];
end 


function [ V, N, F, T, C ] = tube( ASize, Bore, Segments, Axis )

R36
ASize( 1, 3 )double = [ 1, 1, 1 ]
Bore( 1, 1 )double = 0.5
Segments( 1, 1 )double = 24
Axis( 1, 1 )double = 3
end 

Outer = [  - 0.5, 0.5;0.5, 0.5;0.5, 0.5;0.5, 0.5 * Bore ];
[ V, N, F, T, C ] = sim3d.utils.Geometry.revolution( Outer, Segments, false, false );
Inner = [  - 0.5, 0.5; - 0.5, 0.5 * Bore; - 0.5, 0.5 * Bore;0.5, 0.5 * Bore ];
[ v, n, f, t ] = sim3d.utils.Geometry.revolution( Inner, Segments, false, false );
V = [ V;v ];
N = [ N; - n ];
F = [ F;fliplr( f ) + size( v, 1 ) ];
T = [ T;t ];

if Axis == 3
V = V .* ASize;
else 
V = circshift( V, [ 0, Axis ] ) .* ASize;
N = circshift( N, [ 0, Axis ] );
end 
end 


function [ V, N, F, T, C ] = torus( ASize, InnerR, Segments, Axis )

R36
ASize( 1, 3 )double = [ 1, 1, 1 ]
InnerR( 1, 1 )double = 0.5
Segments( 1, 1 )double = 24
Axis( 1, 1 )double = 3
end 

R = ( InnerR + 1 ) / 2;
r = ( 1 - InnerR ) / 2;
th = linspace( 0, 2 * pi, Segments );
phi = linspace( 0, 2 * pi, Segments );
[ Phi, Th ] = meshgrid( phi, th );
x = ( R + r .* cos( Th ) ) .* cos( Phi );
y = ( R + r .* cos( Th ) ) .* sin( Phi );
z = sin( Th );

TR = surf2patch( x, y, z, 'triangles' );
V = TR.vertices;
N = V - R * normalize( V .* [ 1, 1, 0 ], 2, 'norm' );
F = fliplr( TR.faces ) - 1;
T = [  ];

if Axis == 3
V = V .* ASize / 2;
N = N .* ASize;
else 
V = circshift( V, [ 0, Axis ] ) .* ASize / 2;
N = circshift( N, [ 0, Axis ] ) .* ASize;
end 
N = normalize( N, 2, 'norm' );

C = [  ];
end 


function [ V, N, F, T, C ] = triad( ASize, Segments, D )

R36
ASize( 1, 3 )double = [ 1, 1, 1 ]
Segments( 1, 1 )double = 16
D( 1, 1 )double = 0.1
end 

[ V, N, F, T, ~ ] = sim3d.utils.Geometry.arrow( [ 0.5, D, D ], Segments, 1 );
V = V + [ 0.25, 0, 0 ];
C = repmat( [ 1, 0, 0 ], size( V, 1 ), 1 );
[ v1, n1, f1, t1, ~ ] = sim3d.utils.Geometry.arrow( [ D, 0.5, D ], Segments, 2 );
v1 = v1 + [ 0, 0.25, 0 ];
c1 = repmat( [ 0, 1, 0 ], size( v1, 1 ), 1 );
o1 = size( V, 1 );
[ v2, n2, f2, t2, ~ ] = sim3d.utils.Geometry.arrow( [ D, D, 0.5 ], Segments, 3 );
v2 = v2 + [ 0, 0, 0.25 ];
c2 = repmat( [ 0, 0, 1 ], size( v1, 1 ), 1 );
o2 = o1 + size( v1, 1 );

V = [ V;v1;v2 ] .* ASize;
N = [ N;n1;n2 ];
F = [ F;f1 + o1;f2 + o2 ];
T = [ T;t1;t2 ];
C = [ C;c1;c2 ];
end 


function [ V, N, F, T, C ] = voxel( ASize, VoxelScale, ColorData, Colormap )
T = [  ];

if nargin < 4
Colormap = parula( 100 );
end 

if isa( ColorData, 'uint8' )
ColorData = double( ColorData );
ColorData( ColorData == 0 ) = NaN;
end 

cmax = max( ColorData( : ) );
cmin = min( ColorData( : ) );
if ( cmin < 0 ) || ( cmax > 1 )
ColorData = ( ColorData - cmin ) / ( cmax - cmin );
end 

[ nx, ny, nz ] = size( ColorData );
voxSize = ASize ./ [ nx, ny, nz ];
Center = ASize / 2 + voxSize / 2;
ScalePerVoxel = ( length( ColorData ) == length( VoxelScale ) );
if ScalePerVoxel
[ voxV, voxN, voxF ] = sim3d.utils.Geometry.box( voxSize );
else 
[ voxV, voxN, voxF ] = sim3d.utils.Geometry.box( voxSize .* VoxelScale );
end 

nv = size( voxV, 1 );
good = repelem( ~isnan( ColorData( : ) ), nv, 1 );
ind = [ repmat( ( 1:nx )', ny * nz, 1 ), repmat( repelem( ( 1:ny )', nx, 1 ), nz, 1 ), repelem( ( 1:nz )', nx * ny, 1 ) ];
if ScalePerVoxel
VoxelScale = repelem( VoxelScale( : ), nv, 3 );
V = repmat( voxV, nx * ny * nz, 1 ) .* VoxelScale + repelem( ind, nv, 1 ) .* voxSize - Center;
else 
V = repmat( voxV, nx * ny * nz, 1 ) + repelem( ind, nv, 1 ) .* voxSize - Center;
end 
V = V( good, : );

cd = repelem( ColorData( : ), nv, 1 );
cd = round( cd( good ) * ( size( Colormap, 1 ) - 1 ) + 1 );
C = Colormap( cd, : );

nb = size( V, 1 ) / nv;
N = repmat( voxN, nb, 1 );

nf = size( voxF, 1 );
F = repmat( voxF, nb, 1 ) + repelem( ( 0:nb - 1 ) * nv, 1, nf )';
end 


function Floor = templateFloor( Parent, Size, varargin )

R36
Parent( 1, 1 )sim3d.AbstractActor
Size( 1, 3 )double = 100 * [ 10, 10, 0.1 ]
end 
R36( Repeating )
varargin
end 
Floor = sim3d.Actor( 'ActorName', 'Floor' );
Floor.Parent = Parent;
Floor.createShape( 'checker', Size, varargin{ : } );
Floor.Color = [ 0.5, 0.5, 0.5 ];
Floor.VertexBlend = 0.1;
Floor.Shininess = 0.0;
Floor.Translation( 3 ) =  - Size( 3 ) / 2;
end 


function tile = templateTiles( Parent, Size, Count, Origin )
if nargin < 4
Origin = [ 0, 0, 0 ];
end 

c = [ Size .* ( Count + 1 ) / 2, 0 ];
for i = 1:Count( 1 )
for j = 1:Count( 2 )
tileName = "Tile" + length( Parent.ParentWorld.Actors );
tile = sim3d.Actor( 'ActorName', tileName );
tile.Parent = Parent;
tile.Translation = [ i * Size( 1 ), j * Size( 2 ), 0 ] - c + Origin;
tile.createShape( 'tile', [ Size, 0 ] );
tile.Shininess = 0;
tile.TextureMapping.Blend = 1;
tile.Texture = [ matlabroot, '\toolbox\shared\sim3d\sim3d\+sim3d\utils\Data\sim3dtile.png' ];
end 
end 
end 


function Room = templateRoom( Parent, Size, FloorLevel, SeeThrough )

R36
Parent( 1, 1 )sim3d.AbstractActor
Size( 1, 3 )double = [ 10, 10, 10 ]
FloorLevel( 1, : )double = 0
SeeThrough( 1, 1 )logical = true
end 

W = Size( 1 );
L = Size( 2 );
H = Size( 3 );

if isempty( FloorLevel )
FloorLevel =  - H / 2;
end 

ParentWorld = Parent.ParentWorld;
Room = sim3d.Actor( 'ActorName', 'Room' );
ParentWorld.add( Room, Parent );
Room.Translation( 3 ) = FloorLevel + H / 2;

Wall = sim3d.Actor( 'ActorName', 'Back' );
ParentWorld.add( Wall, Room );
Wall.createShape( 'plane', [ W, 0, H ], 2, ~SeeThrough );
Wall.Translation( 2 ) = L / 2;
Wall.TextureTransform = sim3d.internal.TextureTransform( 'Scale', [  - 1, 1 ], 'Angle',  - pi / 2 );

Wall = sim3d.Actor( 'ActorName', 'Front' );
ParentWorld.add( Wall, Room );
Wall.createShape( 'plane', [ W, 0, H ], 2, ~SeeThrough );
Wall.Translation( 2 ) =  - L / 2;
Wall.Rotation( 3 ) =  - pi;
Wall.TextureTransform.Angle =  - pi / 2;
Wall.TextureTransform.Scale = [  - 1, 1 ];

Wall = sim3d.Actor( 'ActorName', 'Bottom' );
ParentWorld.add( Wall, Room );
Wall.createShape( 'box', [ W, L, H / 20 ] );
Wall.Translation( 3 ) =  - H / 2 - H / 40;

Wall = sim3d.Actor( 'ActorName', 'Top' );
ParentWorld.add( Wall, Room );
Wall.createShape( 'plane', [ W, L, 0 ], 3, ~SeeThrough );
Wall.Translation( 3 ) =  + H / 2;
Wall.Rotation( 1 ) = pi;

Wall = sim3d.Actor( 'ActorName', 'Left' );
ParentWorld.add( Wall, Room );
Wall.createShape( 'plane', [ 0, L, H ], 1, ~SeeThrough );
Wall.Translation( 1 ) =  - W / 2;
Wall.TextureTransform.Scale = [  - 1, 1 ];

Wall = sim3d.Actor( 'ActorName', 'Right' );
ParentWorld.add( Wall, Room );

Wall.createShape( 'plane', [ 0, L, H ], 1, ~SeeThrough );
Wall.Rotation( 3 ) = pi;
Wall.Translation( 1 ) =  + W / 2;
Wall.TextureTransform.Scale = [  - 1, 1 ];

Color = [ 1, 1, 1 ];
Room.propagate( 'Color', Color );
Room.propagate( 'Shininess', 0 );
Room.propagate( 'Shadows', false );
end 


function Grid = templateGrid( Parent, Size, Planes )

R36
Parent( 1, 1 )sim3d.AbstractActor
Size( 1, 3 )double = [ 10, 10, 10 ]
Planes( 1, 3 )logical = [ true, false, false ]
end 

X = Size( 1 );
Y = Size( 2 );
Z = Size( 3 );

Pattern = ones( 301 );
Pattern( 1:30:end , : ) = 0.8;
Pattern( :, 1:30:end  ) = 0.8;
Pattern( 2:30:end , : ) = 0.8;
Pattern( :, 2:30:end  ) = 0.8;
Pattern( 150:152, : ) = 0.0;
Pattern( :, 150:152 ) = 0.0;

Grid = sim3d.Actor( 'ActorName', 'Grid' );
Grid.Parent = Parent;
if Planes( 1 )
PlaneXY = sim3d.Actor( 'ActorName', 'PlaneXY' );
PlaneXY.Parent = Grid;
PlaneXY.createShape( 'plane', [ X, Y, 0 ], 3 );
PlaneXY.displayImage( Pattern );
end 
if Planes( 2 )
PlaneYZ = sim3d.Actor( 'ActorName', 'PlaneYZ' );
PlaneYZ.Parent = Grid;
PlaneYZ.createShape( 'plane', [ 0, Y, Z ], 1 );
PlaneYZ.displayImage( Pattern );
end 
if Planes( 3 )
PlaneZX = sim3d.Actor( 'ActorName', 'PlaneZX' );
PlaneZX.Parent = Grid;
PlaneZX.createShape( 'plane', [ X, 0, Z ], 2 );
PlaneZX.displayImage( Pattern );
end 

Grid.propagate( 'Shininess', 0 );
Grid.propagate( 'Transparency', 0.5 );
Grid.propagate( 'TextureMapping.Blend', 1 );
Grid.propagate( 'TextureTransform.Scale', [ 0.1, 0.1 ] );
Grid.propagate( 'Collisions', false );
end 


function Merged = mergeActors( SrcActors, DstParent )
R36
SrcActors( 1, : )sim3d.Actor
DstParent( 1, 1 )sim3d.Actor
end 

world = SrcActors( 1 ).ParentWorld;

V = [  ];
N = [  ];
F = [  ];
T = [  ];
C = [  ];
for a = SrcActors

loc = a.Translation;
rot = a.Rotation;

M = sim3d.internal.Math.mat2unr( sim3d.internal.Math.rot321( rot ) );
v = ( a.Vertices .* a.Scale ) * M + loc;
n = sim3d.internal.Math.normRows( ( a.Normals .* a.Scale ) * M );
F = [ F;a.Faces + size( V, 1 ) ];
V = [ V;v ];
N = [ N;n ];
T = [ T;a.TextureCoordinates ];

end 

actorName = [ 'Merged', num2str( length( world.Actors ) ) ];
Merged = sim3d.Actor( 'ActorName', actorName );
Merged.Parent = DstParent;
Merged.createMesh( V, N, F, T, C );
end 

end 


methods ( Static, Hidden )

function [ coord, normal, coordIndex, texCoord, color ] = getMeshDataUnreal( id, nodeName )
[ cl, co, no, tc, ci ] = vrsfunc( 'GetMeshData', id, nodeName );

[ newPoint, ~, ic ] = unique( [ co, no, tc, cl ], 'rows' );

newCI = reshape( ci, [ 4, length( ci ) / 4 ] );
newCI = newCI( [ 1, 3, 2 ], : );

coordIndex = ic( newCI + 1 )' - 1;

coord = newPoint( :, 1:3 );
normal = newPoint( :, 4:6 );

if isempty( tc )
texCoord = tc;
i = 7;
else 
texCoord = [ newPoint( :, 7 ), 1 - newPoint( :, 8 ) ];
i = 9;
end 

if isempty( cl )
color = cl;
else 
color = newPoint( :, i:i + 2 );
end 
end 


function [ V, F, N, T, C ] = reduceMesh( Ratio, V, F, N, T, C )
F = F + 1;

if true
[ V, i, j ] = unique( V, 'rows' );
j( end  + 1 ) = nan;
F( isnan( F ) ) = length( j );
if size( F, 1 ) == 1
F = j( F )';
else 
F = j( F );
end 

if ~isempty( N )
N = N( i, : );
end 
if ~isempty( T )
T = T( i, : );
end 
if ~isempty( C )
C = C( i, : );
end 
end 

[ F, newV ] = reducepatch( F, V, Ratio, 'fast' );
F = F - 1;

[ ~, id ] = ismember( newV, V, 'rows' );
V = newV;

if ~isempty( N )
N = N( id, : );
end 
if ~isempty( T )
T = T( id, : );
end 
if ~isempty( C )
C = C( id, : );
end 
end 


function TileMenu( Actor, ItemID, CurPos )
switch ( ItemID )
case 1
origPos = Actor.Translation;
origSize = Actor.UserData.TileSize;
if origSize( 2 ) > origSize( 1 )
sim3d.utils.Geometry.templateTiles( Actor.Parent, origSize .* [ 1, 0.5 ], [ 1, 2 ], origPos );
else 
sim3d.utils.Geometry.templateTiles( Actor.Parent, origSize .* [ 0.5, 1 ], [ 2, 1 ], origPos );
end 
Actor.remove;
case 2
[ fileName, dir ] = uigetfile( '*.f3d' );
if ischar( fileName )
Actor.load( fullfile( dir, fileName ) );
end 
case 3
Actor.remove();
end 
end 

end 

end 


