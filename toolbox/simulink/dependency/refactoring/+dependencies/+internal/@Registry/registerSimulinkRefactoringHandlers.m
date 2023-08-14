function handlers=registerSimulinkRefactoringHandlers(~)




    handlers=dependencies.internal.action.RefactoringHandler.empty;

    if dependencies.internal.util.isProductInstalled('SL','simulink')
        handlers=[
        dependencies.internal.action.refactor.ModelReferenceHandler
        dependencies.internal.action.refactor.EnumeratedConstantHandler
        dependencies.internal.action.refactor.FromFileBlockHandler
        dependencies.internal.action.refactor.FromSpreadsheetBlockHandler
        dependencies.internal.action.refactor.ModelWorkspaceHandler
        dependencies.internal.action.refactor.LibraryLinkHandler
        dependencies.internal.action.refactor.CallbackHandler
        dependencies.internal.action.refactor.LibraryForwardingTableHandler
        dependencies.internal.action.refactor.LibraryForwardingTransformHandler
        dependencies.internal.action.refactor.DataDictionaryHandler
        dependencies.internal.action.refactor.SystemObjectHandler
        dependencies.internal.action.refactor.FMUHandler
        dependencies.internal.action.refactor.SubsystemReferenceHandler
        dependencies.internal.action.refactor.ToolboxBlockHandler
        dependencies.internal.action.refactor.ObserverReferenceHandler
        dependencies.internal.action.refactor.SignalEditorBlockHandler
        ];
    end

    if dependencies.internal.util.isProductInstalled('MS','mech')
        handlers=[handlers;dependencies.internal.action.refactor.SimMechanicsHandler];
    end

    if dependencies.internal.util.isProductInstalled('SZ','simulinktest')
        try
            handlers=[handlers;dependencies.internal.action.refactor.TestManagerHandler];
        catch



        end
    end






end
