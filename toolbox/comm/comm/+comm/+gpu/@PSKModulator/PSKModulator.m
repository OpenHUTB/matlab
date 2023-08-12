classdef ( StrictDefaults )PSKModulator < comm.gpu.internal.GPUSystem & comm.internal.ConstellationBase




































































properties ( Nontunable )



ModulationOrder = 8;



PhaseOffset = pi / 8;












BitInput( 1, 1 )logical = false;










SymbolMapping = 'Gray';










CustomSymbolMapping = 0:7;



OutputDataType = 'double';

end 

properties ( Access = private )
pModConst;
pMap;
pPowersOfTwo;
pInputSymbols;
pMainFH;


gPhaseOffset;
end 

properties ( Access = private, Dependent )
pBitsPerSymbol;
end 

properties ( Constant, Hidden )
SymbolMappingSet = comm.CommonSets.getSet( 'BinaryGrayCustom' );
OutputDataTypeSet = comm.CommonSets.getSet( 'DoubleOrSingle' );
end 

methods 

function obj = PSKModulator( varargin )
setProperties( obj, nargin, varargin{ : }, 'ModulationOrder', 'PhaseOffset' );
end 

function set.ModulationOrder( obj, val )
validateattributes( val,  ...
{ 'numeric' }, { 'integer', 'positive', 'scalar', 'finite' }, '', 'ModulationOrder' );
obj.ModulationOrder = val;
end 

function set.PhaseOffset( obj, val )
validateattributes( val,  ...
{ 'numeric' }, { 'real', 'scalar', 'finite' }, '', 'PhaseOffset' );
obj.PhaseOffset = val;
end 
end 

methods 
function v = get.pBitsPerSymbol( obj )
v = log2( obj.ModulationOrder );
end 
end 

methods ( Access = protected )
function validatePropertiesImpl( obj )
symbolMappingIdx = getIndex( obj.SymbolMappingSet, obj.SymbolMapping );
if symbolMappingIdx == 3
status = commblkuserdefinedmapping( obj.ModulationOrder,  ...
obj.CustomSymbolMapping, false );
if ~isempty( status.identifier )
error( message( status.identifier ) );
end 
end 
if obj.BitInput
bitsPerSymbol = obj.pBitsPerSymbol;
if ( bitsPerSymbol <= 0 ) ||  ...
( abs( bitsPerSymbol - fix( bitsPerSymbol ) ) > 2 * eps * bitsPerSymbol )
error( message( 'comm:system:PSKModulator:bitInMNotPow2' ) );
end 
else 
validateattributes( obj.ModulationOrder,  ...
{ 'numeric' }, { 'real', 'scalar', '>', 1 }, '', 'ModulationOrder' );
end 
end 
function setupGPUImpl( obj, varargin )
obj.gPhaseOffset = gpuArray( cast( obj.PhaseOffset, obj.OutputDataType ) );
if obj.BitInput
bitsPerSymbol = obj.pBitsPerSymbol;
sz = 0;
if ( size( varargin, 2 ) > 0 )
sz = size( varargin{ 1 } );
end 
if mod( sz( 1 ), bitsPerSymbol ) ~= 0
error( message( 'comm:system:PSKModulator:bitInVecInWrongLen' ) )
end 
obj.pInputSymbols = sz( 1 ) / bitsPerSymbol;


obj.pPowersOfTwo = gpuArray( cast( 2 .^ ( ( bitsPerSymbol - 1 ): - 1:0 ),  ...
obj.OutputDataType ) );
end 


obj.pModConst = gpuArray( cast( 2 * pi / obj.ModulationOrder,  ...
obj.OutputDataType ) );

if ( obj.BitInput == false ) && strcmp( obj.SymbolMapping, 'Gray' ) && ( obj.PhaseOffset == pi / 8 ) &&  ...
( ( obj.ModulationOrder == 2 ) || ( obj.ModulationOrder == 4 ) || ( obj.ModulationOrder == 8 ) )
directcompute = true;
else 
directcompute = false;
end 


if ~directcompute
if strcmp( obj.SymbolMapping, 'Gray' )

k = ( 0:( obj.ModulationOrder - 1 ) ).';
iv = bitxor( k, floor( k / 2 ) );
pm( iv + 1, 1 ) = k;
obj.pMap = gpuArray( exp( 1j * ( obj.gPhaseOffset + pm .* obj.pModConst ) ) );
elseif strcmp( obj.SymbolMapping, 'Custom' )

