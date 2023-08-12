function mulComp = getMatrixMulComp( hN, hInSignals, hOutSignals,  ...
rndMode, satMode, compName, dspMode, nfpOptions, matMulKind, traceComment )





narginchk( 8, 10 );

if nargin < 10
traceComment = '';
end 

if nargin < 9
matMulKind = 'linear';
end 

X = hInSignals( 1 );
Y = hInSignals( 2 );
xT = X.Type;
yT = Y.Type;


if xT.is2DMatrix
xdims = 2;
elseif xT.isArrayType
xdims = 1;
else 
xdims = 0;
end 

if yT.is2DMatrix
ydims = 2;
elseif yT.isArrayType
ydims = 1;
else 
ydims = 0;
end 

hOutT = hOutSignals.Type;
if hOutT.isArrayType
if hOutT.is2DMatrix

maxrow = hOutT.Dimensions( 1 );
maxcol = hOutT.Dimensions( 2 );
elseif hOutT.isRowVector

maxrow = 1;
maxcol = hOutT.Dimensions( 1 );
elseif hOutT.isColumnVector

maxrow = hOutT.Dimensions( 1 );
maxcol = 1;
else 

maxrow = hOutT.Dimensions( 1 );
maxcol = 1;
end 
else 



maxrow = 1;
maxcol = 1;
end 

if xT.isArrayType
xsize = xT.Dimensions;
else 
xsize = 1;
end 

hBaseT = xT.BaseType;

if numel( xsize ) == 2
trDims = [ xsize( 2 ), xsize( 1 ) ];

hAT = hN.getType( 'Array', 'BaseType', hBaseT, 'Dimensions', trDims,  ...
'VectorOrientation', 1 );
XInSig = hN.addSignal( hAT, [ X.Name, 't' ] );
pirelab.getTransposeComp( hN, X, XInSig );
elseif xT.isArrayType && ~( xT.isRowVector || xT.isColumnVector )

if hOutT.is2DMatrix

newT = hN.getType( 'Array', 'BaseType', hBaseT,  ...
'Dimensions', xT.Dimensions, 'VectorOrientation', 2 );
XInSig = pirelab.insertDTCCompOnInput( hN, X, newT,  ...
'Floor', 'Wrap' );
xT = newT;
else 

XInSig = X;
end 
else 
XInSig = X;
end 


if ( xdims > 0 && ~( xdims == 1 && ydims > 0 ) ) ||  ...
( xdims == 1 && ydims == 1 && xT.isColumnVector )
Xsplit = XInSig.split;
Xsig = Xsplit.PirOutputSignals;
else 
Xsig = X;
end 


if ydims > 0 && ~( xdims > 0 && ydims == 1 ) ||  ...
( xdims == 1 && ydims == 1 && xT.isColumnVector )
Ysplit = Y.split;
Ysig = Ysplit.PirOutputSignals;
else 
Ysig = Y;
end 


Z = hdlhandles( maxrow, maxcol );


hOutT = hOutSignals.Type;
if hOutT.isArrayType

hBaseOutT = hOutT.BaseType;
else 


hBaseOutT = hOutT;
end 

if maxrow == 1
matInnerType = hBaseOutT;
else 
matInnerType = hN.getType( 'Array', 'BaseType', hBaseOutT,  ...
'Dimensions', maxrow );
end 

if xdims == 0 || ydims == 0

scalarMul = true;
matsig = hdlhandles( maxrow, maxcol );
if xdims == 0
scalarsig = Xsig;
if yT.is2DMatrix
for cc = 1:maxcol
colSplit = Ysig( cc ).split;
colSig = colSplit.PirOutputSignals;
matsig( :, cc ) = colSig;
end 
clear colSplit colSig;
else 
if all( size( matsig ) == size( Ysig ) )
matsig = Ysig;
else 
matsig = Ysig';
end 
end 
else 

scalarsig = Ysig;
if xT.is2DMatrix
for rr = 1:maxrow
rowSplit = Xsig( rr ).split;
rowSig = rowSplit.PirOutputSignals;
matsig( rr, : ) = rowSig;
end 
clear rowSplit rowSig;
else 
matsig = Xsig;
end 
end 
else 
scalarMul = false;
end 

if strcmpi( matMulKind, 'linear' ) ||  ...
( xT.isColumnVector && yT.isRowVector )
matMulInt = 0;
elseif strcmpi( matMulKind, 'serialmac' )
matMulInt = 1;
else 
assert( strcmpi( matMulKind, 'parallelmac' ) )
matMulInt = 2;
end 



if maxcol > 1
hS = hdlhandles( 1, maxcol );
end 

for cc = 1:maxcol
for rr = 1:maxrow
Z( rr, cc ) = hN.addSignal( hBaseOutT,  ...
sprintf( '%s_%d_%d', compName, rr - 1, cc - 1 ) );
if scalarMul
hC = pirelab.getMulComp( hN, [ scalarsig, matsig( rr, cc ) ],  ...
Z( rr, cc ), rndMode, satMode, 'scalarmatmult', '**', '',  ...
 - 1, dspMode, nfpOptions );
hC.addTraceabilityComment( traceComment );
else 
if matMulInt == 0
pirelab.getDotproductComp( hN, [ Xsig( rr ), Ysig( cc ) ],  ...
Z( rr, cc ), compName, rndMode, satMode, 'linear', nfpOptions,  ...
dspMode, false, traceComment );
elseif matMulInt == 1
hC = pirelab.getVectorMACComp( hN, [ Xsig( rr ), Ysig( cc ) ], Z( rr, cc ),  ...
rndMode, satMode, compName, '',  - 1, 0, 'Serial' );
hC.addTraceabilityComment( traceComment );
else 
hC = pirelab.getVectorMACComp( hN, [ Xsig( rr ), Ysig( cc ) ], Z( rr, cc ),  ...
rndMode, satMode, compName, '',  - 1, 0, 'Parallel' );
hC.addTraceabilityComment( traceComment );
end 
end 
end 

hS( cc ) = hN.addSignal( matInnerType, [ 'colTemp_', int2str( cc ) ] );
pirelab.getConcatenateComp( hN, Z( :, cc ), hS( cc ), 'Vector', '1' );
end 

mulComp = pirelab.getConcatenateComp( hN, hS, hOutSignals( 1 ),  ...
'Multidimensional array', '2' );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpKiuDm1.p.
% Please follow local copyright laws when handling this file.

