function ctx=getCurrentAppContext(studio)


    contextManager=studio.App.getAppContextManager;
    ctx=contextManager.getCustomContext('embeddedCoderApp');
    if isempty(ctx)
        ctx=contextManager.getCustomContext('simulinkCoderApp');
    end
    if isempty(ctx)
        ctx=contextManager.getCustomContext('autosarApp');
    end
    if isempty(ctx)
        ctx=contextManager.getCustomContext('ddsApp');
    end