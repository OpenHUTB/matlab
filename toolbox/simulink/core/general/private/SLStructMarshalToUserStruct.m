









function body = SLStructMarshalToUserStruct( busName, width, isNd, widthStr, dst, srcAddr, offsetList, level, isCplx, busVisitedMap, model, SFunMajorityIdx, DataTypeNames, portNumber, isParentArray, currBusPortInfoIdx )

if existsInGlobalScope( model, busName )
slObj = evalinGlobalScope( model, busName );
else 
return 
end 

infoStruct = busVisitedMap( busName );

if ~SFunMajorityIdx || isequal( SFunMajorityIdx, 2 )



isNd = false;
SFunMajorityIdx = 0;
end 

currBusIdVar = sprintf( [ '%sId' ], busName );

if ~isequal( currBusPortInfoIdx,  - 1 )
currBusSizeVar = sprintf( [ 'busInfo[%d].elemSize' ], currBusPortInfoIdx );
end 

if ~isequal( widthStr, 'topLevel' ) && ~isempty( widthStr )





currBusSizeVar = sprintf( [ '%selemSize' ], widthStr( 1:findstr( widthStr, ']' ) + 1 ) );
end 

forLoopBegin = '';
forLoopEnd = sprintf( [ '\n%s}\n%s}' ], tabSupplier( level + 1 ), tabSupplier( level ) );
inCurrForLoop = '';

if ~isequal( width, 1 )

isParentArrayToSend = true;
loopCounterVar = sprintf( [ 'i%d' ], level );
dtname = sprintf( [ '%s' ], busName );
dst = sprintf( [ '(( %s *)%s)[%s]' ], dtname, dst, loopCounterVar );
loopCounterDecl = sprintf( [ 'int_T %s%s' ], loopCounterVar, CEndLine(  ) );
if ~SFunMajorityIdx || ~isNd
loopOffsetVal = sprintf( [ '%s * %s' ], loopCounterVar, currBusSizeVar );
else 
rowMajorLoopCounterVar = sprintf( [ 'i%dRowMajor' ], level );
rowMajorLoopCounterVarDecl = sprintf( [ 'int_T %s%s' ], rowMajorLoopCounterVar, CEndLine(  ) );
loopOffsetVal = sprintf( [ '%s * %s' ], rowMajorLoopCounterVar, currBusSizeVar );
end 

if isempty( offsetList )
offsetList = [ { loopOffsetVal } ];
else 
offsetList = [ offsetList, { loopOffsetVal } ];
end 
else 
isParentArrayToSend = false;
end 

if isa( slObj, 'Simulink.Bus' )

if ~isequal( width, 1 )

if ~SFunMajorityIdx || ~isNd
if strcmp( widthStr, 'topLevel' ) && isequal( level, 0 )
forLoopBegin = sprintf( [ '\n%s{\n%s%s\n%sfor (%s = 0; %s < busInfo[%d].numElems; %s++) {' ],  ...
tabSupplier( level ), tabSupplier( level + 1 ), loopCounterDecl, tabSupplier( level + 1 ), loopCounterVar, loopCounterVar, currBusPortInfoIdx, loopCounterVar );
else 
if isParentArray
level = level + 1;
end 
forLoopBegin = sprintf( [ '\n%s{\n%s%s\n%sfor (%s = 0; %s < %s; %s++) {' ],  ...
tabSupplier( level ), tabSupplier( level + 1 ), loopCounterDecl, tabSupplier( level + 1 ), loopCounterVar, loopCounterVar, widthStr, loopCounterVar );
if isParentArray
level = level - 1;
end 
end 
else 



