function multiportSwitchComp = getMultiPortSwitchComp( hN, hInSignals, hOutSignals,  ...
inputmode, dpOrder, rndMode, satMode, compName, portSel, dpForDefault, numInputs, nfpOptions, diagForDefaultErr, codingStyle )


























if nargin < 14 || isempty( codingStyle )
codingStyle = 'ifelse_stmt';
end 

if nargin < 13
diagForDefaultErr = true;
end 

if nargin < 12
nfpOptions.Latency = int8( 0 );
nfpOptions.MantMul = int8( 0 );
nfpOptions.Denormals = int8( 0 );
end 

if nargin < 11
numInputs =  - 1;
end 

if nargin < 10
dpForDefault = 'Last data port';
end 

if nargin < 9
portSel = [  ];
end 

if nargin < 8
compName = 'multiportswitch';
end 

if nargin < 7
satMode = 'Wrap';
end 

if nargin < 6
rndMode = 'floor';
end 

if ( nargin < 5 ) || isempty( dpOrder )
dataPortOrder = 'Zero-based contiguous';
else 
if ischar( dpOrder )
dataPortOrder = dpOrder;
else 

if dpOrder == 1
dataPortOrder = 'Zero-based contiguous';
else 
dataPortOrder = 'One-based contiguous';
end 
end 
end 

blkImplcase = false;
selSignal = hInSignals( 1 );
selType = selSignal.Type.getLeafType;
nfpMode = targetcodegen.targetCodeGenerationUtils.isNFPMode;
extraPort = strcmp( dpForDefault, 'Additional data port' );
oneBasedIdx = 0;
if strcmpi( dataPortOrder, 'One-based contiguous' )
oneBasedIdx = 1;
end 

if strcmpi( codingStyle, 'case_stmt' )
blkImplcase = true;
end 

if selType.is1BitType || numInputs == 1

if inputmode == 0
if ~nfpMode
inSigs = [ hInSignals( 1 ), hInSignals( 2 ) ];
else 
maxIndex = ( hInSignals( 2 ).Type.Dimensions - 1 ) + oneBasedIdx;
conversionOut = addSmallestDTC( maxIndex, true );
inSigs = [ conversionOut, hInSignals( 2 ) ];
end 
elseif length( hInSignals ) > 2
inSigs = hInSignals;
else 
multiportSwitchComp = pirelab.getWireComp( hN, hInSignals( 2 ), hOutSignals( 1 ), [ compName, '_wire' ] );
return ;
end 
elseif selType.isFloatType && nfpMode

if numInputs ==  - 1
numInputs = length( hInSignals ) - 1 - extraPort;
end 
maxIndex = numInputs + extraPort + oneBasedIdx - 1;
conversionOut = addSmallestDTC( maxIndex, false );

try 
inSigs = [ conversionOut;hInSignals( 2:end  ) ];
catch 
inSigs = [ conversionOut, hInSignals( 2:end  ) ];
end 
elseif selType.isWordType
fl = selType.FractionLength;
if fl >= 0
if ~blkImplcase
inSigs = hInSignals;
else 
wl = selType.WordLength;


dtc = InsertDtc( [ selSignal.Name, '_shift' ], wl + fl, hN, selSignal );
try 
inSigs = [ dtc;hInSignals( 2:end  ) ];
catch 
inSigs = [ dtc, hInSignals( 2:end  ) ];
end 
end 
else 



wl = selType.WordLength;
newl = wl + fl;
if newl <= 0
newl = 1;
end 
dtc = InsertDtc( [ selSignal.Name, '_floor' ], newl, hN, selSignal );
try 
inSigs = [ dtc;hInSignals( 2:end  ) ];
catch 
inSigs = [ dtc, hInSignals( 2:end  ) ];
end 
end 
else 
inSigs = hInSignals;
end 

if isempty( portSel ) || ~iscell( portSel )
multiportSwitchComp = pircore.getMultiPortSwitchComp( hN, inSigs, hOutSignals,  ...
inputmode, dataPortOrder, rndMode, satMode, compName, portSel, dpForDefault, diagForDefaultErr, codingStyle );
else 



cellSizes = cellfun( @( x )numel( x ), portSel );
totalElem = sum( cellSizes );
expandedInSigs = hdlhandles( totalElem + 1, 1 );
expandedInSigs( 1 ) = inSigs( 1 );


expandedPortSel = repmat( portSel{ 1 }( 1 ), totalElem, 1 );
inSigIdx = 1;
for ii = 1:numel( cellSizes )
for jj = 1:cellSizes( ii )
expandedInSigs( inSigIdx + 1 ) = inSigs( ii + 1 );
expandedPortSel( inSigIdx ) = portSel{ ii }( jj );%#ok<*AGROW>
inSigIdx = inSigIdx + 1;
end 
end 
if extraPort


expandedInSigs( end  + 1 ) = inSigs( end  );
end 

multiportSwitchComp = pircore.getMultiPortSwitchComp( hN, expandedInSigs,  ...
hOutSignals, inputmode, dataPortOrder, rndMode, satMode, compName,  ...
expandedPortSel, dpForDefault, diagForDefaultErr, codingStyle );
end 
function conversionOut = addSmallestDTC( maxIndex, isVectorIndexing )
if ( oneBasedIdx )
roundingMode = 'Floor';
else 
roundingMode = 'Zero';
end 

if ( isVectorIndexing )
saturationMode = 'Wrap';
uintT = pir_unsigned_t( ceil( log2( double( maxIndex + 1 ) ) ) );
else 
saturationMode = 'Saturate';
uintT = pir_signed_t( ceil( log2( double( maxIndex + 1 ) ) ) + 1 );
end 

conversionOut = pirelab.insertDTCCompOnInput( hN, selSignal, uintT, roundingMode, saturationMode, [ compName, '_dtc_comp' ], nfpOptions );


satMode = 'Wrap';
rndMode = 'Floor';
end 
end 

function dtc = InsertDtc( dtcname, wordlen, hN, selSignal )
selType = selSignal.Type.getLeafType;
hT = hN.getType( 'FixedPoint', 'Signed', selType.Signed, 'WordLength',  ...
wordlen, 'FractionLength', 0 );
selType = selSignal.Type;
if selType.isArrayType
hAT = hN.getType( 'Array', 'BaseType', hT,  ...
'Dimensions', selType.Dimensions );
hT = hAT;
end 
dtc = hN.addSignal( hT, dtcname );
pirelab.getDTCComp( hN, selSignal, dtc );

end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpVImO55.p.
% Please follow local copyright laws when handling this file.

