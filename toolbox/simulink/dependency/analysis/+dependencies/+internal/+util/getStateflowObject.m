function obj = getStateflowObject( componentPath, modelName )









R36
componentPath( 1, : )char;
modelName( 1, : )char;
end 

colon = find( componentPath == ':', 1, 'last' );
if isempty( colon )
obj = i_getChart( componentPath );
return ;
end 

ssid = componentPath( colon + 1:end  );
blockSID = componentPath( 1:colon - 1 );

if strcmp( blockSID, modelName )
obj = i_getMachineData( modelName, ssid );
else 
obj = i_getChartElementViaSSID( blockSID, ssid, componentPath );
end 

end 

function obj = i_getChart( path )
rt = sfroot;
obj = rt.find( '-isa', 'Stateflow.Chart', 'Path', path );
end 

function obj = i_getMachineData( machineName, dataName )
obj = [  ];
rt = sfroot;

machine = rt.find( '-isa', 'Stateflow.Machine', 'Name', machineName );

if length( machine ) ~= 1
return ;
end 

obj = machine.find( '-isa', 'Stateflow.Data', 'Name', dataName );
end 

function obj = i_getChartElementViaSSID( blockSID, ssid, path )
if ~Simulink.ID.isValid( blockSID )
blockSID = Simulink.ID.getSID( blockSID );
path = strcat( blockSID, ':', ssid );
end 

obj = Simulink.ID.getHandle( path );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpoEGHA8.p.
% Please follow local copyright laws when handling this file.