if strcmp( widthStr, 'topLevel' ) && isequal( level, 0 )
forLoopBegin = sprintf( [ '\n%s{\n%s%s\n%s%s \n%sconst int_T *srcdims%d = ssGetInputPortDimensions(S, %d); \n%sconst int_T numdims%d = 2; \n%sfor (%s = 0; %s < busInfo[%d].numElems; %s++) {' ],  ...
tabSupplier( level ), tabSupplier( level + 1 ), loopCounterDecl, tabSupplier( level + 1 ), rowMajorLoopCounterVarDecl, tabSupplier( level + 1 ), level, portNumber, tabSupplier( level + 1 ), level, tabSupplier( level + 1 ),  ...
loopCounterVar, loopCounterVar, currBusPortInfoIdx, loopCounterVar );
forLoopBegin = sprintf( [ '%s\n%s/*Get indices for %s bus in row-major format*/' ], forLoopBegin, tabSupplier( level + 2 ), busName );
forLoopBegin = sprintf( [ '%s\n%s%s = linear_idx(srcdims%d, numdims%d, %s);' ], forLoopBegin, tabSupplier( level + 2 ), rowMajorLoopCounterVar, level, level, loopCounterVar );
else 
if isParentArray
level = level + 1;
end 
forLoopBegin = sprintf( [ '\n%s{\n%s%s\n%s%s \n%sfor (%s = 0; %s < %s; %s++) {' ],  ...
tabSupplier( level ), tabSupplier( level + 1 ), loopCounterDecl, tabSupplier( level + 1 ), rowMajorLoopCounterVarDecl,  ...
tabSupplier( level + 1 ), loopCounterVar, loopCounterVar, widthStr, loopCounterVar );
forLoopBegin = sprintf( [ '%s\n%s/*Get indices for %s bus in row-major format*/' ], forLoopBegin, tabSupplier( level + 2 ), busName );
forLoopBegin = sprintf( [ '%s\n%s%s = linear_idx(%sdims, %snumDims, %s);' ], forLoopBegin, tabSupplier( level + 2 ), rowMajorLoopCounterVar, widthStr( 1:findstr( widthStr, ']' ) + 1 ), widthStr( 1:findstr( widthStr, ']' ) + 1 ), loopCounterVar );

if isParentArray
level = level - 1;
end 
end 


end 

level = level + 1;
end 


builtinCount = 1;
busCount = 1;
for i = 1:length( slObj.Elements )
iseBus = false;

eName = slObj.Elements( i ).Name;
busDTStr = 'Bus:';
slObj.Elements( i ).DataType = strrep( slObj.Elements( i ).DataType, ' ', '' );
indicesBus = findstr( slObj.Elements( i ).DataType, busDTStr );
if ( ~isempty( indicesBus ) && indicesBus( 1 ) == 1 )
slObj.Elements( i ).DataType = strtrim( strrep( slObj.Elements( i ).DataType, 'Bus:', '' ) );
iseBus = true;
end 

EnumDTStr = 'Enum:';
indices = findstr( slObj.Elements( i ).DataType, EnumDTStr );
if ( ~isempty( indices ) ) && ( indices( 1 ) == 1 )
slObj.Elements( i ).DataType = slObj.Elements( i ).DataType( length( EnumDTStr ) + 1:end  );
iseBus = false;
elseif ~ismember( slObj.Elements( i ).DataType, DataTypeNames )
iseBus = true;
end 


if findFixdt( slObj.Elements( i ).DataType )
iseBus = false;
end 

eDType = slObj.Elements( i ).DataType;

eWidth = prod( slObj.Elements( i ).Dimensions );

if iseBus

if length( slObj.Elements( i ).Dimensions ) > 1 &&  ...
any( slObj.Elements( i ).Dimensions( 2:end  ) > 1 )
isNd = true;
end 

eOffsetVal = sprintf( [ 'busInfo[%d].offset' ], infoStruct.busCIdx( busCount ) );
eSize = sprintf( [ 'busInfo[%d].elemSize' ], infoStruct.busCIdx( busCount ) );
eWidthStr = sprintf( [ 'busInfo[%d].numElems' ], infoStruct.busCIdx( busCount ) );

busCount = busCount + 1;
else 


eOffsetVal = sprintf( [ 'busInfo[%d].offset' ], infoStruct.builtinCIdx( builtinCount ) );
eSize = sprintf( [ 'busInfo[%d].elemSize' ], infoStruct.builtinCIdx( builtinCount ) );
eWidthStr = '';
eDims = sprintf( [ 'busInfo[%d].dims' ], infoStruct.builtinCIdx( builtinCount ) );
eNumDims = sprintf( [ 'busInfo[%d].numDims' ], infoStruct.builtinCIdx( builtinCount ) );
builtinCount = builtinCount + 1;
end 

eOffsetList = offsetList;

if strcmp( eOffsetList{ 1 }, '0' )
eOffsetList{ 1 } = eOffsetVal;
else 
eOffsetList{ 1 } = sprintf( [ '%s + %s' ], eOffsetList{ 1 }, eOffsetVal );
end 

eIsCplx = ~isequal( slObj.Elements( i ).Complexity, 'real' );

if ~isCplx
if isequal( widthStr, 'topLevel' ) && infoStruct.isNestedBusArray && isequal( prod( width ), 1 )
eDst = [ dst, '->', eName ];
else 
eDst = [ dst, '.', eName ];
end 
end 


if iseBus