csm = reshape( obj.CustomSymbolMapping, obj.ModulationOrder, 1 );
pm( csm + 1 ) = ( 0:( obj.ModulationOrder - 1 ) ).';
obj.pMap = gpuArray( reshape(  ...
exp( 1j * ( obj.gPhaseOffset + pm .* obj.pModConst ) ),  ...
obj.ModulationOrder, 1 ) );
else 

pm = ( 0:( obj.ModulationOrder - 1 ) ).';
obj.pMap = gpuArray( exp( 1j * ( obj.gPhaseOffset + pm .* obj.pModConst ) ) );
end 
end 

if obj.BitInput
obj.pMainFH = @obj.stepGPUBitInput;
else 
if directcompute
if obj.ModulationOrder == 2
obj.pMainFH = @obj.directcmpt_md2;
elseif obj.ModulationOrder == 4
obj.pMainFH = @obj.directcmpt_md4;
elseif obj.ModulationOrder == 8
obj.pMainFH = @obj.directcmpt_md8;
end 

else 
obj.pMainFH = @obj.stepGPUIntegerInput;
end 
end 

end 

function y = stepGPUImpl( obj, x )
y = obj.pMainFH( x );
end 

function y = directcmpt_md2( obj, x )
xi = int32( x );
if any( xi < 0 ) || any( xi > ( obj.ModulationOrder - 1 ) )
error( message( 'comm:system:PSKModulator:inputIntRangeNot0ToMm1' ) );
end 
y = arrayfun( @Gray_default_2pskmod, xi );
end 

function y = directcmpt_md4( obj, x )
xi = int32( x );
if any( xi < 0 ) || any( xi > ( obj.ModulationOrder - 1 ) )
error( message( 'comm:system:PSKModulator:inputIntRangeNot0ToMm1' ) );
end 
y = arrayfun( @Gray_default_4pskmod, xi );
end 

function y = directcmpt_md8( obj, x )
xi = int32( x );
if any( xi < 0 ) || any( xi > ( obj.ModulationOrder - 1 ) )
error( message( 'comm:system:PSKModulator:inputIntRangeNot0ToMm1' ) );
end 
y = arrayfun( @Gray_default_8pskmod, xi );
end 



function y = stepGPUIntegerInput( obj, x )
xi = int32( x );
if any( xi < 0 ) || any( xi > ( obj.ModulationOrder - 1 ) )
error( message( 'comm:system:PSKModulator:inputIntRangeNot0ToMm1' ) );
end 
y = obj.pMap( xi + 1 );
end 
function y = stepGPUBitInput( obj, x )
xi = uint32( x );
flag = ( ( xi ~= 0 ) & ( xi ~= 1 ) );
if any( flag )
error( message( 'comm:system:PSKModulator:inputNotOneOrZero' ) );
end 

x = ( obj.pPowersOfTwo * cast( reshape( x, obj.pBitsPerSymbol, obj.pInputSymbols ), obj.OutputDataType ) ).';

y = obj.pMap( x + 1 );
end 
end 


methods ( Access = protected )

function varargout = getOutputSizeImpl( obj )
if ~( obj.BitInput )
varargout{ 1 } = propagatedInputSize( obj, 1 );
else 
sz = propagatedInputSize( obj, 1 );
varargout{ 1 } = [ sz( 1 ) / log2( obj.ModulationOrder ), sz( 2 ) ];
end 
end 

function varargout = getOutputDataTypeImpl( obj )
varargout{ 1 } = obj.OutputDataType;
end 

function varargout = isOutputComplexImpl( obj )%#ok
varargout{ 1 } = true;
end 

function varargout = isOutputFixedSizeImpl( obj )%#ok
varargout{ 1 } = true;
end 

end 
methods ( Access = protected )
function flag = isInactivePropertyImpl( obj, prop )
flag = strcmp( prop, 'CustomSymbolMapping' ) &&  ...
~strcmp( obj.SymbolMapping, 'Custom' );
end 
end 

methods ( Static, Hidden )
function flag = generatesCode(  )
flag = false;
end 
end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpyfaG3K.p.
% Please follow local copyright laws when handling this file.

