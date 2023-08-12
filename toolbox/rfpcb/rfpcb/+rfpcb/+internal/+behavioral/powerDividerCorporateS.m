function S = powerDividerCorporateS( obj, freq, z0 )




R36
obj( 1, 1 )
freq( 1, : ){ mustBeFinite, mustBeNonnegative, mustBeVector }
z0( 1, 1 ){ mustBeFinite, mustBePositive } = 50
end 
Numports = obj.NumOutputPorts;
numsections = log10( Numports ) / log10( 2 );
final = [ 1, 2, 3, 2, 3, 4, 5 ];
finalval = max( final );
CurrentCol = [  ];
for i = 2:numsections
c = finalval - 2 ^ ( i - 1 ) + 1;
arr = c:finalval;
for j = 1:2 ^ ( i - 1 )
final = [ final, arr( j ), finalval + 1, finalval + 2 ];%#ok<AGROW> 
CurrentCol = [ CurrentCol, finalval + 1, finalval + 2 ];%#ok<AGROW> 
finalval = max( final );
end 
c = finalval - ( 2 ^ ( i - 1 ) ) * 2 + 1;
arr = c:finalval;
for j = 1:2 ^ ( i - 1 )
elems = 2 * j;
final = [ final, arr( elems - 1 ), arr( elems ), finalval + 1, finalval + 2 ];%#ok<AGROW> 
finalval = max( final );
end 
end 
warnflag1 = warning( 'off', 'MATLAB:polyshape:repairedBySimplify' );
warnflag2 = warning( 'off', 'rfpcb:rfpcberrors:BehavioralUnsupported' );
ports = final;
lambda = 3e8 / max( freq );
MEL = lambda / 22;
[ ~, ~, line, wilk ] = BehavioralModel( obj );
[ ~ ] = mesh( wilk, 'MaxEdgeLength', MEL );
s_wilk1 = sparameters( wilk, freq );
for i = 1:numel( line )
[ ~ ] = mesh( line{ i }, 'MaxEdgeLength', MEL );
s_line = sparameters( line{ i }, freq );
nport_line{ i } = nport( s_line );%#ok<AGROW> 
end 
numsections = log10( obj.NumOutputPorts ) / log10( 2 );
ckt = circuit( 'example_circuit2' );
count = 1;
for i = 1:numsections
for j = 1:2 ^ ( i - 1 )
add( ckt, ports( count:count + 2 ), s_wilk1 );
count = count + 3;
end 
for j = 1:2 ^ ( i - 1 )
add( ckt, ports( count:count + 3 ), clone( nport_line{ i } ) );
count = count + 4;
end 
end 
outports = count - ( 2 ^ ( numsections ) ) + 1:count;
portnum = 0;
for i = 1:numel( outports )

portnum = portnum + [ outports( i ), 0 ];
end 
if obj.NumOutputPorts == 2
setports( ckt, [ 1, 0 ], [ 4, 0 ], [ 5, 0 ] );
end 
if obj.NumOutputPorts == 4
setports( ckt, [ 1, 0 ], [ 10, 0 ], [ 11, 0 ], [ 12, 0 ], [ 13, 0 ] );
end 
if obj.NumOutputPorts == 8
setports( ckt, [ 1, 0 ], [ 22, 0 ], [ 23, 0 ], [ 24, 0 ], [ 25, 0 ],  ...
[ 26, 0 ], [ 27, 0 ], [ 28, 0 ], [ 29, 0 ] );
end 
if obj.NumOutputPorts == 16
setports( ckt, [ 1, 0 ], [ 46, 0 ], [ 47, 0 ], [ 48, 0 ], [ 49, 0 ], [ 50, 0 ], [ 51, 0 ], [ 52, 0 ],  ...
[ 53, 0 ], [ 54, 0 ], [ 55, 0 ], [ 56, 0 ], [ 57, 0 ], [ 58, 0 ], [ 59, 0 ], [ 60, 0 ], [ 61, 0 ] );
end 
if obj.NumOutputPorts == 32
setports( ckt, [ 1, 0 ], [ 94, 0 ], [ 95, 0 ], [ 96, 0 ], [ 97, 0 ], [ 98, 0 ],  ...
[ 99, 0 ], [ 100, 0 ], [ 101, 0 ], [ 102, 0 ], [ 103, 0 ], [ 104, 0 ], [ 105, 0 ], [ 106, 0 ], [ 107, 0 ],  ...
[ 108, 0 ], [ 109, 0 ], [ 110, 0 ], [ 111, 0 ], [ 112, 0 ], [ 113, 0 ], [ 114, 0 ], [ 115, 0 ], [ 116, 0 ],  ...
[ 117, 0 ], [ 118, 0 ], [ 119, 0 ], [ 120, 0 ], [ 121, 0 ], [ 122, 0 ], [ 123, 0 ], [ 124, 0 ], [ 125, 0 ] );
end 
S = sparameters( ckt, freq, z0 );
warning( warnflag1 );
warning( warnflag2 );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpa0yaDD.p.
% Please follow local copyright laws when handling this file.

