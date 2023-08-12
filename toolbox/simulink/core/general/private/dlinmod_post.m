function [ a, b, c, d ] = dlinmod_post( J, model, t, Ts, x, u, varargin )



if ~( nargin < 9 )
para = varargin{ 3 };
else 
para = [ 0;0;0 ];
end 

if nargin < 8
spflag = 0;
else 
spflag = varargin{ 2 };
end 

if ( nargin < 7 )
lmflag = 0;
else 
lmflag = varargin{ 1 };
end 



a = J.A;b = J.B;c = J.C;d = J.D;M = J.Mi;

if ( lmflag )


if any( J.Ts( 1:size( a, 1 ) ) )
MSLDiagnostic( 'Simulink:tools:dlinmodIgnoreDiscreteStates' ).reportAsWarning;
ix = find( J.Ts( 1:size( a, 1 ) ) ~= 0 );
a( ix, : ) = [  ];
a( :, ix ) = [  ];
b( ix, : ) = [  ];
c( :, ix ) = [  ];
end 

P = speye( size( d, 1 ) ) - d * M.E;
Q = P\c;
R = P\d;


a = a + b * M.E * Q;
b = b * ( M.F + M.E * R * M.F );
c = M.G * Q;
d = M.H + M.G * R * M.F;
else 
[ ny, nu ] = size( d );
nxz = size( a, 1 );
Tsx = J.Ts( 1:nxz );
Tsy = J.Ts( nxz + 1:end  );
Tuq = unique( J.Ts( J.Ts >= 0 ) );


if isempty( Ts )
Ts = local_vlcm( Tuq );
if isempty( Ts )

modelSolver = get_param( model, 'Solver' );
modelFixedStepSize = get_param( model, 'FixedStep' );
if ( ~strcmpi( modelFixedStepSize, 'auto' ) && any( strcmp( getSolversByParameter( 'SolverType', 'Fixed Step' ), modelSolver ) ) )
MSLDiagnostic( 'Simulink:tools:dlinmodNoSampleTimeFoundUseFixedStepSize' ).reportAsWarning;
Ts = str2double( modelFixedStepSize );
else 
MSLDiagnostic( 'Simulink:tools:dlinmodNoSampleTimeFound' ).reportAsWarning;
Ts = 1;
end 
end 
end 

Tslist = [ Tuq;Ts ];
Eslow = M.E;

for k = 1:length( Tslist ) - 1

ts_current = Tslist( k );
ts_next = min( Ts, Tslist( k + 1 ) );

xix = find( Tsx == ts_current );
nix = find( Tsx ~= ts_current );


[ ix, jx, px ] = find( Eslow );
ux = ismember( jx, find( Tsy == ts_current ) );
Efast = sparse( ix( ux ), jx( ux ), px( ux ), nu, ny );


Eslow = Eslow - Efast;
P = speye( ny ) - d * Efast;


c = P\c;
d = P\d;
a = a + b * Efast * c;
b = b * ( speye( nu ) + Efast * d );


if ts_current ~= ts_next


nxfast = length( xix );
atmp = full( a( xix, xix ) );

if ts_current ~= 0
if ts_next ~= 0
[ Phi, Gam ] = linmod_d2d( atmp, eye( nxfast ), ts_current, ts_next );
else 
[ Phi, Gam ] = d2ci( atmp, eye( nxfast ), ts_current );
end 
else 
[ Phi, Gam ] = linmod_c2d( atmp, eye( nxfast ), ts_next );
end 
if ~all( isreal( Phi( : ) ) ) || ~all( isreal( Gam( : ) ) ) ||  ...
~all( isfinite( Phi( : ) ) ) || ~all( isfinite( Gam( : ) ) )
DAStudio.error( 'Simulink:tools:PosRealCheck' )
end 
a( xix, xix ) = Phi;
if ~isempty( nix )
a( xix, nix ) = Gam * a( xix, nix );
end 
if nu
b( xix, : ) = Gam * b( xix, : );
end 
end 
Tsx( xix ) = ts_next;
end 


b = b * M.F;
c = M.G * c;
d = M.H + M.G * d * M.F;

end 


if spflag == 0
a = full( a );b = full( b );c = full( c );d = full( d );
end 

lst = 1:size( a, 1 );
if para( 3 ) == 1, [ a, b, c, lst ] = minlin( a, b, c );end 

if nargout == 2

[ a, b ] = feval( 'ss2tf', a, b, c, d, 1 );
end 


if nargout == 1
stateNames = J.stateName;
for i = 1:length( stateNames )
if isempty( stateNames{ i } )
stateNames{ i } = J.blockName{ i };
end 
end 
op = struct( 'x', x( : ), 'u', u( 2:end  ), 't', t );
a = struct( 'a', a, 'b', b, 'c', c, 'd', d,  ...
'StateName', { stateNames( lst ) },  ...
'OutputName', { J.Mi.OutputName },  ...
'InputName', { J.Mi.InputName },  ...
'OperPoint', op,  ...
'Ts', Ts );


if para( 3 ) == 1 && length( lst ) ~= length( stateNames )
olst = 1:length( stateNames );
nlst = setdiff( olst, lst );
a.StatesNotOnPath = stateNames( nlst );
end 

end 

end 




function M = local_vlcm( x )



x( ~x ) = [  ];
x( isinf( x ) ) = [  ];
if isempty( x ), M = [  ];return ;end ;

[ a, b ] = rat( x );
v = b( 1 );
for k = 2:length( b ), v = lcm( v, b( k ) );end 
d = v;

y = round( d * x );
v = y( 1 );
for k = 2:length( y ), v = lcm( v, y( k ) );end 
M = v / d;
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpzwQFrW.p.
% Please follow local copyright laws when handling this file.

