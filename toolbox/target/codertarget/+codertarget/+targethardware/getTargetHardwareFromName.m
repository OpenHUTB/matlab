function hwInfo = getTargetHardwareFromName( hwName, product )




validateattributes( hwName, { 'char' }, {  } );
if nargin < 2
product = '';
end 

hwInfo = [  ];
if ~isempty( hwName )
registeredHw = codertarget.targethardware.getRegisteredTargetHardware( product );
for i = 1:numel( registeredHw )
if isequal( hwName, registeredHw( i ).Name )
dataModel = codertarget.target.getTargetVersion( registeredHw( i ).TargetName,  ...
product );
if dataModel == 1
hwInfo = [ hwInfo,  ...
codertarget.Registry.manageInstance( 'get',  ...
'targethardware', registeredHw( i ).DefinitionFileName ) ];%#ok<AGROW>
hwInfo( end  ).TargetName = registeredHw( i ).TargetName;
hwInfo( end  ).TargetFolder = registeredHw( i ).TargetFolder;
elseif dataModel == 2
query = { 
registeredHw( i ).TargetName,  ...
registeredHw( i ).Name,  ...
 };
hwInfo = [ hwInfo, codertarget.Registry.manageInstance( 'get',  ...
'targethardware_v2', query ) ];%#ok<AGROW>
end 
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpex6jny.p.
% Please follow local copyright laws when handling this file.

