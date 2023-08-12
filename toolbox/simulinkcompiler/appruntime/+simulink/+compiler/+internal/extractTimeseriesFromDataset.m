function [ tsArray, tsPaths, tsNames ] = extractTimeseriesFromDataset( ds )
















R36
ds( 1, 1 )Simulink.SimulationData.Dataset
end 

product = "Simulink_Compiler";
[ status, msg ] = builtin( 'license', 'checkout', product );
if ~status
product = extractBetween( msg, 'Cannot find a license for ', '.' );
if ~isempty( product )
error( message( 'simulinkcompiler:build:LicenseCheckoutError', product{ 1 } ) );
end 
error( msg );
end 


tsArray = {  };
tsPaths = {  };
tsNames = {  };

nSigs = ds.numElements;
for is = 1:nSigs

signal = ds{ is };
sigType = class( signal );

tsPathPrefix = ds.Name;
if isempty( tsPathPrefix )
tsPathPrefix = inputname( 1 );
end 
tsPathPrefix = [ tsPathPrefix, '{', num2str( is ), '}' ];%#ok

if isequal( sigType, 'timeseries' )

tsNamePrefix = '';

[ tsArray, tsPaths, tsNames ] = extractTimeseries(  ...
tsArray,  ...
tsPaths,  ...
tsNames,  ...
signal,  ...
tsPathPrefix,  ...
tsNamePrefix );

elseif ( ( isstruct( signal ) && isfield( signal, 'Values' ) ) ||  ...
isequal( sigType, 'Simulink.SimulationData.Signal' ) )

values = signal.Values;
if isempty( values ), continue ;end 

tsNamePrefix = signal.Name;
if isempty( tsNamePrefix ) && isprop( signal, 'PropagatedName' )
tsNamePrefix = signal.PropagatedName;
end 

if isstruct( values )
[ tsArray, tsPaths, tsNames ] = extractTimeseriesFromStruct(  ...
tsArray,  ...
tsPaths,  ...
tsNames,  ...
values,  ...
[ tsPathPrefix, '.Values' ],  ...
tsNamePrefix );
else 

[ tsArray, tsPaths, tsNames ] = extractTimeseries(  ...
tsArray,  ...
tsPaths,  ...
tsNames,  ...
values,  ...
[ tsPathPrefix, '.Values' ],  ...
tsNamePrefix );
end 
end 
end 

end 


function [ tsArray, tsPaths, tsNames ] = extractTimeseries(  ...
tsArray,  ...
tsPaths,  ...
tsNames,  ...
values,  ...
tsPathPrefix,  ...
tsNamePrefix )

assert( isequal( class( values ), 'timeseries' ) );
nTS = length( values );
for iTS = 1:nTS

tsPath = tsPathPrefix;
if nTS > 1
tsPath = [ tsPath, '(', num2str( iTS ), ')' ];%#ok<AGROW>
end 

tsName = values( iTS ).Name;
if isempty( tsName )
tsName = tsNamePrefix;
elseif ~isempty( tsNamePrefix )
tmp = split( tsNamePrefix, '.' );
tmp = tmp{ end  };
if ~isequal( tmp, tsName )
tsName = [ tsNamePrefix, '.', tsName ];%#ok<AGROW>
else 
tsName = tsNamePrefix;
end 
end 
if isempty( tsName ), tsName = tsPath;end 

values( iTS ).Name = tsName;
tsArray{ end  + 1 } = values( iTS );%#ok<AGROW>
tsPaths{ end  + 1 } = tsPath;%#ok<AGROW>
tsNames{ end  + 1 } = values( iTS ).Name;%#ok<AGROW>
end 
end 


function [ tsArray, tsPaths, tsNames ] = extractTimeseriesFromStruct(  ...
tsArray,  ...
tsPaths,  ...
tsNames,  ...
values,  ...
tsPathPrefix,  ...
tsNamePrefix )

assert( isstruct( values ) );



nEl = numel( values );
values = reshape( values, nEl, 1 );
fldNames = fieldnames( values );

for iEl = 1:nEl
for ifn = 1:length( fldNames )
fldName = fldNames{ ifn };
fld = values( iEl ).( fldName );

tsPath = [ tsPathPrefix, '.', fldName ];
if nEl > 1
tsPath = [ tsPath, '(', num2str( iEl ), ')' ];%#ok<AGROW>
end 

tsName = fldName;
if ( ~isempty( tsName ) &&  ...
~isempty( tsNamePrefix ) &&  ...
~isequal( tsNamePrefix, tsName ) )
tsName = [ tsNamePrefix, '.', tsName ];%#ok<AGROW>
end 

if isstruct( fld )
[ tsArray, tsPaths, tsNames ] = extractTimeseriesFromStruct(  ...
tsArray,  ...
tsPaths,  ...
tsNames,  ...
fld,  ...
tsPath,  ...
tsName );
else 
[ tsArray, tsPaths, tsNames ] = extractTimeseries(  ...
tsArray,  ...
tsPaths,  ...
tsNames,  ...
fld,  ...
tsPath,  ...
tsName );
end 
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpovMB6p.p.
% Please follow local copyright laws when handling this file.