inCurrForLoopNew = SLStructMarshalToUserStruct( eDType, eWidth, isNd, eWidthStr, eDst, srcAddr, eOffsetList, level, eIsCplx, busVisitedMap, model, SFunMajorityIdx, DataTypeNames, portNumber, isParentArrayToSend,  - 1 );
inCurrForLoop = sprintf( [ '%s\n%s' ], inCurrForLoop, inCurrForLoopNew );
else 


if eWidth > 1
optAddr = sprintf( '' );
else 
optAddr = sprintf( '&' );
end 

if ismember( eDType, DataTypeNames )
switch eDType
case 'double'
DT = 'real_T';
case 'single'
DT = 'real32_T';
otherwise 
DT = [ eDType, '_T' ];
end 
eDType = DT;

elseif infoStruct.isFpt{ builtinCount - 1 }



eDType = infoStruct.builtinDType{ builtinCount - 1 };
end 

if eIsCplx
eWidth = 2 * eWidth;
end 

eOffsetStr = '';
if ~isCplx


for len = 1:length( eOffsetList ) - 1
if isempty( eOffsetStr )
eOffsetStr = sprintf( [ '%s' ], eOffsetList{ len + 1 } );
else 
eOffsetStr = sprintf( [ '%s + %s' ], eOffsetStr, eOffsetList{ len + 1 } );
end 
end 



if ~strcmp( eOffsetList{ 1 }, '0' )
if ~isempty( eOffsetStr )
eOffsetStr = sprintf( [ '%s + %s' ], eOffsetStr, eOffsetList{ 1 } );
else 
eOffsetStr = sprintf( [ '%s' ], eOffsetList{ 1 } );
end 
end 

if ~isempty( eOffsetStr )
eSrc = sprintf( [ '%s + %s' ], srcAddr, eOffsetStr );
else 
eSrc = sprintf( [ '%s' ], srcAddr );
end 

end 

if width > 1 || ( ~isNd || SFunMajorityIdx )
l = level + 1;
else 
l = level;
end 




if eWidth == 1

if ~isCplx

inCurrForLoop = sprintf( [ '%s\n%s%s = *((%s*)(%s));' ],  ...
inCurrForLoop, tabSupplier( l ), eDst, eDType, eSrc );
end 
else 

if ~isCplx

if ~SFunMajorityIdx
inCurrForLoop = sprintf( [ '%s\n%s(void) memcpy(%s%s, %s, %d*%s);' ],  ...
inCurrForLoop, tabSupplier( l ), optAddr, eDst, eSrc, eWidth, eSize );
else 
inCurrForLoop = sprintf( [ '%s\n%s/*Copy from Simulink for %s in %s bus in row-major format*/' ], inCurrForLoop, tabSupplier( l ), eName, busName );
if eIsCplx
inCurrForLoop = sprintf( [ '%s\n%sNDTransposeBySrcSpecs((void*)(%s%s),(const void*) (%s), %s, %s, 2*%s);' ],  ...
inCurrForLoop, tabSupplier( l ), optAddr, eDst, eSrc, eDims, eNumDims, eSize );
else 
inCurrForLoop = sprintf( [ '%s\n%sNDTransposeBySrcSpecs((void*)(%s%s),(const void*) (%s), %s, %s, %s);' ],  ...
inCurrForLoop, tabSupplier( l ), optAddr, eDst, eSrc, eDims, eNumDims, eSize );
end 
end 

end 
end 
end 
end 

if ~isequal( width, 1 )

body = sprintf( [ ' %s %s %s' ], forLoopBegin, inCurrForLoop, forLoopEnd );
else 
body = inCurrForLoop;

end 

end 


end 


function tabs = tabSupplier( level )
tabs = sprintf( '\t' );

if level > 0
for l = 1:level
tabs = sprintf( [ '%s\t' ], tabs );
end 
end 

end 

function cEnd = CEndLine(  )

cEnd = sprintf( ';' );

end 

function res = findFixdt( dtype )

isBus = false;
isEnum = false;

busDTStr = 'Bus:';
dtype = strrep( dtype, ' ', '' );
indicesBus = findstr( dtype, busDTStr );
if ( ~isempty( indicesBus ) && indicesBus( 1 ) == 1 )
isBus = true;
end 

EnumDTStr = 'Enum:';
indices = findstr( dtype, EnumDTStr );
if ( ~isempty( indices ) ) && ( indices( 1 ) == 1 )
isEnum = true;
end 

res = false;
if ~isEnum && ~isBus
idx = findstr( dtype, 'fixdt' );

if ~isempty( idx )
res = true;
end 
else 
res = false;
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp3IEJKf.p.
% Please follow local copyright laws when handling this file.

