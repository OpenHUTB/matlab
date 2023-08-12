function busObj = slbus_get_object_from_name_withDataAccessor( busName, okToError, dataAccessor, searchBusDict )


















if nargin < 2
okToError = true;
end 

if nargin < 3
dataAccessor = Simulink.data.DataAccessor.createWithNoContext(  );
end 

if nargin < 4
searchBusDict = true;
end 




busName = regexprep( busName, '^dto(Dbl|Sgl|Scl)(Flt|Fxp)?_', '' );

[ success, busObj ] = isBusExist( dataAccessor, busName );


if ~success && searchBusDict
busDict = Simulink.BusDictionary.getInstance(  );


busObj = busDict.getRegisteredBusType( busName );


if isempty( busObj )
busObj = busDict.getClassBasedBusType( busName );
end 

if ~isempty( busObj )
assert( isa( busObj, 'Simulink.Bus' ) );
success = true;
else 

busObj = '';
end 
end 

if ~success && okToError
DAStudio.error( 'Simulink:utility:slUtilityBusObjectNotFoundInDataSources', busName );
end 
end 


function [ success, busObj ] = isBusExist( dataAccessor, busName )
busObj = '';
success = false;


try 
if ( ( ~sldtype_is_builtin( busName ) ) && ( isvarname( busName ) ) )
varId = dataAccessor.name2UniqueIdWithCheck( busName );
if ~isempty( varId )
tmpObj = dataAccessor.getVariable( varId );
if isa( tmpObj, 'Simulink.Bus' ) ||  ...
isa( tmpObj, 'Simulink.ConnectionBus' )
busObj = tmpObj;
success = true;
end 
end 
end 
catch me %#ok
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpEQViJP.p.
% Please follow local copyright laws when handling this file.

