function namedWorkspaces = createSimInputWorkspaces( simInputVars )

arguments
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


