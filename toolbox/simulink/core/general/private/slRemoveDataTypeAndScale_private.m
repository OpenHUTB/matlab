function [ changed, skipped, mustChangeFlags ] = slRemoveDataTypeAndScale_private( system, update, verbose )















assert( nargin == 3 );

changed = struct( 'BlockName', {  }, 'ParamName', {  }, 'OldDTStr', {  }, 'NewDTStr', {  } );
skipped = struct( 'BlockName', {  }, 'ParamName', {  }, 'OldDTStr', {  }, 'NewDTStr', {  } );
mustChangeFlags = false;


try 
handle = get_param( system, 'Handle' );
modelName = getfullname( bdroot( handle ) );
catch e
DAStudio.error( 'Simulink:fixedandfloat:slRmDTInputArg' );
end 

try 

mdlType = strtrim( get_param( bdroot( handle ), 'BlockDiagramType' ) );



if ( isUnderMask( handle ) )



objs_mask = filterParameters( find_system( handle,  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'LookInsideSubsystemReference', 'off',  ...
'LookUnderMasks', 'all',  ...
'BlockParamType', 'DataTypeStr' ) );
objs_nmask = [  ];
nObjs = length( objs_mask );
nObjs_nmask = 0;
else 


objs_nmask = filterParameters( find_system( handle,  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'LookInsideSubsystemReference', 'off',  ...
'LookUnderMasks', 'none',  ...
'BlockParamType', 'DataTypeStr' ) );
objs_all = filterParameters( find_system( handle,  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'LookInsideSubsystemReference', 'off',  ...
'LookUnderMasks', 'all',  ...
'BlockParamType', 'DataTypeStr' ) );
objs_mask = setDiffonParamDescriptor( objs_all, objs_nmask );
nObjs = length( objs_all );
nObjs_nmask = length( objs_nmask );
end 



handles = zeros( nObjs, 1 );
paramNames = cell( nObjs, 1 );


for n = 1:nObjs_nmask
blkPath = objs_nmask( n ).OwnerPath;
handles( n ) = get_param( blkPath, 'Handle' );
paramNames{ n } = objs_nmask( n ).ParameterName;
end 


for n = 1:( nObjs - nObjs_nmask )
blkPath = objs_mask( n ).OwnerPath;
handles( nObjs_nmask + n ) = get_param( blkPath, 'Handle' );
paramNames{ nObjs_nmask + n } = objs_mask( n ).ParameterName;
end 

isChange = false;
itemNum1 = 0;
itemNum2 = 0;
for n = 1:nObjs
blkHdl = handles( n );
paramName = paramNames{ n };
blkPath = getfullname( blkHdl );
oldStr = get_param( blkHdl, paramName );


if ( ~isequal( mdlType, 'library' ) )
if ( n <= nObjs_nmask )
isMasked = 0;
else 
isMasked = 1;
end 
[ newStr, mustChangeFlag ] = replaceFunc( blkHdl, oldStr, isMasked );
else 
newStr = '';
end 

if ( ~isempty( newStr ) )
isChange = true;
itemNum1 = itemNum1 + 1;
changed( itemNum1 ).BlockName = blkPath;
changed( itemNum1 ).ParamName = paramName;
changed( itemNum1 ).OldDTStr = oldStr;
changed( itemNum1 ).NewDTStr = newStr;

mustChangeFlags( itemNum1 ) = mustChangeFlag;

if ( update )
set_param( blkHdl, paramName, newStr );
end 
else 
itemNum2 = itemNum2 + 1;
skipped( itemNum2 ).BlockName = blkPath;
skipped( itemNum2 ).ParamName = paramName;
skipped( itemNum2 ).OldDTStr = oldStr;
skipped( itemNum2 ).NewDTStr = newStr;
end 
end 

if ( ~nObjs && verbose >= 1 )
disp( DAStudio.message( 'Simulink:fixedandfloat:slRmDTVerbose0' ) );
end 
if ( isChange && verbose >= 1 )
if ( update )
disp( DAStudio.message( 'Simulink:fixedandfloat:slRmDTVerbose1u' ) );
else 
disp( DAStudio.message( 'Simulink:fixedandfloat:slRmDTVerbose1' ) );
end 
showResults( changed );
end 
if ( verbose >= 2 && ~isempty( skipped ) )
if ( isequal( mdlType, 'library' ) )
disp( DAStudio.message( 'Simulink:fixedandfloat:slRmDTLibrary', modelName ) );
end 
disp( DAStudio.message( 'Simulink:fixedandfloat:slRmDTVerbose2' ) );
showResults( skipped );
end 

catch e
e.rethrow;
end 








function msk = isUnderMask( hdl )

