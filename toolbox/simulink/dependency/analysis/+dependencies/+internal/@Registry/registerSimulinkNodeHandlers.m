function handlers=registerSimulinkNodeHandlers(~)




    handlers=dependencies.internal.action.NodeHandler.empty;

    if dependencies.internal.util.isProductInstalled('SL','simulink')
        handlers=dependencies.internal.action.node.SimulinkNodeHandler;
    end

    if dependencies.internal.util.isProductInstalled('SZ','simulinktest')
        handlers(end+1)=dependencies.internal.action.node.TestHarnessNodeHandler;
    end

    if dependencies.internal.util.isProductInstalled('SR','simulinkrequirements')
        handlers(end+1)=dependencies.internal.action.node.RequirementLinksNodeHandler;
    end

end
