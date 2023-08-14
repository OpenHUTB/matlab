function handlers=registerSimulinkDependencyHandlers(~)




    handlers=dependencies.internal.action.DependencyHandler.empty;

    if dependencies.internal.util.isProductInstalled('SL','simulink')
        handlers=[
        dependencies.internal.action.dependency.DataDictionaryHandler
        dependencies.internal.action.dependency.MatlabFunctionHandler
        dependencies.internal.action.dependency.ModelCallbackHandler
        dependencies.internal.action.dependency.ModelDependenciesParameterHandler
        dependencies.internal.action.dependency.ModelWorkspaceHandler
        dependencies.internal.action.dependency.OpenBlockHandler
        dependencies.internal.action.dependency.OpenBlockParameterHandler
        dependencies.internal.action.dependency.ToolboxBlocksHandler
        dependencies.internal.action.dependency.SimulationTargetHandler
        ];
    end

    if dependencies.internal.util.isProductInstalled('SL','simulink')...
        ||dependencies.internal.util.isProductInstalled('SF','stateflow')
        handlers=[
handlers
        dependencies.internal.action.dependency.StateflowStateHandler
        dependencies.internal.action.dependency.StateflowTargetHandler
        ];
    end

    if dependencies.internal.util.isProductInstalled('RT','simulinkcoder')
        handlers=[
handlers
        dependencies.internal.action.dependency.SimulinkCoderHandler
        ];
    end

    if dependencies.internal.util.isProductInstalled('RQ','slrequirements')
        handlers=[
handlers
        dependencies.internal.action.dependency.RequirementInfoHandler
        ];
    end

end

