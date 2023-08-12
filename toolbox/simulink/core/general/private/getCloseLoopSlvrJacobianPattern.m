

function Jclose = getCloseLoopSlvrJacobianPattern( JopenInfo )


Jclose.A = [  ];
Jclose.B = [  ];
Jclose.C = [  ];
Jclose.D = [  ];

Jopen = JopenInfo.Jopen;
A = Jopen.A;
B = Jopen.B;
C = Jopen.C;
D = Jopen.D;

E = Jopen.E;
F = Jopen.F;
G = Jopen.G;
H = Jopen.H;

ncx = size( A, 1 );
nu = size( B, 2 );
ncy = size( C, 1 );

nyInport = size( F, 2 );
nuOutport = size( H, 1 );


if ( ncx == 0 )
Apc = A;
Bpc = sparse( 0, nyInport );
Cpc = sparse( nuOutport, 0 );
else 

Aadj = [ A, sparse( ncx, ncy ), B; ...
C, sparse( ncy, ncy ), D; ...
sparse( nu, ncx ), E, sparse( nu, nu ) ];

Apc = LocalTraceState( Aadj, ncx, ncx );


Badj = [ sparse( ncx, nyInport ), sparse( ncx, ncx ), sparse( ncx, ncy ), B; ...
sparse( nyInport, nyInport + ncx + ncy ), sparse( nyInport, nu )
sparse( ncy, nyInport ), sparse( ncy, ncx ), sparse( ncy, ncy ), D; ...
F, sparse( nu, ncx ), E, sparse( nu, nu ) ];

Bpc = LocalTraceState( Badj, ncx, nyInport );



Cadj = [ sparse( nuOutport, ncx ), sparse( nuOutport, nuOutport ), G, sparse( nuOutport, nu ); ...
sparse( ncx, ncx + nuOutport ), sparse( ncx, ncy ), sparse( ncx, nu ); ...
C, sparse( ncy, nuOutport ), sparse( ncy, ncy ), D; ...
sparse( nu, ncx ), sparse( nu, nuOutport ), E, sparse( nu, nu ) ];

Cpc = LocalTraceState( Cadj, nuOutport, ncx );
end 



Dadj = [ H, sparse( nuOutport, nuOutport ), G, sparse( nuOutport, nu ); ...
sparse( nyInport, nyInport ), sparse( nyInport, nuOutport ), sparse( nyInport, ncy ), sparse( nyInport, nu ); ...
sparse( ncy, nyInport ), sparse( ncy, nuOutport ), sparse( ncy, ncy ), D; ...
F, sparse( nu, nuOutport ), E, sparse( nu, nu ) ];

Dpc = LocalTraceState( Dadj, nuOutport, nyInport );

if isempty( JopenInfo.stateOffset )

Jclose.A = Apc;
Jclose.B = Bpc;
Jclose.C = Cpc;
else 

ncx = size( Apc, 1 );
T = spalloc( ncx, ncx, ncx );
for i = 1:ncx
T( i, JopenInfo.stateOffset( i ) + 1 ) = 1;
end 
Jclose.A = T' * Apc * T;
Jclose.B = T' * Bpc;
Jclose.C = Cpc * T;
end 

Jclose.D = Dpc;

end 


function Mpc = LocalTraceState( Adj, mRow, mCol )









nzmax = 0;

for ct = 1:mCol
dx = false( size( Adj, 1 ), 1 );
dx_plus = false( size( Adj, 1 ), 1 );

dx_plus( ct ) = true;
anynewhits = true;

while anynewhits
dx_plus = any( Adj( :, dx_plus ), 2 );
anynewhits = any( dx_plus & ~dx );
dx = dx_plus | dx;
dx_plus( 1:mRow ) = false;
end 
nzmax = nzmax + nnz( dx( 1:mRow ) );
end 

Mpc = spalloc( mRow, mCol, nzmax );

for ct = 1:mCol
dx = false( size( Adj, 1 ), 1 );
dx_plus = false( size( Adj, 1 ), 1 );

dx_plus( ct ) = true;
anynewhits = true;

while anynewhits
dx_plus = any( Adj( :, dx_plus ), 2 );
anynewhits = any( dx_plus & ~dx );
dx = dx_plus | dx;
dx_plus( 1:mRow ) = false;
end 
Mpc( dx( 1:mRow ), ct ) = true;
end 

end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpxt3BzW.p.
% Please follow local copyright laws when handling this file.

