function mulComp = getScalarMatrixMulComp( hN, hInSignals, hOutSignals,  ...
rndMode, satMode, compName, dspMode, nfpOptions, traceComment )




narginchk( 9, 9 );

X = hInSignals( 1 );
Y = hInSignals( 2 );
xT = X.Type;
yT = Y.Type;
hOutT = hOutSignals.Type;
assert( hOutT.is2DMatrix );
assert( xT.is2DMatrix || yT.is2DMatrix );


if yT.is2DMatrix

msT = xT;
maybeScalarSig = X;
matrixSig = Y;
else 
msT = yT;
maybeScalarSig = Y;
matrixSig = X;
end 

maxrow = hOutT.Dimensions( 1 );
maxcol = hOutT.Dimensions( 2 );

if ~msT.isArrayType
scalarExpand = true;
Xsig = maybeScalarSig;
else 
scalarExpand = false;

Xsplit = maybeScalarSig.split;
Xsplit.addTraceabilityComment( traceComment );
Xsig = Xsplit.PirOutputSignals;
end 


Ysplit = matrixSig.split;
Ysplit.addTraceabilityComment( traceComment );
Ysig = Ysplit.PirOutputSignals;


hBaseOutT = hOutT.BaseType;
matInnerType = hN.getType( 'Array', 'BaseType', hBaseOutT,  ...
'Dimensions', maxrow );



hS = hdlhandles( 1, maxcol );

for cc = 1:numel( Ysig )
hS( cc ) = hN.addSignal( matInnerType, [ 'colTemp_', int2str( cc ) ] );
if scalarExpand
Xin = Xsig;
else 
Xin = Xsig( cc );
end 
hC = pirelab.getMulComp( hN, [ Xin, Ysig( cc ) ], hS( cc ), rndMode, satMode,  ...
compName, '**', '',  - 1, dspMode, nfpOptions, 'Element-wise(.*)',  ...
'linear', traceComment );
hC.addTraceabilityComment( traceComment );
end 
mulComp = pirelab.getConcatenateComp( hN, hS, hOutSignals( 1 ),  ...
'Multidimensional array', '2' );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmplgEGJq.p.
% Please follow local copyright laws when handling this file.

