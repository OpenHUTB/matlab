function busObj = slbus_get_object_from_name( busName, okToError, scope, searchBusDict )




















if nargin < 2
okToError = true;
end 

if nargin < 3
scope = Simulink.data.BaseWorkspace;
end 

if nargin < 4
searchBusDict = true;
end 

if isa( scope, 'Simulink.data.BaseWorkspace' )
dataAccessor = Simulink.data.DataAccessor.createWithNoContext(  );
else 
dataAccessor = Simulink.data.DataAccessor.createForOutputData( scope.DataDictionaryFile );
end 

busObj = slbus_get_object_from_name_withDataAccessor( busName, okToError, dataAccessor, searchBusDict );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpDPH0qo.p.
% Please follow local copyright laws when handling this file.

