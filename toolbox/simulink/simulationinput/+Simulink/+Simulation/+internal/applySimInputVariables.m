function applySimInputVariables( in, options )

arguments
    in( 1, 1 )Simulink.SimulationInput
    options.ApplyHidden( 1, 1 )matlab.lang.OnOffSwitchState =  ...
        matlab.lang.OnOffSwitchState.off
end

Simulink.Simulation.internal.loadModelForApply( in.getModelNameForApply, in.CreatedForRevert );


mdlrefs = find_mdlrefs( in.getModelNameForApply,  ...
    'MatchFilter', @Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices );
loadedModels = bdIsLoaded( mdlrefs );
variables = in.Variables;

if options.ApplyHidden
    variables = [ variables, in.HiddenVariables ];
end

isGlobalVarFcn = @( varObj )strcmpi( varObj.Workspace, 'global-workspace' );
isGlobalVar = arrayfun( isGlobalVarFcn, variables );

da = Simulink.data.DataAccessor.createForGlobalNameSpaceClosure( in.ModelName );
for varIdx = find( isGlobalVar )
    varName = variables( varIdx ).Name;
    varValue = variables( varIdx ).Value;

    [ varId, secondaryVarId ] = da.name2UniqueIdWithCheck( varName );
    if ~isempty( varId )
        da.updateVariable( varId, varValue );
        if ~isempty( secondaryVarId )
            da.updateVariable( secondaryVarId, varValue );
        end
    else
        da.createVariableAsExternalData( varName, varValue );
    end
end
bdclose( mdlrefs( ~loadedModels ) );


for i = find( ~isGlobalVar )
    varName = variables( i ).Name;
    varValue = variables( i ).Value;

    modelName = variables( i ).Workspace;
    Simulink.Simulation.internal.loadModelForApply( modelName, in.CreatedForRevert );
    modelWS = get_param( modelName, 'modelworkspace' );
    modelWS.assignin( varName, varValue );
end
end


