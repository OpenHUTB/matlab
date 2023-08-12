function namedWorkspaces = createSimInputWorkspaces( simInputVars )







R36
simInputVars( 1, : )Simulink.Simulation.Variable
end 

varWorkspaces = { simInputVars.Workspace };
[ varWorkspaces{ : } ] = convertStringsToChars( varWorkspaces{ : } );
[ workspaceNames, ~, uniqueInverseIndices ] = unique( varWorkspaces );

namedWorkspaces = struct(  ...
'name', workspaceNames,  ...
'workspace', Simulink.standalone.MatlabWorkspace ...
 );

for i = 1:length( workspaceNames )
vars = simInputVars( uniqueInverseIndices == i );

if isempty( vars )
continue 
end 

varsStruct = struct(  ...
'Name', { vars.Name },  ...
'Value', { vars.Value } ...
 );

namedWorkspaces( i ).workspace.assign( varsStruct );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp2yVaIz.p.
% Please follow local copyright laws when handling this file.