msk = false;
rootHdl = get_param( bdroot( hdl ), 'Handle' );
parent = get_param( hdl, 'Parent' );
if ( isempty( parent ) )
return ;
else 
parentHdl = get_param( parent, 'Handle' );
end 

while ( ~isequal( parentHdl, rootHdl ) )
if ( isequal( get_param( parentHdl, 'Mask' ), 'on' ) )
msk = true;
break ;
else 
parent = get_param( parentHdl, 'Parent' );
parentHdl = get_param( parent, 'Handle' );
end 
end 





function objs = filterParameters( dscps )

L = length( dscps );
i = 0;
for n = 1:L
blkPath = dscps( n ).OwnerPath;
parName = dscps( n ).ParameterName;
paramValue = get_param( blkPath, parName );
if ( strcmp( getFunctionName( paramValue ), 'slDataTypeAndScale' ) )
i = i + 1;
objs( i ) = dscps( n );
end 
end 

if ( i == 0 )
objs = [  ];
end 





function dscps = setDiffonParamDescriptor( dscps1, dscps2 )

L1 = length( dscps1 );
L2 = length( dscps2 );
n = 0;

for n1 = 1:L1
flag = 0;
str1 = [ dscps1( n1 ).OwnerPath, dscps1( n1 ).ParameterName ];
for n2 = 1:L2
str2 = [ dscps2( n2 ).OwnerPath, dscps2( n2 ).ParameterName ];
if ( strcmp( str1, str2 ) )
flag = 1;
break ;
end 
end 
if ( ~flag )
n = n + 1;
dscps( n ) = dscps1( n1 );
end 
end 

if ( n == 0 )
dscps = [  ];
end 



function s = getFunctionName( str )

k = findstr( str, '(' );
if ( ~isempty( k ) && k( 1 ) > 1 )
s = strtrim( str( 1:k( 1 ) - 1 ) );
else 
s = '';
end 





function [ newStr, mustChangeFlag ] = replaceFunc( blkh, str, isMasked )

newStr = '';
mustChangeFlag = 0;


