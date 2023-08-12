function mulComp = getMulComp( hN, hInSignals, hOutSignals,  ...
rndMode, satMode, compName, inputSigns, desc, slbh, dspMode,  ...
nfpOptions, mulKind, matMulKind, traceComment )










if nargin < 14
traceComment = '';
end 


if nargin < 13
matMulKind = 'linear';
end 

defaultMulKind = 'Element-wise(.*)';
if nargin < 12
mulKind = defaultMulKind;
end 

if nargin < 11
nfpOptions.Latency = int8( 0 );
nfpOptions.MantMul = int8( 0 );
nfpOptions.Denormals = int8( 0 );
nfpOptions.Radix = int32( 2 );
end 

if ~isfield( nfpOptions, 'Radix' )
nfpOptions.Radix = int32( 2 );
end 

if nargin < 10
dspMode = int8( 0 );
end 

if nargin < 9
slbh =  - 1;
end 

if nargin < 8
desc = '';
end 

if nargin < 7
inputSigns = '**';
end 

if ( nargin < 6 )
compName = 'multiplier';
end 

if ( nargin < 5 )
satMode = 'Wrap';
end 

if ( nargin < 4 )
rndMode = 'Floor';
end 

in1 = hInSignals;
out1 = hOutSignals;
outType = out1.Type;
isPOE = false;
nDims = 1;
targetMode = targetmapping.mode( out1 );
numInputPorts = numel( hInSignals );

if ( numInputPorts == 1 ) && strcmp( mulKind, 'Element-wise(.*)' )
if ( prod( in1( 1 ).Type.getDimensions ) ~= prod( out1( 1 ).Type.getDimensions ) )
isPOE = true;
end 
hN.renderCodegenPir( true );
end 

if in1( 1 ).Type.isMatrix && isPOE

[ in1, ~, prod_out, ~, nDims ] = splitMatrix2SpecifiedDims( hN, hInSignals, hOutSignals );
else 
prod_out = hOutSignals;
end 

if targetMode && ( numInputPorts > 2 ) &&  ...
targetcodegen.targetCodeGenerationUtils.isNFPMode(  )


ndims = ( numInputPorts );
prev_stage = hInSignals( 1 );


if ( inputSigns( 1 ) == '/' )
stage_in = prev_stage;
stage_out = hN.addSignal( outType, [ compName, '_recip_out' ] );
name = [ compName, '_recip' ];
mulComp = pirelab.getMathComp( hN, stage_in, stage_out, name,  ...
 - 1, 'reciprocal', nfpOptions );
prev_stage = stage_out;
end 

for itr = 2:ndims
stage_in = prev_stage;
if ( itr == ndims )
stage_out = prod_out;
else 
dims = getResultantMatrixDims( [ stage_in, hInSignals( itr ) ] );
if dims( 1 ) == 1 && dims( 2 ) == 1

stage_out = hN.addSignal( outType.BaseType, [ compName, '_out_', int2str( itr - 1 ) ] );
else 

resMatType = pirelab.createPirArrayType( outType.BaseType, dims );
stage_out = hN.addSignal( resMatType, [ compName, '_out_', int2str( itr - 1 ) ] );
end 
end 
mulComp = elaborate_mulComp( hN, [ stage_in, hInSignals( itr ) ], stage_out, rndMode, satMode, compName,  ...
[ '*', inputSigns( itr ) ], [ 'mul #', int2str( itr - 1 ) ], slbh, dspMode, nfpOptions, mulKind, matMulKind, traceComment );
prev_stage = stage_out;
end 
else 
for i = 1:nDims
if isPOE


mulComp = elaborate_poe2CoreComp( hN, in1( i ), prod_out( i ), rndMode, satMode, compName, slbh,  ...
dspMode, nfpOptions, mulKind, matMulKind, traceComment, i );
else 
if numInputPorts == 1

prod_in = in1( i );
else 

prod_in = hInSignals;
end 
mulComp = elaborate_mulComp( hN, prod_in, prod_out( i ), rndMode, satMode, compName,  ...
inputSigns, desc, slbh, dspMode, nfpOptions, mulKind, matMulKind, traceComment );
end 
end 
end 
end 

function poeComp = elaborate_poe2CoreComp( hN, prod_in, prod_out, rndMode, satMode, compName, slbh,  ...
dspMode, nfpOptions, mulKind, matMulKind, traceComment, idx )



outType = prod_out.Type;
demuxComp = prod_in.split(  );
inputDims = length( demuxComp.PirOutputSignals );
prev_stage = demuxComp.PirOutputSignals( 1 );
for itr = 1:inputDims - 1
stage_in = prev_stage;
if itr == ( inputDims - 1 )
stage_out = prod_out;
else 
stage_out = hN.addSignal( outType, [ compName, '_out_', int2str( itr ), int2str( idx ) ] );
end 
poeComp = elaborate_mulComp( hN, [ stage_in,  ...
demuxComp.PirOutputSignals( itr + 1 ) ], stage_out, rndMode, satMode, compName,  ...
'**', [ 'mul #', int2str( itr ) ], slbh, dspMode, nfpOptions, mulKind, matMulKind, traceComment );
prev_stage = stage_out;
end 
end 

function mulComp = elaborate_mulComp( hN, hInSignals, hOutSignals, rndMode, satMode, compName,  ...
inputSigns, desc, slbh, dspMode, nfpOptions, mulKind, matMulKind, traceComment )

matrixMul = ~strcmpi( mulKind, 'Element-wise(.*)' );

if matrixMul
inSigs = hInSignals;
else 
inSigs = pirelab.convertRowVecsToUnorderedVecs( hN, hInSignals );
end 


if matrixMul && numel( inSigs ) == 1
inType = hInSignals( 1 ).Type.getLeafType;
if inType.isFloatType

mulComp = pirelab.getWireComp( hN, inSigs, hOutSignals );
else 


mulComp = pirelab.getDTCComp( hN, inSigs, hOutSignals, rndMode, satMode );
end 
elseif strcmp( hdlfeature( 'MatrixMultiplyTransform' ), 'on' ) ||  ...
( ~matrixMul ||  ...
( ~inSigs( 1 ).Type.isArrayType && ~inSigs( 2 ).Type.isArrayType ) )
mulComp = pircore.getMulComp( hN, inSigs, hOutSignals,  ...
rndMode, satMode, compName, inputSigns, desc, slbh, dspMode,  ...
nfpOptions, mulKind, matMulKind );
else 

assert( strcmp( inputSigns, '**' ) );
mulComp = pirelab.getMatrixMulComp( hN, inSigs, hOutSignals,  ...
rndMode, satMode, compName, dspMode, nfpOptions, matMulKind,  ...
traceComment );
end 
end 




function dims = getResultantMatrixDims( hInSignals )
X = hInSignals( 1 );
Y = hInSignals( 2 );
xT = X.Type;
yT = Y.Type;


if xT.isArrayType
xsize = xT.Dimensions;
if xT.isRowVector
maxrow = 1;
else 
maxrow = xsize( 1 );
end 
else 
maxrow = 1;
end 


if yT.isArrayType
ysize = yT.Dimensions;
if yT.is2DMatrix
maxcol = ysize( 2 );
elseif ~yT.isRowVector

maxcol = 1;
else 

maxcol = ysize( 1 );
end 
else 
maxcol = 1;
end 

dims( 1 ) = maxrow;
dims( 2 ) = maxcol;
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpCrMeIb.p.
% Please follow local copyright laws when handling this file.

