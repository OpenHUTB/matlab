function paramArray = getParameterStructArrayFromSimulationInput( simInput )







R36
simInput( 1, 1 )Simulink.SimulationInput
end 

totalParams = 0;
if ~isempty( simInput.ExternalInput )
totalParams = totalParams + 1;
end 

if ~isempty( simInput.InitialState )
totalParams = totalParams + 1;
end 

totalParams = totalParams + numel( simInput.ModelParameters ) +  ...
numel( simInput.BlockParameters ) +  ...
numel( simInput.Variables );

paramArray = struct( 'index', {  }, 'type', {  },  ...
'name', {  }, 'value', {  }, 'fullname', {  } );
if totalParams == 0
return ;
end 
paramArray( totalParams ) = struct( 'index', [  ], 'type', [  ],  ...
'name', [  ], 'value', [  ], 'fullname', [  ] );

idx = 0;
if ~isempty( simInput.ExternalInput )
idx = idx + 1;
extInpStr = 'ExternalInput';
paramArray( idx ).index = idx;
paramArray( idx ).type = extInpStr;
paramArray( idx ).name = extInpStr;
paramArray( idx ).value = var2str( simInput.ExternalInput );
paramArray( idx ).fullname = extInpStr;
end 

if ~isempty( simInput.InitialState )
idx = idx + 1;
initialStateStr = 'InitialState';
paramArray( idx ).index = idx;
paramArray( idx ).type = initialStateStr;
paramArray( idx ).name = initialStateStr;
paramArray( idx ).value = var2str( simInput.InitialState );
paramArray( idx ).fullname = initialStateStr;
end 

for i = 1:numel( simInput.ModelParameters )
idx = idx + 1;
modelParam = simInput.ModelParameters( i );
paramArray( idx ).index = idx;
paramArray( idx ).type = 'Model Parameter';
paramArray( idx ).name = modelParam.Name;
paramArray( idx ).value = var2str( modelParam.Value );
paramArray( idx ).fullname = modelParam.Name;

switch modelParam.Name
case "SimFaults"
valueSplitStrings = strsplit( paramArray( idx ).value, "|" );
paramArray( idx ).value = "";
for ind = 2:2:numel( valueSplitStrings )
faultString = valueSplitStrings{ ind };
componentAndUUIDString = valueSplitStrings{ ind + 1 };
componentAndUUIDStringArray = strsplit( componentAndUUIDString, ";" );
componentString = componentAndUUIDStringArray{ 1 };
paramArray( idx ).value = strcat( paramArray( idx ).value, faultString, " (", componentString, "); " );
end 
end 
end 

for i = 1:numel( simInput.BlockParameters )
idx = idx + 1;
blockParam = simInput.BlockParameters( i );
paramArray( idx ).index = idx;
paramArray( idx ).type = 'Block Parameter';
paramArray( idx ).name = blockParam.Name;
paramArray( idx ).value = var2str( blockParam.Value );
paramArray( idx ).fullname = blockParam.BlockPath + ":" + blockParam.Name;
end 

for i = 1:numel( simInput.Variables )
idx = idx + 1;
inpVar = simInput.Variables( i );
if ~strcmp( inpVar.Workspace, 'global-workspace' )
fullName = inpVar.Workspace + ":" + inpVar.Name;
else 
fullName = inpVar.Name;
end 
value = inpVar.Value;

valueStr = var2str( value );

paramArray( idx ).index = idx;
paramArray( idx ).type = 'Variable';
paramArray( idx ).name = inpVar.Name;
paramArray( idx ).value = valueStr;
paramArray( idx ).fullname = fullName;
end 
end 

function str = var2str( varValue )


if matlab.internal.datatypes.isScalarText( varValue )
str = convertStringsToChars( varValue );
else 
displayStruct = matlab.internal.datatoolsservices.getWorkspaceDisplay( { varValue } );
str = convertStringsToChars( displayStruct.Value );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpEky5G3.p.
% Please follow local copyright laws when handling this file.