k1 = findstr( '''', str );
leng = length( k1 );
if ( leng < 4 || mod( leng, 2 ) )
return ;
else 
numParam = leng / 2;
end 

if ( numParam > 2 )

k2 = findstr( '''''', str );
k3 = setdiff( k1, [ k2, k2 + 1 ] );
L = length( k3 );
if ( L == 4 && length( k2 ) == 2 && k2( 1 ) > k3( 1 ) && k2( 2 ) + 1 < k3( 2 ) )
str( k2( 1 ) ) = ' ';
str( k2( 2 ) + 1 ) = ' ';
k1 = k3;
else 

return ;
end 
end 


unevaledTypeStr = strtrim( str( k1( 1 ) + 1:k1( 2 ) - 1 ) );
unevaledScaleStr = strtrim( str( k1( 3 ) + 1:k1( 4 ) - 1 ) );


try 
DT = slResolve( unevaledTypeStr, blkh, 'expression' );
if isempty( DT ) && isa( DT, 'meta.class' )
return ;
end 
isfullySpec = isNonFixptFullySpec( DT );
if ~isfullySpec
isfullySpec = getdatatypespecs( DT, [  ], 0, 0, 3 );
Scaling = slResolve( unevaledScaleStr, blkh, 'expression' );
preRes = getdatatypespecs( DT, Scaling, 0, 0, 1 );
end 
catch e
disp( DAStudio.message( 'Simulink:fixedandfloat:slRmDTResolve', unevaledTypeStr, unevaledScaleStr, str, getfullname( blkh ) ) );
return ;
end 

if ( isfullySpec )

if ( isMasked == 0 || isSafeDTFunction( unevaledTypeStr ) )
newStr = unevaledTypeStr;
end 

if ( isa( DT, 'Simulink.NumericType' ) && DT.IsAlias ) || isa( DT, 'Simulink.AliasType' )
mustChangeFlag = true;
else 
mustChangeFlag = false;
end 
else 

[ dtSign, dtBits, dtScaling ] = parseStrforFixDT( unevaledTypeStr, unevaledScaleStr, max( size( Scaling ) ) );
if ~isequal( dtSign, '' )

newStr = [ 'fixdt(', dtSign, ', ', dtBits, ', ', dtScaling, ')' ];

try 
curRes = slResolve( newStr, blkh );
catch e
newStr = '';
return ;
end 

if ( ~isResolutionEqual( preRes, curRes ) )
newStr = '';
return ;
end 
end 
end 


function r = isNonFixptFullySpec( dt )
r = false;
if isa( dt, 'Simulink.StructType' )
r = true;
return ;
end 

if Simulink.data.isSupportedEnumClass( dt )
r = true;
end 
return ;


function s = isSafeDTFunction( dtStr )

funcName = getFunctionName( dtStr );
if ( isempty( funcName ) )
s = 0;
return ;
end 

switch funcName
case 'fixdt'
s = 1;
case 'sint'
s = 1;
case 'uint'
s = 1;
case 'sfrac'
s = 1;
case 'ufrac'
s = 1;
case 'float'
s = 1;
otherwise 
s = 0;
end 









function [ sign, bits, scale ] = parseStrforFixDT( typeStr, scaleStr, numSclParams )

sign = '';
bits = '';
scale = '';


k1 = findstr( typeStr, '(' );
k2 = findstr( typeStr, ')' );
if ( ~isequal( length( k1 ), length( k2 ) ) )

return ;
end 

if ( isempty( k1 ) )

return ;
end 

try 
num = length( k2 );

if isequal( getFunctionName( typeStr ), 'ufix' )
sign = '0';
bits = strtrim( typeStr( k1( 1 ) + 1:k2( num ) - 1 ) );
end 

if isequal( getFunctionName( typeStr ), 'sfix' )
sign = '1';
bits = strtrim( typeStr( k1( 1 ) + 1:k2( num ) - 1 ) );
end 


if isequal( getFunctionName( typeStr ), 'fixdt' )
k3 = findstr( typeStr, ',' );
L = length( k3 );


if ( L == 1 )
sign = strtrim( typeStr( k1( 1 ) + 1:k3( 1 ) - 1 ) );
bits = strtrim( typeStr( k3( 1 ) + 1:k2( num ) - 1 ) );
end 
end 



if ( isequal( sign, '' ) )
return ;
elseif ( numSclParams >= 3 )
sign = '';
return ;
end 



scaling = scaleStr;
num = length( scaling );
counter = 1;

if ( ~isempty( findstr( scaling, '[' ) ) )


for n = 1:num
if ( isequal( scaling( n ), ']' ) || isequal( scaling( n ), '[' ) || isequal( scaling( n ), ',' ) )
scaling( n ) = ' ';
end 
end 
params = strtrim( scaling );


num = length( params );
flag = 0;

for n = 1:num
if ( params( n ) == ' ' && ~flag )
params( n ) = ',';
flag = 1;
counter = counter + 1;
else 
if ( params( n ) ~= ' ' && flag )
flag = 0;
end 
end 
end 
else 
params = strtrim( scaling );
end 

if ( counter >= 3 )
scale = '';
elseif ( numSclParams > 0 && counter ~= numSclParams )

scale = '';
elseif ( counter == 2 )
scale = convertScale4twoP( params );
else 
scale = convertScale4oneP( params );
end 

if ( isempty( scale ) )
sign = '';
end 

catch e
sign = '';
e.rethrow;
return 
end 



function scale = convertScale4oneP( str )

if ( isempty( str ) )
scale = '';
return ;
end 

if ( isValueExpression( str ) )
value =  - log2( str2num( str ) );
if ( isequal( floor( value ), value ) )
scale = sprintf( '%d', floor( value ) );
else 
scale = [ str, ', 0' ];
end 
else 
scale = [ str, ', 0' ];
end 




function scale = convertScale4twoP( str )

k = findstr( str, ',' );

param1 = strtrim( str( 1:k - 1 ) );
param2 = strtrim( str( k + 1:end  ) );

if ( isequal( param2, '0' ) )
scale = convertScale4oneP( param1 );
else 
scale = [ param1, ', ', param2 ];
end 



function status = isValueExpression( str )

status = 0;
idx1 = regexp( str, '[\^\-.+*/() ]' );
idx2 = regexp( str, '[0-9]' );

if ( length( idx1 ) + length( idx2 ) == length( str ) )
status = 1;
end 



function isEq = isResolutionEqual( a, b )

fields_a = fieldnames( a );
fields_b = fieldnames( b );
DTMode = 'DataTypeMode';

isEq = 0;



if ( ismember( DTMode, fields_a ) && ismember( DTMode, fields_b ) &&  ...
strcmp( a.( DTMode ), 'Fixed-point: binary point scaling' ) &&  ...
strcmp( b.( DTMode ), 'Fixed-point: slope and bias scaling' ) )


a.DataTypeMode = 'Fixed-point: slope and bias scaling';
if ( isequal( a, b ) )
isEq = 1;
end 
return ;
end 


if ( isequal( a, b ) )
isEq = 1;
end 
return ;


function showResults( res )

L = length( res );
for itemNum = 1:L
disp( res( itemNum ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpFqsCiZ.p.
% Please follow local copyright laws when handling this file.

