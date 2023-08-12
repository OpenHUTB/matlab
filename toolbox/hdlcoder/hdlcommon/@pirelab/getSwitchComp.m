function switchComp = getSwitchComp( hN, inSignals, outSignals, selSignal, compName,  ...
compareStr, compareVal, rndMode, ovMode, desc, slHandle )















if ( nargin < 11 )
slHandle =  - 1;
end 

if ( nargin < 10 )
desc = '';
end 

if ( nargin < 9 )
ovMode = 'Wrap';
end 
if ( nargin < 8 )
rndMode = 'Floor';
end 

if ( nargin < 7 )
compareVal = 0;
end 

if ( nargin < 6 )
compareStr = '==';
end 

if ( nargin < 5 )
compName = 'mux';
end 


if strcmp( compareStr, '<' ) && compareVal == 1
selType = selSignal.Type;
if selType.isBooleanType || selType.WordLength == 1
compareStr = '==';
compareVal = 0;
end 
end 


equalityOp = validateInputs( inSignals, compareStr, compareVal );

if equalityOp

if length( inSignals ) == 2



if compareVal == 0
inSigs = [ selSignal, inSignals ];
else 
inSigs = [ selSignal, inSignals( 2 ), inSignals( 1 ) ];
end 
else 
inSigs = [ selSignal, inSignals ];
end 
if length( inSignals ) == 1
inputmode = 0;
else 
inputmode = 1;
end 
switchComp = pirelab.getMultiPortSwitchComp( hN, inSigs,  ...
outSignals, inputmode, 1,  ...
rndMode, ovMode, compName );
elseif length( inSignals ) == 2

if strcmp( compareStr, '~=' ) && compareVal ~= 0
error( message( 'hdlcommon:hdlcommon:NotCompAgainst0' ) );
end 
if ~strcmp( compareStr, '>=' ) && ~strcmp( compareStr, '>' ) && ~strcmp( compareStr, '~=' )
error( message( 'hdlcommon:hdlcommon:NotSupportedSwitchOp', compareStr ) );
end 

inSignals = reshapeInputsIfRequired( hN, inSignals );
switchComp = pircore.getSwitchComp( hN, inSignals, outSignals, selSignal,  ...
compName, compareStr, compareVal, rndMode,  ...
ovMode, desc, slHandle );
else 
error( message( 'hdlcommon:hdlcommon:UnsupportedMode' ) );
end 
end 

function equalityOp = validateInputs( inSignals, compareStr, compareVal )

equalityOp = strcmp( compareStr, '==' );
if equalityOp
if length( inSignals ) == 2
if compareVal ~= 0 && compareVal ~= 1
error( message( 'hdlcommon:hdlcommon:NotSupportedVal' ) );
end 
end 
else 
if length( inSignals ) > 2
error( message( 'hdlcommon:hdlcommon:NotSupportedMPSwitchMode' ) );
end 
end 
end 





function outSignals = reshapeInputsIfRequired( hN, inSignals )
outSignals = inSignals;
hT1 = inSignals( 1 ).Type;
hT2 = inSignals( 2 ).Type;
if hT1.isArrayType && hT2.isArrayType
data1Unordered = ~hT1.isRowVector && ~hT1.isColumnVector;
data2Unordered = ~hT2.isRowVector && ~hT2.isColumnVector;
if data1Unordered && ~data2Unordered
hNewT = getpirarraytype( hT1.BaseType, hT1.Dimensions, hT2.isRowVector );
outSignals( 1 ) = hN.addSignal( hNewT, [ inSignals( 1 ).Name, '_reshape' ] );
pirelab.getWireComp( hN, inSignals( 1 ), outSignals( 1 ) );
elseif ~data1Unordered && data2Unordered
hNewT = getpirarraytype( hT2.BaseType, hT2.Dimensions, hT1.isRowVector );
outSignals( 2 ) = hN.addSignal( hNewT, [ inSignals( 2 ).Name, '_reshape' ] );
pirelab.getWireComp( hN, inSignals( 2 ), outSignals( 2 ) );
end 
end 
end 

function pirType = getpirarraytype( basetp, vecLen, isRowVec )
arrtypef = pir_arr_factory_tc;
arrtypef.addDimension( vecLen );
arrtypef.addBaseType( basetp );
if isRowVec
arrtypef.VectorOrientation = 'row';
else 
arrtypef.VectorOrientation = 'column';
end 

pirType = pir_array_t( arrtypef );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpTSYo02.p.
% Please follow local copyright laws when handling this file.

