function e=linkedExplorerAppHandle()






    import simscape.logging.internal.ResultsExplorerLinkManager
    c=ResultsExplorerLinkManager.linkedInstance();
    e=[];
    if~isempty(c)
        e=c.View.getAppHandle();
    end

end
